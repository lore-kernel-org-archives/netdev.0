From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-08-07
Date: Thu, 7 Aug 2008 10:25:20 -0400
Message-ID: <20080807142520.GA27762@tuxdriver.com>
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

A few more patches for 2.6.27.  Also included is an iwlwifi cleanup that
the Intel guys really wanted -- obviously I'm too soft...well, it seems
harmless enough.

I'll be out of town through the weekend celebrating my 10th wedding
anniversary -- woohoo!  I'll be away from email until Monday or so --
FYI...

Still, let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/master

---

The following changes since commit e6fce5b916cd7f7f79b2b3e53ba74bbfc1d7cf8b:
  Robert Olsson (1):
        pktgen: multiqueue etc.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      p54: swap short slot time dcf values

Ivo van Doorn (1):
      rt2x00: Block all unsupported modes

Larry Finger (1):
      p54: Fix for TX sequence number problem

Luis Carlos Cobo (2):
      mac80211: fix use of skb->cb for mesh forwarding
      mac80211: keep mesh ifaces in allmulti mode

Tomas Winkler (1):
      iwlwifi: cleanup iwl_tx_skb

 drivers/net/wireless/iwlwifi/iwl-agn.c   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h |    3 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c    |   40 +++++------
 drivers/net/wireless/p54/p54.h           |    1 +
 drivers/net/wireless/p54/p54common.c     |   18 ++++-
 drivers/net/wireless/rt2x00/rt2x00mac.c  |   54 ++++++++++-----
 net/mac80211/main.c                      |    8 ++-
 net/mac80211/mesh.h                      |    5 +-
 net/mac80211/mesh_hwmp.c                 |   19 +++---
 net/mac80211/mesh_pathtbl.c              |   11 +--
 net/mac80211/rx.c                        |  116 +++++++++++++++++-------------
 net/mac80211/tx.c                        |   45 ++++++------
 12 files changed, 189 insertions(+), 135 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index b8407d5..ed09e48 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2719,7 +2719,7 @@ static int iwl4965_mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 {
 	struct iwl_priv *priv = hw->priv;
 
-	IWL_DEBUG_MAC80211("enter\n");
+	IWL_DEBUG_MACDUMP("enter\n");
 
 	if (priv->iw_mode == IEEE80211_IF_TYPE_MNTR) {
 		IWL_DEBUG_MAC80211("leave - monitor\n");
@@ -2733,7 +2733,7 @@ static int iwl4965_mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	if (iwl_tx_skb(priv, skb))
 		dev_kfree_skb_any(skb);
 
-	IWL_DEBUG_MAC80211("leave\n");
+	IWL_DEBUG_MACDUMP("leave\n");
 	return 0;
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wireless/iwlwifi/iwl-debug.h
index b4ffd33..d2daa17 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-debug.h
@@ -114,7 +114,7 @@ static inline void iwl_dbgfs_unregister(struct iwl_priv *priv)
 #define IWL_DL_MAC80211      (1 << 1)
 #define IWL_DL_HOST_COMMAND  (1 << 2)
 #define IWL_DL_STATE         (1 << 3)
-
+#define IWL_DL_MACDUMP		(1 << 4)
 #define IWL_DL_RADIO         (1 << 7)
 #define IWL_DL_POWER         (1 << 8)
 #define IWL_DL_TEMP          (1 << 9)
@@ -154,6 +154,7 @@ static inline void iwl_dbgfs_unregister(struct iwl_priv *priv)
 #define IWL_DEBUG_INFO(f, a...)    IWL_DEBUG(IWL_DL_INFO, f, ## a)
 
 #define IWL_DEBUG_MAC80211(f, a...)     IWL_DEBUG(IWL_DL_MAC80211, f, ## a)
+#define IWL_DEBUG_MACDUMP(f, a...)     IWL_DEBUG(IWL_DL_MACDUMP, f, ## a)
 #define IWL_DEBUG_TEMP(f, a...)   IWL_DEBUG(IWL_DL_TEMP, f, ## a)
 #define IWL_DEBUG_SCAN(f, a...)   IWL_DEBUG(IWL_DL_SCAN, f, ## a)
 #define IWL_DEBUG_RX(f, a...)     IWL_DEBUG(IWL_DL_RX, f, ## a)
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index aa98c76..4108c7c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -764,20 +764,19 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct iwl_tfd_frame *tfd;
-	u32 *control_flags;
-	int txq_id = skb_get_queue_mapping(skb);
-	struct iwl_tx_queue *txq = NULL;
-	struct iwl_queue *q = NULL;
+	struct iwl_tx_queue *txq;
+	struct iwl_queue *q;
+	struct iwl_cmd *out_cmd;
+	struct iwl_tx_cmd *tx_cmd;
+	int swq_id, txq_id;
 	dma_addr_t phys_addr;
 	dma_addr_t txcmd_phys;
 	dma_addr_t scratch_phys;
-	struct iwl_cmd *out_cmd = NULL;
-	struct iwl_tx_cmd *tx_cmd;
 	u16 len, idx, len_org;
 	u16 seq_number = 0;
-	u8 id, hdr_len, unicast;
-	u8 sta_id;
 	__le16 fc;
+	u8 hdr_len, unicast;
+	u8 sta_id;
 	u8 wait_write_ptr = 0;
 	u8 tid = 0;
 	u8 *qc = NULL;
@@ -802,7 +801,6 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	}
 
 	unicast = !is_multicast_ether_addr(hdr->addr1);
-	id = 0;
 
 	fc = hdr->frame_control;
 
@@ -840,14 +838,16 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 
 	IWL_DEBUG_TX("station Id %d\n", sta_id);
 
+	swq_id = skb_get_queue_mapping(skb);
+	txq_id = swq_id;
 	if (ieee80211_is_data_qos(fc)) {
 		qc = ieee80211_get_qos_ctl(hdr);
 		tid = qc[0] & 0xf;
-		seq_number = priv->stations[sta_id].tid[tid].seq_number &
-				IEEE80211_SCTL_SEQ;
-		hdr->seq_ctrl = cpu_to_le16(seq_number) |
-			(hdr->seq_ctrl &
-				__constant_cpu_to_le16(IEEE80211_SCTL_FRAG));
+		seq_number = priv->stations[sta_id].tid[tid].seq_number;
+		seq_number &= IEEE80211_SCTL_SEQ;
+		hdr->seq_ctrl = hdr->seq_ctrl &
+				__constant_cpu_to_le16(IEEE80211_SCTL_FRAG);
+		hdr->seq_ctrl |= cpu_to_le16(seq_number);
 		seq_number += 0x10;
 		/* aggregation is on for this <sta,tid> */
 		if (info->flags & IEEE80211_TX_CTL_AMPDU)
@@ -864,7 +864,6 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	/* Set up first empty TFD within this queue's circular TFD buffer */
 	tfd = &txq->bd[q->write_ptr];
 	memset(tfd, 0, sizeof(*tfd));
-	control_flags = (u32 *) tfd;
 	idx = get_cmd_index(q, q->write_ptr, 0);
 
 	/* Set up driver data for this TFD */
@@ -983,8 +982,7 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 			iwl_txq_update_write_ptr(priv, txq);
 			spin_unlock_irqrestore(&priv->lock, flags);
 		} else {
-			ieee80211_stop_queue(priv->hw,
-					     skb_get_queue_mapping(skb));
+			ieee80211_stop_queue(priv->hw, swq_id);
 		}
 	}
 
@@ -1013,13 +1011,12 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 	struct iwl_tx_queue *txq = &priv->txq[IWL_CMD_QUEUE_NUM];
 	struct iwl_queue *q = &txq->q;
 	struct iwl_tfd_frame *tfd;
-	u32 *control_flags;
 	struct iwl_cmd *out_cmd;
-	u32 idx;
-	u16 fix_size;
 	dma_addr_t phys_addr;
-	int len, ret;
 	unsigned long flags;
+	int len, ret;
+	u32 idx;
+	u16 fix_size;
 
 	cmd->len = priv->cfg->ops->utils->get_hcmd_size(cmd->id, cmd->len);
 	fix_size = (u16)(cmd->len + sizeof(out_cmd->hdr));
@@ -1045,7 +1042,6 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 	tfd = &txq->bd[q->write_ptr];
 	memset(tfd, 0, sizeof(*tfd));
 
-	control_flags = (u32 *) tfd;
 
 	idx = get_cmd_index(q, q->write_ptr, cmd->meta.flags & CMD_SIZE_HUGE);
 	out_cmd = txq->cmd[idx];
diff --git a/drivers/net/wireless/p54/p54.h b/drivers/net/wireless/p54/p54.h
index cac9a51..4801a36 100644
--- a/drivers/net/wireless/p54/p54.h
+++ b/drivers/net/wireless/p54/p54.h
@@ -52,6 +52,7 @@ struct p54_common {
 	int (*open)(struct ieee80211_hw *dev);
 	void (*stop)(struct ieee80211_hw *dev);
 	int mode;
+	u16 seqno;
 	struct mutex conf_mutex;
 	u8 mac_addr[ETH_ALEN];
 	u8 bssid[ETH_ALEN];
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index 4da89ea..83cd85e 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -553,6 +553,7 @@ static int p54_tx(struct ieee80211_hw *dev, struct sk_buff *skb)
 	struct ieee80211_tx_queue_stats *current_queue;
 	struct p54_common *priv = dev->priv;
 	struct p54_control_hdr *hdr;
+	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr *)skb->data;
 	struct p54_tx_control_allocdata *txhdr;
 	size_t padding, len;
 	u8 rate;
@@ -605,6 +606,19 @@ static int p54_tx(struct ieee80211_hw *dev, struct sk_buff *skb)
 	if (padding)
 		txhdr->align[0] = padding;
 
+	/* FIXME: The sequence that follows is needed for this driver to
+	 * work with mac80211 since "mac80211: fix TX sequence numbers".
+	 * As with the temporary code in rt2x00, changes will be needed
+	 * to get proper sequence numbers on beacons. In addition, this
+	 * patch places the sequence number in the hardware state, which
+	 * limits us to a single virtual state.
+	 */
+	if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
+		if (info->flags & IEEE80211_TX_CTL_FIRST_FRAGMENT)
+			priv->seqno += 0x10;
+		ieee80211hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
+		ieee80211hdr->seq_ctrl |= cpu_to_le16(priv->seqno);
+	}
 	/* modifies skb->cb and with it info, so must be last! */
 	p54_assign_address(dev, skb, hdr, skb->len);
 
@@ -803,8 +817,8 @@ static void p54_set_vdcf(struct ieee80211_hw *dev)
 
 	if (dev->conf.flags & IEEE80211_CONF_SHORT_SLOT_TIME) {
 		vdcf->slottime = 9;
-		vdcf->magic1 = 0x00;
-		vdcf->magic2 = 0x10;
+		vdcf->magic1 = 0x10;
+		vdcf->magic2 = 0x00;
 	} else {
 		vdcf->slottime = 20;
 		vdcf->magic1 = 0x0a;
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index bd422fd..d065073 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -203,23 +203,43 @@ int rt2x00mac_add_interface(struct ieee80211_hw *hw,
 	    !test_bit(DEVICE_STARTED, &rt2x00dev->flags))
 		return -ENODEV;
 
-	/*
-	 * We don't support mixed combinations of sta and ap virtual
-	 * interfaces. We can only add this interface when the rival
-	 * interface count is 0.
-	 */
-	if ((conf->type == IEEE80211_IF_TYPE_AP && rt2x00dev->intf_sta_count) ||
-	    (conf->type != IEEE80211_IF_TYPE_AP && rt2x00dev->intf_ap_count))
-		return -ENOBUFS;
-
-	/*
-	 * Check if we exceeded the maximum amount of supported interfaces.
-	 */
-	if ((conf->type == IEEE80211_IF_TYPE_AP &&
-	     rt2x00dev->intf_ap_count >= rt2x00dev->ops->max_ap_intf) ||
-	    (conf->type != IEEE80211_IF_TYPE_AP &&
-	     rt2x00dev->intf_sta_count >= rt2x00dev->ops->max_sta_intf))
-		return -ENOBUFS;
+	switch (conf->type) {
+	case IEEE80211_IF_TYPE_AP:
+		/*
+		 * We don't support mixed combinations of
+		 * sta and ap interfaces.
+		 */
+		if (rt2x00dev->intf_sta_count)
+			return -ENOBUFS;
+
+		/*
+		 * Check if we exceeded the maximum amount
+		 * of supported interfaces.
+		 */
+		if (rt2x00dev->intf_ap_count >= rt2x00dev->ops->max_ap_intf)
+			return -ENOBUFS;
+
+		break;
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS:
+		/*
+		 * We don't support mixed combinations of
+		 * sta and ap interfaces.
+		 */
+		if (rt2x00dev->intf_ap_count)
+			return -ENOBUFS;
+
+		/*
+		 * Check if we exceeded the maximum amount
+		 * of supported interfaces.
+		 */
+		if (rt2x00dev->intf_sta_count >= rt2x00dev->ops->max_sta_intf)
+			return -ENOBUFS;
+
+		break;
+	default:
+		return -EINVAL;
+	}
 
 	/*
 	 * Loop through all beacon queues to find a free
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 0c02c47..aa5a191 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -245,10 +245,13 @@ static int ieee80211_open(struct net_device *dev)
 	case IEEE80211_IF_TYPE_AP:
 		sdata->bss = &sdata->u.ap;
 		break;
+	case IEEE80211_IF_TYPE_MESH_POINT:
+		/* mesh ifaces must set allmulti to forward mcast traffic */
+		atomic_inc(&local->iff_allmultis);
+		break;
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_MNTR:
 	case IEEE80211_IF_TYPE_IBSS:
-	case IEEE80211_IF_TYPE_MESH_POINT:
 		/* no special treatment */
 		break;
 	case IEEE80211_IF_TYPE_INVALID:
@@ -495,6 +498,9 @@ static int ieee80211_stop(struct net_device *dev)
 		netif_addr_unlock_bh(local->mdev);
 		break;
 	case IEEE80211_IF_TYPE_MESH_POINT:
+		/* allmulti is always set on mesh ifaces */
+		atomic_dec(&local->iff_allmultis);
+		/* fall through */
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
 		sdata->u.sta.state = IEEE80211_DISABLED;
diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
index 669eafa..7495fbb 100644
--- a/net/mac80211/mesh.h
+++ b/net/mac80211/mesh.h
@@ -214,8 +214,7 @@ void ieee80211s_stop(void);
 void ieee80211_mesh_init_sdata(struct ieee80211_sub_if_data *sdata);
 
 /* Mesh paths */
-int mesh_nexthop_lookup(u8 *next_hop, struct sk_buff *skb,
-		struct net_device *dev);
+int mesh_nexthop_lookup(struct sk_buff *skb, struct net_device *dev);
 void mesh_path_start_discovery(struct net_device *dev);
 struct mesh_path *mesh_path_lookup(u8 *dst, struct net_device *dev);
 struct mesh_path *mesh_path_lookup_by_idx(int idx, struct net_device *dev);
@@ -286,6 +285,4 @@ static inline void mesh_path_activate(struct mesh_path *mpath)
 #define mesh_allocated	0
 #endif
 
-#define MESH_PREQ(skb)	(skb->cb + 30)
-
 #endif /* IEEE80211S_H */
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 7fa149e..08aca44 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -758,29 +758,30 @@ enddiscovery:
 /**
  * ieee80211s_lookup_nexthop - put the appropriate next hop on a mesh frame
  *
- * @next_hop: output argument for next hop address
- * @skb: frame to be sent
+ * @skb: 802.11 frame to be sent
  * @dev: network device the frame will be sent through
+ * @fwd_frame: true if this frame was originally from a different host
  *
  * Returns: 0 if the next hop was found. Nonzero otherwise. If no next hop is
  * found, the function will start a path discovery and queue the frame so it is
  * sent when the path is resolved. This means the caller must not free the skb
  * in this case.
  */
-int mesh_nexthop_lookup(u8 *next_hop, struct sk_buff *skb,
-		struct net_device *dev)
+int mesh_nexthop_lookup(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct sk_buff *skb_to_free = NULL;
 	struct mesh_path *mpath;
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	u8 *dst_addr = hdr->addr3;
 	int err = 0;
 
 	rcu_read_lock();
-	mpath = mesh_path_lookup(skb->data, dev);
+	mpath = mesh_path_lookup(dst_addr, dev);
 
 	if (!mpath) {
-		mesh_path_add(skb->data, dev);
-		mpath = mesh_path_lookup(skb->data, dev);
+		mesh_path_add(dst_addr, dev);
+		mpath = mesh_path_lookup(dst_addr, dev);
 		if (!mpath) {
 			dev_kfree_skb(skb);
 			sdata->u.sta.mshstats.dropped_frames_no_route++;
@@ -792,13 +793,13 @@ int mesh_nexthop_lookup(u8 *next_hop, struct sk_buff *skb,
 	if (mpath->flags & MESH_PATH_ACTIVE) {
 		if (time_after(jiffies, mpath->exp_time -
 			msecs_to_jiffies(sdata->u.sta.mshcfg.path_refresh_time))
-				&& skb->pkt_type != PACKET_OTHERHOST
+				&& !memcmp(dev->dev_addr, hdr->addr4, ETH_ALEN)
 				&& !(mpath->flags & MESH_PATH_RESOLVING)
 				&& !(mpath->flags & MESH_PATH_FIXED)) {
 			mesh_queue_preq(mpath,
 					PREQ_Q_F_START | PREQ_Q_F_REFRESH);
 		}
-		memcpy(next_hop, mpath->next_hop->addr,
+		memcpy(hdr->addr1, mpath->next_hop->addr,
 				ETH_ALEN);
 	} else {
 		if (!(mpath->flags & MESH_PATH_RESOLVING)) {
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 5f88a2e..838ee60 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -388,18 +388,15 @@ void mesh_path_tx_pending(struct mesh_path *mpath)
 void mesh_path_discard_frame(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct mesh_path *mpath;
 	u32 dsn = 0;
 
-	if (skb->pkt_type == PACKET_OTHERHOST) {
-		struct ieee80211s_hdr *prev_meshhdr;
-		int mshhdrlen;
+	if (memcmp(hdr->addr4, dev->dev_addr, ETH_ALEN) != 0) {
 		u8 *ra, *da;
 
-		prev_meshhdr = ((struct ieee80211s_hdr *)skb->cb);
-		mshhdrlen = ieee80211_get_mesh_hdrlen(prev_meshhdr);
-		da = skb->data;
-		ra = MESH_PREQ(skb);
+		da = hdr->addr3;
+		ra = hdr->addr2;
 		mpath = mesh_path_lookup(da, dev);
 		if (mpath)
 			dsn = ++mpath->dsn;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 6d9ae67..6db8545 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1109,20 +1109,9 @@ ieee80211_data_to_8023(struct ieee80211_rx_data *rx)
 
 	hdrlen = ieee80211_get_hdrlen(fc);
 
-	if (ieee80211_vif_is_mesh(&sdata->vif)) {
-		int meshhdrlen = ieee80211_get_mesh_hdrlen(
+	if (ieee80211_vif_is_mesh(&sdata->vif))
+		hdrlen += ieee80211_get_mesh_hdrlen(
 				(struct ieee80211s_hdr *) (skb->data + hdrlen));
-		/* Copy on cb:
-		 *  - mesh header: to be used for mesh forwarding
-		 * decision. It will also be used as mesh header template at
-		 * tx.c:ieee80211_subif_start_xmit() if interface
-		 * type is mesh and skb->pkt_type == PACKET_OTHERHOST
-		 *  - ta: to be used if a RERR needs to be sent.
-		 */
-		memcpy(skb->cb, skb->data + hdrlen, meshhdrlen);
-		memcpy(MESH_PREQ(skb), hdr->addr2, ETH_ALEN);
-		hdrlen += meshhdrlen;
-	}
 
 	/* convert IEEE 802.11 header + possible LLC headers into Ethernet
 	 * header
@@ -1269,38 +1258,6 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 		}
 	}
 
-	/* Mesh forwarding */
-	if (ieee80211_vif_is_mesh(&sdata->vif)) {
-		u8 *mesh_ttl = &((struct ieee80211s_hdr *)skb->cb)->ttl;
-		(*mesh_ttl)--;
-
-		if (is_multicast_ether_addr(skb->data)) {
-			if (*mesh_ttl > 0) {
-				xmit_skb = skb_copy(skb, GFP_ATOMIC);
-				if (xmit_skb)
-					xmit_skb->pkt_type = PACKET_OTHERHOST;
-				else if (net_ratelimit())
-					printk(KERN_DEBUG "%s: failed to clone "
-					       "multicast frame\n", dev->name);
-			} else
-				IEEE80211_IFSTA_MESH_CTR_INC(&sdata->u.sta,
-							     dropped_frames_ttl);
-		} else if (skb->pkt_type != PACKET_OTHERHOST &&
-			compare_ether_addr(dev->dev_addr, skb->data) != 0) {
-			if (*mesh_ttl == 0) {
-				IEEE80211_IFSTA_MESH_CTR_INC(&sdata->u.sta,
-							     dropped_frames_ttl);
-				dev_kfree_skb(skb);
-				skb = NULL;
-			} else {
-				xmit_skb = skb;
-				xmit_skb->pkt_type = PACKET_OTHERHOST;
-				if (!(dev->flags & IFF_PROMISC))
-					skb  = NULL;
-			}
-		}
-	}
-
 	if (skb) {
 		/* deliver to local stack */
 		skb->protocol = eth_type_trans(skb, dev);
@@ -1431,6 +1388,63 @@ ieee80211_rx_h_amsdu(struct ieee80211_rx_data *rx)
 }
 
 static ieee80211_rx_result debug_noinline
+ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
+{
+	struct ieee80211_hdr *hdr;
+	struct ieee80211s_hdr *mesh_hdr;
+	unsigned int hdrlen;
+	struct sk_buff *skb = rx->skb, *fwd_skb;
+
+	hdr = (struct ieee80211_hdr *) skb->data;
+	hdrlen = ieee80211_hdrlen(hdr->frame_control);
+	mesh_hdr = (struct ieee80211s_hdr *) (skb->data + hdrlen);
+
+	if (!ieee80211_is_data(hdr->frame_control))
+		return RX_CONTINUE;
+
+	if (!mesh_hdr->ttl)
+		/* illegal frame */
+		return RX_DROP_MONITOR;
+
+	if (compare_ether_addr(rx->dev->dev_addr, hdr->addr3) == 0)
+		return RX_CONTINUE;
+
+	mesh_hdr->ttl--;
+
+	if (rx->flags & IEEE80211_RX_RA_MATCH) {
+		if (!mesh_hdr->ttl)
+			IEEE80211_IFSTA_MESH_CTR_INC(&rx->sdata->u.sta,
+						     dropped_frames_ttl);
+		else {
+			struct ieee80211_hdr *fwd_hdr;
+			fwd_skb = skb_copy(skb, GFP_ATOMIC);
+
+			if (!fwd_skb && net_ratelimit())
+				printk(KERN_DEBUG "%s: failed to clone mesh frame\n",
+						   rx->dev->name);
+
+			fwd_hdr =  (struct ieee80211_hdr *) fwd_skb->data;
+			/*
+			 * Save TA to addr1 to send TA a path error if a
+			 * suitable next hop is not found
+			 */
+			memcpy(fwd_hdr->addr1, fwd_hdr->addr2, ETH_ALEN);
+			memcpy(fwd_hdr->addr2, rx->dev->dev_addr, ETH_ALEN);
+			fwd_skb->dev = rx->local->mdev;
+			fwd_skb->iif = rx->dev->ifindex;
+			dev_queue_xmit(fwd_skb);
+		}
+	}
+
+	if (is_multicast_ether_addr(hdr->addr3) ||
+	    rx->dev->flags & IFF_PROMISC)
+		return RX_CONTINUE;
+	else
+		return RX_DROP_MONITOR;
+}
+
+
+static ieee80211_rx_result debug_noinline
 ieee80211_rx_h_data(struct ieee80211_rx_data *rx)
 {
 	struct net_device *dev = rx->dev;
@@ -1663,10 +1677,12 @@ static void ieee80211_invoke_rx_handlers(struct ieee80211_sub_if_data *sdata,
 	rx->sdata = sdata;
 	rx->dev = sdata->dev;
 
-#define CALL_RXH(rxh)		\
-	res = rxh(rx);		\
-	if (res != RX_CONTINUE)	\
-		goto rxh_done;
+#define CALL_RXH(rxh)			\
+	do {				\
+		res = rxh(rx);		\
+		if (res != RX_CONTINUE)	\
+			goto rxh_done;  \
+	} while (0);
 
 	CALL_RXH(ieee80211_rx_h_passive_scan)
 	CALL_RXH(ieee80211_rx_h_check)
@@ -1678,6 +1694,8 @@ static void ieee80211_invoke_rx_handlers(struct ieee80211_sub_if_data *sdata,
 	/* must be after MMIC verify so header is counted in MPDU mic */
 	CALL_RXH(ieee80211_rx_h_remove_qos_control)
 	CALL_RXH(ieee80211_rx_h_amsdu)
+	if (ieee80211_vif_is_mesh(&sdata->vif))
+		CALL_RXH(ieee80211_rx_h_mesh_fwding);
 	CALL_RXH(ieee80211_rx_h_data)
 	CALL_RXH(ieee80211_rx_h_ctrl)
 	CALL_RXH(ieee80211_rx_h_mgmt)
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 771ec68..4788f7b 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1301,6 +1301,7 @@ int ieee80211_master_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct net_device *odev = NULL;
 	struct ieee80211_sub_if_data *osdata;
 	int headroom;
@@ -1328,6 +1329,20 @@ int ieee80211_master_start_xmit(struct sk_buff *skb,
 
 	osdata = IEEE80211_DEV_TO_SUB_IF(odev);
 
+	if (ieee80211_vif_is_mesh(&osdata->vif) &&
+	    ieee80211_is_data(hdr->frame_control)) {
+		if (ieee80211_is_data(hdr->frame_control)) {
+			if (is_multicast_ether_addr(hdr->addr3))
+				memcpy(hdr->addr1, hdr->addr3, ETH_ALEN);
+			else
+				if (mesh_nexthop_lookup(skb, odev))
+					return  0;
+			if (memcmp(odev->dev_addr, hdr->addr4, ETH_ALEN) != 0)
+				IEEE80211_IFSTA_MESH_CTR_INC(&osdata->u.sta,
+							     fwded_frames);
+		}
+	}
+
 	may_encrypt = !skb->do_not_encrypt;
 
 	headroom = osdata->local->tx_headroom;
@@ -1472,30 +1487,17 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	case IEEE80211_IF_TYPE_MESH_POINT:
 		fc |= cpu_to_le16(IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS);
 		/* RA TA DA SA */
-		if (is_multicast_ether_addr(skb->data))
-			memcpy(hdr.addr1, skb->data, ETH_ALEN);
-		else if (mesh_nexthop_lookup(hdr.addr1, skb, dev))
-				return 0;
+		memset(hdr.addr1, 0, ETH_ALEN);
 		memcpy(hdr.addr2, dev->dev_addr, ETH_ALEN);
 		memcpy(hdr.addr3, skb->data, ETH_ALEN);
 		memcpy(hdr.addr4, skb->data + ETH_ALEN, ETH_ALEN);
-		if (skb->pkt_type == PACKET_OTHERHOST) {
-			/* Forwarded frame, keep mesh ttl and seqnum */
-			struct ieee80211s_hdr *prev_meshhdr;
-			prev_meshhdr = ((struct ieee80211s_hdr *)skb->cb);
-			meshhdrlen = ieee80211_get_mesh_hdrlen(prev_meshhdr);
-			memcpy(&mesh_hdr, prev_meshhdr, meshhdrlen);
-			sdata->u.sta.mshstats.fwded_frames++;
-		} else {
-			if (!sdata->u.sta.mshcfg.dot11MeshTTL) {
-				/* Do not send frames with mesh_ttl == 0 */
-				sdata->u.sta.mshstats.dropped_frames_ttl++;
-				ret = 0;
-				goto fail;
-			}
-			meshhdrlen = ieee80211_new_mesh_header(&mesh_hdr,
-							       sdata);
+		if (!sdata->u.sta.mshcfg.dot11MeshTTL) {
+			/* Do not send frames with mesh_ttl == 0 */
+			sdata->u.sta.mshstats.dropped_frames_ttl++;
+			ret = 0;
+			goto fail;
 		}
+		meshhdrlen = ieee80211_new_mesh_header(&mesh_hdr, sdata);
 		hdrlen = 30;
 		break;
 #endif
@@ -1543,7 +1545,8 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	 * Drop unicast frames to unauthorised stations unless they are
 	 * EAPOL frames from the local station.
 	 */
-	if (unlikely(!is_multicast_ether_addr(hdr.addr1) &&
+	if (!ieee80211_vif_is_mesh(&sdata->vif) &&
+		unlikely(!is_multicast_ether_addr(hdr.addr1) &&
 		      !(sta_flags & WLAN_STA_AUTHORIZED) &&
 		      !(ethertype == ETH_P_PAE &&
 		       compare_ether_addr(dev->dev_addr,
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
