From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) delay scheduler race with device stopped
Date: Thu, 17 Jun 2004 15:56:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617155603.0651081c@dell_ss3.pdx.osdl.net>
References: <58D550446979A646A05649BF9EAF113AA2E995@orsmsx407>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Dabney, Nathanx T" <nathanx.t.dabney@intel.com>,
        "Venkatesan, Ganesh"
 <ganesh.venkatesan@intel.com>,
        "Glick, Kevin" <kevin.glick@intel.com>, netdev@oss.sgi.com,
        lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <58D550446979A646A05649BF9EAF113AA2E995@orsmsx407>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The delay scheduler dequeue routine has some code cut&pasted from the TBF scheduler
that caused a race with E1000 when ring got full.

It looks like net schedulers should never be calling netif_queue_stopped because
the queue may get unstopped by interrrupt or receive soft irq (NAPI) which races
with the dequeue in the transmit scheduler. 

Also, if requeuing the packet fails, it is probably because the queue became full
by a racing enqueue.  So the right thing to do is to go back and try again.

Same patch should apply to both 2.6 and 2.4

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_delay.c b/net/sched/sch_delay.c
--- a/net/sched/sch_delay.c	2004-06-17 15:21:49 -07:00
+++ b/net/sched/sch_delay.c	2004-06-17 15:21:49 -07:00
@@ -111,7 +111,7 @@
 	if (skb) {
 		struct dly_skb_cb *cb = (struct dly_skb_cb *)skb->cb;
 		psched_time_t now;
-		long diff;
+		long diff, delay;
 
 		PSCHED_GET_TIME(now);
 		diff = q->latency - PSCHED_TDIFF(now, cb->queuetime);
@@ -128,13 +128,10 @@
 			goto retry;
 		}
 
-		if (!netif_queue_stopped(sch->dev)) {
-			long delay = PSCHED_US2JIFFIE(diff);
-			if (delay <= 0)
-				delay = 1;
-			mod_timer(&q->timer, jiffies+delay);
-		}
-
+		delay = PSCHED_US2JIFFIE(diff);
+		if (delay <= 0) 
+			delay = 1;
+		mod_timer(&q->timer, jiffies+delay);
 		sch->flags |= TCQ_F_THROTTLED;
 	}
 	return NULL;
