From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: Make rate estimator work for all platforms
Date: Mon, 4 Oct 2004 23:11:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004211152.GF15898@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes the existing rate estimator to compile cleanly on all platforms
and avoids carrying on the variance on platforms with HZ%4 != 0.

Patch also applies to 2.4 with some fuzz.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc3-bk4.orig/net/sched/estimator.c	2004-10-04 22:41:26.000000000 +0200
+++ linux-2.6.9-rc3-bk4/net/sched/estimator.c	2004-10-04 22:53:54.000000000 +0200
@@ -66,15 +66,11 @@
 
    * Minimal interval is HZ/4=250msec (it is the greatest common divisor
      for HZ=100 and HZ=1024 8)), maximal interval
-     is (HZ/4)*2^EST_MAX_INTERVAL = 8sec. Shorter intervals
+     is (HZ*2^EST_MAX_INTERVAL)/4 = 8sec. Shorter intervals
      are too expensive, longer ones can be implemented
      at user level painlessly.
  */
 
-#if (HZ%4) != 0
-#error Bad HZ value.
-#endif
-
 #define EST_MAX_INTERVAL	5
 
 struct qdisc_estimator
@@ -128,7 +124,7 @@
 		spin_unlock(e->stats_lock);
 	}
 
-	mod_timer(&elist[idx].timer, jiffies + ((HZ/4)<<idx));
+	mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
 	read_unlock(&est_lock);
 }
 
@@ -161,7 +157,7 @@
 	if (est->next == NULL) {
 		init_timer(&elist[est->interval].timer);
 		elist[est->interval].timer.data = est->interval;
-		elist[est->interval].timer.expires = jiffies + ((HZ/4)<<est->interval);
+		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
 		elist[est->interval].timer.function = est_timer;
 		add_timer(&elist[est->interval].timer);
 	}
