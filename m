From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/12) skge: suspend/resume related state management
Date: Thu, 3 Mar 2005 11:35:43 -0800
Message-ID: <20050303113543.72ba7dbf@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix suspend/resume logic.  On suspend, shutdown board if it is already
up, and on resume only bring it up if it was up before the suspend

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-02 17:17:25.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-02 17:21:40.000000000 -0800
@@ -3268,11 +3268,12 @@
 	for(i = 0; i < 2; i++) {
 		struct net_device *dev = hw->dev[i];
 
-		if (dev && netif_running(dev)) {
+		if (dev) {
 			struct skge_port *skge = netdev_priv(dev);
-
-			netif_carrier_off(dev);
-			skge_down(dev);
+			if (netif_running(dev)) {
+				netif_carrier_off(dev);
+				skge_down(dev);
+			}
 			netif_device_detach(dev);
 			wol |= skge->wol;
 		}
@@ -3293,13 +3294,17 @@
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	pci_enable_wake(pdev, PCI_D0, 0);
 
 	skge_reset(hw);
 
 	for(i = 0; i < 2; i++) {
 		struct net_device *dev = hw->dev[i];
-		if (dev && netif_running(dev))
-			skge_up(dev);
+		if (dev) {
+			netif_device_attach(dev);
+			if(netif_running(dev))
+				skge_up(dev);
+		}
 	}
 	return 0;
 }
