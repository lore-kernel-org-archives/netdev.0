From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 10/16] Host AP: Use void __iomem * with {read,write}{b,w}
Date: Sat, 13 Nov 2004 21:18:47 -0800
Message-ID: <20041114051847.GB14810@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu> <20041108071630.GK1076@jm.kir.nu> <419071D5.8070208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <419071D5.8070208@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Start using void __iomem * instead of unsigned long with {read,write}{b,w}
to silence compiler warning with Linux 2.6.9-rc2 and newer.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
--- a/drivers/net/wireless/hostap/hostap_pci.c	2004-11-13 20:55:58 -08:00
+++ b/drivers/net/wireless/hostap/hostap_pci.c	2004-11-13 20:55:58 -08:00
@@ -50,25 +50,25 @@
 
 static inline void hfa384x_outb_debug(struct net_device *dev, int a, u8 v)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	unsigned long flags;
 
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTB, a, v);
-	writeb(v, dev->mem_start + a);
+	writeb(v, local->mem_start + a);
 	spin_unlock_irqrestore(&local->lock, flags);
 }
 
 static inline u8 hfa384x_inb_debug(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	unsigned long flags;
 	u8 v;
 
 	spin_lock_irqsave(&local->lock, flags);
-	v = readb(dev->mem_start + a);
+	v = readb(local->mem_start + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INB, a, v);
 	spin_unlock_irqrestore(&local->lock, flags);
 	return v;
@@ -76,25 +76,25 @@
 
 static inline void hfa384x_outw_debug(struct net_device *dev, int a, u16 v)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	unsigned long flags;
 
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTW, a, v);
-	writew(v, dev->mem_start + a);
+	writew(v, local->mem_start + a);
 	spin_unlock_irqrestore(&local->lock, flags);
 }
 
 static inline u16 hfa384x_inw_debug(struct net_device *dev, int a)
 {
-	struct hostap_interface *iface = dev->priv;
+	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
 	unsigned long flags;
 	u16 v;
 
 	spin_lock_irqsave(&local->lock, flags);
-	v = readw(dev->mem_start + a);
+	v = readw(local->mem_start + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INW, a, v);
 	spin_unlock_irqrestore(&local->lock, flags);
 	return v;
@@ -109,12 +109,40 @@
 
 #else /* PRISM2_IO_DEBUG */
 
-#define HFA384X_OUTB(v,a) writeb((v), dev->mem_start + (a))
-#define HFA384X_INB(a) (u8) readb(dev->mem_start + (a))
-#define HFA384X_OUTW(v,a) writew((v), dev->mem_start + (a))
-#define HFA384X_INW(a) (u16) readw(dev->mem_start + (a))
-#define HFA384X_OUTW_DATA(v,a) writew(cpu_to_le16(v), dev->mem_start + (a))
-#define HFA384X_INW_DATA(a) (u16) le16_to_cpu(readw(dev->mem_start + (a)))
+static inline void hfa384x_outb(struct net_device *dev, int a, u8 v)
+{
+	struct hostap_interface *iface = netdev_priv(dev);
+	local_info_t *local = iface->local;
+	writeb(v, local->mem_start + a);
+}
+
+static inline u8 hfa384x_inb(struct net_device *dev, int a)
+{
+	struct hostap_interface *iface = netdev_priv(dev);
+	local_info_t *local = iface->local;
+	return readb(local->mem_start + a);
+}
+
+static inline void hfa384x_outw(struct net_device *dev, int a, u16 v)
+{
+	struct hostap_interface *iface = netdev_priv(dev);
+	local_info_t *local = iface->local;
+	writew(v, local->mem_start + a);
+}
+
+static inline u16 hfa384x_inw(struct net_device *dev, int a)
+{
+	struct hostap_interface *iface = netdev_priv(dev);
+	local_info_t *local = iface->local;
+	return readw(local->mem_start + a);
+}
+
+#define HFA384X_OUTB(v,a) hfa384x_outb(dev, (a), (v))
+#define HFA384X_INB(a) hfa384x_inb(dev, (a))
+#define HFA384X_OUTW(v,a) hfa384x_outw(dev, (a), (v))
+#define HFA384X_INW(a) hfa384x_inw(dev, (a))
+#define HFA384X_OUTW_DATA(v,a) hfa384x_outw(dev, (a), cpu_to_le16((v)))
+#define HFA384X_INW_DATA(a) (u16) le16_to_cpu(hfa384x_inw(dev, (a)))
 
 #endif /* PRISM2_IO_DEBUG */
 
@@ -232,7 +260,7 @@
 			    const struct pci_device_id *id)
 {
 	unsigned long phymem;
-	unsigned long mem = 0;
+	void __iomem *mem = NULL;
 	local_info_t *local = NULL;
 	struct net_device *dev = NULL;
 	static int cards_found /* = 0 */;
@@ -249,8 +277,8 @@
 		goto err_out_disable;
 	}
 
-	mem = (unsigned long) ioremap(phymem, pci_resource_len(pdev, 0));
-	if (!mem) {
+	mem = ioremap(phymem, pci_resource_len(pdev, 0));
+	if (mem == NULL) {
 		printk(KERN_ERR "prism2: Cannot remap PCI memory region\n") ;
 		goto fail;
 	}
@@ -267,8 +295,7 @@
 	cards_found++;
 
         dev->irq = pdev->irq;
-        dev->mem_start = mem;
-        dev->mem_end = mem + pci_resource_len(pdev, 0);
+        local->mem_start = mem;
 
 	prism2_pci_cor_sreset(local);
 
@@ -297,7 +324,7 @@
 		free_irq(dev->irq, dev);
 
 	if (mem)
-		iounmap((void *) mem);
+		iounmap(mem);
 
 	release_mem_region(phymem, pci_resource_len(pdev, 0));
 
@@ -312,8 +339,8 @@
 static void prism2_pci_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct hostap_interface *iface = dev->priv;
-	unsigned long mem_start;
+	struct hostap_interface *iface = netdev_priv(dev);
+	void __iomem *mem_start;
 
 	/* Reset the hardware, and ensure interrupts are disabled. */
 	prism2_pci_cor_sreset(iface->local);
@@ -322,10 +349,10 @@
 	if (dev->irq)
 		free_irq(dev->irq, dev);
 
-	mem_start = dev->mem_start;
+	mem_start = iface->local->mem_start;
 	prism2_free_local_data(dev);
 
-	iounmap((void *) mem_start);
+	iounmap(mem_start);
 
 	release_mem_region(pci_resource_start(pdev, 0),
 			   pci_resource_len(pdev, 0));
diff -Nru a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
--- a/drivers/net/wireless/hostap/hostap_plx.c	2004-11-13 20:55:58 -08:00
+++ b/drivers/net/wireless/hostap/hostap_plx.c	2004-11-13 20:55:58 -08:00
@@ -247,7 +247,7 @@
 
 	/* Set sreset bit of COR and clear it after hold time */
 
-	if (local->attr_mem == 0) {
+	if (local->attr_mem == NULL) {
 		/* TMD7160 - COR at card's first I/O addr */
 		corsave = inb(local->cor_offset);
 		outb(corsave | COR_SRESET, local->cor_offset);
@@ -271,7 +271,7 @@
 {
 	unsigned char corsave;
 
-	if (local->attr_mem == 0) {
+	if (local->attr_mem == NULL) {
 		/* TMD7160 - COR at card's first I/O addr */
 		corsave = inb(local->cor_offset);
 		outb(corsave | COR_SRESET, local->cor_offset);
@@ -306,7 +306,7 @@
 };
 
 
-static int prism2_plx_check_cis(unsigned long attr_mem, int attr_len,
+static int prism2_plx_check_cis(void __iomem *attr_mem, int attr_len,
 				unsigned int *cor_offset,
 				unsigned int *cor_index)
 {
@@ -401,7 +401,7 @@
 	unsigned int pccard_ioaddr, plx_ioaddr;
 	unsigned long pccard_attr_mem;
 	unsigned int pccard_attr_len;
-	unsigned long attr_mem = 0;
+	void __iomem *attr_mem = NULL;
 	unsigned int cor_offset, cor_index;
 	u32 reg;
 	local_info_t *local = NULL;
@@ -422,7 +422,7 @@
 
 	if (tmd7160) {
 		/* TMD7160 */
-		attr_mem = 0; /* no access to PC Card attribute memory */
+		attr_mem = NULL; /* no access to PC Card attribute memory */
 
 		printk(KERN_INFO "TMD7160 PCI/PCMCIA adapter: io=0x%x, "
 		       "irq=%d, pccard_io=0x%x\n",
@@ -448,9 +448,8 @@
 			goto fail;
 
 
-		attr_mem = (unsigned long) ioremap(pccard_attr_mem,
-						   pccard_attr_len);
-		if (!attr_mem) {
+		attr_mem = ioremap(pccard_attr_mem, pccard_attr_len);
+		if (attr_mem == NULL) {
 			printk(KERN_ERR "%s: cannot remap attr_mem\n",
 			       dev_info);
 			goto fail;
@@ -532,7 +531,7 @@
 		free_irq(dev->irq, dev);
 
 	if (attr_mem)
-		iounmap((void *) attr_mem);
+		iounmap(attr_mem);
 
 	pci_disable_device(pdev);
 
@@ -550,7 +549,7 @@
 	hfa384x_disable_interrupts(dev);
 
 	if (iface->local->attr_mem)
-		iounmap((void *) iface->local->attr_mem);
+		iounmap(iface->local->attr_mem);
 	if (dev->irq)
 		free_irq(dev->irq, dev);
 
diff -Nru a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
--- a/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-13 20:55:58 -08:00
+++ b/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-13 20:55:58 -08:00
@@ -895,11 +895,12 @@
 #endif /* PRISM2_PCCARD */
 
 #ifdef PRISM2_PLX
-	unsigned long attr_mem;
+	void __iomem *attr_mem;
 	unsigned int cor_offset;
 #endif /* PRISM2_PLX */
 
 #ifdef PRISM2_PCI
+	void __iomem *mem_start;
 #ifdef PRISM2_BUS_MASTER
 	/* bus master for BAP0 (TX) */
 	int bus_m0_tx_idx;


-- 
Jouni Malinen                                            PGP id EFC895FA
