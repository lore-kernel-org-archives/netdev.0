From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/10] netfilter: nft_set_bitmap: fetch the element key based on the set->klen
Date: Wed, 15 Mar 2017 18:01:06 +0100
Message-ID: <1489597272-30347-5-git-send-email-pablo@netfilter.org>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Currently we just assume the element key as a u32 integer, regardless of
the set key length.

This is incorrect, for example, the tcp port number is only 16 bits.
So when we use the nft_payload expr to get the tcp dport and store
it to dreg, the dport will be stored at 0~15 bits, and 16~31 bits
will be padded with zero.

So the reg->data[dreg] will be looked like as below:
  0          15           31
  +-+-+-+-+-+-+-+-+-+-+-+-+
  | tcp dport |      0    |
  +-+-+-+-+-+-+-+-+-+-+-+-+
But for these big-endian systems, if we treate this register as a u32
integer, the element key will be larger than 65535, so the following
lookup in bitmap set will cause out of bound access.

Another issue is that if we add element with comments in bitmap
set(although the comments will be ignored eventually), the element will
vanish strangely. Because we treate the element key as a u32 integer, so
the comments will become the part of the element key, then the element
key will also be larger than 65535 and out of bound access will happen:
  # nft add element t s { 1 comment test }

Since set->klen is 1 or 2, it's fine to treate the element key as a u8 or
u16 integer.

Fixes: 665153ff5752 ("netfilter: nf_tables: add bitmap set type")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_set_bitmap.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/nft_set_bitmap.c b/net/netfilter/nft_set_bitmap.c
index 152d226552c1..9b024e22717b 100644
--- a/net/netfilter/nft_set_bitmap.c
+++ b/net/netfilter/nft_set_bitmap.c
@@ -45,9 +45,17 @@ struct nft_bitmap {
 	u8	bitmap[];
 };
 
-static inline void nft_bitmap_location(u32 key, u32 *idx, u32 *off)
+static inline void nft_bitmap_location(const struct nft_set *set,
+				       const void *key,
+				       u32 *idx, u32 *off)
 {
-	u32 k = (key << 1);
+	u32 k;
+
+	if (set->klen == 2)
+		k = *(u16 *)key;
+	else
+		k = *(u8 *)key;
+	k <<= 1;
 
 	*idx = k / BITS_PER_BYTE;
 	*off = k % BITS_PER_BYTE;
@@ -69,7 +77,7 @@ static bool nft_bitmap_lookup(const struct net *net, const struct nft_set *set,
 	u8 genmask = nft_genmask_cur(net);
 	u32 idx, off;
 
-	nft_bitmap_location(*key, &idx, &off);
+	nft_bitmap_location(set, key, &idx, &off);
 
 	return nft_bitmap_active(priv->bitmap, idx, off, genmask);
 }
@@ -83,7 +91,7 @@ static int nft_bitmap_insert(const struct net *net, const struct nft_set *set,
 	u8 genmask = nft_genmask_next(net);
 	u32 idx, off;
 
-	nft_bitmap_location(nft_set_ext_key(ext)->data[0], &idx, &off);
+	nft_bitmap_location(set, nft_set_ext_key(ext), &idx, &off);
 	if (nft_bitmap_active(priv->bitmap, idx, off, genmask))
 		return -EEXIST;
 
@@ -102,7 +110,7 @@ static void nft_bitmap_remove(const struct net *net,
 	u8 genmask = nft_genmask_next(net);
 	u32 idx, off;
 
-	nft_bitmap_location(nft_set_ext_key(ext)->data[0], &idx, &off);
+	nft_bitmap_location(set, nft_set_ext_key(ext), &idx, &off);
 	/* Enter 00 state. */
 	priv->bitmap[idx] &= ~(genmask << off);
 }
@@ -116,7 +124,7 @@ static void nft_bitmap_activate(const struct net *net,
 	u8 genmask = nft_genmask_next(net);
 	u32 idx, off;
 
-	nft_bitmap_location(nft_set_ext_key(ext)->data[0], &idx, &off);
+	nft_bitmap_location(set, nft_set_ext_key(ext), &idx, &off);
 	/* Enter 11 state. */
 	priv->bitmap[idx] |= (genmask << off);
 }
@@ -128,7 +136,7 @@ static bool nft_bitmap_flush(const struct net *net,
 	u8 genmask = nft_genmask_next(net);
 	u32 idx, off;
 
-	nft_bitmap_location(nft_set_ext_key(ext)->data[0], &idx, &off);
+	nft_bitmap_location(set, nft_set_ext_key(ext), &idx, &off);
 	/* Enter 10 state, similar to deactivation. */
 	priv->bitmap[idx] &= ~(genmask << off);
 
@@ -161,10 +169,9 @@ static void *nft_bitmap_deactivate(const struct net *net,
 	struct nft_bitmap *priv = nft_set_priv(set);
 	u8 genmask = nft_genmask_next(net);
 	struct nft_set_ext *ext;
-	u32 idx, off, key = 0;
+	u32 idx, off;
 
-	memcpy(&key, elem->key.val.data, set->klen);
-	nft_bitmap_location(key, &idx, &off);
+	nft_bitmap_location(set, elem->key.val.data, &idx, &off);
 
 	if (!nft_bitmap_active(priv->bitmap, idx, off, genmask))
 		return NULL;
-- 
2.1.4

