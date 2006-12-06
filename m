From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 5 Dec 2006 20:42:32 -0500
Message-ID: <20061206014227.GA9830@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3638 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759666AbWLFCLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 21:11:41 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit e62438630ca37539c8cc1553710bbfaa3cf960a7:
  Matthew Wilcox:
        Centralise definitions of sector_t and blkcnt_t

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Daniel Drake:
      zd1211rw: zd_mac_rx isn't always called in IRQ context
      zd1211rw: Fill enc_capa in GIWRANGE handler

Maxime Austruy:
      softmac: fix unbalanced mutex_lock/unlock in ieee80211softmac_wx_set_mlme

Ulrich Kunitz:
      zd1211rw: Support for multicast addresses
      softmac: Fixed handling of deassociation from AP

Yan Burman:
      hostap: replace kmalloc+memset with kzalloc
      prism54: replace kmalloc+memset with kzalloc
      ipw2200: replace kmalloc+memset with kcalloc

Zhu Yi:
      ipw2200: Add IEEE80211_RADIOTAP_TSFT for promiscuous mode
      ipw2200: Update version stamp to 1.2.0
      ipw2200: Fix a typo
      ipw2200: Fix debug output endian issue

 drivers/net/wireless/hostap/hostap_ap.c        |    4 --
 drivers/net/wireless/hostap/hostap_cs.c        |    3 -
 drivers/net/wireless/hostap/hostap_download.c  |    4 --
 drivers/net/wireless/hostap/hostap_hw.c        |   12 +----
 drivers/net/wireless/hostap/hostap_info.c      |    3 -
 drivers/net/wireless/hostap/hostap_ioctl.c     |   12 +----
 drivers/net/wireless/hostap/hostap_pci.c       |    3 -
 drivers/net/wireless/hostap/hostap_plx.c       |    3 -
 drivers/net/wireless/ipw2100.c                 |    2 -
 drivers/net/wireless/ipw2200.c                 |   24 +++++++----
 drivers/net/wireless/prism54/isl_ioctl.c       |    9 +---
 drivers/net/wireless/prism54/oid_mgt.c         |    4 --
 drivers/net/wireless/zd1211rw/zd_chip.c        |   13 ++++++
 drivers/net/wireless/zd1211rw/zd_chip.h        |   43 +++++++++++++++++++
 drivers/net/wireless/zd1211rw/zd_mac.c         |   53 ++++++++++++++++++++++--
 drivers/net/wireless/zd1211rw/zd_mac.h         |    3 +
 drivers/net/wireless/zd1211rw/zd_netdev.c      |    2 -
 net/ieee80211/softmac/ieee80211softmac_assoc.c |   14 +++++-
 net/ieee80211/softmac/ieee80211softmac_auth.c  |    2 +
 net/ieee80211/softmac/ieee80211softmac_priv.h  |    2 +
 net/ieee80211/softmac/ieee80211softmac_wx.c    |    3 +
 21 files changed, 158 insertions(+), 60 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index ba13125..798a855 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -1099,15 +1099,13 @@ static struct sta_info * ap_add_sta(stru
 {
 	struct sta_info *sta;
 
-	sta = (struct sta_info *)
-		kmalloc(sizeof(struct sta_info), GFP_ATOMIC);
+	sta = kzalloc(sizeof(struct sta_info), GFP_ATOMIC);
 	if (sta == NULL) {
 		PDEBUG(DEBUG_AP, "AP: kmalloc failed\n");
 		return NULL;
 	}
 
 	/* initialize STA info data */
-	memset(sta, 0, sizeof(struct sta_info));
 	sta->local = ap->local;
 	skb_queue_head_init(&sta->tx_buf);
 	memcpy(sta->addr, addr, ETH_ALEN);
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index f63909e..ef470e6 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -566,12 +566,11 @@ static int prism2_config(struct pcmcia_d
 	PDEBUG(DEBUG_FLOW, "prism2_config()\n");
 
 	parse = kmalloc(sizeof(cisparse_t), GFP_KERNEL);
-	hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
+	hw_priv = kzalloc(sizeof(*hw_priv), GFP_KERNEL);
 	if (parse == NULL || hw_priv == NULL) {
 		ret = -ENOMEM;
 		goto failed;
 	}
-	memset(hw_priv, 0, sizeof(*hw_priv));
 
 	tuple.DesiredTuple = CISTPL_CONFIG;
 	tuple.Attributes = 0;
diff --git a/drivers/net/wireless/hostap/hostap_download.c b/drivers/net/wireless/hostap/hostap_download.c
index ab26b52..24fc387 100644
--- a/drivers/net/wireless/hostap/hostap_download.c
+++ b/drivers/net/wireless/hostap/hostap_download.c
@@ -685,14 +685,12 @@ static int prism2_download(local_info_t 
 		goto out;
 	}
 
-	dl = kmalloc(sizeof(*dl) + param->num_areas *
+	dl = kzalloc(sizeof(*dl) + param->num_areas *
 		     sizeof(struct prism2_download_data_area), GFP_KERNEL);
 	if (dl == NULL) {
 		ret = -ENOMEM;
 		goto out;
 	}
-	memset(dl, 0, sizeof(*dl) + param->num_areas *
-	       sizeof(struct prism2_download_data_area));
 	dl->dl_cmd = param->dl_cmd;
 	dl->start_addr = param->start_addr;
 	dl->num_areas = param->num_areas;
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index ed00ebb..9c50336 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -347,14 +347,12 @@ static int hfa384x_cmd(struct net_device
 	if (signal_pending(current))
 		return -EINTR;
 
-	entry = (struct hostap_cmd_queue *)
-		kmalloc(sizeof(*entry), GFP_ATOMIC);
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL) {
 		printk(KERN_DEBUG "%s: hfa384x_cmd - kmalloc failed\n",
 		       dev->name);
 		return -ENOMEM;
 	}
-	memset(entry, 0, sizeof(*entry));
 	atomic_set(&entry->usecnt, 1);
 	entry->type = CMD_SLEEP;
 	entry->cmd = cmd;
@@ -517,14 +515,12 @@ static int hfa384x_cmd_callback(struct n
 		return -1;
 	}
 
-	entry = (struct hostap_cmd_queue *)
-		kmalloc(sizeof(*entry), GFP_ATOMIC);
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL) {
 		printk(KERN_DEBUG "%s: hfa384x_cmd_callback - kmalloc "
 		       "failed\n", dev->name);
 		return -ENOMEM;
 	}
-	memset(entry, 0, sizeof(*entry));
 	atomic_set(&entry->usecnt, 1);
 	entry->type = CMD_CALLBACK;
 	entry->cmd = cmd;
@@ -3015,14 +3011,12 @@ static int prism2_set_tim(struct net_dev
 	iface = netdev_priv(dev);
 	local = iface->local;
 
-	new_entry = (struct set_tim_data *)
-		kmalloc(sizeof(*new_entry), GFP_ATOMIC);
+	new_entry = kzalloc(sizeof(*new_entry), GFP_ATOMIC);
 	if (new_entry == NULL) {
 		printk(KERN_DEBUG "%s: prism2_set_tim: kmalloc failed\n",
 		       local->dev->name);
 		return -ENOMEM;
 	}
-	memset(new_entry, 0, sizeof(*new_entry));
 	new_entry->aid = aid;
 	new_entry->set = set;
 
diff --git a/drivers/net/wireless/hostap/hostap_info.c b/drivers/net/wireless/hostap/hostap_info.c
index 50f72d8..00ed638 100644
--- a/drivers/net/wireless/hostap/hostap_info.c
+++ b/drivers/net/wireless/hostap/hostap_info.c
@@ -327,11 +327,10 @@ static void prism2_info_hostscanresults(
 	ptr = (u8 *) pos;
 
 	new_count = left / result_size;
-	results = kmalloc(new_count * sizeof(struct hfa384x_hostscan_result),
+	results = kcalloc(new_count, sizeof(struct hfa384x_hostscan_result),
 			  GFP_ATOMIC);
 	if (results == NULL)
 		return;
-	memset(results, 0, new_count * sizeof(struct hfa384x_hostscan_result));
 
 	for (i = 0; i < new_count; i++) {
 		memcpy(&results[i], ptr, copy_len);
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index d061fb3..3b7b806 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -181,12 +181,10 @@ static int prism2_ioctl_siwencode(struct
 		struct ieee80211_crypt_data *new_crypt;
 
 		/* take WEP into use */
-		new_crypt = (struct ieee80211_crypt_data *)
-			kmalloc(sizeof(struct ieee80211_crypt_data),
+		new_crypt = kzalloc(sizeof(struct ieee80211_crypt_data),
 				GFP_KERNEL);
 		if (new_crypt == NULL)
 			return -ENOMEM;
-		memset(new_crypt, 0, sizeof(struct ieee80211_crypt_data));
 		new_crypt->ops = ieee80211_get_crypto_ops("WEP");
 		if (!new_crypt->ops) {
 			request_module("ieee80211_crypt_wep");
@@ -3320,14 +3318,12 @@ static int prism2_ioctl_siwencodeext(str
 
 		prism2_crypt_delayed_deinit(local, crypt);
 
-		new_crypt = (struct ieee80211_crypt_data *)
-			kmalloc(sizeof(struct ieee80211_crypt_data),
+		new_crypt = kzalloc(sizeof(struct ieee80211_crypt_data),
 				GFP_KERNEL);
 		if (new_crypt == NULL) {
 			ret = -ENOMEM;
 			goto done;
 		}
-		memset(new_crypt, 0, sizeof(struct ieee80211_crypt_data));
 		new_crypt->ops = ops;
 		new_crypt->priv = new_crypt->ops->init(i);
 		if (new_crypt->priv == NULL) {
@@ -3538,14 +3534,12 @@ static int prism2_ioctl_set_encryption(l
 
 		prism2_crypt_delayed_deinit(local, crypt);
 
-		new_crypt = (struct ieee80211_crypt_data *)
-			kmalloc(sizeof(struct ieee80211_crypt_data),
+		new_crypt = kzalloc(sizeof(struct ieee80211_crypt_data),
 				GFP_KERNEL);
 		if (new_crypt == NULL) {
 			ret = -ENOMEM;
 			goto done;
 		}
-		memset(new_crypt, 0, sizeof(struct ieee80211_crypt_data));
 		new_crypt->ops = ops;
 		new_crypt->priv = new_crypt->ops->init(param->u.crypt.idx);
 		if (new_crypt->priv == NULL) {
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index d1de976..c4f6020 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -300,10 +300,9 @@ static int prism2_pci_probe(struct pci_d
 	struct hostap_interface *iface;
 	struct hostap_pci_priv *hw_priv;
 
-	hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
+	hw_priv = kzalloc(sizeof(*hw_priv), GFP_KERNEL);
 	if (hw_priv == NULL)
 		return -ENOMEM;
-	memset(hw_priv, 0, sizeof(*hw_priv));
 
 	if (pci_enable_device(pdev))
 		goto err_out_free;
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index bc81b13..e235e06 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -447,10 +447,9 @@ static int prism2_plx_probe(struct pci_d
 	int tmd7160;
 	struct hostap_plx_priv *hw_priv;
 
-	hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
+	hw_priv = kzalloc(sizeof(*hw_priv), GFP_KERNEL);
 	if (hw_priv == NULL)
 		return -ENOMEM;
-	memset(hw_priv, 0, sizeof(*hw_priv));
 
 	if (pci_enable_device(pdev))
 		goto err_out_free;
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 79607b8..060018e 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6215,7 +6215,7 @@ static int ipw2100_pci_init_one(struct p
 	/* Allocate and initialize the Tx/Rx queues and lists */
 	if (ipw2100_queues_allocate(priv)) {
 		printk(KERN_WARNING DRV_NAME
-		       "Error calilng ipw2100_queues_allocate.\n");
+		       "Error calling ipw2100_queues_allocate.\n");
 		err = -ENOMEM;
 		goto fail;
 	}
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index c692d01..d29f427 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -70,7 +70,7 @@ #else
 #define VQ
 #endif
 
-#define IPW2200_VERSION "1.1.4" VK VD VM VP VR VQ
+#define IPW2200_VERSION "1.2.0" VK VD VM VP VR VQ
 #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2200/2915 Network Driver"
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
 #define DRV_VERSION     IPW2200_VERSION
@@ -7656,7 +7656,8 @@ static void ipw_handle_data_packet_monit
 
 	/* Big bitfield of all the fields we provide in radiotap */
 	ipw_rt->rt_hdr.it_present =
-	    ((1 << IEEE80211_RADIOTAP_FLAGS) |
+	    ((1 << IEEE80211_RADIOTAP_TSFT) |
+	     (1 << IEEE80211_RADIOTAP_FLAGS) |
 	     (1 << IEEE80211_RADIOTAP_RATE) |
 	     (1 << IEEE80211_RADIOTAP_CHANNEL) |
 	     (1 << IEEE80211_RADIOTAP_DBM_ANTSIGNAL) |
@@ -7665,10 +7666,14 @@ static void ipw_handle_data_packet_monit
 
 	/* Zero the flags, we'll add to them as we go */
 	ipw_rt->rt_flags = 0;
-	ipw_rt->rt_tsf = 0ULL;
+	ipw_rt->rt_tsf = (u64)(frame->parent_tsf[3] << 24 |
+			       frame->parent_tsf[2] << 16 |
+			       frame->parent_tsf[1] << 8  |
+			       frame->parent_tsf[0]);
 
 	/* Convert signal to DBM */
 	ipw_rt->rt_dbmsignal = antsignal;
+	ipw_rt->rt_dbmnoise = frame->noise;
 
 	/* Convert the channel data and set the flags */
 	ipw_rt->rt_channel = cpu_to_le16(ieee80211chan2mhz(received_channel));
@@ -7868,7 +7873,8 @@ static void ipw_handle_promiscuous_rx(st
 
 	/* Big bitfield of all the fields we provide in radiotap */
 	ipw_rt->rt_hdr.it_present =
-	    ((1 << IEEE80211_RADIOTAP_FLAGS) |
+	    ((1 << IEEE80211_RADIOTAP_TSFT) |
+	     (1 << IEEE80211_RADIOTAP_FLAGS) |
 	     (1 << IEEE80211_RADIOTAP_RATE) |
 	     (1 << IEEE80211_RADIOTAP_CHANNEL) |
 	     (1 << IEEE80211_RADIOTAP_DBM_ANTSIGNAL) |
@@ -7877,7 +7883,10 @@ static void ipw_handle_promiscuous_rx(st
 
 	/* Zero the flags, we'll add to them as we go */
 	ipw_rt->rt_flags = 0;
-	ipw_rt->rt_tsf = 0ULL;
+	ipw_rt->rt_tsf = (u64)(frame->parent_tsf[3] << 24 |
+			       frame->parent_tsf[2] << 16 |
+			       frame->parent_tsf[1] << 8  |
+			       frame->parent_tsf[0]);
 
 	/* Convert to DBM */
 	ipw_rt->rt_dbmsignal = signal;
@@ -8276,7 +8285,7 @@ #endif
 				    ("Notification: subtype=%02X flags=%02X size=%d\n",
 				     pkt->u.notification.subtype,
 				     pkt->u.notification.flags,
-				     pkt->u.notification.size);
+				     le16_to_cpu(pkt->u.notification.size));
 				ipw_rx_notification(priv, &pkt->u.notification);
 				break;
 			}
@@ -11129,14 +11138,13 @@ static int ipw_up(struct ipw_priv *priv)
 		return -EIO;
 
 	if (cmdlog && !priv->cmdlog) {
-		priv->cmdlog = kmalloc(sizeof(*priv->cmdlog) * cmdlog,
+		priv->cmdlog = kcalloc(cmdlog, sizeof(*priv->cmdlog),
 				       GFP_KERNEL);
 		if (priv->cmdlog == NULL) {
 			IPW_ERROR("Error allocating %d command log entries.\n",
 				  cmdlog);
 			return -ENOMEM;
 		} else {
-			memset(priv->cmdlog, 0, sizeof(*priv->cmdlog) * cmdlog);
 			priv->cmdlog_len = cmdlog;
 		}
 	}
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 4a20e45..a48edd1 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -2140,11 +2140,9 @@ prism54_wpa_bss_ie_add(islpci_private *p
 					 struct islpci_bss_wpa_ie, list);
 			list_del(&bss->list);
 		} else {
-			bss = kmalloc(sizeof (*bss), GFP_ATOMIC);
-			if (bss != NULL) {
+			bss = kzalloc(sizeof (*bss), GFP_ATOMIC);
+			if (bss != NULL)
 				priv->num_bss_wpa++;
-				memset(bss, 0, sizeof (*bss));
-			}
 		}
 		if (bss != NULL) {
 			memcpy(bss->bssid, bssid, ETH_ALEN);
@@ -2684,11 +2682,10 @@ prism2_ioctl_set_generic_element(struct 
                return -EINVAL;
 
        alen = sizeof(*attach) + len;
-       attach = kmalloc(alen, GFP_KERNEL);
+       attach = kzalloc(alen, GFP_KERNEL);
        if (attach == NULL)
                return -ENOMEM;
 
-       memset(attach, 0, alen);
 #define WLAN_FC_TYPE_MGMT 0
 #define WLAN_FC_STYPE_ASSOC_REQ 0
 #define WLAN_FC_STYPE_REASSOC_REQ 2
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
index fbc52b6..e6cf9df 100644
--- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -235,12 +235,10 @@ mgt_init(islpci_private *priv)
 {
 	int i;
 
-	priv->mib = kmalloc(OID_NUM_LAST * sizeof (void *), GFP_KERNEL);
+	priv->mib = kcalloc(OID_NUM_LAST, sizeof (void *), GFP_KERNEL);
 	if (!priv->mib)
 		return -ENOMEM;
 
-	memset(priv->mib, 0, OID_NUM_LAST * sizeof (void *));
-
 	/* Alloc the cache */
 	for (i = 0; i < OID_NUM_LAST; i++) {
 		if (isl_oid[i].flags & OID_FLAG_CACHED) {
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 8be99eb..77e11dd 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1673,3 +1673,16 @@ int zd_rfwritev_cr_locked(struct zd_chip
 
 	return 0;
 }
+
+int zd_chip_set_multicast_hash(struct zd_chip *chip,
+	                       struct zd_mc_hash *hash)
+{
+	struct zd_ioreq32 ioreqs[] = {
+		{ CR_GROUP_HASH_P1, hash->low },
+		{ CR_GROUP_HASH_P2, hash->high },
+	};
+
+	dev_dbg_f(zd_chip_dev(chip), "hash l 0x%08x h 0x%08x\n",
+		ioreqs[0].value, ioreqs[1].value);
+	return zd_iowrite32a(chip, ioreqs, ARRAY_SIZE(ioreqs));
+}
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index ca892b9..a4e3cee 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -390,10 +390,19 @@ #define CR_MAC_ADDR_P2			CTL_REG(0x0614)
 #define CR_BSSID_P1			CTL_REG(0x0618)
 #define CR_BSSID_P2			CTL_REG(0x061C)
 #define CR_BCN_PLCP_CFG			CTL_REG(0x0620)
+
+/* Group hash table for filtering incoming packets.
+ *
+ * The group hash table is 64 bit large and split over two parts. The first
+ * part is the lower part. The upper 6 bits of the last byte of the target
+ * address are used as index. Packets are received if the hash table bit is
+ * set. This is used for multicast handling, but for broadcasts (address
+ * ff:ff:ff:ff:ff:ff) the highest bit in the second table must also be set.
+ */
 #define CR_GROUP_HASH_P1		CTL_REG(0x0624)
 #define CR_GROUP_HASH_P2		CTL_REG(0x0628)
-#define CR_RX_TIMEOUT			CTL_REG(0x062C)
 
+#define CR_RX_TIMEOUT			CTL_REG(0x062C)
 /* Basic rates supported by the BSS. When producing ACK or CTS messages, the
  * device will use a rate in this table that is less than or equal to the rate
  * of the incoming frame which prompted the response */
@@ -864,4 +873,36 @@ u8 zd_rx_strength_percent(u8 rssi);
 
 u16 zd_rx_rate(const void *rx_frame, const struct rx_status *status);
 
+struct zd_mc_hash {
+	u32 low;
+	u32 high;
+};
+
+static inline void zd_mc_clear(struct zd_mc_hash *hash)
+{
+	hash->low = 0;
+	/* The interfaces must always received broadcasts.
+	 * The hash of the broadcast address ff:ff:ff:ff:ff:ff is 63.
+	 */
+	hash->high = 0x80000000;
+}
+
+static inline void zd_mc_add_all(struct zd_mc_hash *hash)
+{
+	hash->low = hash->high = 0xffffffff;
+}
+
+static inline void zd_mc_add_addr(struct zd_mc_hash *hash, u8 *addr)
+{
+	unsigned int i = addr[5] >> 2;
+	if (i < 32) {
+		hash->low |= 1 << i;
+	} else {
+		hash->high |= 1 << (i-32);
+	}
+}
+
+int zd_chip_set_multicast_hash(struct zd_chip *chip,
+	                       struct zd_mc_hash *hash);
+
 #endif /* _ZD_CHIP_H */
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 2696f95..1dd3f76 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -39,6 +39,8 @@ static void housekeeping_init(struct zd_
 static void housekeeping_enable(struct zd_mac *mac);
 static void housekeeping_disable(struct zd_mac *mac);
 
+static void set_multicast_hash_handler(void *mac_ptr);
+
 int zd_mac_init(struct zd_mac *mac,
 	        struct net_device *netdev,
 	        struct usb_interface *intf)
@@ -55,6 +57,8 @@ int zd_mac_init(struct zd_mac *mac,
 	softmac_init(ieee80211_priv(netdev));
 	zd_chip_init(&mac->chip, netdev, intf);
 	housekeeping_init(mac);
+	INIT_WORK(&mac->set_multicast_hash_work, set_multicast_hash_handler,
+		  mac);
 	return 0;
 }
 
@@ -136,6 +140,7 @@ out:
 
 void zd_mac_clear(struct zd_mac *mac)
 {
+	flush_workqueue(zd_workqueue);
 	zd_chip_clear(&mac->chip);
 	ZD_ASSERT(!spin_is_locked(&mac->lock));
 	ZD_MEMCLEAR(mac, sizeof(struct zd_mac));
@@ -256,6 +261,42 @@ int zd_mac_set_mac_address(struct net_de
 	return 0;
 }
 
+static void set_multicast_hash_handler(void *mac_ptr)
+{
+	struct zd_mac *mac = mac_ptr;
+	struct zd_mc_hash hash;
+
+	spin_lock_irq(&mac->lock);
+	hash = mac->multicast_hash;
+	spin_unlock_irq(&mac->lock);
+
+	zd_chip_set_multicast_hash(&mac->chip, &hash);
+}
+
+void zd_mac_set_multicast_list(struct net_device *dev)
+{
+	struct zd_mc_hash hash;
+	struct zd_mac *mac = zd_netdev_mac(dev);
+	struct dev_mc_list *mc;
+	unsigned long flags;
+
+	if (dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) {
+		zd_mc_add_all(&hash);
+	} else {
+		zd_mc_clear(&hash);
+		for (mc = dev->mc_list; mc; mc = mc->next) {
+			dev_dbg_f(zd_mac_dev(mac), "mc addr " MAC_FMT "\n",
+				  MAC_ARG(mc->dmi_addr));
+			zd_mc_add_addr(&hash, mc->dmi_addr);
+		}
+	}
+
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->multicast_hash = hash;
+	spin_unlock_irqrestore(&mac->lock, flags);
+	queue_work(zd_workqueue, &mac->set_multicast_hash_work);
+}
+
 int zd_mac_set_regdomain(struct zd_mac *mac, u8 regdomain)
 {
 	int r;
@@ -615,6 +656,9 @@ int zd_mac_get_range(struct zd_mac *mac,
 	range->we_version_compiled = WIRELESS_EXT;
 	range->we_version_source = 20;
 
+	range->enc_capa = IW_ENC_CAPA_WPA |  IW_ENC_CAPA_WPA2 |
+			  IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
+
 	ZD_ASSERT(!irqs_disabled());
 	spin_lock_irq(&mac->lock);
 	regdomain = mac->regdomain;
@@ -927,7 +971,8 @@ static int is_data_packet_for_us(struct 
 	}
 
 	return memcmp(hdr->addr1, netdev->dev_addr, ETH_ALEN) == 0 ||
-	       is_multicast_ether_addr(hdr->addr1) ||
+	       (is_multicast_ether_addr(hdr->addr1) &&
+		memcmp(hdr->addr3, netdev->dev_addr, ETH_ALEN) != 0) ||
 	       (netdev->flags & IFF_PROMISC);
 }
 
@@ -1059,10 +1104,8 @@ int zd_mac_rx(struct zd_mac *mac, const 
 	memcpy(skb_put(skb, length), buffer, length);
 
 	r = ieee80211_rx(ieee, skb, &stats);
-	if (!r) {
-		ZD_ASSERT(in_irq());
-		dev_kfree_skb_irq(skb);
-	}
+	if (!r)
+		dev_kfree_skb_any(skb);
 	return 0;
 }
 
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index 5dcfb25..77f1268 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -133,6 +133,8 @@ struct zd_mac {
 	struct iw_statistics iw_stats;
 
 	struct housekeeping housekeeping;
+	struct work_struct set_multicast_hash_work;
+	struct zd_mc_hash multicast_hash;
 	struct work_struct set_rts_cts_work;
 	struct work_struct set_basic_rates_work;
 
@@ -189,6 +191,7 @@ int zd_mac_init_hw(struct zd_mac *mac, u
 int zd_mac_open(struct net_device *netdev);
 int zd_mac_stop(struct net_device *netdev);
 int zd_mac_set_mac_address(struct net_device *dev, void *p);
+void zd_mac_set_multicast_list(struct net_device *netdev);
 
 int zd_mac_rx(struct zd_mac *mac, const u8 *buffer, unsigned int length);
 
diff --git a/drivers/net/wireless/zd1211rw/zd_netdev.c b/drivers/net/wireless/zd1211rw/zd_netdev.c
index 60f1b0f..8bda48d 100644
--- a/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ b/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -242,7 +242,7 @@ struct net_device *zd_netdev_alloc(struc
 	netdev->open = zd_mac_open;
 	netdev->stop = zd_mac_stop;
 	/* netdev->get_stats = */
-	/* netdev->set_multicast_list = */
+	netdev->set_multicast_list = zd_mac_set_multicast_list;
 	netdev->set_mac_address = zd_mac_set_mac_address;
 	netdev->wireless_handlers = &iw_handler_def;
 	/* netdev->ethtool_ops = */
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index cf51c87..614aa8d 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -427,6 +427,17 @@ ieee80211softmac_handle_assoc_response(s
 	return 0;
 }
 
+void
+ieee80211softmac_try_reassoc(struct ieee80211softmac_device *mac)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->associnfo.associating = 1;
+	schedule_work(&mac->associnfo.work);
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
 int
 ieee80211softmac_handle_disassoc(struct net_device * dev,
 				 struct ieee80211_disassoc *disassoc)
@@ -445,8 +456,7 @@ ieee80211softmac_handle_disassoc(struct 
 	dprintk(KERN_INFO PFX "got disassoc frame\n");
 	ieee80211softmac_disassoc(mac);
 
-	/* try to reassociate */
-	schedule_work(&mac->associnfo.work);
+	ieee80211softmac_try_reassoc(mac);
 
 	return 0;
 }
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 0612015..ec44900 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -334,6 +334,8 @@ ieee80211softmac_deauth_from_net(struct 
 	/* can't transmit data right now... */
 	netif_carrier_off(mac->dev);
 	spin_unlock_irqrestore(&mac->lock, flags);
+
+	ieee80211softmac_try_reassoc(mac);
 }
 
 /* 
diff --git a/net/ieee80211/softmac/ieee80211softmac_priv.h b/net/ieee80211/softmac/ieee80211softmac_priv.h
index 0642e09..3ae894f 100644
--- a/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ b/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -238,4 +238,6 @@ void ieee80211softmac_call_events_locked
 int ieee80211softmac_notify_internal(struct ieee80211softmac_device *mac,
 	int event, void *event_context, notify_function_ptr fun, void *context, gfp_t gfp_mask);
 
+void ieee80211softmac_try_reassoc(struct ieee80211softmac_device *mac);
+
 #endif /* IEEE80211SOFTMAC_PRIV_H_ */
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 23068a8..5b7b5b4 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -495,7 +495,8 @@ ieee80211softmac_wx_set_mlme(struct net_
 			printk(KERN_DEBUG PFX "wx_set_mlme: we should know the net here...\n");
 			goto out;
 		}
-		return ieee80211softmac_deauth_req(mac, net, reason);
+		err =  ieee80211softmac_deauth_req(mac, net, reason);
+		goto out;
 	case IW_MLME_DISASSOC:
 		ieee80211softmac_send_disassoc_req(mac, reason);
 		mac->associnfo.associated = 0;
-- 
John W. Linville
linville@tuxdriver.com
