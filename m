From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: fix race for one-to-many sockets in sendmsg's
 auto associate
Date: Fri, 16 Jan 2015 09:31:56 -0500
Message-ID: <54B920DC.5060209@gmail.com>
References: <1421336075-25061-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:37189 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbAPOcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 09:32:10 -0500
In-Reply-To: <1421336075-25061-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2015 10:34 AM, Daniel Borkmann wrote:
> I.e. one-to-many sockets in SCTP are not required to explicitly
> call into connect(2) or sctp_connectx(2) prior to data exchange.
> Instead, they can directly invoke sendmsg(2) and the SCTP stack
> will automatically trigger connection establishment through 4WHS
> via sctp_primitive_ASSOCIATE(). However, this in its current
> implementation is racy: INIT is being sent out immediately (as
> it cannot be bundled anyway) and the rest of the DATA chunks are
> queued up for later xmit when connection is established, meaning
> sendmsg(2) will return successfully. This behaviour can result
> in an undesired side-effect that the kernel made the application
> think the data has already been transmitted, although none of it
> has actually left the machine, worst case even after close(2)'ing
> the socket.
> 
> Instead, when the association from client side has been shut down
> e.g. first gracefully through SCTP_EOF and then close(2), the
> client could afterwards still receive the server's INIT_ACK due
> to a connection with higher latency. This INIT_ACK is then considered
> out of the blue and hence responded with ABORT as there was no
> alive assoc found anymore. This can be easily reproduced f.e.
> with sctp_test application from lksctp. One way to fix this race
> is to wait for the handshake to actually complete.
> 
> The fix defers waiting after sctp_primitive_ASSOCIATE() and
> sctp_primitive_SEND() succeeded, so that DATA chunks cooked up
> from sctp_sendmsg() have already been placed into the output
> queue through the side-effect interpreter, and therefore can then
> be bundeled together with COOKIE_ECHO control chunks.
> 
> strace from example application (shortened):
> 
> socket(PF_INET, SOCK_SEQPACKET, IPPROTO_SCTP) = 3
> sendmsg(3, {msg_name(28)={sa_family=AF_INET, sin_port=htons(8888), sin_addr=inet_addr("192.168.1.115")},
>            msg_iov(1)=[{"hello", 5}], msg_controllen=0, msg_flags=0}, 0) = 5
> sendmsg(3, {msg_name(28)={sa_family=AF_INET, sin_port=htons(8888), sin_addr=inet_addr("192.168.1.115")},
>            msg_iov(1)=[{"hello", 5}], msg_controllen=0, msg_flags=0}, 0) = 5
> sendmsg(3, {msg_name(28)={sa_family=AF_INET, sin_port=htons(8888), sin_addr=inet_addr("192.168.1.115")},
>            msg_iov(1)=[{"hello", 5}], msg_controllen=0, msg_flags=0}, 0) = 5
> sendmsg(3, {msg_name(28)={sa_family=AF_INET, sin_port=htons(8888), sin_addr=inet_addr("192.168.1.115")},
>            msg_iov(1)=[{"hello", 5}], msg_controllen=0, msg_flags=0}, 0) = 5
> sendmsg(3, {msg_name(28)={sa_family=AF_INET, sin_port=htons(8888), sin_addr=inet_addr("192.168.1.115")},
>            msg_iov(0)=[], msg_controllen=48, {cmsg_len=48, cmsg_level=0x84 /* SOL_??? */, cmsg_type=, ...},
>            msg_flags=0}, 0) = 0 // graceful shutdown for SOCK_SEQPACKET via SCTP_EOF
> close(3) = 0
> 
> tcpdump before patch (fooling the application):
> 
> 22:33:36.306142 IP 192.168.1.114.41462 > 192.168.1.115.8888: sctp (1) [INIT] [init tag: 3879023686] [rwnd: 106496] [OS: 10] [MIS: 65535] [init TSN: 3139201684]
> 22:33:36.316619 IP 192.168.1.115.8888 > 192.168.1.114.41462: sctp (1) [INIT ACK] [init tag: 3345394793] [rwnd: 106496] [OS: 10] [MIS: 10] [init TSN: 3380109591]
> 22:33:36.317600 IP 192.168.1.114.41462 > 192.168.1.115.8888: sctp (1) [ABORT]
> 
> tcpdump after patch:
> 
> 14:28:58.884116 IP 192.168.1.114.35846 > 192.168.1.115.8888: sctp (1) [INIT] [init tag: 438593213] [rwnd: 106496] [OS: 10] [MIS: 65535] [init TSN: 3092969729]
> 14:28:58.888414 IP 192.168.1.115.8888 > 192.168.1.114.35846: sctp (1) [INIT ACK] [init tag: 381429855] [rwnd: 106496] [OS: 10] [MIS: 10] [init TSN: 2141904492]
> 14:28:58.888638 IP 192.168.1.114.35846 > 192.168.1.115.8888: sctp (1) [COOKIE ECHO] , (2) [DATA] (B)(E) [TSN: 3092969729] [...]
> 14:28:58.893278 IP 192.168.1.115.8888 > 192.168.1.114.35846: sctp (1) [COOKIE ACK] , (2) [SACK] [cum ack 3092969729] [a_rwnd 106491] [#gap acks 0] [#dup tsns 0]
> 14:28:58.893591 IP 192.168.1.114.35846 > 192.168.1.115.8888: sctp (1) [DATA] (B)(E) [TSN: 3092969730] [...]
> 14:28:59.096963 IP 192.168.1.115.8888 > 192.168.1.114.35846: sctp (1) [SACK] [cum ack 3092969730] [a_rwnd 106496] [#gap acks 0] [#dup tsns 0]
> 14:28:59.097086 IP 192.168.1.114.35846 > 192.168.1.115.8888: sctp (1) [DATA] (B)(E) [TSN: 3092969731] [...] , (2) [DATA] (B)(E) [TSN: 3092969732] [...]
> 14:28:59.103218 IP 192.168.1.115.8888 > 192.168.1.114.35846: sctp (1) [SACK] [cum ack 3092969732] [a_rwnd 106486] [#gap acks 0] [#dup tsns 0]
> 14:28:59.103330 IP 192.168.1.114.35846 > 192.168.1.115.8888: sctp (1) [SHUTDOWN]
> 14:28:59.107793 IP 192.168.1.115.8888 > 192.168.1.114.35846: sctp (1) [SHUTDOWN ACK]
> 14:28:59.107890 IP 192.168.1.114.35846 > 192.168.1.115.8888: sctp (1) [SHUTDOWN COMPLETE]
> 
> Looks like this bug is from the pre-git history museum. ;)
> 
> Fixes: 08707d5482df ("lksctp-2_5_31-0_5_1.patch")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

We also need to be remember that the same scenario can be reproduced without an
implicit connect by simply using non-blocking socket on a high rtt link.  I've made this
comment privately to Daniel, but want to mention this on the list.  Daniel and I will be
working on additional patches to address that issue.

-vlad

> ---
>  net/sctp/socket.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 2625ecc..aafe94b 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1603,7 +1603,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
>  	sctp_assoc_t associd = 0;
>  	sctp_cmsgs_t cmsgs = { NULL };
>  	sctp_scope_t scope;
> -	bool fill_sinfo_ttl = false;
> +	bool fill_sinfo_ttl = false, wait_connect = false;
>  	struct sctp_datamsg *datamsg;
>  	int msg_flags = msg->msg_flags;
>  	__u16 sinfo_flags = 0;
> @@ -1943,6 +1943,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
>  		if (err < 0)
>  			goto out_free;
>  
> +		wait_connect = true;
>  		pr_debug("%s: we associated primitively\n", __func__);
>  	}
>  
> @@ -1980,6 +1981,11 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
>  	sctp_datamsg_put(datamsg);
>  	err = msg_len;
>  
> +	if (unlikely(wait_connect)) {
> +		timeo = sock_sndtimeo(sk, msg_flags & MSG_DONTWAIT);
> +		sctp_wait_for_connect(asoc, &timeo);
> +	}
> +
>  	/* If we are already past ASSOCIATE, the lower
>  	 * layers are responsible for association cleanup.
>  	 */
> 
