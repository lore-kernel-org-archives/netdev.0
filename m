From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] netif_queue_stopped in TBF scheduler
Date: Thu, 17 Jun 2004 16:09:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617160930.729b35ad@dell_ss3.pdx.osdl.net>
References: <58D550446979A646A05649BF9EAF113AA2E995@orsmsx407>
	<20040617155603.0651081c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040617155603.0651081c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There is a race between the device and scheduler if the scheduler looks
at netif_queue_stopped.  What can happen is that the device decides it is ready,
just after the stopped check, and the scheduler decides it is throttled.

The simple way is to just have the scheduler always dequeue and leave the flow
control up to the driver and the core scheduling loop.

Here is an untested fix for TBF scheduler based on the tested changes to the
delay scheduler. 


diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	2004-06-17 15:56:47 -07:00
+++ b/net/sched/sch_tbf.c	2004-06-17 15:56:47 -07:00
@@ -201,7 +201,7 @@
 
 	if (skb) {
 		psched_time_t now;
-		long toks;
+		long toks, delay;
 		long ptoks = 0;
 		unsigned int len = skb->len;
 
@@ -229,14 +229,11 @@
 			return skb;
 		}
 
-		if (!netif_queue_stopped(sch->dev)) {
-			long delay = PSCHED_US2JIFFIE(max_t(long, -toks, -ptoks));
+		delay = PSCHED_US2JIFFIE(max_t(long, -toks, -ptoks));
+		if (delay == 0)
+			delay = 1;
 
-			if (delay == 0)
-				delay = 1;
-
-			mod_timer(&q->wd_timer, jiffies+delay);
-		}
+		mod_timer(&q->wd_timer, jiffies+delay);
 
 		/* Maybe we have a shorter packet in the queue,
 		   which can be sent now. It sounds cool,
