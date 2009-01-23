From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-01-23
Date: Fri, 23 Jan 2009 16:03:49 -0500
Message-ID: <20090123210348.GF30486@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43988 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755232AbZAWVPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 16:15:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another quick round of fixes intended for 2.6.29...

The p54 and rtl8187 fixes are simple changes inspired by other fixes
already in 2.6.29.  The iwlwifi one fixes an annoying WARN_ON that
people are hitting quite a bit.

Please let me know if there are problems!  A batch for net-next-2.6 is
coming soon!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit c64d2a9afbccd0aecb122d108770a407fe7b7e3f:
  Steve Glendinning (1):
        phy: Add suspend/resume support to SMSC PHYs

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abbas, Mohamed (1):
      iwlwifi: fix rs_get_rate WARN_ON()

Christian Lamparter (1):
      p54usb: fix packet loss with first generation devices

Larry Finger (1):
      rtl8187: Add termination packet to prevent stall

 drivers/net/wireless/iwlwifi/iwl-3945-rs.c |   14 +++++++++++---
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c  |   14 ++++++++++++--
 drivers/net/wireless/p54/p54usb.c          |    7 +++++--
 drivers/net/wireless/rtl818x/rtl8187_dev.c |    1 +
 4 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/arch/arm/mach-integrator/clock.h b/arch/arm/mach-integrator/clock.h
deleted file mode 100644
index e69de29..0000000
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
index 9b60a0c..21c8418 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
@@ -638,12 +638,16 @@ static void rs_get_rate(void *priv_r, struct ieee80211_sta *sta,
 	s8 scale_action = 0;
 	unsigned long flags;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
-	u16 fc, rate_mask;
+	u16 fc;
+	u16 rate_mask = 0;
 	struct iwl3945_priv *priv = (struct iwl3945_priv *)priv_r;
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 
 	IWL_DEBUG_RATE("enter\n");
 
+	if (sta)
+		rate_mask = sta->supp_rates[sband->band];
+
 	/* Send management frames and broadcast/multicast data using lowest
 	 * rate. */
 	fc = le16_to_cpu(hdr->frame_control);
@@ -651,11 +655,15 @@ static void rs_get_rate(void *priv_r, struct ieee80211_sta *sta,
 	    is_multicast_ether_addr(hdr->addr1) ||
 	    !sta || !priv_sta) {
 		IWL_DEBUG_RATE("leave: No STA priv data to update!\n");
-		info->control.rates[0].idx = rate_lowest_index(sband, sta);
+		if (!rate_mask)
+			info->control.rates[0].idx =
+					rate_lowest_index(sband, NULL);
+		else
+			info->control.rates[0].idx =
+					rate_lowest_index(sband, sta);
 		return;
 	}
 
-	rate_mask = sta->supp_rates[sband->band];
 	index = min(rs_sta->last_txrate_idx & 0xffff, IWL_RATE_COUNT - 1);
 
 	if (sband->band == IEEE80211_BAND_5GHZ)
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index f3f1792..27f5047 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -944,7 +944,8 @@ static void rs_tx_status(void *priv_r, struct ieee80211_supported_band *sband,
 	}
 
 	/* See if there's a better rate or modulation mode to try. */
-	rs_rate_scale_perform(priv, hdr, sta, lq_sta);
+	if (sta && sta->supp_rates[sband->band])
+		rs_rate_scale_perform(priv, hdr, sta, lq_sta);
 out:
 	return;
 }
@@ -2101,14 +2102,23 @@ static void rs_get_rate(void *priv_r, struct ieee80211_sta *sta, void *priv_sta,
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct iwl_lq_sta *lq_sta = priv_sta;
 	int rate_idx;
+	u64 mask_bit = 0;
 
 	IWL_DEBUG_RATE_LIMIT("rate scale calculate new rate for skb\n");
 
+	if (sta)
+		mask_bit = sta->supp_rates[sband->band];
+
 	/* Send management frames and broadcast/multicast data using lowest
 	 * rate. */
 	if (!ieee80211_is_data(hdr->frame_control) ||
 	    is_multicast_ether_addr(hdr->addr1) || !sta || !lq_sta) {
-		info->control.rates[0].idx = rate_lowest_index(sband, sta);
+		if (!mask_bit)
+			info->control.rates[0].idx =
+					rate_lowest_index(sband, NULL);
+		else
+			info->control.rates[0].idx =
+					rate_lowest_index(sband, sta);
 		return;
 	}
 
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 4487cc5..5de2ebf 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -229,6 +229,8 @@ static void p54u_tx_3887(struct ieee80211_hw *dev, struct sk_buff *skb)
 			  usb_sndbulkpipe(priv->udev, P54U_PIPE_DATA),
 			  skb->data, skb->len, FREE_AFTER_TX(skb) ?
 			  p54u_tx_cb : p54u_tx_dummy_cb, skb);
+	addr_urb->transfer_flags |= URB_ZERO_PACKET;
+	data_urb->transfer_flags |= URB_ZERO_PACKET;
 
 	usb_anchor_urb(addr_urb, &priv->submitted);
 	err = usb_submit_urb(addr_urb, GFP_ATOMIC);
@@ -237,7 +239,7 @@ static void p54u_tx_3887(struct ieee80211_hw *dev, struct sk_buff *skb)
 		goto out;
 	}
 
-	usb_anchor_urb(addr_urb, &priv->submitted);
+	usb_anchor_urb(data_urb, &priv->submitted);
 	err = usb_submit_urb(data_urb, GFP_ATOMIC);
 	if (err)
 		usb_unanchor_urb(data_urb);
@@ -332,12 +334,13 @@ static void p54u_tx_net2280(struct ieee80211_hw *dev, struct sk_buff *skb)
 	 * free what's inside the transfer_buffer after the callback routine
 	 * has completed.
 	 */
-	int_urb->transfer_flags |= URB_FREE_BUFFER;
+	int_urb->transfer_flags |= URB_FREE_BUFFER | URB_ZERO_PACKET;
 
 	usb_fill_bulk_urb(data_urb, priv->udev,
 			  usb_sndbulkpipe(priv->udev, P54U_PIPE_DATA),
 			  hdr, skb->len + sizeof(*hdr), FREE_AFTER_TX(skb) ?
 			  p54u_tx_cb : p54u_tx_dummy_cb, skb);
+	data_urb->transfer_flags |= URB_ZERO_PACKET;
 
 	usb_anchor_urb(int_urb, &priv->submitted);
 	err = usb_submit_urb(int_urb, GFP_ATOMIC);
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index 6ad6bac..22bc07e 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -273,6 +273,7 @@ static int rtl8187_tx(struct ieee80211_hw *dev, struct sk_buff *skb)
 
 	usb_fill_bulk_urb(urb, priv->udev, usb_sndbulkpipe(priv->udev, ep),
 			  buf, skb->len, rtl8187_tx_cb, skb);
+	urb->transfer_flags |= URB_ZERO_PACKET;
 	usb_anchor_urb(urb, &priv->anchored);
 	rc = usb_submit_urb(urb, GFP_ATOMIC);
 	if (rc < 0) {
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
