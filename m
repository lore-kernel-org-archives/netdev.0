From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-03-06
Date: Fri, 6 Mar 2009 16:24:14 -0500
Message-ID: <20090306212414.GG3712@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34188 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbZCFVa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 16:30:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are a few small patches intended for 2.6.29.

Two of them add USB IDs to the Ralink drivers.  Some of those IDs are
already in -next, so there will be some minor conflicts.

The one from Roel Kluin avoids checking for <0 on an unsigned variable.
It seems like a very low-risk fix to a potentially hard to find
problem, so it seems worthwhile to me.

The iwlwifi fix corrects some problems with cleaning-up after
initialization errors, avoiding some potential resources leaks.

The p54 patch corrects a crash that was unveiled by applying a patch
headed to -next.  The problem was their all along, so it seems work
taking now.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 72e2240f181871675d3a979766330c91d48a1673:
  Patrick McHardy (1):
        bonding: Fix device passed into ->ndo_neigh_setup().

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      p54: fix race condition in memory management

Reinette Chatre (1):
      iwlwifi: fix error flow in iwl*_pci_probe

Roel Kluin (1):
      cfg80211: test before subtraction on unsigned

Xose Vazquez Perez (2):
      rt2x00 : more devices to rt2500usb.c
      rt2x00 : more devices to rt73usb.c

 drivers/net/wireless/iwlwifi/iwl-agn.c      |    6 +++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   17 ++++++--------
 drivers/net/wireless/p54/p54common.c        |    9 +++++--
 drivers/net/wireless/rt2x00/rt2500usb.c     |    8 ++++++
 drivers/net/wireless/rt2x00/rt73usb.c       |   32 ++++++++++++++++++++++++++-
 net/wireless/reg.c                          |    3 +-
 6 files changed, 58 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 36bafeb..129e2d3 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3868,7 +3868,7 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	err = iwl_eeprom_check_version(priv);
 	if (err)
-		goto out_iounmap;
+		goto out_free_eeprom;
 
 	/* extract MAC Address */
 	iwl_eeprom_get_mac(priv, priv->mac_addr);
@@ -3945,6 +3945,8 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
  out_remove_sysfs:
+	destroy_workqueue(priv->workqueue);
+	priv->workqueue = NULL;
 	sysfs_remove_group(&pdev->dev.kobj, &iwl_attribute_group);
  out_uninit_drv:
 	iwl_uninit_drv(priv);
@@ -3953,8 +3955,8 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
  out_iounmap:
 	pci_iounmap(pdev, priv->hw_base);
  out_pci_release_regions:
-	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
+	pci_release_regions(pdev);
  out_pci_disable_device:
 	pci_disable_device(pdev);
  out_ieee80211_free_hw:
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 93be74a..57dd34e 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -7911,7 +7911,7 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 				CSR_GP_CNTRL_REG_FLAG_MAC_CLOCK_READY, 25000);
 	if (err < 0) {
 		IWL_DEBUG_INFO("Failed to init the card\n");
-		goto out_remove_sysfs;
+		goto out_iounmap;
 	}
 
 	/***********************
@@ -7921,7 +7921,7 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	err = iwl3945_eeprom_init(priv);
 	if (err) {
 		IWL_ERROR("Unable to init EEPROM\n");
-		goto out_remove_sysfs;
+		goto out_iounmap;
 	}
 	/* MAC Address location in EEPROM same for 3945/4965 */
 	get_eeprom_mac(priv, priv->mac_addr);
@@ -7975,7 +7975,7 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	err = iwl3945_init_channel_map(priv);
 	if (err) {
 		IWL_ERROR("initializing regulatory failed: %d\n", err);
-		goto out_release_irq;
+		goto out_unset_hw_setting;
 	}
 
 	err = iwl3945_init_geos(priv);
@@ -8045,25 +8045,22 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	return 0;
 
  out_remove_sysfs:
+	destroy_workqueue(priv->workqueue);
+	priv->workqueue = NULL;
 	sysfs_remove_group(&pdev->dev.kobj, &iwl3945_attribute_group);
  out_free_geos:
 	iwl3945_free_geos(priv);
  out_free_channel_map:
 	iwl3945_free_channel_map(priv);
-
-
- out_release_irq:
-	destroy_workqueue(priv->workqueue);
-	priv->workqueue = NULL;
+ out_unset_hw_setting:
 	iwl3945_unset_hw_setting(priv);
-
  out_iounmap:
 	pci_iounmap(pdev, priv->hw_base);
  out_pci_release_regions:
 	pci_release_regions(pdev);
  out_pci_disable_device:
-	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
+	pci_disable_device(pdev);
  out_ieee80211_free_hw:
 	ieee80211_free_hw(priv->hw);
  out:
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index 34561e6..f170106 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -710,10 +710,11 @@ static struct sk_buff *p54_find_tx_entry(struct ieee80211_hw *dev,
 					   __le32 req_id)
 {
 	struct p54_common *priv = dev->priv;
-	struct sk_buff *entry = priv->tx_queue.next;
+	struct sk_buff *entry;
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
+	entry = priv->tx_queue.next;
 	while (entry != (struct sk_buff *)&priv->tx_queue) {
 		struct p54_hdr *hdr = (struct p54_hdr *) entry->data;
 
@@ -732,7 +733,7 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 	struct p54_common *priv = dev->priv;
 	struct p54_hdr *hdr = (struct p54_hdr *) skb->data;
 	struct p54_frame_sent *payload = (struct p54_frame_sent *) hdr->data;
-	struct sk_buff *entry = (struct sk_buff *) priv->tx_queue.next;
+	struct sk_buff *entry;
 	u32 addr = le32_to_cpu(hdr->req_id) - priv->headroom;
 	struct memrecord *range = NULL;
 	u32 freed = 0;
@@ -741,6 +742,7 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 	int count, idx;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
+	entry = (struct sk_buff *) priv->tx_queue.next;
 	while (entry != (struct sk_buff *)&priv->tx_queue) {
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(entry);
 		struct p54_hdr *entry_hdr;
@@ -976,7 +978,7 @@ static int p54_assign_address(struct ieee80211_hw *dev, struct sk_buff *skb,
 			       struct p54_hdr *data, u32 len)
 {
 	struct p54_common *priv = dev->priv;
-	struct sk_buff *entry = priv->tx_queue.next;
+	struct sk_buff *entry;
 	struct sk_buff *target_skb = NULL;
 	struct ieee80211_tx_info *info;
 	struct memrecord *range;
@@ -1014,6 +1016,7 @@ static int p54_assign_address(struct ieee80211_hw *dev, struct sk_buff *skb,
 		}
 	}
 
+	entry = priv->tx_queue.next;
 	while (left--) {
 		u32 hole_size;
 		info = IEEE80211_SKB_CB(entry);
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index af6b584..3e2ac2b 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1952,6 +1952,8 @@ static struct usb_device_id rt2500usb_device_table[] = {
 	{ USB_DEVICE(0x13b1, 0x000d), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x13b1, 0x0011), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x13b1, 0x001a), USB_DEVICE_DATA(&rt2500usb_ops) },
+	/* CNet */
+	{ USB_DEVICE(0x1371, 0x9022), USB_DEVICE_DATA(&rt2500usb_ops) },
 	/* Conceptronic */
 	{ USB_DEVICE(0x14b2, 0x3c02), USB_DEVICE_DATA(&rt2500usb_ops) },
 	/* D-LINK */
@@ -1976,14 +1978,20 @@ static struct usb_device_id rt2500usb_device_table[] = {
 	{ USB_DEVICE(0x148f, 0x2570), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x148f, 0x2573), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x148f, 0x9020), USB_DEVICE_DATA(&rt2500usb_ops) },
+	/* Sagem */
+	{ USB_DEVICE(0x079b, 0x004b), USB_DEVICE_DATA(&rt2500usb_ops) },
 	/* Siemens */
 	{ USB_DEVICE(0x0681, 0x3c06), USB_DEVICE_DATA(&rt2500usb_ops) },
 	/* SMC */
 	{ USB_DEVICE(0x0707, 0xee13), USB_DEVICE_DATA(&rt2500usb_ops) },
 	/* Spairon */
 	{ USB_DEVICE(0x114b, 0x0110), USB_DEVICE_DATA(&rt2500usb_ops) },
+	/* SURECOM */
+	{ USB_DEVICE(0x0769, 0x11f3), USB_DEVICE_DATA(&rt2500usb_ops) },
 	/* Trust */
 	{ USB_DEVICE(0x0eb0, 0x9020), USB_DEVICE_DATA(&rt2500usb_ops) },
+	/* VTech */
+	{ USB_DEVICE(0x0f88, 0x3012), USB_DEVICE_DATA(&rt2500usb_ops) },
 	/* Zinwell */
 	{ USB_DEVICE(0x5a57, 0x0260), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ 0, }
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 96a8d69..cefee1b 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2281,7 +2281,18 @@ static const struct rt2x00_ops rt73usb_ops = {
  */
 static struct usb_device_id rt73usb_device_table[] = {
 	/* AboCom */
+	{ USB_DEVICE(0x07b8, 0xb21b), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x07b8, 0xb21c), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x07b8, 0xb21d), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x07b8, 0xb21e), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x07b8, 0xb21f), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* AL */
+	{ USB_DEVICE(0x14b2, 0x3c10), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* Amigo */
+	{ USB_DEVICE(0x148f, 0x9021), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x0eb0, 0x9021), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* AMIT  */
+	{ USB_DEVICE(0x18c5, 0x0002), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Askey */
 	{ USB_DEVICE(0x1690, 0x0722), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* ASUS */
@@ -2294,7 +2305,9 @@ static struct usb_device_id rt73usb_device_table[] = {
 	{ USB_DEVICE(0x050d, 0x905c), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Billionton */
 	{ USB_DEVICE(0x1631, 0xc019), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x08dd, 0x0120), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Buffalo */
+	{ USB_DEVICE(0x0411, 0x00d8), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0411, 0x00f4), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* CNet */
 	{ USB_DEVICE(0x1371, 0x9022), USB_DEVICE_DATA(&rt73usb_ops) },
@@ -2308,6 +2321,11 @@ static struct usb_device_id rt73usb_device_table[] = {
 	{ USB_DEVICE(0x07d1, 0x3c04), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x07d1, 0x3c06), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x07d1, 0x3c07), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* Edimax */
+	{ USB_DEVICE(0x7392, 0x7318), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x7392, 0x7618), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* EnGenius */
+	{ USB_DEVICE(0x1740, 0x3701), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Gemtek */
 	{ USB_DEVICE(0x15a9, 0x0004), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Gigabyte */
@@ -2328,22 +2346,34 @@ static struct usb_device_id rt73usb_device_table[] = {
 	{ USB_DEVICE(0x0db0, 0xa861), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0db0, 0xa874), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Ralink */
+	{ USB_DEVICE(0x04bb, 0x093d), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x148f, 0x2573), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x148f, 0x2671), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Qcom */
 	{ USB_DEVICE(0x18e8, 0x6196), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x18e8, 0x6229), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x18e8, 0x6238), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* Samsung */
+	{ USB_DEVICE(0x04e8, 0x4471), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Senao */
 	{ USB_DEVICE(0x1740, 0x7100), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Sitecom */
-	{ USB_DEVICE(0x0df6, 0x9712), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x0df6, 0x0024), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x0df6, 0x0027), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x0df6, 0x002f), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0df6, 0x90ac), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x0df6, 0x9712), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Surecom */
 	{ USB_DEVICE(0x0769, 0x31f3), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* Philips */
+	{ USB_DEVICE(0x0471, 0x200a), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Planex */
 	{ USB_DEVICE(0x2019, 0xab01), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x2019, 0xab50), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* Zcom */
+	{ USB_DEVICE(0x0cde, 0x001c), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* ZyXEL */
+	{ USB_DEVICE(0x0586, 0x3415), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ 0, }
 };
 
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 85c9034..bd0a16c 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -380,7 +380,8 @@ static bool is_valid_reg_rule(const struct ieee80211_reg_rule *rule)
 
 	freq_diff = freq_range->end_freq_khz - freq_range->start_freq_khz;
 
-	if (freq_diff <= 0 || freq_range->max_bandwidth_khz > freq_diff)
+	if (freq_range->end_freq_khz <= freq_range->start_freq_khz ||
+			freq_range->max_bandwidth_khz > freq_diff)
 		return false;
 
 	return true;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
