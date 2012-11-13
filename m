From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 01/11] batman-adv: don't rely on positions in
	struct for hashing
Date: Tue, 13 Nov 2012 10:15:29 +0100
Message-ID: <1352798139-19458-2-git-send-email-ordex@autistici.org>
References: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1352798139-19458-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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
 net/batman-adv/bridge_loop_avoidance.c | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 29a5542..decc042 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -37,18 +37,26 @@ static void batadv_bla_periodic_work(struct work_struct *work);
 static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
 				     struct batadv_backbone_gw *backbone_gw);
 
+static inline void hash_bytes(uint32_t *hash, void *data, uint32_t size)
+{
+	const unsigned char *key = data;
+	int i;
+
+	for (i = 0; i < size; i++) {
+		*hash += key[i];
+		*hash += (*hash << 10);
+		*hash ^= (*hash >> 6);
+	}
+}
+
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
+	hash_bytes(&hash, &claim->addr, sizeof(claim->addr));
+	hash_bytes(&hash, &claim->vid, sizeof(claim->vid));
 
 	hash += (hash << 3);
 	hash ^= (hash >> 11);
@@ -61,15 +69,11 @@ static inline uint32_t batadv_choose_claim(const void *data, uint32_t size)
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
+	hash_bytes(&hash, &claim->addr, sizeof(claim->addr));
+	hash_bytes(&hash, &claim->vid, sizeof(claim->vid));
 
 	hash += (hash << 3);
 	hash ^= (hash >> 11);
-- 
1.8.0
