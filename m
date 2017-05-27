From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] net/core: remove explicit do_softirq() from
 busy_poll_stop()
Date: Sat, 27 May 2017 18:23:45 +0200
Message-ID: <20170527162345.gpeag2z2lwzfpsig@linutronix.de>
References: <20170522192641.hylqmhb7t2fykk5e@linutronix.de>
 <CANn89iJx0-z2KZWMRZdqmYUNAWcqQo4nBbRwK7pLz2-WAymqrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:44476 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750717AbdE0QXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 12:23:48 -0400
Content-Disposition: inline
In-Reply-To: <CANn89iJx0-z2KZWMRZdqmYUNAWcqQo4nBbRwK7pLz2-WAymqrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-22 14:26:44 [-0700], Eric Dumazet wrote:
> On Mon, May 22, 2017 at 12:26 PM, Sebastian Andrzej Siewior
> <bigeasy@linutronix.de> wrote:
> > Since commit 217f69743681 ("net: busy-poll: allow preemption in
> > sk_busy_loop()") there is an explicit do_softirq() invocation after
> > local_bh_enable() has been invoked.
> > I don't understand why we need this because local_bh_enable() will
> > invoke do_softirq() once the softirq counter reached zero and we have
> > softirq-related work pending.
> >
> > Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> > ---
> >  net/core/dev.c | 2 --
> >  1 file changed, 2 deletions(-)
> >
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index fca407b4a6ea..e84eb0ec5529 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -5199,8 +5199,6 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
> >         if (rc == BUSY_POLL_BUDGET)
> >                 __napi_schedule(napi);
> >         local_bh_enable();
> > -       if (local_softirq_pending())
> > -               do_softirq();
> >  }
> 
> preemption is disabled.
so? This patch:

diff --git a/init/main.c b/init/main.c
--- a/init/main.c
+++ b/init/main.c
@@ -1001,6 +1001,21 @@ static int __ref kernel_init(void *unused)
 	      "See Linux Documentation/admin-guide/init.rst for guidance.");
 }
 
+static void delay_thingy_func(struct work_struct *x)
+{
+	preempt_disable();
+	local_bh_disable();
+	pr_err("one %s\n", current->comm);
+	raise_softirq(TASKLET_SOFTIRQ);
+	pr_err("two %s\n", current->comm);
+	local_bh_enable();
+	pr_err("three %s\n", current->comm);
+	preempt_enable();
+	pr_err("four %s\n", current->comm);
+}
+
+static DECLARE_DELAYED_WORK(delay_thingy, delay_thingy_func);
+
 static noinline void __init kernel_init_freeable(void)
 {
 	/*
@@ -1038,6 +1053,7 @@ static noinline void __init kernel_init_freeable(void)
 
 	do_basic_setup();
 
+	schedule_delayed_work(&delay_thingy, HZ * 5);
 	/* Open the /dev/console on the rootfs, this should never fail */
 	if (sys_open((const char __user *) "/dev/console", O_RDWR, 0) < 0)
 		pr_err("Warning: unable to open an initial console.\n");
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 4e09821f9d9e..b8dcb9dc5692 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -500,6 +500,7 @@ static __latent_entropy void tasklet_action(struct softirq_action *a)
 {
 	struct tasklet_struct *list;
 
+	pr_err("%s() %s\n", __func__, current->comm);
 	local_irq_disable();
 	list = __this_cpu_read(tasklet_vec.head);
 	__this_cpu_write(tasklet_vec.head, NULL);

gives me this output:
[    7.132439] one kworker/4:2
[    7.132806] two kworker/4:2
[    7.133120] softirq: tasklet_action() kworker/4:2
[    7.133623] three kworker/4:2
[    7.133940] four kworker/4:2

which means after the last local_bh_enable() we already invoke the
raised softirq handler. It does not matter that we are in a
preempt_disable() region. 

> 
> Look at netif_rx_ni() for a similar construct.

correct, this is old and it is already patched in -RT. And I have no
clue why this is required by because netif_rx_internal() itself does
preempt_disable() / get_cpu() so this one already disables preemption.
Looking at it, I *think* you want local_bh_disable() instead of
preempt_disable() and do_softirq() removed, too.

Let me browse at the musuem a little bit… ahhh, here -> "[PATCH] Make
netif_rx_ni preempt-safe" [0]. There we got the preempt_disable() from
which protects against parallel invocations of do_softirq() in user
context. And we only do the check for pending softirqs (and invoke
do_softirq()) because netif_rx() sets the pending bits without raising
the softirq and it is done in a BH-enabled section. And in interrupt
context we check for those in the interrupt-exit path. So in this case
we have to do it manually.

[0] http://oss.sgi.com/projects/netdev/archive/2004-10/msg02211.html

> What exact problem do you have with existing code, that is worth
> adding this change ?

I need to workaround the non-existing do_softirq() function in RT and my
current workaround is the patch I posted. I don't see the need for the
two lines. And it seems that the other construct in netif_rx_ni() can be
simplified / removed, too.

> Thanks.

Sebastian
