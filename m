From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC] skbuff: introduce skb_put_zero()
Date: Wed, 24 May 2017 09:07:47 +0200
Message-ID: <20170524070747.18573-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This pattern was introduced a number of times in mac80211 just now,
and since it's present in a number of other places it makes sense
to add a little helper for it.

The transformations of all code were done with the following spatch:

@@
identifier p;
expression len;
expression skb;
@@
-p = skb_put(skb, len);
-memset(p, 0, len);
+p = skb_put_zero(skb, len);

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
NB: the patch won't apply to net-next because a few of the mac80211
    users don't exist there yet
---
 drivers/net/ethernet/apple/bmac.c            | 3 +--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 3 +--
 drivers/net/ethernet/qualcomm/qca_spi.c      | 3 +--
 drivers/net/wireless/marvell/mwifiex/tdls.c  | 4 ++--
 drivers/nfc/pn533/pn533.c                    | 3 +--
 include/linux/skbuff.h                       | 9 +++++++++
 lib/nlattr.c                                 | 3 +--
 net/mac80211/mesh.c                          | 9 +++------
 net/mac80211/mesh_plink.c                    | 3 +--
 net/sctp/sm_make_chunk.c                     | 3 +--
 10 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index 2b2d87089987..eac740c476ce 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1218,8 +1218,7 @@ static void bmac_reset_and_enable(struct net_device *dev)
 	 */
 	skb = netdev_alloc_skb(dev, ETHERMINPACKET);
 	if (skb != NULL) {
-		data = skb_put(skb, ETHERMINPACKET);
-		memset(data, 0, ETHERMINPACKET);
+		data = skb_put_zero(skb, ETHERMINPACKET);
 		memcpy(data, dev->dev_addr, ETH_ALEN);
 		memcpy(data + ETH_ALEN, dev->dev_addr, ETH_ALEN);
 		bmac_transmit_packet(skb, dev);
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 50d88d3e03b6..18edc2622135 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -609,8 +609,7 @@ static int bcm_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev_kfree_skb(skb);
 			skb = nskb;
 		}
-		data = skb_put(skb, needed);
-		memset(data, 0, needed);
+		data = skb_put_zero(skb, needed);
 	}
 
 	/* point to the next available desc */
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 24ca7df15d07..d37256a8b831 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -696,8 +696,7 @@ qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	qcafrm_create_header(ptmp, frame_len);
 
 	if (pad_len) {
-		ptmp = skb_put(skb, pad_len);
-		memset(ptmp, 0, pad_len);
+		ptmp = skb_put_zero(skb, pad_len);
 	}
 
 	ptmp = skb_put(skb, QCAFRM_FOOTER_LEN);
diff --git a/drivers/net/wireless/marvell/mwifiex/tdls.c b/drivers/net/wireless/marvell/mwifiex/tdls.c
index 7d0d3ff3dd4c..fe74ce598418 100644
--- a/drivers/net/wireless/marvell/mwifiex/tdls.c
+++ b/drivers/net/wireless/marvell/mwifiex/tdls.c
@@ -856,8 +856,8 @@ int mwifiex_send_tdls_action_frame(struct mwifiex_private *priv, const u8 *peer,
 
 	pkt_type = PKT_TYPE_MGMT;
 	tx_control = 0;
-	pos = skb_put(skb, MWIFIEX_MGMT_FRAME_HEADER_SIZE + sizeof(pkt_len));
-	memset(pos, 0, MWIFIEX_MGMT_FRAME_HEADER_SIZE + sizeof(pkt_len));
+	pos = skb_put_zero(skb,
+			   MWIFIEX_MGMT_FRAME_HEADER_SIZE + sizeof(pkt_len));
 	memcpy(pos, &pkt_type, sizeof(pkt_type));
 	memcpy(pos + sizeof(pkt_type), &tx_control, sizeof(tx_control));
 
diff --git a/drivers/nfc/pn533/pn533.c b/drivers/nfc/pn533/pn533.c
index 65bbaa5fcdda..70c304504a29 100644
--- a/drivers/nfc/pn533/pn533.c
+++ b/drivers/nfc/pn533/pn533.c
@@ -1043,8 +1043,7 @@ static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 	get_random_bytes(felica + 2, 6);
 
 	/* NFCID3 */
-	nfcid3 = skb_put(skb, 10);
-	memset(nfcid3, 0, 10);
+	nfcid3 = skb_put_zero(skb, 10);
 	memcpy(nfcid3, felica, 8);
 
 	/* General bytes */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bfc7892f6c33..d92056b2da44 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1937,6 +1937,15 @@ static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 	return tmp;
 }
 
+static inline unsigned char *skb_put_zero(struct sk_buff *skb, unsigned int len)
+{
+	unsigned char *tmp = skb_put(skb, len);
+
+	memset(tmp, 0, len);
+
+	return tmp;
+}
+
 unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 {
diff --git a/lib/nlattr.c b/lib/nlattr.c
index a7e0b16078df..d09d9746fc5d 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -400,8 +400,7 @@ void *__nla_reserve_nohdr(struct sk_buff *skb, int attrlen)
 {
 	void *start;
 
-	start = skb_put(skb, NLA_ALIGN(attrlen));
-	memset(start, 0, NLA_ALIGN(attrlen));
+	start = skb_put_zero(skb, NLA_ALIGN(attrlen));
 
 	return start;
 }
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 3d6b3d674ca3..ad5d1cf39190 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -744,8 +744,7 @@ ieee80211_mesh_build_beacon(struct ieee80211_if_mesh *ifmsh)
 		int ie_len = 2 + sizeof(struct ieee80211_channel_sw_ie) +
 			     2 + sizeof(struct ieee80211_mesh_chansw_params_ie);
 
-		pos = skb_put(skb, ie_len);
-		memset(pos, 0, ie_len);
+		pos = skb_put_zero(skb, ie_len);
 		*pos++ = WLAN_EID_CHANNEL_SWITCH;
 		*pos++ = 3;
 		*pos++ = 0x0;
@@ -772,8 +771,7 @@ ieee80211_mesh_build_beacon(struct ieee80211_if_mesh *ifmsh)
 		switch (csa->settings.chandef.width) {
 		case NL80211_CHAN_WIDTH_40:
 			ie_len = 2 + sizeof(struct ieee80211_sec_chan_offs_ie);
-			pos = skb_put(skb, ie_len);
-			memset(pos, 0, ie_len);
+			pos = skb_put_zero(skb, ie_len);
 
 			*pos++ = WLAN_EID_SECONDARY_CHANNEL_OFFSET; /* EID */
 			*pos++ = 1;				    /* len */
@@ -789,8 +787,7 @@ ieee80211_mesh_build_beacon(struct ieee80211_if_mesh *ifmsh)
 			/* Channel Switch Wrapper + Wide Bandwidth CSA IE */
 			ie_len = 2 + 2 +
 				 sizeof(struct ieee80211_wide_bw_chansw_ie);
-			pos = skb_put(skb, ie_len);
-			memset(pos, 0, ie_len);
+			pos = skb_put_zero(skb, ie_len);
 
 			*pos++ = WLAN_EID_CHANNEL_SWITCH_WRAPPER; /* EID */
 			*pos++ = 5;				  /* len */
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 1131cd504a15..82cfd232a25e 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -264,8 +264,7 @@ static int mesh_plink_frame_tx(struct ieee80211_sub_if_data *sdata,
 		band = sband->band;
 
 		/* capability info */
-		pos = skb_put(skb, 2);
-		memset(pos, 0, 2);
+		pos = skb_put_zero(skb, 2);
 		if (action == WLAN_SP_MESH_PEERING_CONFIRM) {
 			/* AID */
 			pos = skb_put(skb, 2);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 8a08f13469c4..19ad326f3825 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1296,8 +1296,7 @@ struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc)
 	retval->subh.auth_hdr = sctp_addto_chunk(retval, sizeof(sctp_authhdr_t),
 						&auth_hdr);
 
-	hmac = skb_put(retval->skb, hmac_desc->hmac_len);
-	memset(hmac, 0, hmac_desc->hmac_len);
+	hmac = skb_put_zero(retval->skb, hmac_desc->hmac_len);
 
 	/* Adjust the chunk header to include the empty MAC */
 	retval->chunk_hdr->length =
-- 
2.11.0
