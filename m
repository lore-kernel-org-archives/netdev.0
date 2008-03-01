From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3 (spin 2)] TCP_DEFER_ACCEPT updates - process as
 established
Date: Sun, 2 Mar 2008 00:03:34 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803012355510.2793@kivilampi-30.cs.helsinki.fi>
References: <1204405149.5792.28.camel@tng> <1204405501.5792.36.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34340 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbYCAWDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 17:03:36 -0500
In-Reply-To: <1204405501.5792.36.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1 Mar 2008, Patrick McManus wrote:

There are a number of style issues, please see Documentation/CodingStyle 
for more details (most of them noted below as well)...

> @@ -461,9 +457,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
>                 reqp=&lopt->syn_table[i];
>                 while ((req = *reqp) != NULL) {
>                         if (time_after_eq(now, req->expires)) {
> -                               if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh))
> -                                   &&  (inet_rsk(req)->acked ||
> -                                        !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
> +                               if (req->retrans < thresh
> +                                   && !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {

These &&/|| are usually placed into end of the previous line.

>                                         unsigned long timeo;
> 
>                                         if (req->retrans++ == 0)
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 071e83a..905e39e 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2105,16 +2105,15 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>                 break;
> 
>         case TCP_DEFER_ACCEPT:
> -               icsk->icsk_accept_queue.rskq_defer_accept = 0;
> -               if (val > 0) {
> -                       /* Translate value in seconds to number of
> -                        * retransmits */
> -                       while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
> -                              val > ((TCP_TIMEOUT_INIT / HZ) <<
> -                                      icsk->icsk_accept_queue.rskq_defer_accept))
> -                               icsk->icsk_accept_queue.rskq_defer_accept++;
> -                       icsk->icsk_accept_queue.rskq_defer_accept++;
> +               if (val < 0)
> +                       err = -EINVAL;
> +               else
> +               {

Put brace to the same line with else and use braces for the both blocks  
whenever either block needs them.

> +                       if (val > MAX_TCP_ACCEPT_DEFERRED)
> +                               val = MAX_TCP_ACCEPT_DEFERRED;
> +                       icsk->icsk_accept_queue.rskq_defer_accept = val;
>                 }
> +
>                 break;
> 
>         case TCP_WINDOW_CLAMP:
> @@ -2295,8 +2294,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>                         val = (val ? : sysctl_tcp_fin_timeout) / HZ;
>                 break;
>         case TCP_DEFER_ACCEPT:
> -               val = !icsk->icsk_accept_queue.rskq_defer_accept ? 0 :
> -                       ((TCP_TIMEOUT_INIT / HZ) << (icsk->icsk_accept_queue.rskq_defer_accept - 1));
> +               val = icsk->icsk_accept_queue.rskq_defer_accept;
>                 break;
>         case TCP_WINDOW_CLAMP:
>                 val = tp->window_clamp;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 19c449f..60a51e7 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4807,6 +4807,40 @@ step5:
> 
>         tcp_data_snd_check(sk);
>         tcp_ack_snd_check(sk);
> +
> +       if (tp->defer_tcp_accept.request ) {

space--

> +
> +               if ((!th->fin) &&
> +                   tp->defer_tcp_accept.listen_sk->sk_state == TCP_LISTEN) {
> +
> +                       if (sock_flag(sk, SOCK_KEEPOPEN)) {
> +                               inet_csk_reset_keepalive_timer(sk,
> +                                                              keepalive_time_when(tp));
> +                       }
> +                       else {

braces & elses to the same line please.

> +                               inet_csk_delete_keepalive_timer(sk);
> +                       }
> +
> +                       inet_csk_reqsk_queue_add(
> +                               tp->defer_tcp_accept.listen_sk,
> +                               tp->defer_tcp_accept.request,
> +                               sk);
> +
> +                       tp->defer_tcp_accept.listen_sk->sk_data_ready(
> +                               tp->defer_tcp_accept.listen_sk, 0);
> +
> +                       sock_put (tp->defer_tcp_accept.listen_sk);
> +                       sock_put (sk);

spaces--;

> +                       tp->defer_tcp_accept.listen_sk = NULL;
> +                       tp->defer_tcp_accept.request = NULL;
> +               }
> +               else
> +               {

both braces on the same line as else please.

> +                       tcp_reset(sk);
> +                       return 1;
> +               }
> +       }
> +
>         return 0;

Please check for similar things elsewhere as well, and quickly check what 
the CodingStyle has to say as well. I stopped here and might have missed 
something above as well.


-- 
 i.
