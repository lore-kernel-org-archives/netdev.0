From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 5/5] xfrm: Add TFC padding option to automatically pad to PMTU
Date: Tue, 30 Nov 2010 16:49:15 +0100
Message-ID: <1291132155-31277-6-git-send-email-martin@strongswan.org>
References: <1291132155-31277-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1291132155-31277-1-git-send-email-martin@strongswan.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Traffic Flow Confidentiality padding is most effective if all packets
have exactly the same size. For SAs with mixed traffic, the largest
packet size is usually the PMTU. Instead of calculating the PMTU
manually, the XFRM_TFC_PMTU flag automatically pads to the PMTU.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 include/linux/xfrm.h |    1 +
 net/ipv4/esp4.c      |    7 +++++++
 net/ipv6/esp6.c      |    7 +++++++
 3 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b1e5f8a..2a9f0b4 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -298,6 +298,7 @@ struct xfrm_tfc {
 	__u16		pad;
 	__u16		flags;
 #define XFRM_TFC_ESPV3	1	/* RFC4303 TFC padding, if possible */
+#define XFRM_TFC_PMTU	2	/* ignore pad field, pad to PMTU */
 };
 
 enum xfrm_sadattr_type_t {
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index a6adfbc..cfb4992 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -23,6 +23,8 @@ struct esp_skb_cb {
 
 #define ESP_SKB_CB(__skb) ((struct esp_skb_cb *)&((__skb)->cb[0]))
 
+static u32 esp4_get_mtu(struct xfrm_state *x, int mtu);
+
 /*
  * Allocate an AEAD request structure with extra space for SG and IV.
  *
@@ -133,6 +135,11 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	tfclen = 0;
 	tfcpadto = x->tfc.pad;
+	if (x->tfc.flags & XFRM_TFC_PMTU) {
+		struct xfrm_dst *dst = (struct xfrm_dst *)skb_dst(skb);
+
+		tfcpadto = esp4_get_mtu(x, dst->child_mtu_cached);
+	}
 
 	if (skb->len >= tfcpadto) {
 		clen = ALIGN(skb->len + 2, blksize);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 9494cb1..6cb9a02 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -49,6 +49,8 @@ struct esp_skb_cb {
 
 #define ESP_SKB_CB(__skb) ((struct esp_skb_cb *)&((__skb)->cb[0]))
 
+static u32 esp6_get_mtu(struct xfrm_state *x, int mtu);
+
 /*
  * Allocate an AEAD request structure with extra space for SG and IV.
  *
@@ -157,6 +159,11 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	tfclen = 0;
 	tfcpadto = x->tfc.pad;
+	if (x->tfc.flags & XFRM_TFC_PMTU) {
+		struct xfrm_dst *dst = (struct xfrm_dst *)skb_dst(skb);
+
+		tfcpadto = esp6_get_mtu(x, dst->child_mtu_cached);
+	}
 
 	if (skb->len >= tfcpadto) {
 		clen = ALIGN(skb->len + 2, blksize);
-- 
1.7.1
