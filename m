From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC/RFT 4/4] mac80211: use multi-queue master netdevice
Date: Wed, 30 Apr 2008 14:40:59 +0200
Message-ID: <20080430130051.397094000@sipsolutions.net>
References: <20080430124055.091382000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=039-mac80211-mq.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch updates mac80211 and drivers to be multi-queue aware and
use that instead of the internal queue mapping.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
This is just ground-work. We'll be able to play with Qos much more now.

 drivers/net/wireless/ath5k/base.c           |    2 -
 drivers/net/wireless/b43/dma.c              |    7 ++-
 drivers/net/wireless/b43/pio.c              |    8 ++--
 drivers/net/wireless/b43legacy/dma.c        |    2 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    4 +-
 drivers/net/wireless/p54/p54common.c        |   10 ++---
 drivers/net/wireless/rt2x00/rt2x00mac.c     |   12 +++---
 drivers/net/wireless/rt2x00/rt2x00pci.c     |    2 -
 drivers/net/wireless/rt2x00/rt2x00queue.h   |   13 ------
 drivers/net/wireless/rtl8180_dev.c          |    4 +-
 include/net/mac80211.h                      |   12 ++++--
 net/mac80211/Kconfig                        |   14 ++++++-
 net/mac80211/Makefile                       |    2 -
 net/mac80211/ieee80211_i.h                  |    7 ---
 net/mac80211/main.c                         |   21 ++++++----
 net/mac80211/tx.c                           |    9 ----
 net/mac80211/util.c                         |   54 +++++++++++++++++++---------
 net/mac80211/wme.c                          |   13 ++----
 net/mac80211/wme.h                          |    2 -
 20 files changed, 109 insertions(+), 93 deletions(-)

--- everything.orig/drivers/net/wireless/ath5k/base.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/ath5k/base.c	2008-04-30 14:02:34.000000000 +0200
@@ -2677,7 +2677,7 @@ ath5k_tx(struct ieee80211_hw *hw, struct
 	if (list_empty(&sc->txbuf)) {
 		ATH5K_ERR(sc, "no further txbuf available, dropping packet\n");
 		spin_unlock_irqrestore(&sc->txbuflock, flags);
-		ieee80211_stop_queue(hw, ctl->queue);
+		ieee80211_stop_queue(hw, skb_get_queue_mapping(skb));
 		return -1;
 	}
 	bf = list_first_entry(&sc->txbuf, struct ath5k_buf, list);
--- everything.orig/drivers/net/wireless/iwlwifi/iwl3945-base.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/iwlwifi/iwl3945-base.c	2008-04-30 14:02:34.000000000 +0200
@@ -2562,7 +2562,7 @@ static int iwl3945_tx_skb(struct iwl3945
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct iwl3945_tfd_frame *tfd;
 	u32 *control_flags;
-	int txq_id = ctl->queue;
+	int txq_id = skb_get_queue_mapping(skb);
 	struct iwl3945_tx_queue *txq = NULL;
 	struct iwl3945_queue *q = NULL;
 	dma_addr_t phys_addr;
@@ -2776,7 +2776,7 @@ static int iwl3945_tx_skb(struct iwl3945
 			spin_unlock_irqrestore(&priv->lock, flags);
 		}
 
-		ieee80211_stop_queue(priv->hw, ctl->queue);
+		ieee80211_stop_queue(priv->hw, skb_get_queue_mapping(skb));
 	}
 
 	return 0;
--- everything.orig/drivers/net/wireless/iwlwifi/iwl4965-base.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/iwlwifi/iwl4965-base.c	2008-04-30 14:02:34.000000000 +0200
@@ -2126,7 +2126,7 @@ static int iwl4965_tx_skb(struct iwl_pri
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct iwl4965_tfd_frame *tfd;
 	u32 *control_flags;
-	int txq_id = ctl->queue;
+	int txq_id = skb_get_queue_mapping(skb);
 	struct iwl4965_tx_queue *txq = NULL;
 	struct iwl4965_queue *q = NULL;
 	dma_addr_t phys_addr;
@@ -2350,7 +2350,7 @@ static int iwl4965_tx_skb(struct iwl_pri
 			spin_unlock_irqrestore(&priv->lock, flags);
 		}
 
-		ieee80211_stop_queue(priv->hw, ctl->queue);
+		ieee80211_stop_queue(priv->hw, skb_get_queue_mapping(skb));
 	}
 
 	return 0;
--- everything.orig/drivers/net/wireless/p54/p54common.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/p54/p54common.c	2008-04-30 14:02:34.000000000 +0200
@@ -417,7 +417,7 @@ static void p54_rx_frame_sent(struct iee
 			memcpy(&status.control, range->control,
 			       sizeof(status.control));
 			kfree(range->control);
-			priv->tx_stats[status.control.queue].len--;
+			priv->tx_stats[skb_get_queue_mapping(skb)].len--;
 			entry_hdr = (struct p54_control_hdr *) entry->data;
 			entry_data = (struct p54_tx_control_allocdata *) entry_hdr->data;
 			if ((entry_hdr->magic1 & cpu_to_le16(0x4000)) != 0)
@@ -562,13 +562,13 @@ static int p54_tx(struct ieee80211_hw *d
 	size_t padding, len;
 	u8 rate;
 
-	current_queue = &priv->tx_stats[control->queue];
+	current_queue = &priv->tx_stats[skb_get_queue_mapping(skb)];
 	if (unlikely(current_queue->len > current_queue->limit))
 		return NETDEV_TX_BUSY;
 	current_queue->len++;
 	current_queue->count++;
 	if (current_queue->len == current_queue->limit)
-		ieee80211_stop_queue(dev, control->queue);
+		ieee80211_stop_queue(dev, skb_get_queue_mapping(skb));
 
 	padding = (unsigned long)(skb->data - (sizeof(*hdr) + sizeof(*txhdr))) & 3;
 	len = skb->len;
@@ -605,7 +605,7 @@ static int p54_tx(struct ieee80211_hw *d
 	memset(txhdr->rateset, rate, 8);
 	txhdr->wep_key_present = 0;
 	txhdr->wep_key_len = 0;
-	txhdr->frame_type = cpu_to_le32(control->queue + 4);
+	txhdr->frame_type = cpu_to_le32(skb_get_queue_mapping(skb) + 4);
 	txhdr->magic4 = 0;
 	txhdr->antenna = (control->antenna_sel_tx == 0) ?
 		2 : control->antenna_sel_tx - 1;
@@ -944,7 +944,7 @@ static int p54_conf_tx(struct ieee80211_
 	vdcf = (struct p54_tx_control_vdcf *)(((struct p54_control_hdr *)
 		((void *)priv->cached_vdcf + priv->tx_hdr_len))->data);
 
-	if ((params) && !((queue < 0) || (queue > 4))) {
+	if (params && queue < dev->queues) {
 		P54_SET_QUEUE(vdcf->queue[queue], params->aifs,
 			params->cw_min, params->cw_max, params->txop);
 	} else
--- everything.orig/drivers/net/wireless/rtl8180_dev.c	2008-04-30 14:02:31.000000000 +0200
+++ everything/drivers/net/wireless/rtl8180_dev.c	2008-04-30 14:02:34.000000000 +0200
@@ -251,7 +251,7 @@ static int rtl8180_tx(struct ieee80211_h
 	u16 plcp_len = 0;
 	__le16 rts_duration = 0;
 
-	prio = control->queue;
+	prio = skb_get_queue_mapping(skb);
 	ring = &priv->tx_ring[prio];
 
 	mapping = pci_map_single(priv->pdev, skb->data,
@@ -306,7 +306,7 @@ static int rtl8180_tx(struct ieee80211_h
 	entry->flags = cpu_to_le32(tx_flags);
 	__skb_queue_tail(&ring->queue, skb);
 	if (ring->entries - skb_queue_len(&ring->queue) < 2)
-		ieee80211_stop_queue(dev, control->queue);
+		ieee80211_stop_queue(dev, skb_get_queue_mapping(skb));
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	rtl818x_iowrite8(priv, &priv->map->TX_DMA_POLLING, (1 << (prio + 4)));
--- everything.orig/include/net/mac80211.h	2008-04-30 14:02:31.000000000 +0200
+++ everything/include/net/mac80211.h	2008-04-30 14:02:34.000000000 +0200
@@ -282,9 +282,6 @@ struct ieee80211_tx_control {
 				 * This could be used when set_retry_limit
 				 * is not implemented by the driver */
 
-	u16 queue;		/* hardware queue to use for this frame;
-				 * 0 = highest, hw->queues-1 = lowest */
-
 	struct ieee80211_vif *vif;
 
 	/* Key used for hardware encryption
@@ -1575,6 +1572,15 @@ void ieee80211_wake_queue(struct ieee802
 void ieee80211_stop_queue(struct ieee80211_hw *hw, int queue);
 
 /**
+ * ieee80211_start_queue - start specific queue
+ * @hw: pointer as obtained from ieee80211_alloc_hw().
+ * @queue: queue number (counted from zero).
+ *
+ * Drivers should use this function instead of netif_start_queue.
+ */
+void ieee80211_start_queue(struct ieee80211_hw *hw, int queue);
+
+/**
  * ieee80211_start_queues - start all queues
  * @hw: pointer to as obtained from ieee80211_alloc_hw().
  *
--- everything.orig/net/mac80211/Kconfig	2008-04-30 14:02:31.000000000 +0200
+++ everything/net/mac80211/Kconfig	2008-04-30 14:25:39.000000000 +0200
@@ -7,11 +7,23 @@ config MAC80211
 	select CRC32
 	select WIRELESS_EXT
 	select CFG80211
-	select NET_SCH_FIFO
 	---help---
 	  This option enables the hardware independent IEEE 802.11
 	  networking stack.
 
+config MAC80211_QOS
+	def_bool y
+	depends on MAC80211
+	depends on NET_SCHED
+	depends on NETDEVICES_MULTIQUEUE
+
+comment "QoS/HT support disabled"
+	depends on !MAC80211_QOS
+comment "QoS/HT support needs CONFIG_NET_SCHED"
+	depends on MAC80211 && !NET_SCHED
+comment "QoS/HT support needs CONFIG_NETDEVICES_MULTIQUEUE"
+	depends on MAC80211 && !NETDEVICES_MULTIQUEUE
+
 menu "Rate control algorithm selection"
 	depends on MAC80211 != n
 
--- everything.orig/net/mac80211/Makefile	2008-04-30 14:02:31.000000000 +0200
+++ everything/net/mac80211/Makefile	2008-04-30 14:02:34.000000000 +0200
@@ -29,7 +29,7 @@ mac80211-y := \
 	event.o
 
 mac80211-$(CONFIG_MAC80211_LEDS) += led.o
-mac80211-$(CONFIG_NET_SCHED) += wme.o
+mac80211-$(CONFIG_MAC80211_QOS) += wme.o
 mac80211-$(CONFIG_MAC80211_DEBUGFS) += \
 	debugfs.o \
 	debugfs_sta.o \
--- everything.orig/net/mac80211/ieee80211_i.h	2008-04-30 14:02:31.000000000 +0200
+++ everything/net/mac80211/ieee80211_i.h	2008-04-30 14:02:34.000000000 +0200
@@ -213,7 +213,6 @@ struct ieee80211_rx_data {
 struct ieee80211_tx_packet_data {
 	u32 flags;
 	int ifindex;
-	u16 queue;
 	unsigned long jiffies;
 };
 
@@ -605,8 +604,6 @@ struct ieee80211_local {
 	struct sta_info *sta_hash[STA_HASH_SIZE];
 	struct timer_list sta_cleanup;
 
-	unsigned long state[IEEE80211_MAX_AMPDU_QUEUES + IEEE80211_MAX_AMPDU_QUEUES];
-
 	/* number of interfaces with corresponding IFF_ flags */
 	atomic_t iff_allmultis, iff_promiscs;
 
@@ -836,10 +833,6 @@ static inline struct ieee80211_hw *local
 	return &local->hw;
 }
 
-enum ieee80211_link_state_t {
-	IEEE80211_LINK_STATE_XOFF = 0,
-};
-
 struct sta_attribute {
 	struct attribute attr;
 	ssize_t (*show)(const struct sta_info *, char *buf);
--- everything.orig/net/mac80211/main.c	2008-04-30 14:02:31.000000000 +0200
+++ everything/net/mac80211/main.c	2008-04-30 14:18:53.000000000 +0200
@@ -1313,7 +1313,6 @@ static void ieee80211_remove_tx_extra(st
 		pkt_data->flags |= IEEE80211_TXPD_REQUEUE;
 	if (control->flags & IEEE80211_TXCTL_EAPOL_FRAME)
 		pkt_data->flags |= IEEE80211_TXPD_EAPOL_FRAME;
-	pkt_data->queue = control->queue;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
 
@@ -1713,9 +1712,20 @@ int ieee80211_register_hw(struct ieee802
 	if (result < 0)
 		return result;
 
+#ifdef CONFIG_MAC80211_QOS
+	if (hw->queues > IEEE80211_MAX_QUEUES)
+		hw->queues = IEEE80211_MAX_QUEUES;
+	if (hw->ampdu_queues > IEEE80211_MAX_AMPDU_QUEUES)
+		hw->ampdu_queues = IEEE80211_MAX_AMPDU_QUEUES;
+#else
+	hw->queues = 1;
+	hw->ampdu_queues = 0;
+#endif
+
 	/* for now, mdev needs sub_if_data :/ */
-	mdev = alloc_netdev(sizeof(struct ieee80211_sub_if_data),
-			    "wmaster%d", ether_setup);
+	mdev = alloc_netdev_mq(sizeof(struct ieee80211_sub_if_data),
+			       "wmaster%d", ether_setup,
+			       hw->queues + hw->ampdu_queues);
 	if (!mdev)
 		goto fail_mdev_alloc;
 
@@ -1807,11 +1817,6 @@ int ieee80211_register_hw(struct ieee802
 		goto fail_wep;
 	}
 
-	if (hw->queues > IEEE80211_MAX_QUEUES)
-		hw->queues = IEEE80211_MAX_QUEUES;
-	if (hw->ampdu_queues > IEEE80211_MAX_AMPDU_QUEUES)
-		hw->ampdu_queues = IEEE80211_MAX_AMPDU_QUEUES;
-
 	ieee80211_install_qdisc(local->mdev);
 
 	/* add one default STA interface */
--- everything.orig/net/mac80211/tx.c	2008-04-30 14:02:31.000000000 +0200
+++ everything/net/mac80211/tx.c	2008-04-30 14:02:34.000000000 +0200
@@ -210,12 +210,6 @@ static u16 ieee80211_duration(struct iee
 	return dur;
 }
 
-static inline int __ieee80211_queue_stopped(const struct ieee80211_local *local,
-					    int queue)
-{
-	return test_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]);
-}
-
 static int inline is_ieee80211_device(struct net_device *dev,
 				      struct net_device *master)
 {
@@ -1066,7 +1060,7 @@ static int ___ieee80211_tx(struct ieee80
 	print_control(control, skb);
 
 	if (unlikely(netif_queue_stopped(local->mdev) ||
-		     __ieee80211_queue_stopped(local, control->queue)))
+		     netif_subqueue_stopped(local->mdev, skb)))
 		return NETDEV_TX_BUSY;
 
 	ieee80211_dump_frame(wiphy_name(local->hw.wiphy),
@@ -1354,7 +1348,6 @@ int ieee80211_master_start_xmit(struct s
 		control.flags |= IEEE80211_TXCTL_EAPOL_FRAME;
 	if (pkt_data->flags & IEEE80211_TXPD_AMPDU)
 		control.flags |= IEEE80211_TXCTL_AMPDU;
-	control.queue = pkt_data->queue;
 
 	memset(skb->cb, 0, sizeof(skb->cb));
 	ret = ieee80211_tx(odev, skb, &control);
--- everything.orig/net/mac80211/util.c	2008-04-30 14:02:31.000000000 +0200
+++ everything/net/mac80211/util.c	2008-04-30 14:20:06.000000000 +0200
@@ -323,18 +323,28 @@ __le16 ieee80211_ctstoself_duration(stru
 }
 EXPORT_SYMBOL(ieee80211_ctstoself_duration);
 
+void ieee80211_start_queue(struct ieee80211_hw *hw, int queue)
+{
+	struct ieee80211_local *local = hw_to_local(hw);
+#ifdef CONFIG_MAC80211_QOS
+	netif_start_subqueue(local->mdev, queue);
+#else
+	WARN_ON(queue != 0);
+	netif_start_queue(local->mdev);
+#endif
+}
+EXPORT_SYMBOL(ieee80211_start_queue);
+
 void ieee80211_wake_queue(struct ieee80211_hw *hw, int queue)
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 
-	if (test_and_clear_bit(IEEE80211_LINK_STATE_XOFF,
-			       &local->state[queue])) {
-		if (!ieee80211_qdisc_installed(local->mdev)) {
-			if (queue == 0)
-				netif_wake_queue(local->mdev);
-		} else
-			__netif_schedule(local->mdev);
-	}
+#ifdef CONFIG_MAC80211_QOS
+	netif_wake_subqueue(local->mdev, queue);
+#else
+	WARN_ON(queue != 0);
+	netif_wake_queue(local->mdev);
+#endif
 }
 EXPORT_SYMBOL(ieee80211_wake_queue);
 
@@ -342,39 +352,51 @@ void ieee80211_stop_queue(struct ieee802
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 
-	if (!ieee80211_qdisc_installed(local->mdev) && queue == 0)
-		netif_stop_queue(local->mdev);
-	set_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]);
+#ifdef CONFIG_MAC80211_QOS
+	netif_stop_subqueue(local->mdev, queue);
+#else
+	WARN_ON(queue != 0);
+	netif_stop_queue(local->mdev);
+#endif
 }
 EXPORT_SYMBOL(ieee80211_stop_queue);
 
 void ieee80211_start_queues(struct ieee80211_hw *hw)
 {
-	struct ieee80211_local *local = hw_to_local(hw);
+#ifdef CONFIG_MAC80211_QOS
 	int i;
 
-	for (i = 0; i < local->hw.queues; i++)
-		clear_bit(IEEE80211_LINK_STATE_XOFF, &local->state[i]);
-	if (!ieee80211_qdisc_installed(local->mdev))
-		netif_start_queue(local->mdev);
+	for (i = 0; i < hw->queues; i++)
+		ieee80211_start_queue(hw, i);
+#else
+	netif_start_queue(local->mdev);
+#endif
 }
 EXPORT_SYMBOL(ieee80211_start_queues);
 
 void ieee80211_stop_queues(struct ieee80211_hw *hw)
 {
+#ifdef CONFIG_MAC80211_QOS
 	int i;
 
 	for (i = 0; i < hw->queues; i++)
 		ieee80211_stop_queue(hw, i);
+#else
+	netif_stop_queue(local->mdev);
+#endif
 }
 EXPORT_SYMBOL(ieee80211_stop_queues);
 
 void ieee80211_wake_queues(struct ieee80211_hw *hw)
 {
+#ifdef CONFIG_MAC80211_QOS
 	int i;
 
 	for (i = 0; i < hw->queues; i++)
 		ieee80211_wake_queue(hw, i);
+#else
+	netif_wake_queue(local->mdev);
+#endif
 }
 EXPORT_SYMBOL(ieee80211_wake_queues);
 
--- everything.orig/net/mac80211/wme.c	2008-04-30 14:02:31.000000000 +0200
+++ everything/net/mac80211/wme.c	2008-04-30 14:35:44.000000000 +0200
@@ -160,7 +160,7 @@ static int wme_qdiscop_enqueue(struct sk
 	u8 tid;
 
 	if (pkt_data->flags & IEEE80211_TXPD_REQUEUE) {
-		queue = pkt_data->queue;
+		queue = skb_get_queue_mapping(skb);
 		rcu_read_lock();
 		sta = sta_info_get(local, hdr->addr1);
 		tid = skb->priority & QOS_CONTROL_TAG1D_MASK;
@@ -221,7 +221,7 @@ static int wme_qdiscop_enqueue(struct sk
 			err = NET_XMIT_DROP;
 	} else {
 		tid = skb->priority & QOS_CONTROL_TAG1D_MASK;
-		pkt_data->queue = (unsigned int) queue;
+		skb_set_queue_mapping(skb, queue);
 		qdisc = q->queues[queue];
 		err = qdisc->enqueue(skb, qdisc);
 		if (err == NET_XMIT_SUCCESS) {
@@ -239,13 +239,10 @@ static int wme_qdiscop_enqueue(struct sk
 static int wme_qdiscop_requeue(struct sk_buff *skb, struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_tx_packet_data *pkt_data =
-		(struct ieee80211_tx_packet_data *) skb->cb;
 	struct Qdisc *qdisc;
 	int err;
 
-	/* We recorded which queue to use earlier. */
-	qdisc = q->queues[pkt_data->queue];
+	qdisc = q->queues[skb_get_queue_mapping(skb)];
 
 	if ((err = qdisc->ops->requeue(skb, qdisc)) == 0) {
 		qd->q.qlen++;
@@ -269,9 +266,7 @@ static struct sk_buff *wme_qdiscop_deque
 	/* check all the h/w queues in numeric/priority order */
 	for (queue = 0; queue < QD_NUM(hw); queue++) {
 		/* see if there is room in this hardware queue */
-		if ((test_bit(IEEE80211_LINK_STATE_XOFF,
-				&local->state[queue])) ||
-		    (!test_bit(queue, q->qdisc_pool)))
+		if (__netif_subqueue_stopped(local->mdev, queue))
 			continue;
 
 		/* there is space - try and get a frame */
--- everything.orig/net/mac80211/wme.h	2008-04-30 14:02:31.000000000 +0200
+++ everything/net/mac80211/wme.h	2008-04-30 14:02:34.000000000 +0200
@@ -31,7 +31,7 @@ static inline int WLAN_FC_IS_QOS_DATA(u1
 	return (fc & 0x8C) == 0x88;
 }
 
-#ifdef CONFIG_NET_SCHED
+#ifdef CONFIG_MAC80211_QOS
 void ieee80211_install_qdisc(struct net_device *dev);
 int ieee80211_qdisc_installed(struct net_device *dev);
 int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
--- everything.orig/drivers/net/wireless/b43/dma.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/b43/dma.c	2008-04-30 14:02:34.000000000 +0200
@@ -1298,7 +1298,8 @@ int b43_dma_tx(struct b43_wldev *dev,
 		hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREDATA);
 	} else {
 		/* Decide by priority where to put this frame. */
-		ring = select_ring_by_priority(dev, ctl->queue);
+		ring = select_ring_by_priority(
+			dev, skb_get_queue_mapping(skb));
 	}
 
 	spin_lock_irqsave(&ring->lock, flags);
@@ -1316,7 +1317,7 @@ int b43_dma_tx(struct b43_wldev *dev,
 	/* Assign the queue number to the ring (if not already done before)
 	 * so TX status handling can use it. The queue to ring mapping is
 	 * static, so we don't need to store it per frame. */
-	ring->queue_prio = ctl->queue;
+	ring->queue_prio = skb_get_queue_mapping(skb);
 
 	err = dma_tx_fragment(ring, skb, ctl);
 	if (unlikely(err == -ENOKEY)) {
@@ -1334,7 +1335,7 @@ int b43_dma_tx(struct b43_wldev *dev,
 	if ((free_slots(ring) < SLOTS_PER_PACKET) ||
 	    should_inject_overflow(ring)) {
 		/* This TX ring is full. */
-		ieee80211_stop_queue(dev->wl->hw, ctl->queue);
+		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
 		ring->stopped = 1;
 		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
 			b43dbg(dev->wl, "Stopped TX ring %d\n", ring->index);
--- everything.orig/drivers/net/wireless/b43/pio.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/b43/pio.c	2008-04-30 14:02:34.000000000 +0200
@@ -510,7 +510,7 @@ int b43_pio_tx(struct b43_wldev *dev,
 		hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREDATA);
 	} else {
 		/* Decide by priority where to put this frame. */
-		q = select_queue_by_priority(dev, ctl->queue);
+		q = select_queue_by_priority(dev, skb_get_queue_mapping(skb));
 	}
 
 	spin_lock_irqsave(&q->lock, flags);
@@ -533,7 +533,7 @@ int b43_pio_tx(struct b43_wldev *dev,
 	if (total_len > (q->buffer_size - q->buffer_used)) {
 		/* Not enough memory on the queue. */
 		err = -EBUSY;
-		ieee80211_stop_queue(dev->wl->hw, ctl->queue);
+		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
 		q->stopped = 1;
 		goto out_unlock;
 	}
@@ -541,7 +541,7 @@ int b43_pio_tx(struct b43_wldev *dev,
 	/* Assign the queue number to the ring (if not already done before)
 	 * so TX status handling can use it. The mac80211-queue to b43-queue
 	 * mapping is static, so we don't need to store it per frame. */
-	q->queue_prio = ctl->queue;
+	q->queue_prio = skb_get_queue_mapping(skb);
 
 	err = pio_tx_frame(q, skb, ctl);
 	if (unlikely(err == -ENOKEY)) {
@@ -561,7 +561,7 @@ int b43_pio_tx(struct b43_wldev *dev,
 	if (((q->buffer_size - q->buffer_used) < roundup(2 + 2 + 6, 4)) ||
 	    (q->free_packet_slots == 0)) {
 		/* The queue is full. */
-		ieee80211_stop_queue(dev->wl->hw, ctl->queue);
+		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
 		q->stopped = 1;
 	}
 
--- everything.orig/drivers/net/wireless/b43legacy/dma.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/b43legacy/dma.c	2008-04-30 14:02:34.000000000 +0200
@@ -1330,7 +1330,7 @@ int b43legacy_dma_tx(struct b43legacy_wl
 	int err = 0;
 	unsigned long flags;
 
-	ring = priority_to_txring(dev, ctl->queue);
+	ring = priority_to_txring(dev, skb_get_queue_mapping(skb));
 	spin_lock_irqsave(&ring->lock, flags);
 	B43legacy_WARN_ON(!ring->tx);
 	if (unlikely(free_slots(ring) < SLOTS_PER_PACKET)) {
--- everything.orig/drivers/net/wireless/rt2x00/rt2x00mac.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/rt2x00/rt2x00mac.c	2008-04-30 14:02:34.000000000 +0200
@@ -81,7 +81,7 @@ int rt2x00mac_tx(struct ieee80211_hw *hw
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
 	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr *)skb->data;
-	enum data_queue_qid qid = mac80211_queue_to_qid(control->queue);
+	enum data_queue_qid qid = skb_get_queue_mapping(skb);
 	struct data_queue *queue;
 	struct skb_frame_desc *skbdesc;
 	u16 frame_control;
@@ -129,12 +129,14 @@ int rt2x00mac_tx(struct ieee80211_hw *hw
 			       IEEE80211_TXCTL_USE_CTS_PROTECT)) &&
 	    !rt2x00dev->ops->hw->set_rts_threshold) {
 		if (rt2x00queue_available(queue) <= 1) {
-			ieee80211_stop_queue(rt2x00dev->hw, control->queue);
+			ieee80211_stop_queue(
+				rt2x00dev->hw, skb_get_queue_mapping(skb));
 			return NETDEV_TX_BUSY;
 		}
 
 		if (rt2x00mac_tx_rts_cts(rt2x00dev, queue, skb, control)) {
-			ieee80211_stop_queue(rt2x00dev->hw, control->queue);
+			ieee80211_stop_queue(
+				rt2x00dev->hw, skb_get_queue_mapping(skb));
 			return NETDEV_TX_BUSY;
 		}
 	}
@@ -146,12 +148,12 @@ int rt2x00mac_tx(struct ieee80211_hw *hw
 	memset(skbdesc, 0, sizeof(*skbdesc));
 
 	if (rt2x00dev->ops->lib->write_tx_data(rt2x00dev, queue, skb, control)) {
-		ieee80211_stop_queue(rt2x00dev->hw, control->queue);
+		ieee80211_stop_queue(rt2x00dev->hw, skb_get_queue_mapping(skb));
 		return NETDEV_TX_BUSY;
 	}
 
 	if (rt2x00queue_full(queue))
-		ieee80211_stop_queue(rt2x00dev->hw, control->queue);
+		ieee80211_stop_queue(rt2x00dev->hw, skb_get_queue_mapping(skb));
 
 	if (rt2x00dev->ops->lib->kick_tx_queue)
 		rt2x00dev->ops->lib->kick_tx_queue(rt2x00dev, qid);
--- everything.orig/drivers/net/wireless/rt2x00/rt2x00pci.c	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/rt2x00/rt2x00pci.c	2008-04-30 14:02:34.000000000 +0200
@@ -178,7 +178,7 @@ void rt2x00pci_txdone(struct rt2x00_dev 
 	 * is reenabled when the txdone handler has finished.
 	 */
 	if (!rt2x00queue_full(entry->queue))
-		ieee80211_wake_queue(rt2x00dev->hw, priv_tx->control.queue);
+		ieee80211_wake_queue(rt2x00dev->hw, entry->queue->qid);
 
 }
 EXPORT_SYMBOL_GPL(rt2x00pci_txdone);
--- everything.orig/drivers/net/wireless/rt2x00/rt2x00queue.h	2008-04-30 14:02:32.000000000 +0200
+++ everything/drivers/net/wireless/rt2x00/rt2x00queue.h	2008-04-30 14:02:34.000000000 +0200
@@ -80,19 +80,6 @@ enum data_queue_qid {
 };
 
 /**
- * mac80211_queue_to_qid - Convert mac80211 queue to rt2x00 qid
- * @queue: mac80211 queue.
- */
-static inline enum data_queue_qid mac80211_queue_to_qid(unsigned int queue)
-{
-	/* Regular TX queues are mapped directly */
-	if (queue < 4)
-		return queue;
-	WARN_ON(1);
-	return QID_OTHER;
-}
