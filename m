From: ganesh.venkatesan@intel.com
Subject: [PATCH 6/12 2.5] e1000 - include work down in tx path to decide when
 to quit polling mode
Date: Thu, 29 Jul 2004 08:32:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290807541.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-07-28 21:50:08.672461176 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-07-28 21:50:09.523331824 -0700
@@ -2137,15 +2137,18 @@ e1000_clean(struct net_device *netdev, i
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	int work_to_do = min(*budget, netdev->quota);
+	int tx_cleaned;
 	int work_done = 0;
 	
-	e1000_clean_tx_irq(adapter);
+	tx_cleaned = e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
 	
-	if(work_done < work_to_do || !netif_running(netdev)) {
+	/* if no Rx and Tx cleanup work was done, exit the polling mode */
+	if(!tx_cleaned || (work_done < work_to_do) || 
+				!netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
