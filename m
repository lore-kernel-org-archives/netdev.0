From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Tue, 14 Jul 2009 10:22:02 +0200
Message-ID: <4A5C402A.7090906@trash.net>
References: <20090709215455.703939259@linutronix.de>	<20090709215606.526259917@linutronix.de> <20090712.135555.207096388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090301050400030805030507"
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754043AbZGNIWM@vger.kernel.org>
In-Reply-To: <20090712.135555.207096388.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090301050400030805030507
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Thu, 09 Jul 2009 21:59:22 -0000
> 
>> The hrtimer callback cbq_undelay() is not serialized against
>> cbq_ovl_delay(). That affects at least q->pmask and q->delay_timer.
>>
>> Lock it proper.
>>
>> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> 
> The problems here are even much deeper than it appears.
> 
> First of all, I am to understand that hrtimers run from hardware
> interrupt context, right?  If so, all of these datastructures are
> softirq safe only.
> 
> And it is not merely the immediate things you see being modified in
> this hrtimer, such as ->pmask etc., it is also the q->active[]
> pointers, the list state for the classes, just about everything in the
> qdisc state is referenced in this hrtimer code path.
> 
> I wonder how many queer unexplainable bugs we see because of this.
> 
> What should probably happen is that the hrtimer merely fires off work
> at software interrupt context (perhaps a tasklet or similar), and that
> software interrupt code take the qdisc's root lock throughout it's
> execution.

That's my understanding what HRTIMER_SOFTIRQ is used for. I think
simply grabbing the root lock in cbq_undelay() should be fine.

Compile-tested only.


--------------090301050400030805030507
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit a790fb8873f1cbe8b9cb48cb368851e30d3ec172
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jul 14 10:19:47 2009 +0200

    net-sched: sch_cbq: fix locking in cbq_undelay()
    
    The hrtimer callback cbq_undelay() is not serialized against
    cbq_ovl_delay(). That affects at least q->pmask and q->delay_timer.
    
    Lock it proper.
    
    Based on patch by Thomas Gleixner <tglx@linutronix.de>
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 23a1676..7c659c6 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -593,12 +593,16 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 	struct cbq_sched_data *q = container_of(timer, struct cbq_sched_data,
 						delay_timer);
 	struct Qdisc *sch = q->watchdog.qdisc;
+	spinlock_t *root_lock;
 	psched_time_t now;
 	psched_tdiff_t delay = 0;
 	unsigned pmask;
 
 	now = psched_get_time();
 
+	root_lock = qdisc_lock(qdisc_root(sch));
+	spin_lock(root_lock);
+
 	pmask = q->pmask;
 	q->pmask = 0;
 
@@ -615,6 +619,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 				delay = tmp;
 		}
 	}
+	spin_unlock(root_lock);
 
 	if (delay) {
 		ktime_t time;

--------------090301050400030805030507--
