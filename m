From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] timers: consider slack value in mod_timer()
Date: Wed, 25 May 2011 12:17:50 +0200 (CEST)
Message-ID: <alpine.LFD.2.02.1105251126590.3078@ionos>
References: <20110521105828.GA29442@Chamillionaire.breakpoint.cc> <BANLkTinGZ0L4oQkBYo9H=R==X5Z+efjRaQ@mail.gmail.com> <20110524121343.GA17312@Chamillionaire.breakpoint.cc> <BANLkTikNSa9otE_cFKRcThUZ5ZCtE7Kyxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	LKML <linux-kernel@vger.kernel.org>,
	Arjan van de Ven <arjan@infradead.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Yong Zhang <yong.zhang0@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTikNSa9otE_cFKRcThUZ5ZCtE7Kyxw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 May 2011, Yong Zhang wrote:

> On Tue, May 24, 2011 at 8:13 PM, Sebastian Andrzej Siewior
> <sebastian@breakpoint.cc> wrote:
> > * Yong Zhang | 2011-05-24 15:54:17 [+0800]:
> >
> >>> diff --git a/kernel/timer.c b/kernel/timer.c
> >>> index fd61986..bf09726 100644
> >>> --- a/kernel/timer.c
> >>> +++ b/kernel/timer.c
> >>> @@ -804,6 +804,8 @@ int mod_timer(struct timer_list *timer, unsigned long expires)
> >>> ?? ?? ?? ?? ?? ?? ?? ??return 1;
> >>>
> >>> ?? ?? ?? ??expires = apply_slack(timer, expires);
> >>
> >>So, why not move above line up, then we can use the recalculated
> >>expires?
> >
> > We leave often before apply_slack() kicks in. From printks() it looks
> > like we leave more often in first "return 1" than in the second. Moving
> > that line up would lead to more __mode_timer() calls.
> 
> Hmmm, so the reason is for a timer whose timer->slack is not set
> explicitly. when we recalculate expires, we will get different value
> sometimes.

No, that's not the problem.
 
> Could you please try the attached patch(webmail will mangle it)

Grrr. gmail allows usage of real mail clients, doesn't it ?

> diff --git a/kernel/timer.c b/kernel/timer.c
> index fd61986..73af53c 100644
> --- a/kernel/timer.c
> +++ b/kernel/timer.c
> @@ -749,6 +749,10 @@ unsigned long apply_slack(struct timer_list *timer, unsigned long expires)
>  	unsigned long expires_limit, mask;
>  	int bit;
>  
> +	/* no need to account slack again for a same-expire pending timer */
> +	if (timer_pending(timer) && time_after_eq(timer->expires, expires))
> +		return timer->expires;

That's total crap. Assume some code sets the timer with 5 seconds for
some purpose and after a second it wants it to fire in 50ms from now
because some state change happened. The above will keep the original 5
seconds timeout no matter what, so the requested 50ms timeout will
fire about 4 seconds late.

>  	expires_limit = expires;
>  
>  	if (timer->slack >= 0) {
> @@ -795,6 +799,8 @@ unsigned long apply_slack(struct timer_list *timer, unsigned long expires)
>   */
>  int mod_timer(struct timer_list *timer, unsigned long expires)
>  {
> +	expires = apply_slack(timer, expires);
> +

We need to analyse the problem thoroughly and not slap random changes
into the code without knowing about the consequences. And the problem
is mostly in the call sites because they are not aware of the slack
effect.

The sunrpc code is one of those which are affected by the slack magic
simply because it makes the mod_timer() call basically unconditional
even if the jiffies value is unchanged.

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ce5eb68..cb0574f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1053,10 +1053,12 @@ void xprt_release(struct rpc_task *task)
 		xprt->ops->release_request(task);
 	if (!list_empty(&req->rq_list))
 		list_del(&req->rq_list);
-	xprt->last_used = jiffies;
-	if (list_empty(&xprt->recv) && xprt_has_timer(xprt))
-		mod_timer(&xprt->timer,
-				xprt->last_used + xprt->idle_timeout);
+	if (xprt->last_used = jiffies) {
+		xprt->last_used = jiffies;
+		if (list_empty(&xprt->recv) && xprt_has_timer(xprt))
+			mod_timer(&xprt->timer,
+				  xprt->last_used + xprt->idle_timeout);
+	}
 	spin_unlock_bh(&xprt->transport_lock);
 	if (req->rq_buffer)
 		xprt->ops->buf_free(req->rq_buffer);

The above patch does not solve the problem when the resulting new
timeout is rounded up to the same expiry value after the slack is
applied, which is not unlikely when jiffies only advanced by a small
amount.

So we must check after apply_slack() and the reason why the first
check before apply_slack triggers very often is that auto slack only
changes the expiry value for timeouts >= 256 jiffies.

And the main caller is the networking code via
tcp_send_delayed_ack(). The standard delay we see from there is 40ms
(10 jiffies for HZ=250) and that falls below the 256 jiffies treshold.

The patch below is a reasonable compromise between overhead and
correctness.

Thanks,

	tglx

diff --git a/kernel/timer.c b/kernel/timer.c
index fd61986..458fd81 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -749,16 +749,15 @@ unsigned long apply_slack(struct timer_list *timer, unsigned long expires)
 	unsigned long expires_limit, mask;
 	int bit;
 
-	expires_limit = expires;
-
 	if (timer->slack >= 0) {
 		expires_limit = expires + timer->slack;
 	} else {
-		unsigned long now = jiffies;
+		long delta = expires - jiffies;
+
+		if (delta < 256)
+			return expires;
 
-		/* No slack, if already expired else auto slack 0.4% */
-		if (time_after(expires, now))
-			expires_limit = expires + (expires - now)/256;
+		expires_limit = expires + (expires - now)/256;
 	}
 	mask = expires ^ expires_limit;
 	if (mask == 0)
@@ -795,6 +794,8 @@ unsigned long apply_slack(struct timer_list *timer, unsigned long expires)
  */
 int mod_timer(struct timer_list *timer, unsigned long expires)
 {
+	expires = apply_slack(timer, expires);
+
 	/*
 	 * This is a common optimization triggered by the
 	 * networking code - if the timer is re-modified
@@ -803,8 +804,6 @@ int mod_timer(struct timer_list *timer, unsigned long expires)
 	if (timer_pending(timer) && timer->expires == expires)
 		return 1;
 
-	expires = apply_slack(timer, expires);
-
 	return __mod_timer(timer, expires, false, TIMER_NOT_PINNED);
 }
 EXPORT_SYMBOL(mod_timer);
