From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 2/6] ieee80211: Fix TX code doesn't enable QoS when using WPA + QoS
Date: Thu, 13 Apr 2006 17:17:17 +0800
Message-ID: <20060413091717.GA28650@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:39088 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S964833AbWDMJYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:24:24 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix ieee80211 TX code when using WPA+QOS. TKIP/CCMP will use
the TID field of qos_ctl in 802.11 frame header to do encryption. We
cannot ignore this field when doing host encryption and add the qos_ctl
field later.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 include/net/ieee80211.h      |    1 +
 net/ieee80211/ieee80211_tx.c |   63 ++++++++++++++++++++++++++++++++++--------
 2 files changed, 52 insertions(+), 12 deletions(-)

809115bccebe1ccae12c66466dad2c3d6874ac8b
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index 66dc136..bc6bdd6 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -1076,6 +1076,7 @@ struct ieee80211_device {
 
 	int (*handle_management) (struct net_device * dev,
 				  struct ieee80211_network * network, u16 type);
+	int (*is_qos_active) (struct net_device *dev, struct sk_buff *skb);
 
 	/* Typical STA methods */
 	int (*handle_auth) (struct net_device * dev,
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index 8b4332f..233d527 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -220,13 +220,43 @@ static struct ieee80211_txb *ieee80211_a
 	return txb;
 }
 
+static int ieee80211_classify(struct sk_buff *skb)
+{
+	struct ethhdr *eth;
+	struct iphdr *ip;
+
+	eth = (struct ethhdr *)skb->data;
+	if (eth->h_proto != __constant_htons(ETH_P_IP))
+		return 0;
+
+	ip = skb->nh.iph;
+	switch (ip->tos & 0xfc) {
+	case 0x20:
+		return 2;
+	case 0x40:
+		return 1;
+	case 0x60:
+		return 3;
+	case 0x80:
+		return 4;
+	case 0xa0:
+		return 5;
+	case 0xc0:
+		return 6;
+	case 0xe0:
+		return 7;
+	default:
+		return 0;
+	}
+}
+
 /* Incoming skb is converted to a txb which consists of
  * a block of 802.11 fragment packets (stored as skbs) */
 int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ieee80211_device *ieee = netdev_priv(dev);
 	struct ieee80211_txb *txb = NULL;
-	struct ieee80211_hdr_3addr *frag_hdr;
+	struct ieee80211_hdr_3addrqos *frag_hdr;
 	int i, bytes_per_frag, nr_frags, bytes_last_frag, frag_size,
 	    rts_required;
 	unsigned long flags;
@@ -234,9 +264,10 @@ int ieee80211_xmit(struct sk_buff *skb, 
 	int ether_type, encrypt, host_encrypt, host_encrypt_msdu, host_build_iv;
 	int bytes, fc, hdr_len;
 	struct sk_buff *skb_frag;
-	struct ieee80211_hdr_3addr header = {	/* Ensure zero initialized */
+	struct ieee80211_hdr_3addrqos header = {/* Ensure zero initialized */
 		.duration_id = 0,
-		.seq_ctl = 0
+		.seq_ctl = 0,
+		.qos_ctl = 0
 	};
 	u8 dest[ETH_ALEN], src[ETH_ALEN];
 	struct ieee80211_crypt_data *crypt;
@@ -282,12 +313,6 @@ int ieee80211_xmit(struct sk_buff *skb, 
 	memcpy(dest, skb->data, ETH_ALEN);
 	memcpy(src, skb->data + ETH_ALEN, ETH_ALEN);
 
-	/* Advance the SKB to the start of the payload */
-	skb_pull(skb, sizeof(struct ethhdr));
-
-	/* Determine total amount of storage required for TXB packets */
-	bytes = skb->len + SNAP_SIZE + sizeof(u16);
-
 	if (host_encrypt || host_build_iv)
 		fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA |
 		    IEEE80211_FCTL_PROTECTED;
@@ -306,9 +331,23 @@ int ieee80211_xmit(struct sk_buff *skb, 
 		memcpy(header.addr2, src, ETH_ALEN);
 		memcpy(header.addr3, ieee->bssid, ETH_ALEN);
 	}
-	header.frame_ctl = cpu_to_le16(fc);
 	hdr_len = IEEE80211_3ADDR_LEN;
 
+	if (ieee->is_qos_active && ieee->is_qos_active(dev, skb)) {
+		fc |= IEEE80211_STYPE_QOS_DATA;
+		hdr_len += 2;
+
+		skb->priority = ieee80211_classify(skb);
+		header.qos_ctl |= skb->priority & IEEE80211_QCTL_TID;
+	}
+	header.frame_ctl = cpu_to_le16(fc);
+
+	/* Advance the SKB to the start of the payload */
+	skb_pull(skb, sizeof(struct ethhdr));
+
+	/* Determine total amount of storage required for TXB packets */
+	bytes = skb->len + SNAP_SIZE + sizeof(u16);
+
 	/* Encrypt msdu first on the whole data packet. */
 	if ((host_encrypt || host_encrypt_msdu) &&
 	    crypt && crypt->ops && crypt->ops->encrypt_msdu) {
@@ -402,7 +441,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
 	if (rts_required) {
 		skb_frag = txb->fragments[0];
 		frag_hdr =
-		    (struct ieee80211_hdr_3addr *)skb_put(skb_frag, hdr_len);
+		    (struct ieee80211_hdr_3addrqos *)skb_put(skb_frag, hdr_len);
 
 		/*
 		 * Set header frame_ctl to the RTS.
@@ -433,7 +472,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
 				    crypt->ops->extra_mpdu_prefix_len);
 
 		frag_hdr =
-		    (struct ieee80211_hdr_3addr *)skb_put(skb_frag, hdr_len);
+		    (struct ieee80211_hdr_3addrqos *)skb_put(skb_frag, hdr_len);
 		memcpy(frag_hdr, &header, hdr_len);
 
 		/* If this is not the last fragment, then add the MOREFRAGS
-- 
1.2.6

