From: Horia Geanta <horia.geanta@freescale.com>
Subject: [PATCH v2 2/4] net: esp: check CRYPTO_TFM_REQ_DMA flag when allocating crypto request
Date: Fri, 13 Mar 2015 19:38:11 +0200
Message-ID: <1426268291-21507-1-git-send-email-horia.geanta@freescale.com>
References: <1426268260-20824-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kim Phillips <kim.phillips@freescale.com>,
	Horia Geanta <horia.geanta@freescale.com>
To: <linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1426268260-20824-1-git-send-email-horia.geanta@freescale.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some crypto backends might require the requests' private contexts
to be allocated in DMA-able memory.

Signed-off-by: Horia Geanta <horia.geanta@freescale.com>
---

Depends on patch 1/4 (sent only on crypto list) that adds the
CRYPTO_TFM_REQ_DMA flag.

 net/ipv4/esp4.c | 7 ++++++-
 net/ipv6/esp6.c | 7 ++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 60173d4d3a0e..3e6ddece0cbe 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -38,6 +38,7 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu);
 static void *esp_alloc_tmp(struct crypto_aead *aead, int nfrags, int seqhilen)
 {
 	unsigned int len;
+	gfp_t gfp = GFP_ATOMIC;
 
 	len = seqhilen;
 
@@ -54,7 +55,11 @@ static void *esp_alloc_tmp(struct crypto_aead *aead, int nfrags, int seqhilen)
 
 	len += sizeof(struct scatterlist) * nfrags;
 
-	return kmalloc(len, GFP_ATOMIC);
+	if (crypto_aead_reqsize(aead) &&
+	    (crypto_aead_get_flags(aead) & CRYPTO_TFM_REQ_DMA))
+		gfp |= GFP_DMA;
+
+	return kmalloc(len, gfp);
 }
 
 static inline __be32 *esp_tmp_seqhi(void *tmp)
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index e48f2c7c5c59..0d173eedad4e 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -65,6 +65,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu);
 static void *esp_alloc_tmp(struct crypto_aead *aead, int nfrags, int seqihlen)
 {
 	unsigned int len;
+	gfp_t gfp = GFP_ATOMIC;
 
 	len = seqihlen;
 
@@ -81,7 +82,11 @@ static void *esp_alloc_tmp(struct crypto_aead *aead, int nfrags, int seqihlen)
 
 	len += sizeof(struct scatterlist) * nfrags;
 
-	return kmalloc(len, GFP_ATOMIC);
+	if (crypto_aead_reqsize(aead) &&
+	    (crypto_aead_get_flags(aead) & CRYPTO_TFM_REQ_DMA))
+		gfp |= GFP_DMA;
+
+	return kmalloc(len, gfp);
 }
 
 static inline __be32 *esp_tmp_seqhi(void *tmp)
-- 
1.8.3.1
