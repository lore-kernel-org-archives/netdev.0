From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] 3c59x: use module_param and netdev_priv
Date: Mon, 18 Oct 2004 13:12:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018131236.2f70117a@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv and module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- netdev-2.6/drivers/net/3c59x.c	2004-10-18 13:09:11.664690912 -0700
+++ tcp-2.6/drivers/net/3c59x.c	2004-10-18 13:09:26.020508496 -0700
@@ -240,6 +240,7 @@ static int vortex_debug = 1;
 
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -278,22 +279,35 @@ MODULE_DESCRIPTION("3Com 3c59x/3c9xx eth
 					DRV_VERSION " " DRV_RELDATE);
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(debug, "i");
-MODULE_PARM(global_options, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(global_full_duplex, "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(hw_checksums, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(flow_ctrl, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(global_enable_wol, "i");
-MODULE_PARM(enable_wol, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(compaq_ioaddr, "i");
-MODULE_PARM(compaq_irq, "i");
-MODULE_PARM(compaq_device_id, "i");
-MODULE_PARM(watchdog, "i");
-MODULE_PARM_DESC(debug, "3c59x debug level (0-6)");
+/* This driver uses 'options' to pass the media type, full-duplex flag, etc. */
+/* Option count limit only -- unlimited interfaces are supported. */
+#define MAX_UNITS 8
+static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1,};
+static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int hw_checksums[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int flow_ctrl[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int enable_wol[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int global_options = -1;
+static int global_full_duplex = -1;
+static int global_enable_wol = -1;
+static int compaq_ioaddr, compaq_irq, compaq_device_id = 0x5900;
+
+static int num_units;
+module_param(global_options, int, 0);
+module_param_array(options, int, num_units, 0);
+module_param(global_full_duplex, int, 0);
+module_param_array(full_duplex, int, num_units, 0);
+module_param_array(hw_checksums, int, num_units, 0);
+module_param_array(flow_ctrl, int, num_units, 0);
+module_param(global_enable_wol, int, 0);
+module_param_array(enable_wol, int, num_units, 0);
+module_param(rx_copybreak, int, 0);
+module_param(max_interrupt_work, int, 0);
+module_param(compaq_ioaddr, int, 0);
+module_param(compaq_irq, int, 0);
+module_param(compaq_device_id, int, 0);
+module_param(watchdog, int, 0);
+
 MODULE_PARM_DESC(options, "3c59x: Bits 0-3: media type, bit 4: bus mastering, bit 9: full duplex");
 MODULE_PARM_DESC(global_options, "3c59x: same as options, but applies to all NICs if options is unset");
 MODULE_PARM_DESC(full_duplex, "3c59x full duplex setting(s) (1)");
@@ -911,22 +925,10 @@ static struct ethtool_ops vortex_ethtool
 static void set_8021q_mode(struct net_device *dev, int enable);
 
 
-/* This driver uses 'options' to pass the media type, full-duplex flag, etc. */
-/* Option count limit only -- unlimited interfaces are supported. */
-#define MAX_UNITS 8
-static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1,};
-static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int hw_checksums[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int flow_ctrl[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int enable_wol[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int global_options = -1;
-static int global_full_duplex = -1;
-static int global_enable_wol = -1;
 
 /* #define dev_alloc_skb dev_alloc_skb_debug */
 
 /* Variables to work-around the Compaq PCI BIOS32 problem. */
-static int compaq_ioaddr, compaq_irq, compaq_device_id = 0x5900;
 static struct net_device *compaq_net_device;
 
 static int vortex_cards_found;
@@ -934,7 +936,7 @@ static int vortex_cards_found;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_vortex(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	unsigned long flags;
 	local_save_flags(flags);
 	local_irq_disable();
@@ -949,7 +951,7 @@ static int vortex_suspend (struct pci_de
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
-	if (dev && dev->priv) {
+	if (dev) {
 		if (netif_running(dev)) {
 			netif_device_detach(dev);
 			vortex_down(dev, 1);
@@ -962,7 +964,7 @@ static int vortex_resume (struct pci_dev
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
-	if (dev && dev->priv) {
+	if (dev) {
 		if (netif_running(dev)) {
 			vortex_up(dev);
 			netif_device_attach(dev);
@@ -2888,7 +2890,7 @@ static void vortex_get_drvinfo(struct ne
 }
 
 static struct ethtool_ops vortex_ethtool_ops = {
-	.get_drvinfo		= vortex_get_drvinfo,
+	.get_drvinfo =		vortex_get_drvinfo,
 };
 
 #ifdef CONFIG_PCI
@@ -2982,7 +2984,7 @@ static void set_rx_mode(struct net_devic
 
 static void set_8021q_mode(struct net_device *dev, int enable)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int old_window = inw(ioaddr + EL3_CMD);
 	int mac_ctrl;
@@ -3225,7 +3227,7 @@ static void __exit vortex_eisa_cleanup (
 #endif
 	
 	if (compaq_net_device) {
-		vp = compaq_net_device->priv;
+		vp = netdev_priv(compaq_net_device);
 		ioaddr = compaq_net_device->base_addr;
 
 		unregister_netdev (compaq_net_device);
