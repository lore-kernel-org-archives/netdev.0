From: Christoph Paasch <christoph.paasch@gmail.com>
Subject: Re: [RFC PATCH] tcp: accept RST for rcv_nxt - 1 after receiving a FIN
Date: Tue, 10 Jan 2017 21:17:08 -0800
Message-ID: <20170111051708.GC23178@Chimay.local>
References: <1483652008-20255-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36460 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751993AbdAKFRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 00:17:11 -0500
Received: by mail-pf0-f196.google.com with SMTP id b22so15696645pfd.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 21:17:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1483652008-20255-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jason,

(resending as Gmail sent out with HTML)

On 05/01/17 - 16:33:28, Jason Baron wrote:
> Using a Mac OSX box as a client connecting to a Linux server, we have found
> that when certain applications (such as 'ab'), are abruptly terminated
> (via ^C), a FIN is sent followed by a RST packet on tcp connections. The
> FIN is accepted by the Linux stack but the RST is sent with the same
> sequence number as the FIN, and Linux responds with a challenge ACK per
> RFC 5961. The OSX client then does not reply with any RST as would be
> expected on a closed socket.

do you see this behavior consistently, even in a controlled environment?

The problem seems rather to be that after the first RST, the NAT on the path
has dropped its mapping and is thus dropping all other traffic. So, Linux's
challenge-ack does not go through to the OSX-host to "re-synchronize" the
state (which would allow OSX to send a RST with the updated sequence numbers).

This is also documented in RFC5961:

9.3.  Middleboxes That Drop the Challenge ACK

   It also needs to be noted that, some middleboxes (Firewalls/NATs)
   that don't have the fix recommended in the document, may drop the
   challenge ACK.  This can happen because, the original RST segment
   that was in window had already cleared the flow state pertaining to
   the TCP connection in the middlebox.  In such cases, the end hosts
   that have implemented the RST mitigation described in this document,
   will have the TCP connection left open.  This is a corner case and
   can go away if the middlebox is conformant with the changes proposed
   in this document.



Cheers,
Christoph

> 
> This results in sockets accumulating on the Linux server left mostly in
> the CLOSE_WAIT state, although LAST_ACK and CLOSING are also possible.
> This sequence of events can tie up a lot of resources on the Linux server
> since there may be a lot of data in write buffers at the time of the RST.
> Accepting a RST equal to rcv_nxt - 1, after we have already successfully
> processed a FIN, has made a significant difference for us in practice, by
> freeing up unneeded resources in a more expedient fashion.
> 
> I also found a posting that the iOS client behaves in a similar manner here
> (it will send a FIN followed by a RST for rcv_nxt - 1):
> https://www.snellman.net/blog/archive/2016-02-01-tcp-rst/
> 
> A packetdrill test demonstrating the behavior.
> 
> // testing mac osx rst behavior
> 
> // Establish a connection
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> 0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> 0.000 bind(3, ..., ...) = 0
> 0.000 listen(3, 1) = 0
> 
> 0.100 < S 0:0(0) win 32768 <mss 1460,nop,wscale 10>
> 0.100 > S. 0:0(0) ack 1 <mss 1460,nop,wscale 5>
> 0.200 < . 1:1(0) ack 1 win 32768
> 0.200 accept(3, ..., ...) = 4
> 
> // Client closes the connection
> 0.300 < F. 1:1(0) ack 1 win 32768
> 
> // now send rst with same sequence
> 0.300 < R. 1:1(0) ack 1 win 32768
> 
> // make sure we are in TCP_CLOSE
> 0.400 %{
> assert tcpi_state == 7
> }%
> 
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> ---
>  net/ipv4/tcp_input.c | 23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index ec6d84363024..373bea05c93b 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5249,6 +5249,24 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
>  	return err;
>  }
>  
> +/* Accept RST for rcv_nxt - 1 after a FIN.
> + * When tcp connections are abruptly terminated from Mac OSX (via ^C), a
> + * FIN is sent followed by a RST packet. The RST is sent with the same
> + * sequence number as the FIN, and thus according to RFC 5961 a challenge
> + * ACK should be sent. However, Mac OSX does not reply to the challenge ACK
> + * with a RST on the closed socket, hence accept this class of RSTs.
> + */
> +static bool tcp_reset_check(struct sock *sk, struct sk_buff *skb)
> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +
> +	return unlikely((TCP_SKB_CB(skb)->seq == (tp->rcv_nxt - 1)) &&
> +			(TCP_SKB_CB(skb)->end_seq == (tp->rcv_nxt - 1))	&&
> +			(sk->sk_state == TCP_CLOSE_WAIT ||
> +			 sk->sk_state == TCP_LAST_ACK ||
> +			 sk->sk_state == TCP_CLOSING));
> +}
> +
>  /* Does PAWS and seqno based validation of an incoming segment, flags will
>   * play significant role here.
>   */
> @@ -5287,6 +5305,8 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
>  						  LINUX_MIB_TCPACKSKIPPEDSEQ,
>  						  &tp->last_oow_ack_time))
>  				tcp_send_dupack(sk, skb);
> +		} else if (tcp_reset_check(sk, skb)) {
> +			tcp_reset(sk);
>  		}
>  		goto discard;
>  	}
> @@ -5300,7 +5320,8 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
>  		 * else
>  		 *     Send a challenge ACK
>  		 */
> -		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt) {
> +		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt ||
> +		    tcp_reset_check(sk, skb)) {
>  			rst_seq_match = true;
>  		} else if (tcp_is_sack(tp) && tp->rx_opt.num_sacks > 0) {
>  			struct tcp_sack_block *sp = &tp->selective_acks[0];
> -- 
> 2.6.1
> 
