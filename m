From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 01/11] batman-adv: don't rely on positions in
	struct for hashing
Date: Wed, 14 Nov 2012 21:16:19 +0100
Message-ID: <1352924189-18843-2-git-send-email-ordex@autistici.org>
References: <1352924189-18843-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1352924189-18843-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

The hash functions in the bridge loop avoidance code expects the
VLAN vid to be right after the mac address, but this is not guaranteed.

Fix this by explicitly hashing over the right fields of the struct.

Reported-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 20 ++++++--------------
 net/batman-adv/hash.h                  | 22 ++++++++++++++++++++++
 2 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 29a5542..49c35a6 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -40,15 +40,11 @@ static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
 /* return the index of the claim */
 static inline uint32_t batadv_choose_claim(const void *data, uint32_t size)
 {
-	const unsigned char *key = data;
+	struct batadv_claim *claim = (struct batadv_claim *)data;
 	uint32_t hash = 0;
-	size_t i;
 
-	for (i = 0; i < ETH_ALEN + sizeof(short); i++) {
-		hash += key[i];
-		hash += (hash << 10);
-		hash ^= (hash >> 6);
-	}
+	hash = batadv_hash_bytes(hash, &claim->addr, sizeof(claim->addr));
+	hash = batadv_hash_bytes(hash, &claim->vid, sizeof(claim->vid));
 
 	hash += (hash << 3);
 	hash ^= (hash >> 11);
@@ -61,15 +57,11 @@ static inline uint32_t batadv_choose_claim(const void *data, uint32_t size)
 static inline uint32_t batadv_choose_backbone_gw(const void *data,
 						 uint32_t size)
 {
-	const unsigned char *key = data;
+	struct batadv_claim *claim = (struct batadv_claim *)data;
 	uint32_t hash = 0;
-	size_t i;
 
-	for (i = 0; i < ETH_ALEN + sizeof(short); i++) {
-		hash += key[i];
-		hash += (hash << 10);
-		hash ^= (hash >> 6);
-	}
+	hash = batadv_hash_bytes(hash, &claim->addr, sizeof(claim->addr));
+	hash = batadv_hash_bytes(hash, &claim->vid, sizeof(claim->vid));
 
 	hash += (hash << 3);
 	hash ^= (hash >> 11);
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 977de9c..e053339 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -82,6 +82,28 @@ static inline void batadv_hash_delete(struct batadv_hashtable *hash,
 }
 
 /**
+ *	batadv_hash_bytes - hash some bytes and add them to the previous hash
+ *	@hash: previous hash value
+ *	@data: data to be hashed
+ *	@size: number of bytes to be hashed
+ *
+ *	Returns the new hash value.
+ */
+static inline uint32_t batadv_hash_bytes(uint32_t hash, void *data,
+					 uint32_t size)
+{
+	const unsigned char *key = data;
+	int i;
+
+	for (i = 0; i < size; i++) {
+		hash += key[i];
+		hash += (hash << 10);
+		hash ^= (hash >> 6);
+	}
+	return hash;
+}
+
+/**
  *	batadv_hash_add - adds data to the hashtable
  *	@hash: storage hash table
  *	@compare: callback to determine if 2 hash elements are identical
-- 
1.8.0
