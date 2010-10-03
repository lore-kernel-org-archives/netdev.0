From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] tms380tr: fix long delays in initialization
Date: Sun, 3 Oct 2010 22:34:30 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1010032228450.28867@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.it.da.ut.ee ([193.40.5.66]:50704 "EHLO smtp1.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381Ab0JCTec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 15:34:32 -0400
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp1.it.da.ut.ee (Postfix) with ESMTP id 067C76E4D56
	for <netdev@vger.kernel.org>; Sun,  3 Oct 2010 22:34:31 +0300 (EEST)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id E12B2DAF80
	for <netdev@vger.kernel.org>; Sun,  3 Oct 2010 22:34:30 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tms380tr driver tries to use udelay (meaning busy loop) for several half 
second delays during hardware initialization. Crazy overly long busy 
wait delays mean no delay at all so driver initialization fails without 
waiting. Fix it by using msleep() for long delays and leave it to 
udelay() for short delays.

Signed-off-by: Meelis Roos <mroos@linux.ee>

---
 drivers/net/tokenring/tms380tr.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index aaec637..e6dc2df 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -177,6 +177,7 @@ static void 	tms380tr_update_rcv_stats(struct net_local *tp,
 			unsigned char DataPtr[], unsigned int Length);
 /* "W" */
 void	 	tms380tr_wait(unsigned long time);
+static void	tms380tr_wait_long(unsigned long time);
 static void 	tms380tr_write_rpl_status(RPL *rpl, unsigned int Status);
 static void 	tms380tr_write_tpl_status(TPL *tpl, unsigned int Status);
 
@@ -1216,20 +1217,19 @@ static void tms380tr_set_multicast_list(struct net_device *dev)
 }
 
 /*
- * Wait for some time (microseconds)
+ * Wait for some time (microseconds) - busy wait
  */
 void tms380tr_wait(unsigned long time)
 {
-#if 0
-	long tmp;
-	
-	tmp = jiffies + time/(1000000/HZ);
-	do {
-		tmp = schedule_timeout_interruptible(tmp);
-	} while(time_after(tmp, jiffies));
-#else
 	udelay(time);
-#endif
+}
+
+/*
+ * Wait for long time (microseconds) - schedule
+ */
+static void tms380tr_wait_long(unsigned long time)
+{
+	msleep(time / 1000);
 }
 
 /*
@@ -1352,9 +1352,9 @@ static int tms380tr_bringup_diags(struct net_device *dev)
 	int loop_cnt, retry_cnt;
 	unsigned short Status;
 
-	tms380tr_wait(HALF_SECOND);
+	tms380tr_wait_long(HALF_SECOND);
 	tms380tr_exec_sifcmd(dev, EXEC_SOFT_RESET);
-	tms380tr_wait(HALF_SECOND);
+	tms380tr_wait_long(HALF_SECOND);
 
 	retry_cnt = BUD_MAX_RETRIES;	/* maximal number of retrys */
 
@@ -1365,7 +1365,7 @@ static int tms380tr_bringup_diags(struct net_device *dev)
 		loop_cnt = BUD_MAX_LOOPCNT;	/* maximum: three seconds*/
 		do {			/* Inspect BUD results */
 			loop_cnt--;
-			tms380tr_wait(HALF_SECOND);
+			tms380tr_wait_long(HALF_SECOND);
 			Status = SIFREADW(SIFSTS);
 			Status &= STS_MASK;
 
@@ -1384,7 +1384,7 @@ static int tms380tr_bringup_diags(struct net_device *dev)
 			printk(KERN_INFO "%s: Adapter Software Reset.\n", 
 				dev->name);
 			tms380tr_exec_sifcmd(dev, EXEC_SOFT_RESET);
-			tms380tr_wait(HALF_SECOND);
+			tms380tr_wait_long(HALF_SECOND);
 		}
 	} while(retry_cnt > 0);
 
@@ -1457,7 +1457,7 @@ static int tms380tr_init_adapter(struct net_device *dev)
 		do {
 			Status = 0;
 			loop_cnt--;
-			tms380tr_wait(HALF_SECOND);
+			tms380tr_wait_long(HALF_SECOND);
 
 			/* Mask interesting status bits */
 			Status = SIFREADW(SIFSTS);
@@ -1506,7 +1506,7 @@ static int tms380tr_init_adapter(struct net_device *dev)
 				{
 					/* Reset adapter and try init again */
 					tms380tr_exec_sifcmd(dev, EXEC_SOFT_RESET);
-					tms380tr_wait(HALF_SECOND);
+					tms380tr_wait_long(HALF_SECOND);
 				}
 			}
 		}
-- 
1.7.1


-- 
Meelis Roos (mroos@linux.ee)
