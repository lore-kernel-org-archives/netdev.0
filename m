From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] macsec: key identifier is 128 bits, not 64
Date: Sat,  7 May 2016 20:19:29 +0200
Message-ID: <a4f37c780ee1a5c368662bb389274995b2b51dbc.1462644509.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbcEGSUA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2016 14:20:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MACsec standard mentions a key identifier for each key, but
doesn't specify anything about it, so I arbitrarily chose 64 bits.

IEEE 802.1X-2010 specifies MKA (MACsec Key Agreement), and defines the
key identifier to be 128 bits (96 bits "member identifier" + 32 bits
"key number").

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Let's make uapi consistent now, before macsec lands in an official
kernel release.

 drivers/net/macsec.c           | 19 +++++++++++++------
 include/uapi/linux/if_macsec.h |  4 +++-
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index c6385617bfb2..92eaab95ae2b 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -85,7 +85,7 @@ struct gcm_iv {
  * @tfm: crypto struct, key storage
  */
 struct macsec_key {
-	u64 id;
+	u8 id[MACSEC_KEYID_LEN];
 	struct crypto_aead *tfm;
 };
 
@@ -1529,7 +1529,8 @@ static const struct nla_policy macsec_genl_sa_policy[NUM_MACSEC_SA_ATTR] = {
 	[MACSEC_SA_ATTR_AN] = { .type = NLA_U8 },
 	[MACSEC_SA_ATTR_ACTIVE] = { .type = NLA_U8 },
 	[MACSEC_SA_ATTR_PN] = { .type = NLA_U32 },
-	[MACSEC_SA_ATTR_KEYID] = { .type = NLA_U64 },
+	[MACSEC_SA_ATTR_KEYID] = { .type = NLA_BINARY,
+				   .len = MACSEC_KEYID_LEN, },
 	[MACSEC_SA_ATTR_KEY] = { .type = NLA_BINARY,
 				 .len = MACSEC_MAX_KEY_LEN, },
 };
@@ -1576,6 +1577,9 @@ static bool validate_add_rxsa(struct nlattr **attrs)
 			return false;
 	}
 
+	if (nla_len(attrs[MACSEC_SA_ATTR_KEYID]) != MACSEC_KEYID_LEN)
+		return false;
+
 	return true;
 }
 
@@ -1641,7 +1645,7 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct genl_info *info)
 	if (tb_sa[MACSEC_SA_ATTR_ACTIVE])
 		rx_sa->active = !!nla_get_u8(tb_sa[MACSEC_SA_ATTR_ACTIVE]);
 
-	rx_sa->key.id = nla_get_u64(tb_sa[MACSEC_SA_ATTR_KEYID]);
+	nla_memcpy(rx_sa->key.id, tb_sa[MACSEC_SA_ATTR_KEY], MACSEC_KEYID_LEN);
 	rx_sa->sc = rx_sc;
 	rcu_assign_pointer(rx_sc->sa[assoc_num], rx_sa);
 
@@ -1722,6 +1726,9 @@ static bool validate_add_txsa(struct nlattr **attrs)
 			return false;
 	}
 
+	if (nla_len(attrs[MACSEC_SA_ATTR_KEYID]) != MACSEC_KEYID_LEN)
+		return false;
+
 	return true;
 }
 
@@ -1777,7 +1784,7 @@ static int macsec_add_txsa(struct sk_buff *skb, struct genl_info *info)
 		return -ENOMEM;
 	}
 
-	tx_sa->key.id = nla_get_u64(tb_sa[MACSEC_SA_ATTR_KEYID]);
+	nla_memcpy(tx_sa->key.id, tb_sa[MACSEC_SA_ATTR_KEY], MACSEC_KEYID_LEN);
 
 	spin_lock_bh(&tx_sa->lock);
 	tx_sa->next_pn = nla_get_u32(tb_sa[MACSEC_SA_ATTR_PN]);
@@ -2318,7 +2325,7 @@ static int dump_secy(struct macsec_secy *secy, struct net_device *dev,
 
 		if (nla_put_u8(skb, MACSEC_SA_ATTR_AN, i) ||
 		    nla_put_u32(skb, MACSEC_SA_ATTR_PN, tx_sa->next_pn) ||
-		    nla_put_u64(skb, MACSEC_SA_ATTR_KEYID, tx_sa->key.id) ||
+		    nla_put(skb, MACSEC_SA_ATTR_KEYID, MACSEC_KEYID_LEN, tx_sa->key.id) ||
 		    nla_put_u8(skb, MACSEC_SA_ATTR_ACTIVE, tx_sa->active)) {
 			nla_nest_cancel(skb, txsa_nest);
 			nla_nest_cancel(skb, txsa_list);
@@ -2419,7 +2426,7 @@ static int dump_secy(struct macsec_secy *secy, struct net_device *dev,
 
 			if (nla_put_u8(skb, MACSEC_SA_ATTR_AN, i) ||
 			    nla_put_u32(skb, MACSEC_SA_ATTR_PN, rx_sa->next_pn) ||
-			    nla_put_u64(skb, MACSEC_SA_ATTR_KEYID, rx_sa->key.id) ||
+			    nla_put(skb, MACSEC_SA_ATTR_KEYID, MACSEC_KEYID_LEN, rx_sa->key.id) ||
 			    nla_put_u8(skb, MACSEC_SA_ATTR_ACTIVE, rx_sa->active)) {
 				nla_nest_cancel(skb, rxsa_nest);
 				nla_nest_cancel(skb, rxsc_nest);
diff --git a/include/uapi/linux/if_macsec.h b/include/uapi/linux/if_macsec.h
index 4c58d9917aa4..3411ed06b9c0 100644
--- a/include/uapi/linux/if_macsec.h
+++ b/include/uapi/linux/if_macsec.h
@@ -19,6 +19,8 @@
 
 #define MACSEC_MAX_KEY_LEN 128
 
+#define MACSEC_KEYID_LEN 16
+
 #define MACSEC_DEFAULT_CIPHER_ID   0x0080020001000001ULL
 #define MACSEC_DEFAULT_CIPHER_ALT  0x0080C20001000001ULL
 
@@ -77,7 +79,7 @@ enum macsec_sa_attrs {
 	MACSEC_SA_ATTR_ACTIVE, /* config/dump, u8 0..1 */
 	MACSEC_SA_ATTR_PN,     /* config/dump, u32 */
 	MACSEC_SA_ATTR_KEY,    /* config, data */
-	MACSEC_SA_ATTR_KEYID,  /* config/dump, u64 */
+	MACSEC_SA_ATTR_KEYID,  /* config/dump, 128-bit */
 	MACSEC_SA_ATTR_STATS,  /* dump, nested, macsec_sa_stats_attr */
 	__MACSEC_SA_ATTR_END,
 	NUM_MACSEC_SA_ATTR = __MACSEC_SA_ATTR_END,
-- 
2.8.2
