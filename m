From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH net-next] networking: use skb_put_zero()
Date: Tue, 13 Jun 2017 14:28:18 +0200
Message-ID: <20170613122818.3523-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54304 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753245AbdFMM2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 08:28:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Use the recently introduced helper to replace the pattern of
skb_put() && memset(), this transformation was done with the
following spatch:

@@
identifier p;
expression len;
expression skb;
@@
-p = skb_put(skb, len);
-memset(p, 0, len);
+p = skb_put_zero(skb, len);

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
This obviously requires skb_put_zero() which is coming in through
the mac80211-next merge I just sent you a pull request for.
---
 drivers/net/ethernet/apple/bmac.c            | 3 +--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 3 +--
 drivers/net/ethernet/qualcomm/qca_spi.c      | 3 +--
 drivers/net/wireless/marvell/mwifiex/tdls.c  | 4 ++--
 drivers/nfc/pn533/pn533.c                    | 3 +--
 lib/nlattr.c                                 | 3 +--
 net/sctp/sm_make_chunk.c                     | 3 +--
 7 files changed, 8 insertions(+), 14 deletions(-)

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
index de78f60309a0..9c236298fe21 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -719,8 +719,7 @@ qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	qcafrm_create_header(ptmp, frame_len);
 
 	if (pad_len) {
-		ptmp = skb_put(skb, pad_len);
-		memset(ptmp, 0, pad_len);
+		ptmp = skb_put_zero(skb, pad_len);
 	}
 
 	ptmp = skb_put(skb, QCAFRM_FOOTER_LEN);
diff --git a/drivers/net/wireless/marvell/mwifiex/tdls.c b/drivers/net/wireless/marvell/mwifiex/tdls.c
index d76ce8797de1..b7d124dbef0c 100644
--- a/drivers/net/wireless/marvell/mwifiex/tdls.c
+++ b/drivers/net/wireless/marvell/mwifiex/tdls.c
@@ -853,8 +853,8 @@ int mwifiex_send_tdls_action_frame(struct mwifiex_private *priv, const u8 *peer,
 
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
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index bd439edf2d8a..ea2601501654 100644
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
