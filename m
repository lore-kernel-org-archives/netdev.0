From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] 3c505: use module_param and netdev_priv
Date: Mon, 18 Oct 2004 13:05:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018130549.2cbe9bb8@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert 3c505 to use netdev_priv and module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/3c505.c b/drivers/net/3c505.c
--- a/drivers/net/3c505.c	2004-10-18 12:58:31 -07:00
+++ b/drivers/net/3c505.c	2004-10-18 12:58:31 -07:00
@@ -97,6 +97,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/interrupt.h>
@@ -217,11 +218,12 @@
 
 static inline void outb_control(unsigned char val, struct net_device *dev)
 {
+	elp_device *adapter = netdev_priv(dev);
 	outb(val, dev->base_addr + PORT_CONTROL);
-	((elp_device *)(dev->priv))->hcr_val = val;
+	adapter->hcr_val = val;
 }
 
-#define HCR_VAL(x)   (((elp_device *)((x)->priv))->hcr_val)
+#define HCR_VAL(x)   (((elp_device *)netdev_priv(x))->hcr_val)
 
 static inline void outb_command(unsigned char val, unsigned int base_addr)
 {
@@ -272,7 +274,7 @@
 
 static inline void set_hsf(struct net_device *dev, int hsf)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&adapter->lock, flags);
@@ -285,7 +287,7 @@
 inline static void adapter_reset(struct net_device *dev)
 {
 	unsigned long timeout;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned char orig_hcr = adapter->hcr_val;
 
 	outb_control(0, dev);
@@ -318,7 +320,7 @@
  */
 static inline void check_3c505_dma(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	if (adapter->dmaing && time_after(jiffies, adapter->current_dma.start_time + 10)) {
 		unsigned long flags, f;
 		printk(KERN_ERR "%s: DMA %s timed out, %d bytes left\n", dev->name, adapter->current_dma.direction ? "download" : "upload", get_dma_residue(dev->dma));
@@ -365,7 +367,7 @@
 /* Check to see if the receiver needs restarting, and kick it if so */
 static inline void prime_rx(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	while (adapter->rx_active < ELP_RX_PCBS && netif_running(dev)) {
 		if (!start_receive(dev, &adapter->itx_pcb))
 			break;
@@ -400,7 +402,7 @@
 {
 	int i;
 	unsigned long timeout;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long flags;
 
 	check_3c505_dma(dev);
@@ -488,7 +490,7 @@
 	unsigned long timeout;
 	unsigned long flags;
 
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	set_hsf(dev, 0);
 
@@ -568,7 +570,7 @@
 static int start_receive(struct net_device *dev, pcb_struct * tx_pcb)
 {
 	int status;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: restarting receiver\n", dev->name);
@@ -596,7 +598,7 @@
 static void receive_packet(struct net_device *dev, int len)
 {
 	int rlen;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	void *target;
 	struct sk_buff *skb;
 	unsigned long flags;
@@ -669,7 +671,7 @@
 	unsigned long timeout;
 
 	dev = dev_id;
-	adapter = (elp_device *) dev->priv;
+	adapter = netdev_priv(dev);
 	
 	spin_lock(&adapter->lock);
 
@@ -867,7 +869,7 @@
 	elp_device *adapter;
 	int retval;
 
-	adapter = dev->priv;
+	adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request to open device\n", dev->name);
@@ -997,7 +999,7 @@
 
 static int send_packet(struct net_device *dev, struct sk_buff *skb)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long target;
 	unsigned long flags;
 
@@ -1067,7 +1069,7 @@
  
 static void elp_timeout(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	int stat;
 
 	stat = inb_status(dev->base_addr);
@@ -1089,7 +1091,7 @@
 static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	
 	spin_lock_irqsave(&adapter->lock, flags);
 	check_3c505_dma(dev);
@@ -1131,7 +1133,7 @@
 
 static struct net_device_stats *elp_get_stats(struct net_device *dev)
 {
-	elp_device *adapter = (elp_device *) dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request for stats\n", dev->name);
@@ -1195,7 +1197,7 @@
 {
 	elp_device *adapter;
 
-	adapter = dev->priv;
+	adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request to close device\n", dev->name);
@@ -1236,7 +1238,7 @@
 
 static void elp_set_mc_list(struct net_device *dev)
 {
-	elp_device *adapter = (elp_device *) dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	struct dev_mc_list *dmi = dev->mc_list;
 	int i;
 	unsigned long flags;
@@ -1409,7 +1411,7 @@
 
 static int __init elplus_setup(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	int i, tries, tries1, okay;
 	unsigned long timeout;
 	unsigned long cookie = 0;
@@ -1638,14 +1640,17 @@
 static int io[ELP_MAX_CARDS];
 static int irq[ELP_MAX_CARDS];
 static int dma[ELP_MAX_CARDS];
-MODULE_PARM(io, "1-" __MODULE_STRING(ELP_MAX_CARDS) "i");
-MODULE_PARM(irq, "1-" __MODULE_STRING(ELP_MAX_CARDS) "i");
-MODULE_PARM(dma, "1-" __MODULE_STRING(ELP_MAX_CARDS) "i");
+
+static int num_params;
+module_param_array(io, int, num_params, 0);
+module_param_array(irq, int, num_params, 0);
+module_param_array(dma, int, num_params, 0);
+
 MODULE_PARM_DESC(io, "EtherLink Plus I/O base address(es)");
 MODULE_PARM_DESC(irq, "EtherLink Plus IRQ number(s) (assigned)");
 MODULE_PARM_DESC(dma, "EtherLink Plus DMA channel(s)");
 
-int init_module(void)
+static __init int elplus_init_module(void)
 {
 	int this_dev, found = 0;
 
@@ -1681,8 +1686,9 @@
 		return -ENODEV;
 	return 0;
 }
+module_init(elplus_init_module);
 
-void cleanup_module(void)
+static __exit void elplus_cleanup_module(void)
 {
 	int this_dev;
 
@@ -1695,6 +1701,7 @@
 		}
 	}
 }
+module_exit(elplus_cleanup_module);
 
 #endif				/* MODULE */
 MODULE_LICENSE("GPL");
