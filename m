From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] macsec: dynamically allocate space for sglist
Date: Tue, 25 Apr 2017 17:23:00 +0200
Message-ID: <20170425152300.3830-1-Jason@zx2c4.com>
References: <CAHmME9rZ29X=R-quViXaEO_ouxeB2EpzR2bkR93rrN4n--QDqw@mail.gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, stable@vger.kernel.org,
        security@kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAHmME9rZ29X=R-quViXaEO_ouxeB2EpzR2bkR93rrN4n--QDqw@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We call skb_cow_data, which is good anyway to ensure we can actually
modify the skb as such (another error from prior). Now that we have the
number of fragments required, we can safely allocate exactly that amount
of memory.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>
Cc: security@kernel.org
Cc: stable@vger.kernel.org
---
 drivers/net/macsec.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index dbab05afcdbe..56dafdee4c9c 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -617,7 +617,8 @@ static void macsec_encrypt_done(struct crypto_async_request *base, int err)
 
 static struct aead_request *macsec_alloc_req(struct crypto_aead *tfm,
 					     unsigned char **iv,
-					     struct scatterlist **sg)
+					     struct scatterlist **sg,
+					     int num_frags)
 {
 	size_t size, iv_offset, sg_offset;
 	struct aead_request *req;
@@ -629,7 +630,7 @@ static struct aead_request *macsec_alloc_req(struct crypto_aead *tfm,
 
 	size = ALIGN(size, __alignof__(struct scatterlist));
 	sg_offset = size;
-	size += sizeof(struct scatterlist) * (MAX_SKB_FRAGS + 1);
+	size += sizeof(struct scatterlist) * num_frags;
 
 	tmp = kmalloc(size, GFP_ATOMIC);
 	if (!tmp)
@@ -649,6 +650,7 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 {
 	int ret;
 	struct scatterlist *sg;
+	struct sk_buff *trailer;
 	unsigned char *iv;
 	struct ethhdr *eth;
 	struct macsec_eth_header *hh;
@@ -723,7 +725,14 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 		return ERR_PTR(-EINVAL);
 	}
 
-	req = macsec_alloc_req(tx_sa->key.tfm, &iv, &sg);
+	ret = skb_cow_data(skb, 0, &trailer);
+	if (unlikely(ret < 0)) {
+		macsec_txsa_put(tx_sa);
+		kfree_skb(skb);
+		return ERR_PTR(ret);
+	}
+
+	req = macsec_alloc_req(tx_sa->key.tfm, &iv, &sg, ret);
 	if (!req) {
 		macsec_txsa_put(tx_sa);
 		kfree_skb(skb);
@@ -917,6 +926,7 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 {
 	int ret;
 	struct scatterlist *sg;
+	struct sk_buff *trailer;
 	unsigned char *iv;
 	struct aead_request *req;
 	struct macsec_eth_header *hdr;
@@ -927,7 +937,12 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	req = macsec_alloc_req(rx_sa->key.tfm, &iv, &sg);
+	ret = skb_cow_data(skb, 0, &trailer);
+	if (unlikely(ret < 0)) {
+		kfree_skb(skb);
+		return ERR_PTR(ret);
+	}
+	req = macsec_alloc_req(rx_sa->key.tfm, &iv, &sg, ret);
 	if (!req) {
 		kfree_skb(skb);
 		return ERR_PTR(-ENOMEM);
@@ -2716,7 +2731,7 @@ static netdev_tx_t macsec_start_xmit(struct sk_buff *skb,
 }
 
 #define MACSEC_FEATURES \
-	(NETIF_F_SG | NETIF_F_HIGHDMA)
+	(NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST)
 static struct lock_class_key macsec_netdev_addr_lock_key;
 
 static int macsec_dev_init(struct net_device *dev)
-- 
2.12.2
