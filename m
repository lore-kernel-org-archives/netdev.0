From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] dscc4 bogosity
Date: Sun, 21 Sep 2003 02:19:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030921021901.A20090@electric-eye.fr.zoreil.com>
References: <20030919113252.67949bc8.rddunlap@osdl.org> <20030919224428.A7296@electric-eye.fr.zoreil.com> <20030919134804.2c8967e4.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030919134804.2c8967e4.rddunlap@osdl.org>; from rddunlap@osdl.org on Fri, Sep 19, 2003 at 01:48:04PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

- dscc4_release_ring() are removed from dscc4_{open/close} as the rings
  are allocated/freed in dscc4_{found1/free1} (giant stupid bug);
- mark dscc4_{rx/tx}_reset with attribute unused as it isn't clear whether
  they will resurrect or disappear;
- removal of label "err_free_ring" in dscc4_open() (it isn't used any more);
- handling return status is getting simpler in dscc4_found1().


 drivers/net/wan/dscc4.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff -puN drivers/net/wan/dscc4.c~dscc4-misplaced-free_ring drivers/net/wan/dscc4.c
--- linux-2.6.0-test5-bk7/drivers/net/wan/dscc4.c~dscc4-misplaced-free_ring	Sun Sep 21 01:03:49 2003
+++ linux-2.6.0-test5-bk7-fr/drivers/net/wan/dscc4.c	Sun Sep 21 02:01:43 2003
@@ -108,7 +108,7 @@
 #include <linux/hdlc.h>
 
 /* Version */
-static const char version[] = "$Id: dscc4.c,v 1.159 2002/04/10 22:05:17 romieu Exp $ for Linux\n";
+static const char version[] = "$Id: dscc4.c,v 1.173 2003/09/20 23:55:34 romieu Exp $ for Linux\n";
 static int debug;
 static int quartz;
 
@@ -593,6 +593,8 @@ static inline int dscc4_xpr_ack(struct d
 	return (i >= 0 ) ? i : -EAGAIN;
 }
 
+/* dscc4_{rx/tx}_reset are both unreliable - more tweak needed */
+__attribute__ ((unused))
 static void dscc4_rx_reset(struct dscc4_dev_priv *dpriv, struct net_device *dev)
 {
 	unsigned long flags;
@@ -607,6 +609,7 @@ static void dscc4_rx_reset(struct dscc4_
 	spin_unlock_irqrestore(&dpriv->pci_priv->lock, flags);
 }
 
+__attribute__ ((unused))
 static void dscc4_tx_reset(struct dscc4_dev_priv *dpriv, struct net_device *dev)
 {
 	u16 i = 0;
@@ -860,7 +863,7 @@ static int dscc4_found1(struct pci_dev *
 {
 	struct dscc4_pci_priv *ppriv;
 	struct dscc4_dev_priv *root;
-	int i = 0;
+	int i, ret = -ENOMEM;
 
 	root = (struct dscc4_dev_priv *)
 		kmalloc(dev_per_card*sizeof(*root), GFP_KERNEL);
@@ -901,7 +904,8 @@ static int dscc4_found1(struct pci_dev *
 		hdlc->xmit = dscc4_start_xmit;
 		hdlc->attach = dscc4_hdlc_attach;
 
-	        if (register_hdlc_device(hdlc)) {
+		ret = register_hdlc_device(hdlc);
+		if (ret < 0) {
 			printk(KERN_ERR "%s: unable to register\n", DRV_NAME);
 			goto err_unregister;
 	        }
@@ -909,17 +913,20 @@ static int dscc4_found1(struct pci_dev *
 		dscc4_init_registers(dpriv, d);
 		dpriv->parity = PARITY_CRC16_PR0_CCITT;
 		dpriv->encoding = ENCODING_NRZ;
-		if (dscc4_init_ring(d)) {
+
+		ret = dscc4_init_ring(d);
+		if (ret < 0) {
 			unregister_hdlc_device(hdlc);
 			goto err_unregister;
 		}
 	}
-	if (dscc4_set_quartz(root, quartz) < 0)
+	ret = dscc4_set_quartz(root, quartz);
+	if (ret < 0)
 		goto err_unregister;
 	ppriv->root = root;
 	spin_lock_init(&ppriv->lock);
 	pci_set_drvdata(pdev, ppriv);
-	return 0;
+	return ret;
 
 err_unregister:
 	while (--i >= 0) {
@@ -930,7 +937,7 @@ err_unregister:
 err_free_dev:
 	kfree(root);
 err_out:
-	return -1;
+	return ret;
 };
 
 /* FIXME: get rid of the unneeded code */
@@ -1093,9 +1100,7 @@ done:
 
 err_disable_scc_events:
 	scc_writel(0xffffffff, dpriv, dev, IMR);
-err_free_ring:
 	scc_patchl(PowerUp | Vis, 0, dpriv, dev, CCR0);
-	dscc4_release_ring(dpriv);
 err_out:
 	hdlc_close(hdlc);
 err:
@@ -1161,7 +1166,6 @@ static int dscc4_close(struct net_device
 	dpriv->flags |= FakeReset;
 
 	hdlc_close(hdlc);
-	dscc4_release_ring(dpriv);
 
 	return 0;
 }

_
