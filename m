From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] 3c523: use module_param an netdev_priv
Date: Mon, 18 Oct 2004 13:42:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018134211.36163604@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change 3c523 to use module_param and netdev_priv

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/3c523.c b/drivers/net/3c523.c
--- a/drivers/net/3c523.c	2004-10-18 13:39:27 -07:00
+++ b/drivers/net/3c523.c	2004-10-18 13:39:27 -07:00
@@ -94,6 +94,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -308,7 +309,7 @@
 
 static int __init check586(struct net_device *dev, unsigned long where, unsigned size)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	char *iscp_addrs[2];
 	int i = 0;
 
@@ -349,7 +350,7 @@
 
 void alloc586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	elmc_id_reset586();
 	DELAY(2);
@@ -420,7 +421,7 @@
 	int i = 0;
 	unsigned int size = 0;
 	int retval;
-	struct priv *pr = dev->priv;
+	struct priv *pr = netdev_priv(dev);
 
 	SET_MODULE_OWNER(dev);
 	if (MCA_bus == 0) {
@@ -581,7 +582,8 @@
  
 static void cleanup_card(struct net_device *dev)
 {
-	mca_set_adapter_procfn(((struct priv *) (dev->priv))->slot, NULL, NULL);
+	struct priv *priv = netdev_priv(priv);
+	mca_set_adapter_procfn(priv->slot, NULL, NULL);
 	release_region(dev->base_addr, ELMC_IO_EXTENT);
 }
 
@@ -622,7 +624,7 @@
 	void *ptr;
 	unsigned long s;
 	int i, result = 0;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	volatile struct configure_cmd_struct *cfg_cmd;
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
@@ -860,7 +862,7 @@
 	volatile struct rfd_struct *rfd = (struct rfd_struct *) ptr;
 	volatile struct rbd_struct *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset((char *) rfd, 0, sizeof(struct rfd_struct) * p->num_recv_buffs);
 	p->rfd_first = rfd;
@@ -924,7 +926,7 @@
 	}
 	/* reading ELMC_CTRL also clears the INT bit. */
 
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	while ((stat = p->scb->status & STAT_MASK)) 
 	{
@@ -980,7 +982,7 @@
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct *rbd;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	for (; (status = p->rfd_top->status) & STAT_COMPL;) {
 		rbd = (struct rbd_struct *) make32(p->rfd_top->rbd_offset);
@@ -1025,7 +1027,7 @@
 
 static void elmc_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->stats.rx_errors++;
 
@@ -1048,7 +1050,7 @@
 static void elmc_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	status = p->xmit_cmds[p->xmit_last]->cmd_status;
 	if (!(status & STAT_COMPL)) {
@@ -1091,7 +1093,7 @@
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->scb->rfa_offset = make16(p->rfd_first);
 	p->scb->cmd = RUC_START;
@@ -1105,7 +1107,7 @@
  
 static void elmc_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	/* COMMAND-UNIT active? */
 	if (p->scb->status & CU_ACTIVE) {
 #ifdef DEBUG
@@ -1141,7 +1143,7 @@
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -1212,7 +1214,7 @@
 
 static struct net_device_stats *elmc_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc, aln, rsc, ovrn;
 
 	crc = p->scb->crc_errs;	/* get error-statistic from the ni82586 */
@@ -1271,12 +1273,14 @@
 static struct net_device *dev_elmc[MAX_3C523_CARDS];
 static int irq[MAX_3C523_CARDS];
 static int io[MAX_3C523_CARDS];
-MODULE_PARM(irq, "1-" __MODULE_STRING(MAX_3C523_CARDS) "i");
-MODULE_PARM(io, "1-" __MODULE_STRING(MAX_3C523_CARDS) "i");
+
+static int num_params;
+module_param_array(irq, int, num_params, 0);
+module_param_array(io, int, num_params, 0);
 MODULE_PARM_DESC(io, "EtherLink/MC I/O base address(es)");
 MODULE_PARM_DESC(irq, "EtherLink/MC IRQ number(s)");
 
-int init_module(void)
+static int __init elmc_init_module(void)
 {
 	int this_dev,found = 0;
 
@@ -1306,8 +1310,9 @@
 		return -ENXIO;
 	} else return 0;
 }
+module_init(elmc_init_module);
 
-void cleanup_module(void)
+static void __exit elmc_cleanup_module(void)
 {
 	int this_dev;
 	for (this_dev=0; this_dev<MAX_3C523_CARDS; this_dev++) {
@@ -1319,5 +1324,6 @@
 		}
 	}
 }
+module_exit(elmc_cleanup_module);
 
 #endif				/* MODULE */
