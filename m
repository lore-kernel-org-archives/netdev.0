From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 5/16 2.5] ixgb: Condition that determines when to quit polling
 mode includes work done in Tx path
Date: Fri, 15 Oct 2004 06:54:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150625170.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
@@ -1640,15 +1640,18 @@ static irqreturn_t ixgb_intr(int irq, vo
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	int work_to_do = min(*budget, netdev->quota);
+	int tx_cleaned;
 	int work_done = 0;
-
-	ixgb_clean_tx_irq(adapter);
+	
+	tx_cleaned = ixgb_clean_tx_irq(adapter);
 	ixgb_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
-
-	if (work_done < work_to_do || !netif_running(netdev)) {
+	
+	/* if no Rx and Tx cleanup work was done, exit the polling mode */
+	if(!tx_cleaned || (work_done < work_to_do) || 
+				!netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		/* RAIDC will be automatically restarted by irq_enable */
 		ixgb_irq_enable(adapter);
