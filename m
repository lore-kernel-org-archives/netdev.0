From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-03-24
Date: Mon, 24 Mar 2008 19:49:51 -0400
Message-ID: <20080324234951.GA8712@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is today's round of fixes for 2.6.25.  Most of them are one-liners,
including a few typos, a couple of warning fixes, and a new USB ID for
rt73.  The only one of much size is a b43 fix relating to the hacks
used to overcome the limitations of its DMA hardware.  Overall, I don't
think there is anything controversial this time around.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 8f3ea33a5078a09eba12bfe57424507809367756:
  Martin Devera (1):
        sch_htb: fix "too many events" situation

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Al Viro (1):
      wavelan_cs arm fix

John W. Linville (1):
      arlan: fix warning when PROC_FS=n

Masakazu Mokuno (1):
      rt2x00: Add id for Corega CG-WLUSB2GPX

Michael Buesch (2):
      b43: Fix DMA mapping leakage
      b43: Remove irqs_disabled() sanity checks

Pascal Terjan (1):
      iwlwifi: fix a typo in Kconfig message

Reinette Chatre (2):
      MAINTAINERS: update iwlwifi git url
      iwlwifi: fix __devexit_p points to __devexit functions

Rick Farrington (1):
      iwlwifi: mac start synchronization issue

 MAINTAINERS                                 |    2 +-
 drivers/net/wireless/arlan-proc.c           |    8 ------
 drivers/net/wireless/b43/debugfs.c          |    4 +-
 drivers/net/wireless/b43/dma.c              |   32 ++++++++++++++++----------
 drivers/net/wireless/b43/main.c             |    2 -
 drivers/net/wireless/iwlwifi/Kconfig        |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    2 +
 drivers/net/wireless/wavelan_cs.h           |    2 +-
 10 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 76843d0..f148fa6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2110,7 +2110,7 @@ M:	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 L:	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
 W:	http://intellinuxwireless.org
-T:	git git://intellinuxwireless.org/repos/iwlwifi
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/rchatre/iwlwifi-2.6.git
 S:	Supported
 
 IOC3 ETHERNET DRIVER
diff --git a/drivers/net/wireless/arlan-proc.c b/drivers/net/wireless/arlan-proc.c
index c6e70db..2ab1d59 100644
--- a/drivers/net/wireless/arlan-proc.c
+++ b/drivers/net/wireless/arlan-proc.c
@@ -1202,13 +1202,6 @@ static ctl_table arlan_table[MAX_ARLANS + 1] =
 	{ .ctl_name = 0 }
 };
 #endif
-#else
-
-static ctl_table arlan_table[MAX_ARLANS + 1] =
-{
-	{ .ctl_name = 0 }
-};
-#endif
 
 
 // static int mmtu = 1234;
@@ -1233,7 +1226,6 @@ static ctl_table arlan_root_table[] =
 //};
 
 
-#ifdef CONFIG_PROC_FS
 static struct ctl_table_header *arlan_device_sysctl_header;
 
 int __init init_arlan_proc(void)
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index e38ed0f..7fca2eb 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -618,6 +618,7 @@ void b43_debugfs_remove_device(struct b43_wldev *dev)
 	kfree(e);
 }
 
+/* Called with IRQs disabled. */
 void b43_debugfs_log_txstat(struct b43_wldev *dev,
 			    const struct b43_txstatus *status)
 {
@@ -629,8 +630,7 @@ void b43_debugfs_log_txstat(struct b43_wldev *dev,
 	if (!e)
 		return;
 	log = &e->txstatlog;
-	B43_WARN_ON(!irqs_disabled());
-	spin_lock(&log->lock);
+	spin_lock(&log->lock); /* IRQs are already disabled. */
 	i = log->end + 1;
 	if (i == B43_NR_LOGGED_TXSTATUS)
 		i = 0;
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 3dfb28a..cfbc1a2 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -560,7 +560,7 @@ static int b43_dmacontroller_tx_reset(struct b43_wldev *dev, u16 mmio_base,
 /* Check if a DMA mapping address is invalid. */
 static bool b43_dma_mapping_error(struct b43_dmaring *ring,
 				  dma_addr_t addr,
-				  size_t buffersize)
+				  size_t buffersize, bool dma_to_device)
 {
 	if (unlikely(dma_mapping_error(addr)))
 		return 1;
@@ -568,11 +568,11 @@ static bool b43_dma_mapping_error(struct b43_dmaring *ring,
 	switch (ring->type) {
 	case B43_DMA_30BIT:
 		if ((u64)addr + buffersize > (1ULL << 30))
-			return 1;
+			goto address_error;
 		break;
 	case B43_DMA_32BIT:
 		if ((u64)addr + buffersize > (1ULL << 32))
-			return 1;
+			goto address_error;
 		break;
 	case B43_DMA_64BIT:
 		/* Currently we can't have addresses beyond
@@ -582,6 +582,12 @@ static bool b43_dma_mapping_error(struct b43_dmaring *ring,
 
 	/* The address is OK. */
 	return 0;
+
+address_error:
+	/* We can't support this address. Unmap it again. */
+	unmap_descbuffer(ring, addr, buffersize, dma_to_device);
+
+	return 1;
 }
 
 static int setup_rx_descbuffer(struct b43_dmaring *ring,
@@ -599,7 +605,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 	if (unlikely(!skb))
 		return -ENOMEM;
 	dmaaddr = map_descbuffer(ring, skb->data, ring->rx_buffersize, 0);
-	if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize)) {
+	if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
 		/* ugh. try to realloc in zone_dma */
 		gfp_flags |= GFP_DMA;
 
@@ -612,7 +618,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 					 ring->rx_buffersize, 0);
 	}
 
-	if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize)) {
+	if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
 		dev_kfree_skb_any(skb);
 		return -EIO;
 	}
@@ -852,7 +858,8 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 					  b43_txhdr_size(dev),
 					  DMA_TO_DEVICE);
 
-		if (b43_dma_mapping_error(ring, dma_test, b43_txhdr_size(dev))) {
+		if (b43_dma_mapping_error(ring, dma_test,
+					  b43_txhdr_size(dev), 1)) {
 			/* ugh realloc */
 			kfree(ring->txhdr_cache);
 			ring->txhdr_cache = kcalloc(nr_slots,
@@ -867,7 +874,7 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 						  DMA_TO_DEVICE);
 
 			if (b43_dma_mapping_error(ring, dma_test,
-						  b43_txhdr_size(dev)))
+						  b43_txhdr_size(dev), 1))
 				goto err_kfree_txhdr_cache;
 		}
 
@@ -1189,7 +1196,7 @@ static int dma_tx_fragment(struct b43_dmaring *ring,
 
 	meta_hdr->dmaaddr = map_descbuffer(ring, (unsigned char *)header,
 					   hdrsize, 1);
-	if (b43_dma_mapping_error(ring, meta_hdr->dmaaddr, hdrsize)) {
+	if (b43_dma_mapping_error(ring, meta_hdr->dmaaddr, hdrsize, 1)) {
 		ring->current_slot = old_top_slot;
 		ring->used_slots = old_used_slots;
 		return -EIO;
@@ -1208,7 +1215,7 @@ static int dma_tx_fragment(struct b43_dmaring *ring,
 
 	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 	/* create a bounce buffer in zone_dma on mapping failure. */
-	if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len)) {
+	if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
 		bounce_skb = __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb) {
 			ring->current_slot = old_top_slot;
@@ -1222,7 +1229,7 @@ static int dma_tx_fragment(struct b43_dmaring *ring,
 		skb = bounce_skb;
 		meta->skb = skb;
 		meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
-		if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len)) {
+		if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
 			ring->current_slot = old_top_slot;
 			ring->used_slots = old_used_slots;
 			err = -EIO;
@@ -1337,6 +1344,7 @@ out_unlock:
 	return err;
 }
 
+/* Called with IRQs disabled. */
 void b43_dma_handle_txstatus(struct b43_wldev *dev,
 			     const struct b43_txstatus *status)
 {
@@ -1349,8 +1357,8 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 	ring = parse_cookie(dev, status->cookie, &slot);
 	if (unlikely(!ring))
 		return;
-	B43_WARN_ON(!irqs_disabled());
-	spin_lock(&ring->lock);
+
+	spin_lock(&ring->lock); /* IRQs are already disabled. */
 
 	B43_WARN_ON(!ring->tx);
 	ops = ring->ops;
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 51dfce1..c73a75b 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2049,7 +2049,6 @@ void b43_mac_enable(struct b43_wldev *dev)
 {
 	dev->mac_suspended--;
 	B43_WARN_ON(dev->mac_suspended < 0);
-	B43_WARN_ON(irqs_disabled());
 	if (dev->mac_suspended == 0) {
 		b43_write32(dev, B43_MMIO_MACCTL,
 			    b43_read32(dev, B43_MMIO_MACCTL)
@@ -2075,7 +2074,6 @@ void b43_mac_suspend(struct b43_wldev *dev)
 	u32 tmp;
 
 	might_sleep();
-	B43_WARN_ON(irqs_disabled());
 	B43_WARN_ON(dev->mac_suspended < 0);
 
 	if (dev->mac_suspended == 0) {
diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iwlwifi/Kconfig
index d1af938..b79a35a 100644
--- a/drivers/net/wireless/iwlwifi/Kconfig
+++ b/drivers/net/wireless/iwlwifi/Kconfig
@@ -20,7 +20,7 @@ config IWL4965
 	  runs.
 
 	  If you want to compile the driver as a module ( = code which can be
-	  inserted in and remvoed from the running kernel whenever you want),
+	  inserted in and removed from the running kernel whenever you want),
 	  say M here and read <file:Documentation/kbuild/modules.txt>.  The
 	  module will be called iwl4965.ko.
 
@@ -101,7 +101,7 @@ config IWL3945
 	  runs.
 
 	  If you want to compile the driver as a module ( = code which can be
-	  inserted in and remvoed from the running kernel whenever you want),
+	  inserted in and removed from the running kernel whenever you want),
 	  say M here and read <file:Documentation/kbuild/modules.txt>.  The
 	  module will be called iwl3945.ko.
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 40b71bc..cbaeaf1 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6206,11 +6206,11 @@ static void iwl3945_alive_start(struct iwl3945_priv *priv)
 
 	/* At this point, the NIC is initialized and operational */
 	priv->notif_missed_beacons = 0;
-	set_bit(STATUS_READY, &priv->status);
 
 	iwl3945_reg_txpower_periodic(priv);
 
 	IWL_DEBUG_INFO("ALIVE processing complete.\n");
+	set_bit(STATUS_READY, &priv->status);
 	wake_up_interruptible(&priv->wait_command_queue);
 
 	if (priv->error_recovering)
@@ -8706,7 +8706,7 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	return err;
 }
 
-static void iwl3945_pci_remove(struct pci_dev *pdev)
+static void __devexit iwl3945_pci_remove(struct pci_dev *pdev)
 {
 	struct iwl3945_priv *priv = pci_get_drvdata(pdev);
 	struct list_head *p, *q;
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index a23d479..60ec29e 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -6628,11 +6628,11 @@ static void iwl4965_alive_start(struct iwl4965_priv *priv)
 
 	/* At this point, the NIC is initialized and operational */
 	priv->notif_missed_beacons = 0;
-	set_bit(STATUS_READY, &priv->status);
 
 	iwl4965_rf_kill_ct_config(priv);
 
 	IWL_DEBUG_INFO("ALIVE processing complete.\n");
+	set_bit(STATUS_READY, &priv->status);
 	wake_up_interruptible(&priv->wait_command_queue);
 
 	if (priv->error_recovering)
@@ -9282,7 +9282,7 @@ static int iwl4965_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	return err;
 }
 
-static void iwl4965_pci_remove(struct pci_dev *pdev)
+static void __devexit iwl4965_pci_remove(struct pci_dev *pdev)
 {
 	struct iwl4965_priv *priv = pci_get_drvdata(pdev);
 	struct list_head *p, *q;
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 8103d41..3909cf4 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2095,6 +2095,8 @@ static struct usb_device_id rt73usb_device_table[] = {
 	{ USB_DEVICE(0x1371, 0x9032), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Conceptronic */
 	{ USB_DEVICE(0x14b2, 0x3c22), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* Corega */
+	{ USB_DEVICE(0x07aa, 0x002e), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* D-Link */
 	{ USB_DEVICE(0x07d1, 0x3c03), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x07d1, 0x3c04), USB_DEVICE_DATA(&rt73usb_ops) },
diff --git a/drivers/net/wireless/wavelan_cs.h b/drivers/net/wireless/wavelan_cs.h
index fabc63e..2e4bfe4 100644
--- a/drivers/net/wireless/wavelan_cs.h
+++ b/drivers/net/wireless/wavelan_cs.h
@@ -309,7 +309,7 @@ struct mmw_t
 #define	MMW_EXT_ANT_INTERNAL	0x00	/* Internal antenna */
 #define	MMW_EXT_ANT_EXTERNAL	0x03	/* External antenna */
 #define	MMW_EXT_ANT_IQ_TEST	0x1C	/* IQ test pattern (set to 0) */
-};
+} __attribute__((packed));
 
 /* Size for structure checking (if padding is correct) */
 #define	MMW_SIZE	37
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
