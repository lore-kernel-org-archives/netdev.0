From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 4/9] ixgb: Include Tx workdone in deciding when to quit
 polling, Robert Olsson's fix for NAPI quit condition, avoid polling routine
 racing with the interface down routine
Date: Thu, 6 Jan 2005 17:25:12 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061549290.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-01-05 17:13:29.000000000 -0800
@@ -1701,22 +1701,27 @@ ixgb_clean(struct net_device *netdev, in
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	int work_to_do = min(*budget, netdev->quota);
+	int tx_cleaned;
 	int work_done = 0;
+	
+	if (!netif_carrier_ok(netdev))
+		goto quit_polling;
 
-	ixgb_clean_tx_irq(adapter);
+	tx_cleaned = ixgb_clean_tx_irq(adapter);
 	ixgb_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
-
-	if (work_done < work_to_do || !netif_running(netdev)) {
-		netif_rx_complete(netdev);
-		/* RAIDC will be automatically restarted by irq_enable */
+	
+	/* if cleanup and not enough Rx work done, exit the polling mode */
+	if((!tx_cleaned && (work_done < work_to_do)) || 
+				!netif_running(netdev)) {
+quit_polling:	netif_rx_complete(netdev);
 		ixgb_irq_enable(adapter);
 		return 0;
 	}
 
-	return (work_done >= work_to_do);
+	return 1;
 }
 #endif
 
