From: Jon Mason <mason@myri.com>
Subject: [PATCH 3/9 v3] myri10ge: rework parity error check and cleanup
Date: Mon, 27 Jun 2011 22:57:28 -0500
Message-ID: <20110628035727.GA23979@myri.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
 <1309187108-12715-3-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:54295 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755793Ab1F1D5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 23:57:33 -0400
Received: by pwj7 with SMTP id 7so3330096pwj.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 20:57:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1309187108-12715-3-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up watchdog reset code:
 - move code that checks for stuck slice to a common routine
 - unless there is a confirmed h/w fault, verify that a stuck
   slice is still stuck in the watchdog worker; if the slice is no
   longer stuck, abort the reset.
 - this removes an egregious 2000ms pause in the watchdog worker that
   was a diagnostic aid (to look for spurious resets) the snuck into
   production code.

v3 includes corrections from Joe Perches

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  100 +++++++++++++++++++++++---------------
 1 files changed, 60 insertions(+), 40 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 0f0f83d..ca03457 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -193,6 +193,7 @@ struct myri10ge_slice_state {
 	int watchdog_tx_done;
 	int watchdog_tx_req;
 	int watchdog_rx_done;
+	int stuck;
 #ifdef CONFIG_MYRI10GE_DCA
 	int cached_dca_tag;
 	int cpu;
@@ -3442,6 +3443,42 @@ static u32 myri10ge_read_reboot(struct myri10ge_priv *mgp)
 	return reboot;
 }
 
+static void
+myri10ge_check_slice(struct myri10ge_slice_state *ss, int *reset_needed,
+		     int *busy_slice_cnt, u32 rx_pause_cnt)
+{
+	struct myri10ge_priv *mgp = ss->mgp;
+	int slice = ss - mgp->ss;
+
+	if (ss->tx.req != ss->tx.done &&
+	    ss->tx.done == ss->watchdog_tx_done &&
+	    ss->watchdog_tx_req != ss->watchdog_tx_done) {
+		/* nic seems like it might be stuck.. */
+		if (rx_pause_cnt != mgp->watchdog_pause) {
+			if (net_ratelimit())
+				netdev_warn(mgp->dev, "slice %d: TX paused, "
+					    "check link partner\n", slice);
+		} else {
+			netdev_warn(mgp->dev,
+				    "slice %d: TX stuck %d %d %d %d %d %d\n",
+				    slice, ss->tx.queue_active, ss->tx.req,
+				    ss->tx.done, ss->tx.pkt_start,
+				    ss->tx.pkt_done,
+				    (int)ntohl(mgp->ss[slice].fw_stats->
+					       send_done_count));
+			*reset_needed = 1;
+			ss->stuck = 1;
+		}
+	}
+	if (ss->watchdog_tx_done != ss->tx.done ||
+	    ss->watchdog_rx_done != ss->rx_done.cnt) {
+		*busy_slice_cnt += 1;
+	}
+	ss->watchdog_tx_done = ss->tx.done;
+	ss->watchdog_tx_req = ss->tx.req;
+	ss->watchdog_rx_done = ss->rx_done.cnt;
+}
+
 /*
  * This watchdog is used to check whether the board has suffered
  * from a parity error and needs to be recovered.
@@ -3450,10 +3487,12 @@ static void myri10ge_watchdog(struct work_struct *work)
 {
 	struct myri10ge_priv *mgp =
 	    container_of(work, struct myri10ge_priv, watchdog_work);
-	struct myri10ge_tx_buf *tx;
-	u32 reboot;
+	struct myri10ge_slice_state *ss;
+	u32 reboot, rx_pause_cnt;
 	int status, rebooted;
 	int i;
+	int reset_needed = 0;
+	int busy_slice_cnt = 0;
 	u16 cmd, vendor;
 
 	mgp->watchdog_resets++;
@@ -3465,8 +3504,7 @@ static void myri10ge_watchdog(struct work_struct *work)
 		 * For now, just report it */
 		reboot = myri10ge_read_reboot(mgp);
 		netdev_err(mgp->dev, "NIC rebooted (0x%x),%s resetting\n",
-			   reboot,
-			   myri10ge_reset_recover ? "" : " not");
+			   reboot, myri10ge_reset_recover ? "" : " not");
 		if (myri10ge_reset_recover == 0)
 			return;
 		rtnl_lock();
@@ -3498,23 +3536,24 @@ static void myri10ge_watchdog(struct work_struct *work)
 				return;
 			}
 		}
-		/* Perhaps it is a software error.  Try to reset */
-
-		netdev_err(mgp->dev, "device timeout, resetting\n");
+		/* Perhaps it is a software error. See if stuck slice
+		 * has recovered, reset if not */
+		rx_pause_cnt = ntohl(mgp->ss[0].fw_stats->dropped_pause);
 		for (i = 0; i < mgp->num_slices; i++) {
-			tx = &mgp->ss[i].tx;
-			netdev_err(mgp->dev, "(%d): %d %d %d %d %d %d\n",
-				   i, tx->queue_active, tx->req,
-				   tx->done, tx->pkt_start, tx->pkt_done,
-				   (int)ntohl(mgp->ss[i].fw_stats->
-					      send_done_count));
-			msleep(2000);
-			netdev_info(mgp->dev, "(%d): %d %d %d %d %d %d\n",
-				    i, tx->queue_active, tx->req,
-				    tx->done, tx->pkt_start, tx->pkt_done,
-				    (int)ntohl(mgp->ss[i].fw_stats->
-					       send_done_count));
+			ss = mgp->ss;
+			if (ss->stuck) {
+				myri10ge_check_slice(ss, &reset_needed,
+						     &busy_slice_cnt,
+						     rx_pause_cnt);
+				ss->stuck = 0;
+			}
 		}
+		if (!reset_needed) {
+			netdev_dbg(mgp->dev, "not resetting\n");
+			return;
+		}
+
+		netdev_err(mgp->dev, "device timeout, resetting\n");
 	}
 
 	if (!rebooted) {
@@ -3567,27 +3606,8 @@ static void myri10ge_watchdog_timer(unsigned long arg)
 			    myri10ge_fill_thresh)
 				ss->rx_big.watchdog_needed = 0;
 		}
-
-		if (ss->tx.req != ss->tx.done &&
-		    ss->tx.done == ss->watchdog_tx_done &&
-		    ss->watchdog_tx_req != ss->watchdog_tx_done) {
-			/* nic seems like it might be stuck.. */
-			if (rx_pause_cnt != mgp->watchdog_pause) {
-				if (net_ratelimit())
-					netdev_err(mgp->dev, "slice %d: TX paused, check link partner\n",
-						   i);
-			} else {
-				netdev_warn(mgp->dev, "slice %d stuck:", i);
-				reset_needed = 1;
-			}
-		}
-		if (ss->watchdog_tx_done != ss->tx.done ||
-		    ss->watchdog_rx_done != ss->rx_done.cnt) {
-			busy_slice_cnt++;
-		}
-		ss->watchdog_tx_done = ss->tx.done;
-		ss->watchdog_tx_req = ss->tx.req;
-		ss->watchdog_rx_done = ss->rx_done.cnt;
+		myri10ge_check_slice(ss, &reset_needed, &busy_slice_cnt,
+				     rx_pause_cnt);
 	}
 	/* if we've sent or received no traffic, poll the NIC to
 	 * ensure it is still there.  Otherwise, we risk not noticing
-- 
1.7.5.4

