From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH]  hrtimer, softirq: Fix hrtimer->softirq trampoline
Date: Tue, 02 Feb 2010 15:20:01 +0100
Message-ID: <1265120401.24455.306.camel@laptop>
References: <4B66A670.70503@cn.fujitsu.com>
	 <20100202074914.GD11081@gondor.apana.org.au>
	 <20100202085117.7a5c3530@penta.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, polyanskiy@gmail.com,
	Thomas Gleixner <tglx@linutronix.de>,
	lkml <linux-kernel@vger.kernel.org>
To: Yury Polyanskiy <ypolyans@princeton.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100202085117.7a5c3530@penta.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-02-02 at 08:51 -0500, Yury Polyanskiy wrote:

> If hrtimer_tasklet interface functions properly, the
> xfrm_timer_handler should be called in softirq context (and thus is
> never in parallel with xfrm_input()). The deadlock isn't possible then.
> 
> In this case it seems that for some reason xfrm_timer_handler() is
> called in the hardirq context. The relevant code in hrtimer_tasklet:
> 
> static enum hrtimer_restart __hrtimer_tasklet_trampoline(struct hrtimer *timer)
> {
> 	struct tasklet_hrtimer *ttimer =
> 		container_of(timer, struct tasklet_hrtimer, timer);
> 
> 	if (hrtimer_is_hres_active(timer)) {
> 		tasklet_hi_schedule(&ttimer->tasklet);
> 		return HRTIMER_NORESTART;
> 	}
> 	return ttimer->function(timer);
> }
> 
> I am copying Peter on this. Peter, how is it possible that
> ttimer->function() is called in hardirq?
> 
> Could it be that switch from hres_active happened after the call to
> trampoline and before the if() above?

The original email had more information:

> {IN-HARDIRQ-W} state was registered at:
>   [<c04718dc>] __lock_acquire+0xa9c/0x1890
>   [<c047274f>] lock_acquire+0x7f/0xf0
>   [<c0762958>] _raw_spin_lock+0x38/0x50
>   [<c072b5ca>] xfrm_timer_handler+0x3a/0x260
>   [<c0447d9d>] __hrtimer_tasklet_trampoline+0xd/0x10
>   [<c04634ce>] hrtimer_run_queues+0x15e/0x2a0
>   [<c045146d>] run_local_timers+0xd/0x20
>   [<c04514b4>] update_process_times+0x34/0x70
>   [<c046ce8a>] tick_periodic+0x2a/0x80
>   [<c046cefe>] tick_handle_periodic+0x1e/0x90
>   [<c0768377>] smp_apic_timer_interrupt+0x57/0x8b
>   [<c076382f>] apic_timer_interrupt+0x2f/0x34
>   [<c0401d3b>] cpu_idle+0x4b/0x80
>   [<c074e0d7>] rest_init+0x67/0x70
>   [<c0956874>] start_kernel+0x30e/0x314
>   [<c095609e>] i386_start_kernel+0x9e/0xa5

Which indicates we were called from hardirq context, it appears that
that hrtimer_is_hres_active() case is indeed faulty. Not sure if I made
a mistake when I wrote that or if we changed hrtimer behaviour
afterwards, but the hrtimer fallback is still from hardirq context.

Which would seem to suggest the following patch:

---
Subject: hrtimer, softirq: Fix hrtimer->softirq trampoline

hrtimers callbacks are always done from hardirq context, either the
jiffy tick interrupt or the hrtimer device interrupt.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/softirq.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/kernel/softirq.c b/kernel/softirq.c
index a09502e..c1983b7 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -500,22 +500,15 @@ EXPORT_SYMBOL(tasklet_kill);
  */
 
 /*
- * The trampoline is called when the hrtimer expires. If this is
- * called from the hrtimer interrupt then we schedule the tasklet as
- * the timer callback function expects to run in softirq context. If
- * it's called in softirq context anyway (i.e. high resolution timers
- * disabled) then the hrtimer callback is called right away.
+ * The trampoline is called when the hrtimer expires. 
  */
 static enum hrtimer_restart __hrtimer_tasklet_trampoline(struct hrtimer *timer)
 {
 	struct tasklet_hrtimer *ttimer =
 		container_of(timer, struct tasklet_hrtimer, timer);
 
-	if (hrtimer_is_hres_active(timer)) {
-		tasklet_hi_schedule(&ttimer->tasklet);
-		return HRTIMER_NORESTART;
-	}
-	return ttimer->function(timer);
+	tasklet_hi_schedule(&ttimer->tasklet);
+	return HRTIMER_NORESTART;
 }
 
 /*
