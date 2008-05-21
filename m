From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-05-20
Date: Tue, 20 May 2008 22:57:16 -0400
Message-ID: <20080521025716.GA11085@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4933 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583AbYEUD2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 23:28:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another round of fixes intended for 2.6.26...one of these ("ath5k: Fix
loop variable initializations") is already queued in net-next-2.6, but
it fixes the following bugzilla:

	http://bugzilla.kernel.org/show_bug.cgi?id=10605

Also included is "mac80211: fix NULL pointer dereference in
ieee80211_compatible_rates", which fixes another bugzilla:

	http://bugzilla.kernel.org/show_bug.cgi?id=10755

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 6f704992d3658aadff9e506c7fd80957fce33c5f:
  YOSHIFUJI Hideaki (1):
        ipv6 addrconf: Allow infinite prefix lifetime.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Copeland (1):
      ath5k: Fix loop variable initializations

David Woodhouse (1):
      libertas: Fix ethtool statistics

Helmut Schaa (1):
      mac80211: fix NULL pointer dereference in ieee80211_compatible_rates

Johannes Berg (1):
      mac80211: don't claim iwspy support

Oliver Neukum (1):
      rtl8187: resource leak in error case

Pavel Roskin (2):
      hostap_cs: add ID for Conceptronic CON11CPro
      orinoco_cs: add ID for SpeedStream wireless adapters

 drivers/net/wireless/ath5k/base.c       |    2 ++
 drivers/net/wireless/ath5k/hw.c         |    6 ++++--
 drivers/net/wireless/hostap/hostap_cs.c |    1 +
 drivers/net/wireless/libertas/ethtool.c |   27 +++++++++++++--------------
 drivers/net/wireless/orinoco_cs.c       |    1 +
 drivers/net/wireless/rtl8187_dev.c      |   14 ++++++++++++--
 net/mac80211/mlme.c                     |   15 +++++++++++----
 net/mac80211/wext.c                     |    1 -
 8 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index 4e5c8fc..635b9ac 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -1787,6 +1787,8 @@ ath5k_tasklet_rx(unsigned long data)
 
 	spin_lock(&sc->rxbuflock);
 	do {
+		rxs.flag = 0;
+
 		if (unlikely(list_empty(&sc->rxbuf))) {
 			ATH5K_WARN(sc, "empty rx buf pool\n");
 			break;
diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index 5fb1ae6..77990b5 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -4119,6 +4119,7 @@ static int ath5k_hw_proc_5210_rx_status(struct ath5k_hw *ah,
 	rs->rs_tstamp = AR5K_REG_MS(rx_status->rx_status_1,
 		AR5K_5210_RX_DESC_STATUS1_RECEIVE_TIMESTAMP);
 	rs->rs_status = 0;
+	rs->rs_phyerr = 0;
 
 	/*
 	 * Key table status
@@ -4145,7 +4146,7 @@ static int ath5k_hw_proc_5210_rx_status(struct ath5k_hw *ah,
 		if (rx_status->rx_status_1 &
 				AR5K_5210_RX_DESC_STATUS1_PHY_ERROR) {
 			rs->rs_status |= AR5K_RXERR_PHY;
-			rs->rs_phyerr = AR5K_REG_MS(rx_status->rx_status_1,
+			rs->rs_phyerr |= AR5K_REG_MS(rx_status->rx_status_1,
 					   AR5K_5210_RX_DESC_STATUS1_PHY_ERROR);
 		}
 
@@ -4193,6 +4194,7 @@ static int ath5k_hw_proc_5212_rx_status(struct ath5k_hw *ah,
 	rs->rs_tstamp = AR5K_REG_MS(rx_status->rx_status_1,
 		AR5K_5212_RX_DESC_STATUS1_RECEIVE_TIMESTAMP);
 	rs->rs_status = 0;
+	rs->rs_phyerr = 0;
 
 	/*
 	 * Key table status
@@ -4215,7 +4217,7 @@ static int ath5k_hw_proc_5212_rx_status(struct ath5k_hw *ah,
 		if (rx_status->rx_status_1 &
 				AR5K_5212_RX_DESC_STATUS1_PHY_ERROR) {
 			rs->rs_status |= AR5K_RXERR_PHY;
-			rs->rs_phyerr = AR5K_REG_MS(rx_err->rx_error_1,
+			rs->rs_phyerr |= AR5K_REG_MS(rx_err->rx_error_1,
 					   AR5K_RX_DESC_ERROR1_PHY_ERROR_CODE);
 		}
 
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 437a9bc..ed4317a 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -833,6 +833,7 @@ static struct pcmcia_device_id hostap_cs_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x0001),
 	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x7300),
 /*	PCMCIA_DEVICE_MANF_CARD(0xc00f, 0x0000),    conflict with pcnet_cs */
+	PCMCIA_DEVICE_MANF_CARD(0xc250, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0005),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0010),
diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/libertas/ethtool.c
index dcfdb40..688d60d 100644
--- a/drivers/net/wireless/libertas/ethtool.c
+++ b/drivers/net/wireless/libertas/ethtool.c
@@ -73,8 +73,8 @@ out:
         return ret;
 }
 
-static void lbs_ethtool_get_stats(struct net_device * dev,
-				struct ethtool_stats * stats, u64 * data)
+static void lbs_ethtool_get_stats(struct net_device *dev,
+				  struct ethtool_stats *stats, uint64_t *data)
 {
 	struct lbs_private *priv = dev->priv;
 	struct cmd_ds_mesh_access mesh_access;
@@ -83,12 +83,12 @@ static void lbs_ethtool_get_stats(struct net_device * dev,
 	lbs_deb_enter(LBS_DEB_ETHTOOL);
 
 	/* Get Mesh Statistics */
-	ret = lbs_prepare_and_send_command(priv,
-			CMD_MESH_ACCESS, CMD_ACT_MESH_GET_STATS,
-			CMD_OPTION_WAITFORRSP, 0, &mesh_access);
+	ret = lbs_mesh_access(priv, CMD_ACT_MESH_GET_STATS, &mesh_access);
 
-	if (ret)
+	if (ret) {
+		memset(data, 0, MESH_STATS_NUM*(sizeof(uint64_t)));
 		return;
+	}
 
 	priv->mstats.fwd_drop_rbt = le32_to_cpu(mesh_access.data[0]);
 	priv->mstats.fwd_drop_ttl = le32_to_cpu(mesh_access.data[1]);
@@ -111,19 +111,18 @@ static void lbs_ethtool_get_stats(struct net_device * dev,
 	lbs_deb_enter(LBS_DEB_ETHTOOL);
 }
 
-static int lbs_ethtool_get_sset_count(struct net_device * dev, int sset)
+static int lbs_ethtool_get_sset_count(struct net_device *dev, int sset)
 {
-	switch (sset) {
-	case ETH_SS_STATS:
+	struct lbs_private *priv = dev->priv;
+
+	if (sset == ETH_SS_STATS && dev == priv->mesh_dev)
 		return MESH_STATS_NUM;
-	default:
-		return -EOPNOTSUPP;
-	}
+
+	return -EOPNOTSUPP;
 }
 
 static void lbs_ethtool_get_strings(struct net_device *dev,
-					  u32 stringset,
-					  u8 * s)
+				    uint32_t stringset, uint8_t *s)
 {
 	int i;
 
diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index 8b7f576..1c216e0 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -461,6 +461,7 @@ static struct pcmcia_device_id orinoco_cs_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0673), /* Linksys WCF12 Wireless CompactFlash Card */
 	PCMCIA_DEVICE_MANF_CARD(0x02aa, 0x0002), /* ASUS SpaceLink WL-100 */
 	PCMCIA_DEVICE_MANF_CARD(0x02ac, 0x0002), /* SpeedStream SS1021 Wireless Adapter */
+	PCMCIA_DEVICE_MANF_CARD(0x02ac, 0x3021), /* SpeedStream Wireless Adapter */
 	PCMCIA_DEVICE_MANF_CARD(0x14ea, 0xb001), /* PLANEX RoadLannerWave GW-NS11H */
 	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x7300), /* Airvast WN-100 */
 	PCMCIA_DEVICE_MANF_CARD(0x9005, 0x0021), /* Adaptec Ultra Wireless ANW-8030 */
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index d5787b3..9223ada 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -92,6 +92,7 @@ static void rtl8187_iowrite_async(struct rtl8187_priv *priv, __le16 addr,
 		u8 data[4];
 		struct usb_ctrlrequest dr;
 	} *buf;
+	int rc;
 
 	buf = kmalloc(sizeof(*buf), GFP_ATOMIC);
 	if (!buf)
@@ -116,7 +117,11 @@ static void rtl8187_iowrite_async(struct rtl8187_priv *priv, __le16 addr,
 	usb_fill_control_urb(urb, priv->udev, usb_sndctrlpipe(priv->udev, 0),
 			     (unsigned char *)dr, buf, len,
 			     rtl8187_iowrite_async_cb, buf);
-	usb_submit_urb(urb, GFP_ATOMIC);
+	rc = usb_submit_urb(urb, GFP_ATOMIC);
+	if (rc < 0) {
+		kfree(buf);
+		usb_free_urb(urb);
+	}
 }
 
 static inline void rtl818x_iowrite32_async(struct rtl8187_priv *priv,
@@ -169,6 +174,7 @@ static int rtl8187_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
 	struct urb *urb;
 	__le16 rts_dur = 0;
 	u32 flags;
+	int rc;
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
@@ -208,7 +214,11 @@ static int rtl8187_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
 	info->dev = dev;
 	usb_fill_bulk_urb(urb, priv->udev, usb_sndbulkpipe(priv->udev, 2),
 			  hdr, skb->len, rtl8187_tx_cb, skb);
-	usb_submit_urb(urb, GFP_ATOMIC);
+	rc = usb_submit_urb(urb, GFP_ATOMIC);
+	if (rc < 0) {
+		usb_free_urb(urb);
+		kfree_skb(skb);
+	}
 
 	return 0;
 }
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index e470bf1..7cfd12e 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -730,7 +730,17 @@ static void ieee80211_send_assoc(struct net_device *dev,
 		if (bss->wmm_ie) {
 			wmm = 1;
 		}
+
+		/* get all rates supported by the device and the AP as
+		 * some APs don't like getting a superset of their rates
+		 * in the association request (e.g. D-Link DAP 1353 in
+		 * b-only mode) */
+		rates_len = ieee80211_compatible_rates(bss, sband, &rates);
+
 		ieee80211_rx_bss_put(dev, bss);
+	} else {
+		rates = ~0;
+		rates_len = sband->n_bitrates;
 	}
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
@@ -761,10 +771,7 @@ static void ieee80211_send_assoc(struct net_device *dev,
 	*pos++ = ifsta->ssid_len;
 	memcpy(pos, ifsta->ssid, ifsta->ssid_len);
 
-	/* all supported rates should be added here but some APs
-	 * (e.g. D-Link DAP 1353 in b-only mode) don't like that
-	 * Therefore only add rates the AP supports */
-	rates_len = ieee80211_compatible_rates(bss, sband, &rates);
+	/* add all rates which were marked to be used above */
 	supp_rates_len = rates_len;
 	if (supp_rates_len > 8)
 		supp_rates_len = 8;
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index 76e1de1..457ebf9 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -209,7 +209,6 @@ static int ieee80211_ioctl_giwrange(struct net_device *dev,
 	range->num_frequency = c;
 
 	IW_EVENT_CAPA_SET_KERNEL(range->event_capa);
-	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWTHRSPY);
 	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWAP);
 	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWSCAN);
 
-- 
John W. Linville
linville@tuxdriver.com
