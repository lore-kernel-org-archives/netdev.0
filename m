From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] net_sched: netem: remove
 qdisc_is_throttled() use
Date: Thu, 04 Aug 2016 14:35:51 +0200
Message-ID: <1470314151.13693.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465602099-15808-1-git-send-email-edumazet@google.com>
	 <1465602099-15808-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36217 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933388AbcHDMg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 08:36:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id x83so43843204wma.3
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 05:36:26 -0700 (PDT)
In-Reply-To: <1465602099-15808-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-10 at 16:41 -0700, Eric Dumazet wrote:
> Looks like it is only there as some optimization attempt.
> 
> Since __QDISC_STATE_THROTTLED set/unset is way too expensive,
> and netem is the last user, just remove this check.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/sched/sch_netem.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index 9ca7947ab643..2dbe732ca135 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -582,9 +582,6 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
>  	struct sk_buff *skb;
>  	struct rb_node *p;
>  
> -	if (qdisc_is_throttled(sch))
> -		return NULL;
> -
>  tfifo_dequeue:
>  	skb = __skb_dequeue(&sch->q);
>  	if (skb) {


Note that this commit (42117927cab5a13192ecc227bea19da5059ffc6c
"net_sched: netem: remove qdisc_is_throttled() use")
is a stable candidate, as it incidentally removes one long standing bug.

Namely, we were not calling qdisc_unthrottled() from netem enqueue(), so
we would be forced to wait a timer activation to be able to drain the
queue(s).

This matters with either a jitter, or a "tc qdisc change ... delay <new
delay>"
