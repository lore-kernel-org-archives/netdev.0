From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-05-12
Date: Mon, 12 May 2008 22:03:25 -0400
Message-ID: <20080513020325.GA4006@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a round of fixes intended for 2.6.26.  Most of these are fairly
obvious -- I don't think there is anything controversial here.

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit c4492586a618d18e8a5343a04bad0ec606064846:
  Wei Yongjun (1):
        sctp: Add address type check while process paramaters of ASCONF chunk

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Emmanuel Grumbach (1):
      iwlwifi: Fix frequency in rx_status fill

Helmut Schaa (1):
      mac80211: fix association with some APs

Ivo van Doorn (4):
      rt2x00: Don't use pskb_expand_head()
      rt2x00: Fix broken recover-on-error path
      rt2x00: Clean up error handling of PCI queue DMA allocation.
      mac80211: Don't encrypt beacons

Johannes Berg (2):
      mac80211: fix debugfs default key oops
      zd1211rw: fix potential use-after-free bug

John W. Linville (1):
      wavelan: avoid index past end of array if DEBUG_SHOW_UNUSED is defined

Luis Carlos Cobo (2):
      mac80211: fix incorrect mesh header length
      mac80211: fix access to null skb

Luis R. Rodriguez (1):
      prism54: fix regression with missing carrier in AP-mode

Masakazu Mokuno (1):
      PS3: gelic: fix memory leak

Patrick McHardy (1):
      mac80211: mesh hwmp: fix kfree(skb)

Pavel Emelyanov (3):
      Fix GFP_KERNEL allocation under read lock.
      Fix not checked kmalloc() result.
      Fix potential scheduling while atomic in mesh_path_add.

Pavel Roskin (1):
      mac80211: add missing newlines in printk()

Steven Rostedt (1):
      fix irq flags in mac80211 code

Zhu Yi (1):
      iwlwifi: fix compile error when CONFIG_MAC80211_DEBUGFS is not selected

 drivers/net/ps3_gelic_wireless.c           |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c    |    2 +-
 drivers/net/wireless/prism54/islpci_dev.c  |   11 ++++-
 drivers/net/wireless/rt2x00/rt2x00dev.c    |   11 ++---
 drivers/net/wireless/rt2x00/rt2x00pci.c    |    5 +-
 drivers/net/wireless/rt2x00/rt61pci.c      |   31 +++++---------
 drivers/net/wireless/wavelan.c             |    4 +-
 drivers/net/wireless/wavelan_cs.c          |    6 +--
 drivers/net/wireless/zd1211rw/zd_usb.c     |    6 ++-
 net/mac80211/debugfs_key.c                 |   15 +++++-
 net/mac80211/mesh.c                        |    2 +-
 net/mac80211/mesh_hwmp.c                   |    2 +-
 net/mac80211/mesh_pathtbl.c                |   17 +++++--
 net/mac80211/mlme.c                        |   64 ++++++++++++++++++++++------
 net/mac80211/rc80211_pid_debugfs.c         |    4 +-
 net/mac80211/rx.c                          |   12 +++---
 net/mac80211/tx.c                          |    1 +
 net/mac80211/util.c                        |   10 ++--
 net/mac80211/wme.c                         |    3 +-
 21 files changed, 133 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index 0d32123..1dae1f2 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2474,6 +2474,8 @@ static void gelic_wl_free(struct gelic_wl_info *wl)
 
 	pr_debug("%s: <-\n", __func__);
 
+	free_page((unsigned long)wl->buf);
+
 	pr_debug("%s: destroy queues\n", __func__);
 	destroy_workqueue(wl->eurus_cmd_queue);
 	destroy_workqueue(wl->event_queue);
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index d340683..62a3d8f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -666,7 +666,7 @@ static void iwl3945_rx_reply_rx(struct iwl3945_priv *priv,
 	rx_status.flag = 0;
 	rx_status.mactime = le64_to_cpu(rx_end->timestamp);
 	rx_status.freq =
-		ieee80211_frequency_to_channel(le16_to_cpu(rx_hdr->channel));
+		ieee80211_channel_to_frequency(le16_to_cpu(rx_hdr->channel));
 	rx_status.band = (rx_hdr->phy_flags & RX_RES_PHY_FLAGS_BAND_24_MSK) ?
 				IEEE80211_BAND_2GHZ : IEEE80211_BAND_5GHZ;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
index b608e1c..c9847b1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
@@ -163,8 +163,8 @@ struct iwl4965_lq_sta {
 	struct dentry *rs_sta_dbgfs_tx_agg_tid_en_file;
 #endif
 	struct iwl4965_rate dbg_fixed;
-	struct iwl_priv *drv;
 #endif
+	struct iwl_priv *drv;
 };
 
 static void rs_rate_scale_perform(struct iwl_priv *priv,
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 17f629f..bf19eb8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -3978,7 +3978,7 @@ static void iwl4965_rx_reply_rx(struct iwl_priv *priv,
 
 	rx_status.mactime = le64_to_cpu(rx_start->timestamp);
 	rx_status.freq =
-		ieee80211_frequency_to_channel(le16_to_cpu(rx_start->channel));
+		ieee80211_channel_to_frequency(le16_to_cpu(rx_start->channel));
 	rx_status.band = (rx_start->phy_flags & RX_RES_PHY_FLAGS_BAND_24_MSK) ?
 				IEEE80211_BAND_2GHZ : IEEE80211_BAND_5GHZ;
 	rx_status.rate_idx =
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 04c2638..9196825 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -388,8 +388,15 @@ islpci_open(struct net_device *ndev)
 
 	netif_start_queue(ndev);
 
-	/* Turn off carrier unless we know we have associated */
-	netif_carrier_off(ndev);
+	/* Turn off carrier if in STA or Ad-hoc mode. It will be turned on
+	 * once the firmware receives a trap of being associated
+	 * (GEN_OID_LINKSTATE). In other modes (AP or WDS or monitor) we
+	 * should just leave the carrier on as its expected the firmware
+	 * won't send us a trigger. */
+	if (priv->iw_mode == IW_MODE_INFRA || priv->iw_mode == IW_MODE_ADHOC)
+		netif_carrier_off(ndev);
+	else
+		netif_carrier_on(ndev);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 8d8657f..b22c027 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1032,8 +1032,10 @@ static int rt2x00lib_initialize(struct rt2x00_dev *rt2x00dev)
 	 * Initialize the device.
 	 */
 	status = rt2x00dev->ops->lib->initialize(rt2x00dev);
-	if (status)
-		goto exit;
+	if (status) {
+		rt2x00queue_uninitialize(rt2x00dev);
+		return status;
+	}
 
 	__set_bit(DEVICE_INITIALIZED, &rt2x00dev->flags);
 
@@ -1043,11 +1045,6 @@ static int rt2x00lib_initialize(struct rt2x00_dev *rt2x00dev)
 	rt2x00rfkill_register(rt2x00dev);
 
 	return 0;
-
-exit:
-	rt2x00lib_uninitialize(rt2x00dev);
-
-	return status;
 }
 
 int rt2x00lib_start(struct rt2x00_dev *rt2x00dev)
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 7867ec6..971af25 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -314,13 +314,14 @@ int rt2x00pci_initialize(struct rt2x00_dev *rt2x00dev)
 	if (status) {
 		ERROR(rt2x00dev, "IRQ %d allocation failed (error %d).\n",
 		      pci_dev->irq, status);
-		return status;
+		goto exit;
 	}
 
 	return 0;
 
 exit:
-	rt2x00pci_uninitialize(rt2x00dev);
+	queue_for_each(rt2x00dev, queue)
+		rt2x00pci_free_queue_dma(rt2x00dev, queue);
 
 	return status;
 }
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index ae12dcd..14bc7b2 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2366,6 +2366,7 @@ static int rt61pci_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb,
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
 	struct rt2x00_intf *intf = vif_to_intf(control->vif);
+	struct queue_entry_priv_pci_tx *priv_tx;
 	struct skb_frame_desc *skbdesc;
 	unsigned int beacon_base;
 	u32 reg;
@@ -2373,21 +2374,8 @@ static int rt61pci_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb,
 	if (unlikely(!intf->beacon))
 		return -ENOBUFS;
 
-	/*
-	 * We need to append the descriptor in front of the
-	 * beacon frame.
-	 */
-	if (skb_headroom(skb) < intf->beacon->queue->desc_size) {
-		if (pskb_expand_head(skb, intf->beacon->queue->desc_size,
-				     0, GFP_ATOMIC))
-			return -ENOMEM;
-	}
-
-	/*
-	 * Add the descriptor in front of the skb.
-	 */
-	skb_push(skb, intf->beacon->queue->desc_size);
-	memset(skb->data, 0, intf->beacon->queue->desc_size);
+	priv_tx = intf->beacon->priv_data;
+	memset(priv_tx->desc, 0, intf->beacon->queue->desc_size);
 
 	/*
 	 * Fill in skb descriptor
@@ -2395,9 +2383,9 @@ static int rt61pci_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb,
 	skbdesc = get_skb_frame_desc(skb);
 	memset(skbdesc, 0, sizeof(*skbdesc));
 	skbdesc->flags |= FRAME_DESC_DRIVER_GENERATED;
-	skbdesc->data = skb->data + intf->beacon->queue->desc_size;
-	skbdesc->data_len = skb->len - intf->beacon->queue->desc_size;
-	skbdesc->desc = skb->data;
+	skbdesc->data = skb->data;
+	skbdesc->data_len = skb->len;
+	skbdesc->desc = priv_tx->desc;
 	skbdesc->desc_len = intf->beacon->queue->desc_size;
 	skbdesc->entry = intf->beacon;
 
@@ -2425,7 +2413,10 @@ static int rt61pci_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb,
 	 */
 	beacon_base = HW_BEACON_OFFSET(intf->beacon->entry_idx);
 	rt2x00pci_register_multiwrite(rt2x00dev, beacon_base,
-				      skb->data, skb->len);
+				      skbdesc->desc, skbdesc->desc_len);
+	rt2x00pci_register_multiwrite(rt2x00dev,
+				      beacon_base + skbdesc->desc_len,
+				      skbdesc->data, skbdesc->data_len);
 	rt61pci_kick_tx_queue(rt2x00dev, control->queue);
 
 	return 0;
@@ -2490,7 +2481,7 @@ static const struct data_queue_desc rt61pci_queue_tx = {
 
 static const struct data_queue_desc rt61pci_queue_bcn = {
 	.entry_num		= 4 * BEACON_ENTRIES,
-	.data_size		= MGMT_FRAME_SIZE,
+	.data_size		= 0, /* No DMA required for beacons */
 	.desc_size		= TXINFO_SIZE,
 	.priv_size		= sizeof(struct queue_entry_priv_pci_tx),
 };
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 03384a4..49ae970 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -908,9 +908,9 @@ static void wv_psa_show(psa_t * p)
 	     p->psa_call_code[3], p->psa_call_code[4], p->psa_call_code[5],
 	     p->psa_call_code[6], p->psa_call_code[7]);
 #ifdef DEBUG_SHOW_UNUSED
-	printk(KERN_DEBUG "psa_reserved[]: %02X:%02X:%02X:%02X\n",
+	printk(KERN_DEBUG "psa_reserved[]: %02X:%02X\n",
 	       p->psa_reserved[0],
-	       p->psa_reserved[1], p->psa_reserved[2], p->psa_reserved[3]);
+	       p->psa_reserved[1]);
 #endif				/* DEBUG_SHOW_UNUSED */
 	printk(KERN_DEBUG "psa_conf_status: %d, ", p->psa_conf_status);
 	printk("psa_crc: 0x%02x%02x, ", p->psa_crc[0], p->psa_crc[1]);
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index baf7401..b584c0e 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -1074,11 +1074,9 @@ wv_psa_show(psa_t *	p)
 	 p->psa_call_code[6],
 	 p->psa_call_code[7]);
 #ifdef DEBUG_SHOW_UNUSED
-  printk(KERN_DEBUG "psa_reserved[]: %02X:%02X:%02X:%02X\n",
+  printk(KERN_DEBUG "psa_reserved[]: %02X:%02X\n",
 	 p->psa_reserved[0],
-	 p->psa_reserved[1],
-	 p->psa_reserved[2],
-	 p->psa_reserved[3]);
+	 p->psa_reserved[1]);
 #endif	/* DEBUG_SHOW_UNUSED */
   printk(KERN_DEBUG "psa_conf_status: %d, ", p->psa_conf_status);
   printk("psa_crc: 0x%02x%02x, ", p->psa_crc[0], p->psa_crc[1]);
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 5316074..12e24f0 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -889,9 +889,13 @@ static void tx_urb_complete(struct urb *urb)
 	}
 free_urb:
 	skb = (struct sk_buff *)urb->context;
-	zd_mac_tx_to_dev(skb, urb->status);
+	/*
+	 * grab 'usb' pointer before handing off the skb (since
+	 * it might be freed by zd_mac_tx_to_dev or mac80211)
+	 */
 	cb = (struct zd_tx_skb_control_block *)skb->cb;
 	usb = &zd_hw_mac(cb->hw)->chip.usb;
+	zd_mac_tx_to_dev(skb, urb->status);
 	free_tx_urb(usb, urb);
 	tx_dec_submitted_urbs(usb);
 	return;
diff --git a/net/mac80211/debugfs_key.c b/net/mac80211/debugfs_key.c
index 879e721..19efc3a 100644
--- a/net/mac80211/debugfs_key.c
+++ b/net/mac80211/debugfs_key.c
@@ -255,14 +255,23 @@ void ieee80211_debugfs_key_remove(struct ieee80211_key *key)
 void ieee80211_debugfs_key_add_default(struct ieee80211_sub_if_data *sdata)
 {
 	char buf[50];
+	struct ieee80211_key *key;
 
 	if (!sdata->debugfsdir)
 		return;
 
-	sprintf(buf, "../keys/%d", sdata->default_key->debugfs.cnt);
-	sdata->debugfs.default_key =
-		debugfs_create_symlink("default_key", sdata->debugfsdir, buf);
+	/* this is running under the key lock */
+
+	key = sdata->default_key;
+	if (key) {
+		sprintf(buf, "../keys/%d", key->debugfs.cnt);
+		sdata->debugfs.default_key =
+			debugfs_create_symlink("default_key",
+					       sdata->debugfsdir, buf);
+	} else
+		ieee80211_debugfs_key_remove_default(sdata);
 }
+
 void ieee80211_debugfs_key_remove_default(struct ieee80211_sub_if_data *sdata)
 {
 	if (!sdata)
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index f76bc26..697ef67 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -397,7 +397,7 @@ int ieee80211_new_mesh_header(struct ieee80211s_hdr *meshhdr,
 	put_unaligned(cpu_to_le32(sdata->u.sta.mesh_seqnum), &meshhdr->seqnum);
 	sdata->u.sta.mesh_seqnum++;
 
-	return 5;
+	return 6;
 }
 
 void ieee80211_mesh_init_sdata(struct ieee80211_sub_if_data *sdata)
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 3df8092..af0cd1e 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -120,7 +120,7 @@ static int mesh_path_sel_frame_tx(enum mpath_frame_type action, u8 flags,
 		*pos++ = WLAN_EID_PREP;
 		break;
 	default:
-		kfree(skb);
+		kfree_skb(skb);
 		return -ENOTSUPP;
 		break;
 	}
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 5845dc2..99c2d36 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -158,19 +158,25 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 	if (atomic_add_unless(&sdata->u.sta.mpaths, 1, MESH_MAX_MPATHS) == 0)
 		return -ENOSPC;
 
-	read_lock(&pathtbl_resize_lock);
-
 	new_mpath = kzalloc(sizeof(struct mesh_path), GFP_KERNEL);
 	if (!new_mpath) {
 		atomic_dec(&sdata->u.sta.mpaths);
 		err = -ENOMEM;
 		goto endadd2;
 	}
+	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
+	if (!new_node) {
+		kfree(new_mpath);
+		atomic_dec(&sdata->u.sta.mpaths);
+		err = -ENOMEM;
+		goto endadd2;
+	}
+
+	read_lock(&pathtbl_resize_lock);
 	memcpy(new_mpath->dst, dst, ETH_ALEN);
 	new_mpath->dev = dev;
 	new_mpath->flags = 0;
 	skb_queue_head_init(&new_mpath->frame_queue);
-	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
 	new_node->mpath = new_mpath;
 	new_mpath->timer.data = (unsigned long) new_mpath;
 	new_mpath->timer.function = mesh_path_timer;
@@ -202,7 +208,6 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 
 endadd:
 	spin_unlock(&mesh_paths->hashwlock[hash_idx]);
-endadd2:
 	read_unlock(&pathtbl_resize_lock);
 	if (!err && grow) {
 		struct mesh_table *oldtbl, *newtbl;
@@ -215,10 +220,12 @@ endadd2:
 			return -ENOMEM;
 		}
 		rcu_assign_pointer(mesh_paths, newtbl);
+		write_unlock(&pathtbl_resize_lock);
+
 		synchronize_rcu();
 		mesh_table_free(oldtbl, false);
-		write_unlock(&pathtbl_resize_lock);
 	}
+endadd2:
 	return err;
 }
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index a5e5c31..4adba09 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -665,6 +665,26 @@ static void ieee80211_authenticate(struct net_device *dev,
 	mod_timer(&ifsta->timer, jiffies + IEEE80211_AUTH_TIMEOUT);
 }
 
+static int ieee80211_compatible_rates(struct ieee80211_sta_bss *bss,
+				      struct ieee80211_supported_band *sband,
+				      u64 *rates)
+{
+	int i, j, count;
+	*rates = 0;
+	count = 0;
+	for (i = 0; i < bss->supp_rates_len; i++) {
+		int rate = (bss->supp_rates[i] & 0x7F) * 5;
+
+		for (j = 0; j < sband->n_bitrates; j++)
+			if (sband->bitrates[j].bitrate == rate) {
+				*rates |= BIT(j);
+				count++;
+				break;
+			}
+	}
+
+	return count;
+}
 
 static void ieee80211_send_assoc(struct net_device *dev,
 				 struct ieee80211_if_sta *ifsta)
@@ -673,11 +693,12 @@ static void ieee80211_send_assoc(struct net_device *dev,
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 	u8 *pos, *ies;
-	int i, len;
+	int i, len, count, rates_len, supp_rates_len;
 	u16 capab;
 	struct ieee80211_sta_bss *bss;
 	int wmm = 0;
 	struct ieee80211_supported_band *sband;
+	u64 rates = 0;
 
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
 			    sizeof(*mgmt) + 200 + ifsta->extra_ie_len +
@@ -740,24 +761,39 @@ static void ieee80211_send_assoc(struct net_device *dev,
 	*pos++ = ifsta->ssid_len;
 	memcpy(pos, ifsta->ssid, ifsta->ssid_len);
 
+	/* all supported rates should be added here but some APs
+	 * (e.g. D-Link DAP 1353 in b-only mode) don't like that
+	 * Therefore only add rates the AP supports */
+	rates_len = ieee80211_compatible_rates(bss, sband, &rates);
+	supp_rates_len = rates_len;
+	if (supp_rates_len > 8)
+		supp_rates_len = 8;
+
 	len = sband->n_bitrates;
-	if (len > 8)
-		len = 8;
-	pos = skb_put(skb, len + 2);
+	pos = skb_put(skb, supp_rates_len + 2);
 	*pos++ = WLAN_EID_SUPP_RATES;
-	*pos++ = len;
-	for (i = 0; i < len; i++) {
-		int rate = sband->bitrates[i].bitrate;
-		*pos++ = (u8) (rate / 5);
-	}
+	*pos++ = supp_rates_len;
 
-	if (sband->n_bitrates > len) {
-		pos = skb_put(skb, sband->n_bitrates - len + 2);
-		*pos++ = WLAN_EID_EXT_SUPP_RATES;
-		*pos++ = sband->n_bitrates - len;
-		for (i = len; i < sband->n_bitrates; i++) {
+	count = 0;
+	for (i = 0; i < sband->n_bitrates; i++) {
+		if (BIT(i) & rates) {
 			int rate = sband->bitrates[i].bitrate;
 			*pos++ = (u8) (rate / 5);
+			if (++count == 8)
+				break;
+		}
+	}
+
+	if (count == 8) {
+		pos = skb_put(skb, rates_len - count + 2);
+		*pos++ = WLAN_EID_EXT_SUPP_RATES;
+		*pos++ = rates_len - count;
+
+		for (i++; i < sband->n_bitrates; i++) {
+			if (BIT(i) & rates) {
+				int rate = sband->bitrates[i].bitrate;
+				*pos++ = (u8) (rate / 5);
+			}
 		}
 	}
 
diff --git a/net/mac80211/rc80211_pid_debugfs.c b/net/mac80211/rc80211_pid_debugfs.c
index ae75d41..ff5c380 100644
--- a/net/mac80211/rc80211_pid_debugfs.c
+++ b/net/mac80211/rc80211_pid_debugfs.c
@@ -85,7 +85,7 @@ static int rate_control_pid_events_open(struct inode *inode, struct file *file)
 	struct rc_pid_sta_info *sinfo = inode->i_private;
 	struct rc_pid_event_buffer *events = &sinfo->events;
 	struct rc_pid_events_file_info *file_info;
-	unsigned int status;
+	unsigned long status;
 
 	/* Allocate a state struct */
 	file_info = kmalloc(sizeof(*file_info), GFP_KERNEL);
@@ -135,7 +135,7 @@ static ssize_t rate_control_pid_events_read(struct file *file, char __user *buf,
 	char pb[RC_PID_PRINT_BUF_SIZE];
 	int ret;
 	int p;
-	unsigned int status;
+	unsigned long status;
 
 	/* Check if there is something to read. */
 	if (events->next_entry == file_info->next_entry) {
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 02f436a..1958bfb 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1305,11 +1305,11 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 		if (is_multicast_ether_addr(skb->data)) {
 			if (*mesh_ttl > 0) {
 				xmit_skb = skb_copy(skb, GFP_ATOMIC);
-				if (!xmit_skb && net_ratelimit())
+				if (xmit_skb)
+					xmit_skb->pkt_type = PACKET_OTHERHOST;
+				else if (net_ratelimit())
 					printk(KERN_DEBUG "%s: failed to clone "
 					       "multicast frame\n", dev->name);
-				else
-					xmit_skb->pkt_type = PACKET_OTHERHOST;
 			} else
 				IEEE80211_IFSTA_MESH_CTR_INC(&sdata->u.sta,
 							     dropped_frames_ttl);
@@ -1395,7 +1395,7 @@ ieee80211_rx_h_amsdu(struct ieee80211_rx_data *rx)
 		padding = ((4 - subframe_len) & 0x3);
 		/* the last MSDU has no padding */
 		if (subframe_len > remaining) {
-			printk(KERN_DEBUG "%s: wrong buffer size", dev->name);
+			printk(KERN_DEBUG "%s: wrong buffer size\n", dev->name);
 			return RX_DROP_UNUSABLE;
 		}
 
@@ -1418,7 +1418,7 @@ ieee80211_rx_h_amsdu(struct ieee80211_rx_data *rx)
 			eth = (struct ethhdr *) skb_pull(skb, ntohs(len) +
 							padding);
 			if (!eth) {
-				printk(KERN_DEBUG "%s: wrong buffer size ",
+				printk(KERN_DEBUG "%s: wrong buffer size\n",
 				       dev->name);
 				dev_kfree_skb(frame);
 				return RX_DROP_UNUSABLE;
@@ -1952,7 +1952,7 @@ static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
 		if (!skb_new) {
 			if (net_ratelimit())
 				printk(KERN_DEBUG "%s: failed to copy "
-				       "multicast frame for %s",
+				       "multicast frame for %s\n",
 				       wiphy_name(local->hw.wiphy),
 				       prev->dev->name);
 			continue;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index f35eaea..28d8bd5 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1898,6 +1898,7 @@ struct sk_buff *ieee80211_beacon_get(struct ieee80211_hw *hw,
 			control->flags |= IEEE80211_TXCTL_SHORT_PREAMBLE;
 		control->antenna_sel_tx = local->hw.conf.antenna_sel_tx;
 		control->flags |= IEEE80211_TXCTL_NO_ACK;
+		control->flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
 		control->retry_limit = 1;
 		control->flags |= IEEE80211_TXCTL_CLEAR_PS_FILT;
 	}
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index cc9f715..24a465c 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -153,15 +153,15 @@ int ieee80211_get_mesh_hdrlen(struct ieee80211s_hdr *meshhdr)
 	/* 7.1.3.5a.2 */
 	switch (ae) {
 	case 0:
-		return 5;
+		return 6;
 	case 1:
-		return 11;
+		return 12;
 	case 2:
-		return 17;
+		return 18;
 	case 3:
-		return 23;
+		return 24;
 	default:
-		return 5;
+		return 6;
 	}
 }
 
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 64faa3d..dc1598b 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -394,7 +394,8 @@ static int wme_qdiscop_init(struct Qdisc *qd, struct nlattr *opt)
 						 qd->handle);
 		if (!q->queues[i]) {
 			q->queues[i] = &noop_qdisc;
-			printk(KERN_ERR "%s child qdisc %i creation failed", dev->name, i);
+			printk(KERN_ERR "%s child qdisc %i creation failed\n",
+			       dev->name, i);
 		}
 	}
 
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
