From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 1/2] via-velocity: use module_param
Date: Mon, 18 Oct 2004 14:08:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018140809.05bf92ce@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use module_param and netdev_priv

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-10-18 13:48:03 -07:00
+++ b/drivers/net/via-velocity.c	2004-10-18 13:48:03 -07:00
@@ -46,6 +46,7 @@
 
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/config.h>
 #include <linux/init.h>
@@ -100,8 +101,9 @@
 MODULE_DESCRIPTION("VIA Networking Velocity Family Gigabit Ethernet Adapter Driver");
 
 #define VELOCITY_PARAM(N,D) \
-        static const int N[MAX_UNITS]=OPTION_DEFAULT;\
-        MODULE_PARM(N, "1-" __MODULE_STRING(MAX_UNITS) "i");\
+	static int num##N; \
+        static int N[MAX_UNITS]=OPTION_DEFAULT;\
+	module_param_array(N, int, num##N, 0); \
         MODULE_PARM_DESC(N, D);
 
 #define RX_DESC_MIN     64
@@ -229,7 +231,7 @@
 VELOCITY_PARAM(int_works, "Number of packets per interrupt services");
 
 static int rx_copybreak = 200;
-MODULE_PARM(rx_copybreak, "i");
+module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 
 static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr, struct velocity_info_tbl *info);
@@ -343,7 +345,7 @@
 static void __devexit velocity_remove1(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 
 #ifdef CONFIG_PM
 	unsigned long flags;
@@ -710,7 +712,7 @@
 	
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	vptr = dev->priv;
+	vptr = netdev_priv(dev);
 
 
 	if (first) {
@@ -1724,7 +1726,7 @@
  
 static int velocity_open(struct net_device *dev)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	int ret;
 
 	vptr->rx_buf_sz = (dev->mtu <= 1504 ? PKT_BUF_SZ : dev->mtu + 32);
@@ -1781,7 +1783,7 @@
  
 static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	unsigned long flags;
 	int oldmtu = dev->mtu;
 	int ret = 0;
@@ -1857,7 +1859,7 @@
 
 static int velocity_close(struct net_device *dev)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	velocity_shutdown(vptr);
@@ -1890,7 +1892,7 @@
  
 static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	int qnum = 0;
 	struct tx_desc *td_ptr;
 	struct velocity_td_info *tdinfo;
@@ -2041,7 +2043,7 @@
 static int velocity_intr(int irq, void *dev_instance, struct pt_regs *regs)
 {
 	struct net_device *dev = dev_instance;
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	u32 isr_status;
 	int max_count = 0;
 
@@ -2096,7 +2098,7 @@
  
 static void velocity_set_multi(struct net_device *dev)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	struct mac_regs * regs = vptr->mac_regs;
 	u8 rx_mode;
 	int i;
@@ -2145,7 +2147,7 @@
  
 static struct net_device_stats *velocity_get_stats(struct net_device *dev)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	
 	/* If the hardware is down, don't touch MII */
 	if(!netif_running(dev))
@@ -2188,7 +2190,7 @@
  
 static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	int ret;
 
 	/* If we are asked for information and the device is power
@@ -2817,7 +2819,7 @@
  
 static int velocity_ethtool_up(struct net_device *dev)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	if(!netif_running(dev))
 		pci_set_power_state(vptr->pdev, 0);
 	return 0;
@@ -2833,14 +2835,14 @@
  
 static void velocity_ethtool_down(struct net_device *dev)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	if(!netif_running(dev))
 		pci_set_power_state(vptr->pdev, 3);
 }
 
 static int velocity_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	struct mac_regs * regs = vptr->mac_regs;
 	u32 status;
 	status = check_connection_type(vptr->mac_regs);
@@ -2865,7 +2867,7 @@
 
 static int velocity_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	u32 curr_status;
 	u32 new_status = 0;
 	int ret = 0;
@@ -2888,14 +2890,14 @@
 
 static u32 velocity_get_link(struct net_device *dev)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	struct mac_regs * regs = vptr->mac_regs;
 	return BYTE_REG_BITS_IS_ON(PHYSR0_LINKGD, &regs->PHYSR0)  ? 0 : 1;
 }
 
 static void velocity_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	strcpy(info->driver, VELOCITY_NAME);
 	strcpy(info->version, VELOCITY_VERSION);
 	strcpy(info->bus_info, vptr->pdev->slot_name);
@@ -2903,7 +2905,7 @@
 
 static void velocity_ethtool_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	wol->supported = WAKE_PHY | WAKE_MAGIC | WAKE_UCAST | WAKE_ARP;
 	wol->wolopts |= WAKE_MAGIC;
 	/*
@@ -2919,7 +2921,7 @@
 
 static int velocity_ethtool_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 
 	if (!(wol->wolopts & (WAKE_PHY | WAKE_MAGIC | WAKE_UCAST | WAKE_ARP)))
 		return -EFAULT;
@@ -2984,7 +2986,7 @@
  
 static int velocity_mii_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct velocity_info *vptr = dev->priv;
+	struct velocity_info *vptr = netdev_priv(dev);
 	struct mac_regs * regs = vptr->mac_regs;
 	unsigned long flags;
 	struct mii_ioctl_data *miidata = if_mii(ifr);
