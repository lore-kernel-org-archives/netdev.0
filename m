From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4//8) dscc4 convert to new hdlc_device
Date: Tue, 2 Dec 2003 13:58:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202135846.28a93010.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halas <khc@pm.waw.pl>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1493  -> 1.1494 
#	drivers/net/wan/dscc4.c	1.51    -> 1.52   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/26	shemminger@osdl.org	1.1494
# Convert to work with hdlc_device that is not embedded.
# Use list macros for list of ports on card.
# --------------------------------------------
#
diff -Nru a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
--- a/drivers/net/wan/dscc4.c	Wed Nov 26 12:30:13 2003
+++ b/drivers/net/wan/dscc4.c	Wed Nov 26 12:30:13 2003
@@ -185,12 +185,14 @@
         spinlock_t lock;
         struct pci_dev *pdev;
 
-        struct dscc4_dev_priv *root;
+	struct list_head devs;
         dma_addr_t iqcfg_dma;
 	u32 xtal_hz;
 };
 
 struct dscc4_dev_priv {
+	struct list_head dev_list;
+
         struct sk_buff *rx_skbuff[RX_RING_SIZE];
         struct sk_buff *tx_skbuff[TX_RING_SIZE];
 
@@ -228,7 +230,7 @@
 
 	unsigned short encoding;
 	unsigned short parity;
-	hdlc_device hdlc;
+	hdlc_device *hdlc;
 	sync_serial_settings settings;
 	u32 __pad __attribute__ ((aligned (4)));
 };
@@ -371,9 +373,17 @@
 static int dscc4_tx_poll(struct dscc4_dev_priv *, struct net_device *);
 #endif
 
+static inline struct dscc4_dev_priv *dscc4_root_priv(struct dscc4_pci_priv *ppriv)
+{
+	struct list_head *first = ppriv->devs.next;
+
+	return (first == &ppriv->devs) ? NULL 
+		: list_entry(first, struct dscc4_dev_priv, dev_list);
+}
+
 static inline struct dscc4_dev_priv *dscc4_priv(struct net_device *dev)
 {
-	return list_entry(dev, struct dscc4_dev_priv, hdlc.netdev);
+	return dev_to_hdlc(dev)->dev_data;
 }
 
 static void scc_patchl(u32 mask, u32 value, struct dscc4_dev_priv *dpriv,
@@ -636,7 +646,7 @@
 				struct net_device *dev)
 {
 	struct RxFD *rx_fd = dpriv->rx_fd + dpriv->rx_current%RX_RING_SIZE;
-	struct net_device_stats *stats = &dpriv->hdlc.stats;
+	struct net_device_stats *stats = &dpriv->hdlc->stats;
 	struct pci_dev *pdev = dpriv->pci_priv->pdev;
 	struct sk_buff *skb;
 	int pkt_len;
@@ -681,19 +691,16 @@
 
 static void dscc4_free1(struct pci_dev *pdev)
 {
-	struct dscc4_pci_priv *ppriv;
-	struct dscc4_dev_priv *root;
-	int i;
+	struct dscc4_pci_priv *ppriv = pci_get_drvdata(pdev);
+	struct dscc4_dev_priv *dpriv, *dnext;
 
-	ppriv = pci_get_drvdata(pdev);
-	root = ppriv->root;
-
-	for (i = 0; i < dev_per_card; i++)
-		unregister_hdlc_device(&root[i].hdlc);
+	list_for_each_entry_safe(dpriv, dnext, &ppriv->devs, dev_list) {
+		unregister_hdlc_device(dpriv->hdlc);
+		free_hdlc_device(dpriv->hdlc);
+	}
 
 	pci_set_drvdata(pdev, NULL);
 
-	kfree(root);
 	kfree(ppriv);
 }
 
@@ -704,7 +711,6 @@
 	struct dscc4_dev_priv *dpriv;
 	static int cards_found = 0;
 	unsigned long ioaddr;
-	int i;
 
 	printk(KERN_DEBUG "%s", version);
 
@@ -743,7 +749,8 @@
 
 	priv = (struct dscc4_pci_priv *)pci_get_drvdata(pdev);
 
-	if (request_irq(pdev->irq, &dscc4_irq, SA_SHIRQ, DRV_NAME, priv->root)){
+	if (request_irq(pdev->irq, &dscc4_irq, SA_SHIRQ, DRV_NAME, 
+			dscc4_root_priv(priv))) {
 		printk(KERN_WARNING "%s: IRQ %d busy\n", DRV_NAME, pdev->irq);
 		goto err_out_free1;
 	}
@@ -772,21 +779,19 @@
 	 * SCC 0-3 private rx/tx irq structures
 	 * IQRX/TXi needs to be set soon. Learned it the hard way...
 	 */
-	for (i = 0; i < dev_per_card; i++) {
-		dpriv = priv->root + i;
+	list_for_each_entry(dpriv, &priv->devs, dev_list) {
 		dpriv->iqtx = (u32 *) pci_alloc_consistent(pdev,
 			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqtx_dma);
 		if (!dpriv->iqtx)
 			goto err_out_free_iqtx;
-		writel(dpriv->iqtx_dma, ioaddr + IQTX0 + i*4);
+		writel(dpriv->iqtx_dma, ioaddr + IQTX0 + dpriv->dev_id*4);
 	}
-	for (i = 0; i < dev_per_card; i++) {
-		dpriv = priv->root + i;
+	list_for_each_entry(dpriv, &priv->devs, dev_list) {
 		dpriv->iqrx = (u32 *) pci_alloc_consistent(pdev,
 			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqrx_dma);
 		if (!dpriv->iqrx)
 			goto err_out_free_iqrx;
-		writel(dpriv->iqrx_dma, ioaddr + IQRX0 + i*4);
+		writel(dpriv->iqrx_dma, ioaddr + IQRX0 + dpriv->dev_id*4);
 	}
 
 	/* Cf application hint. Beware of hard-lock condition on threshold. */
@@ -804,22 +809,19 @@
 	return 0;
 
 err_out_free_iqrx:
-	while (--i >= 0) {
-		dpriv = priv->root + i;
+	list_for_each_entry(dpriv, &priv->devs, dev_list) {
 		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
 				    dpriv->iqrx, dpriv->iqrx_dma);
 	}
-	i = dev_per_card;
 err_out_free_iqtx:
-	while (--i >= 0) {
-		dpriv = priv->root + i;
+	list_for_each_entry(dpriv, &priv->devs, dev_list) {
 		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
 				    dpriv->iqtx, dpriv->iqtx_dma);
 	}
 	pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32), priv->iqcfg,
 			    priv->iqcfg_dma);
 err_out_free_irq:
-	free_irq(pdev->irq, priv->root);
+	free_irq(pdev->irq, dscc4_root_priv(priv));
 err_out_free1:
 	dscc4_free1(pdev);
 err_out_iounmap:
@@ -863,29 +865,27 @@
 static int dscc4_found1(struct pci_dev *pdev, unsigned long ioaddr)
 {
 	struct dscc4_pci_priv *ppriv;
-	struct dscc4_dev_priv *root;
+	struct dscc4_dev_priv *dpriv, *dnext;
 	int i, ret = -ENOMEM;
 
-	root = (struct dscc4_dev_priv *)
-		kmalloc(dev_per_card*sizeof(*root), GFP_KERNEL);
-	if (!root) {
-		printk(KERN_ERR "%s: can't allocate data\n", DRV_NAME);
-		goto err_out;
-	}
-	memset(root, 0, dev_per_card*sizeof(*root));
-
 	ppriv = (struct dscc4_pci_priv *) kmalloc(sizeof(*ppriv), GFP_KERNEL);
 	if (!ppriv) {
 		printk(KERN_ERR "%s: can't allocate private data\n", DRV_NAME);
-		goto err_free_dev;
+		goto err_out;
 	}
 	memset(ppriv, 0, sizeof(struct dscc4_pci_priv));
+	INIT_LIST_HEAD(&ppriv->devs);
 
 	for (i = 0; i < dev_per_card; i++) {
-		struct dscc4_dev_priv *dpriv = root + i;
-		hdlc_device *hdlc = &dpriv->hdlc;
-		struct net_device *d = hdlc_to_dev(hdlc);
+		hdlc_device *hdlc = alloc_hdlc_device(sizeof(*dpriv));
+		struct net_device *d;
+
+		if (!hdlc) {
+			ret = -ENOMEM;
+			goto err_unregister;
+		}
 
+		d = hdlc_to_dev(hdlc);
 	        d->base_addr = ioaddr;
 		d->init = NULL;
 	        d->irq = pdev->irq;
@@ -898,6 +898,8 @@
 		SET_MODULE_OWNER(d);
 		SET_NETDEV_DEV(d, &pdev->dev);
 
+		dpriv = dscc4_priv(d);
+		dpriv->hdlc = hdlc;
 		dpriv->dev_id = i;
 		dpriv->pci_priv = ppriv;
 		spin_lock_init(&dpriv->lock);
@@ -920,23 +922,25 @@
 			unregister_hdlc_device(hdlc);
 			goto err_unregister;
 		}
+		list_add_tail(&dpriv->dev_list, &ppriv->devs);
 	}
-	ret = dscc4_set_quartz(root, quartz);
+
+
+	ret = dscc4_set_quartz(dscc4_root_priv(ppriv), quartz);
 	if (ret < 0)
 		goto err_unregister;
-	ppriv->root = root;
+
 	spin_lock_init(&ppriv->lock);
 	pci_set_drvdata(pdev, ppriv);
 	return ret;
 
 err_unregister:
-	while (--i >= 0) {
-		dscc4_release_ring(root + i);
-		unregister_hdlc_device(&root[i].hdlc);
+	list_for_each_entry_safe(dpriv, dnext, &ppriv->devs, dev_list) {
+		dscc4_release_ring(dpriv);
+		unregister_hdlc_device(dpriv->hdlc);
+		free_hdlc_device(dpriv->hdlc);
 	}
 	kfree(ppriv);
-err_free_dev:
-	kfree(root);
 err_out:
 	return ret;
 };
@@ -964,7 +968,7 @@
 	sync_serial_settings *settings = &dpriv->settings;
 
 	if (settings->loopback && (settings->clock_type != CLOCK_INT)) {
-		struct net_device *dev = hdlc_to_dev(&dpriv->hdlc);
+		struct net_device *dev = hdlc_to_dev(dpriv->hdlc);
 
 		printk(KERN_INFO "%s: loopback requires clock\n", dev->name);
 		return -1;
@@ -1015,7 +1019,7 @@
 static int dscc4_open(struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
-	hdlc_device *hdlc = &dpriv->hdlc;
+	hdlc_device *hdlc = dpriv->hdlc;
 	struct dscc4_pci_priv *ppriv;
 	int ret = -EAGAIN;
 
@@ -1467,7 +1471,7 @@
 	int i, handled = 1;
 
 	priv = root->pci_priv;
-	dev = hdlc_to_dev(&root->hdlc);
+	dev = hdlc_to_dev(root->hdlc);
 
 	spin_lock_irqsave(&priv->lock, flags);
 
@@ -1518,7 +1522,7 @@
 static inline void dscc4_tx_irq(struct dscc4_pci_priv *ppriv,
 				struct dscc4_dev_priv *dpriv)
 {
-	struct net_device *dev = hdlc_to_dev(&dpriv->hdlc);
+	struct net_device *dev = hdlc_to_dev(dpriv->hdlc);
 	u32 state;
 	int cur, loop = 0;
 
@@ -1549,7 +1553,7 @@
 
 	if (state & SccEvt) {
 		if (state & Alls) {
-			struct net_device_stats *stats = &dpriv->hdlc.stats;
+			struct net_device_stats *stats = &dpriv->hdlc->stats;
 			struct sk_buff *skb;
 			struct TxFD *tx_fd;
 
@@ -1687,7 +1691,7 @@
 static inline void dscc4_rx_irq(struct dscc4_pci_priv *priv,
 				    struct dscc4_dev_priv *dpriv)
 {
-	struct net_device *dev = hdlc_to_dev(&dpriv->hdlc);
+	struct net_device *dev = hdlc_to_dev(dpriv->hdlc);
 	u32 state;
 	int cur;
 
@@ -1954,23 +1958,21 @@
 static void __devexit dscc4_remove_one(struct pci_dev *pdev)
 {
 	struct dscc4_pci_priv *ppriv;
-	struct dscc4_dev_priv *root;
+	struct dscc4_dev_priv *root,  *dpriv;
 	unsigned long ioaddr;
-	int i;
 
 	ppriv = pci_get_drvdata(pdev);
-	root = ppriv->root;
+	root = dscc4_root_priv(ppriv);
 
-	ioaddr = hdlc_to_dev(&root->hdlc)->base_addr;
+	ioaddr = hdlc_to_dev(root->hdlc)->base_addr;
 
 	dscc4_pci_reset(pdev, ioaddr);
 
 	free_irq(pdev->irq, root);
 	pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32), ppriv->iqcfg,
 			    ppriv->iqcfg_dma);
-	for (i = 0; i < dev_per_card; i++) {
-		struct dscc4_dev_priv *dpriv = root + i;
 
+	list_for_each_entry(dpriv, &ppriv->devs, dev_list) {
 		dscc4_release_ring(dpriv);
 		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
 				    dpriv->iqrx, dpriv->iqrx_dma);
