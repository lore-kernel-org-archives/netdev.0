From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] sctp: do sanity checks before migrating the asoc
Date: Tue, 19 Jan 2016 09:19:41 -0500
Message-ID: <569E45FD.4040801@gmail.com>
References: <CACT4Y+Z6jY_n_cpmbFz366=JzoLX=u4Zc_o8gHFwJw8ApKf4zw@mail.gmail.com>
 <10616913996c7a4cbe8a2bb23cf4e78fcfa0a13a.1452891824.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, dvyukov@google.com,
	eric.dumazet@gmail.com, syzkaller@googlegroups.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33112 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbcASOTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 09:19:44 -0500
In-Reply-To: <10616913996c7a4cbe8a2bb23cf4e78fcfa0a13a.1452891824.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2016 04:40 PM, Marcelo Ricardo Leitner wrote:
> On Fri, Jan 15, 2016 at 08:11:03PM +0100, Dmitry Vyukov wrote:
>> On Fri, Jan 15, 2016 at 7:46 PM, Marcelo Ricardo Leitner
>> <marcelo.leitner@gmail.com> wrote:
>>> On Wed, Dec 30, 2015 at 09:42:27PM +0100, Dmitry Vyukov wrote:
>>>> Hello,
>>>>
>>>> The following program leads to a leak of two sock objects:
>>> ...
>>>>
>>>> On commit 8513342170278468bac126640a5d2d12ffbff106 (Dec 28).
>>>
>>> I'm afraid I cannot reproduce this one?
>>> I enabled dynprintk at sctp_destroy_sock and it does print twice when I
>>> run this test app.
>>> Also added debugs to check association lifetime, and then it was
>>> destroyed. Same for endpoint.
>>>
>>> Checking with trace-cmd, both calls to sctp_close() resulted in
>>> sctp_destroy_sock() being called.
>>>
>>> As for sock_hold/put, they are matched too.
>>>
>>> Ideas? Log is below for double checking
>>
>>
>> Hummm... I can reproduce it pretty reliably.
>>
>> [  197.459024] kmemleak: 11 new suspected memory leaks (see
>> /sys/kernel/debug/kmemleak)
>> [  307.494874] kmemleak: 409 new suspected memory leaks (see
>> /sys/kernel/debug/kmemleak)
>> [  549.784022] kmemleak: 125 new suspected memory leaks (see
>> /sys/kernel/debug/kmemleak)
>>
>> I double checked via /proc/slabinfo:
>>
>> SCTPv6              4373   4420   2368   13    8 : tunables    0    0
>>   0 : slabdata    340    340      0
>>
>> SCTPv6 starts with almost 0, but grows infinitely while I run the
>> program in a loop.
>>
>> Here is my SCTP related configs:
>>
>> CONFIG_IP_SCTP=y
>> CONFIG_NET_SCTPPROBE=y
>> CONFIG_SCTP_DBG_OBJCNT=y
>> # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
>> # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
>> CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
>> # CONFIG_SCTP_COOKIE_HMAC_MD5 is not set
>> # CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
>>
>> I am on commit 67990608c8b95d2b8ccc29932376ae73d5818727 and I don't
>> seem to have any sctp-related changes on top.
> 
> Ok, now I can. Enabled slub debugs, now I cannot see calls to
> sctp_destroy_sock. I see to sctp_close, but not to sctp_destroy_sock.
> 
> And SCTPv6 grew by 2 sockets after the execution.
> 
> Further checking, it's a race within SCTP asoc migration:
> thread 0                thread 1
> - app creates a sock
>                         - sends a packet to itself
> 			  - sctp will create an asoc and do implicit
> 			    handshake
> 			  - send the packet
> - listen()
> - accept() is called and
>   that asoc is migrated
>                  - packet is delivered
>                    - skb->destructor is called, BUT:
> 
> (note that if accept() is called after packet is delivered and skb is freed, it
> doesn't happen)
> 
> static void sctp_wfree(struct sk_buff *skb)
> {
>         struct sctp_chunk *chunk = skb_shinfo(skb)->destructor_arg;
>         struct sctp_association *asoc = chunk->asoc;
>         struct sock *sk = asoc->base.sk;
> ...
>         atomic_sub(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
> 
> and it's pointing to the new socket already. So one socket gets a leak
> on sk_wmem_alloc and another gets a negative value:
> 
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1537,12 +1537,14 @@ static void sctp_close(struct sock *sk, long timeout)
>         /* Hold the sock, since sk_common_release() will put sock_put()
>          * and we have just a little more cleanup.
>          */
> +       printk("%s sock_hold %p\n", __func__, sk);
>         sock_hold(sk);
>         sk_common_release(sk);
> 
>         bh_unlock_sock(sk);
>         spin_unlock_bh(&net->sctp.addr_wq_lock);
> 
> +       printk("%s sock_put %p %d %d\n", __func__, sk, atomic_read(&sk->sk_refcnt), atomic_read(&sk->sk_wmem_alloc));
>         sock_put(sk);
> 
>         SCTP_DBG_OBJCNT_DEC(sock);
> 
> 
> gave me:
> 
> [   99.456944] sctp_close sock_hold ffff880137df8940
> ...
> [   99.457337] sctp_close sock_put ffff880137df8940 1 -247
> [   99.458313] sctp_close sock_hold ffff880137dfef00
> ...
> [   99.458383] sctp_close sock_put ffff880137dfef00 1 249
> 
> That's why the socket is not freed..
> 

Interesting...  sctp_sock_migrate() accounts for this race in the
receive buffer, but not the send buffer.

On the one hand I am not crazy about the connect-to-self scenario.
On the other, I think to support it correctly, we should support
skb migrations for the send case just like we do the receive case.

-vlad

> 
> ---8<---
> 
> As reported by Dmitry, we cannot migrate asocs that have skbs in tx
> queue because they have the destructor callback pointing to the asoc,
> but which will point to a different socket if we migrate the asoc in
> between the packet sent and packet release.
> 
> This patch implements proper error handling for sctp_sock_migrate and
> this first sanity check.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/socket.c | 31 ++++++++++++++++++++++++-------
>  1 file changed, 24 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 9bb80ec4c08f..5a22a6cfb699 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -99,8 +99,8 @@ static int sctp_send_asconf(struct sctp_association *asoc,
>  			    struct sctp_chunk *chunk);
>  static int sctp_do_bind(struct sock *, union sctp_addr *, int);
>  static int sctp_autobind(struct sock *sk);
> -static void sctp_sock_migrate(struct sock *, struct sock *,
> -			      struct sctp_association *, sctp_socket_type_t);
> +static int sctp_sock_migrate(struct sock *, struct sock *,
> +			     struct sctp_association *, sctp_socket_type_t);
>  
>  static int sctp_memory_pressure;
>  static atomic_long_t sctp_memory_allocated;
> @@ -3929,7 +3929,11 @@ static struct sock *sctp_accept(struct sock *sk, int flags, int *err)
>  	/* Populate the fields of the newsk from the oldsk and migrate the
>  	 * asoc to the newsk.
>  	 */
> -	sctp_sock_migrate(sk, newsk, asoc, SCTP_SOCKET_TCP);
> +	error = sctp_sock_migrate(sk, newsk, asoc, SCTP_SOCKET_TCP);
> +	if (error) {
> +		sk_common_release(newsk);
> +		newsk = NULL;
> +	}
>  
>  out:
>  	release_sock(sk);
> @@ -4436,10 +4440,16 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
>  	/* Populate the fields of the newsk from the oldsk and migrate the
>  	 * asoc to the newsk.
>  	 */
> -	sctp_sock_migrate(sk, sock->sk, asoc, SCTP_SOCKET_UDP_HIGH_BANDWIDTH);
> +	err = sctp_sock_migrate(sk, sock->sk, asoc,
> +				SCTP_SOCKET_UDP_HIGH_BANDWIDTH);
> +	if (err) {
> +		sk_common_release(sock->sk);
> +		goto out;
> +	}
>  
>  	*sockp = sock;
>  
> +out:
>  	return err;
>  }
>  EXPORT_SYMBOL(sctp_do_peeloff);
> @@ -7217,9 +7227,9 @@ static inline void sctp_copy_descendant(struct sock *sk_to,
>  /* Populate the fields of the newsk from the oldsk and migrate the assoc
>   * and its messages to the newsk.
>   */
> -static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
> -			      struct sctp_association *assoc,
> -			      sctp_socket_type_t type)
> +static int sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
> +			     struct sctp_association *assoc,
> +			     sctp_socket_type_t type)
>  {
>  	struct sctp_sock *oldsp = sctp_sk(oldsk);
>  	struct sctp_sock *newsp = sctp_sk(newsk);
> @@ -7229,6 +7239,12 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
>  	struct sctp_ulpevent *event;
>  	struct sctp_bind_hashbucket *head;
>  
> +	/* We cannot migrate asocs that have skbs tied to it otherwise
> +	 * its destructor will update the wrong socket
> +	 */
> +	if (assoc->sndbuf_used)
> +		return -EBUSY;
> +
>  	/* Migrate socket buffer sizes and all the socket level options to the
>  	 * new socket.
>  	 */
> @@ -7343,6 +7359,8 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
>  
>  	newsk->sk_state = SCTP_SS_ESTABLISHED;
>  	release_sock(newsk);
> +
> +	return 0;
>  }
>  
>  
> 
