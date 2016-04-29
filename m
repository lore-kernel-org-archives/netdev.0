From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v2 net-next 6/7] net: do not block BH while processing
 socket backlog
Date: Fri, 29 Apr 2016 09:37:00 -0400
Message-ID: <CACSApvbh0y9v2yHNDfajmdD5HN9rdR3hN5_BgHdjAihc+A8Nmg@mail.gmail.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com> <1461899449-8096-7-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36617 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbcD2Nhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 09:37:40 -0400
Received: by mail-oi0-f41.google.com with SMTP id x201so118486118oif.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 06:37:40 -0700 (PDT)
In-Reply-To: <1461899449-8096-7-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 11:10 PM, Eric Dumazet <edumazet@google.com> wrote:
> Socket backlog processing is a major latency source.
>
> With current TCP socket sk_rcvbuf limits, I have sampled __release_sock()
> holding cpu for more than 5 ms, and packets being dropped by the NIC
> once ring buffer is filled.
>
> All users are now ready to be called from process context,
> we can unblock BH and let interrupts be serviced faster.
>
> cond_resched_softirq() could be removed, as it has no more user.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---
>  net/core/sock.c | 22 ++++++++--------------
>  1 file changed, 8 insertions(+), 14 deletions(-)
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index e16a5db853c6..70744dbb6c3f 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2019,33 +2019,27 @@ static void __release_sock(struct sock *sk)
>         __releases(&sk->sk_lock.slock)
>         __acquires(&sk->sk_lock.slock)
>  {
> -       struct sk_buff *skb = sk->sk_backlog.head;
> +       struct sk_buff *skb, *next;
>
> -       do {
> +       while ((skb = sk->sk_backlog.head) != NULL) {
>                 sk->sk_backlog.head = sk->sk_backlog.tail = NULL;
> -               bh_unlock_sock(sk);
>
> -               do {
> -                       struct sk_buff *next = skb->next;
> +               spin_unlock_bh(&sk->sk_lock.slock);
>
> +               do {
> +                       next = skb->next;
>                         prefetch(next);
>                         WARN_ON_ONCE(skb_dst_is_noref(skb));
>                         skb->next = NULL;
>                         sk_backlog_rcv(sk, skb);
>
> -                       /*
> -                        * We are in process context here with softirqs
> -                        * disabled, use cond_resched_softirq() to preempt.
> -                        * This is safe to do because we've taken the backlog
> -                        * queue private:
> -                        */
> -                       cond_resched_softirq();
> +                       cond_resched();
>
>                         skb = next;
>                 } while (skb != NULL);
>
> -               bh_lock_sock(sk);
> -       } while ((skb = sk->sk_backlog.head) != NULL);
> +               spin_lock_bh(&sk->sk_lock.slock);
> +       }
>
>         /*
>          * Doing the zeroing here guarantee we can not loop forever
> --
> 2.8.0.rc3.226.g39d4020
>

This is great! very nice patch.
