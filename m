From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: fix recursive locking warning in
 sctp_do_peeloff
Date: Sat, 10 Jun 2017 13:00:55 -0300
Message-ID: <20170610160055.GB5799@localhost.localdomain>
References: <a5f7dc6e508e016041f685179f1d99fc04541bdd.1497077816.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751912AbdFJQBB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 12:01:01 -0400
Content-Disposition: inline
In-Reply-To: <a5f7dc6e508e016041f685179f1d99fc04541bdd.1497077816.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 10, 2017 at 02:56:56PM +0800, Xin Long wrote:
> Dmitry got the following recursive locking report while running syzkaller
> fuzzer, the Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:52
>  print_deadlock_bug kernel/locking/lockdep.c:1729 [inline]
>  check_deadlock kernel/locking/lockdep.c:1773 [inline]
>  validate_chain kernel/locking/lockdep.c:2251 [inline]
>  __lock_acquire+0xef2/0x3430 kernel/locking/lockdep.c:3340
>  lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
>  lock_sock_nested+0xcb/0x120 net/core/sock.c:2536
>  lock_sock include/net/sock.h:1460 [inline]
>  sctp_close+0xcd/0x9d0 net/sctp/socket.c:1497
>  inet_release+0xed/0x1c0 net/ipv4/af_inet.c:425
>  inet6_release+0x50/0x70 net/ipv6/af_inet6.c:432
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  __sock_create+0x38b/0x870 net/socket.c:1226
>  sock_create+0x7f/0xa0 net/socket.c:1237
>  sctp_do_peeloff+0x1a2/0x440 net/sctp/socket.c:4879
>  sctp_getsockopt_peeloff net/sctp/socket.c:4914 [inline]
>  sctp_getsockopt+0x111a/0x67e0 net/sctp/socket.c:6628
>  sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2690
>  SYSC_getsockopt net/socket.c:1817 [inline]
>  SyS_getsockopt+0x240/0x380 net/socket.c:1799
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> 
> This warning is caused by the lock held by sctp_getsockopt() is on one
> socket, while the other lock that sctp_close() is getting later is on
> the newly created (which failed) socket during peeloff operation.
> 
> This patch is to avoid this warning by use lock_sock with subclass
> SINGLE_DEPTH_NESTING as Wang Cong and Marcelo's suggestion.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Thanks for following up on this.

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/socket.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 5f58dd0..32d5495 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1494,7 +1494,7 @@ static void sctp_close(struct sock *sk, long timeout)
>  
>  	pr_debug("%s: sk:%p, timeout:%ld\n", __func__, sk, timeout);
>  
> -	lock_sock(sk);
> +	lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
>  	sk->sk_shutdown = SHUTDOWN_MASK;
>  	sk->sk_state = SCTP_SS_CLOSING;
>  
> @@ -1544,7 +1544,7 @@ static void sctp_close(struct sock *sk, long timeout)
>  	 * held and that should be grabbed before socket lock.
>  	 */
>  	spin_lock_bh(&net->sctp.addr_wq_lock);
> -	bh_lock_sock(sk);
> +	bh_lock_sock_nested(sk);
>  
>  	/* Hold the sock, since sk_common_release() will put sock_put()
>  	 * and we have just a little more cleanup.
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
