From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 06/10] batman-adv: fixed hash functions type
	to uint32_t instead of int
Date: Sat, 26 Nov 2011 22:26:48 +0800
Message-ID: <1322317612-7770-7-git-send-email-lindner_marek@yahoo.de>
References: <1322317612-7770-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1322317612-7770-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

There are two reasons for this fix:
- the result of choose_orig() and vis_choose() is an index and therefore it can't
  be negative. Hence it is correct to make the return type unsigned too.

- sizeof(int) may not be the same on ALL the architectures. Since we plan to use
  choose_orig() as DHT hash function, we need to guarantee that, given the same
  argument, the result is the same. Then it is correct to explicitly express
  the size of the return type (and the second argument). Since the expected
  length is currently 4, uint32_t is the most convenient choice.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/hash.c              |    4 ++--
 net/batman-adv/hash.h              |   13 +++++++------
 net/batman-adv/originator.c        |   13 ++++++++-----
 net/batman-adv/originator.h        |    2 +-
 net/batman-adv/routing.c           |    2 +-
 net/batman-adv/translation-table.c |   32 ++++++++++++++++++--------------
 net/batman-adv/vis.c               |   17 ++++++++++-------
 7 files changed, 47 insertions(+), 36 deletions(-)

diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 2a17250..d1da29d 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -25,7 +25,7 @@
 /* clears the hash */
 static void hash_init(struct hashtable_t *hash)
 {
-	int i;
+	uint32_t i;
 
 	for (i = 0 ; i < hash->size; i++) {
 		INIT_HLIST_HEAD(&hash->table[i]);
@@ -42,7 +42,7 @@ void hash_destroy(struct hashtable_t *hash)
 }
 
 /* allocates and clears the hash */
-struct hashtable_t *hash_new(int size)
+struct hashtable_t *hash_new(uint32_t size)
 {
 	struct hashtable_t *hash;
 
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index d20aa71..4768717 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -33,17 +33,17 @@ typedef int (*hashdata_compare_cb)(const struct hlist_node *, const void *);
 /* the hashfunction, should return an index
  * based on the key in the data of the first
  * argument and the size the second */
-typedef int (*hashdata_choose_cb)(const void *, int);
+typedef uint32_t (*hashdata_choose_cb)(const void *, uint32_t);
 typedef void (*hashdata_free_cb)(struct hlist_node *, void *);
 
 struct hashtable_t {
 	struct hlist_head *table;   /* the hashtable itself with the buckets */
 	spinlock_t *list_locks;     /* spinlock for each hash list entry */
-	int size;		    /* size of hashtable */
+	uint32_t size;		    /* size of hashtable */
 };
 
 /* allocates and clears the hash */
-struct hashtable_t *hash_new(int size);
+struct hashtable_t *hash_new(uint32_t size);
 
 /* free only the hashtable and the hash itself. */
 void hash_destroy(struct hashtable_t *hash);
@@ -57,7 +57,7 @@ static inline void hash_delete(struct hashtable_t *hash,
 	struct hlist_head *head;
 	struct hlist_node *node, *node_tmp;
 	spinlock_t *list_lock; /* spinlock to protect write access */
-	int i;
+	uint32_t i;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -93,7 +93,8 @@ static inline int hash_add(struct hashtable_t *hash,
 			   hashdata_choose_cb choose,
 			   const void *data, struct hlist_node *data_node)
 {
-	int index, ret = -1;
+	uint32_t index;
+	int ret = -1;
 	struct hlist_head *head;
 	struct hlist_node *node;
 	spinlock_t *list_lock; /* spinlock to protect write access */
@@ -137,7 +138,7 @@ static inline void *hash_remove(struct hashtable_t *hash,
 				hashdata_compare_cb compare,
 				hashdata_choose_cb choose, void *data)
 {
-	size_t index;
+	uint32_t index;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	void *data_save = NULL;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 0e5b772..0bc2045 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -164,7 +164,7 @@ void originator_free(struct bat_priv *bat_priv)
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 	struct orig_node *orig_node;
-	int i;
+	uint32_t i;
 
 	if (!hash)
 		return;
@@ -350,7 +350,7 @@ static void _purge_orig(struct bat_priv *bat_priv)
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 	struct orig_node *orig_node;
-	int i;
+	uint32_t i;
 
 	if (!hash)
 		return;
@@ -413,7 +413,8 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 	int batman_count = 0;
 	int last_seen_secs;
 	int last_seen_msecs;
-	int i, ret = 0;
+	uint32_t i;
+	int ret = 0;
 
 	primary_if = primary_if_get_selected(bat_priv);
 
@@ -519,7 +520,8 @@ int orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num)
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct orig_node *orig_node;
-	int i, ret;
+	uint32_t i;
+	int ret;
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
 	 * if_num */
@@ -601,7 +603,8 @@ int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num)
 	struct hlist_head *head;
 	struct hard_iface *hard_iface_tmp;
 	struct orig_node *orig_node;
-	int i, ret;
+	uint32_t i;
+	int ret;
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
 	 * if_num */
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index cfc1f60..67765ff 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -42,7 +42,7 @@ int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
 
 /* hashfunction to choose an entry in a hash table of given size */
 /* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
-static inline int choose_orig(const void *data, int32_t size)
+static inline uint32_t choose_orig(const void *data, uint32_t size)
 {
 	const unsigned char *key = data;
 	uint32_t hash = 0;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index f961cc5..60ce407 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -39,7 +39,7 @@ void slide_own_bcast_window(struct hard_iface *hard_iface)
 	struct hlist_head *head;
 	struct orig_node *orig_node;
 	unsigned long *word;
-	int i;
+	uint32_t i;
 	size_t word_index;
 
 	for (i = 0; i < hash->size; i++) {
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 7ab9d72..5f28a7f0 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -67,7 +67,7 @@ static struct tt_local_entry *tt_local_hash_find(struct bat_priv *bat_priv,
 	struct hlist_head *head;
 	struct hlist_node *node;
 	struct tt_local_entry *tt_local_entry, *tt_local_entry_tmp = NULL;
-	int index;
+	uint32_t index;
 
 	if (!hash)
 		return NULL;
@@ -99,7 +99,7 @@ static struct tt_global_entry *tt_global_hash_find(struct bat_priv *bat_priv,
 	struct hlist_node *node;
 	struct tt_global_entry *tt_global_entry;
 	struct tt_global_entry *tt_global_entry_tmp = NULL;
-	int index;
+	uint32_t index;
 
 	if (!hash)
 		return NULL;
@@ -316,7 +316,8 @@ int tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	struct hlist_head *head;
 	size_t buf_size, pos;
 	char *buff;
-	int i, ret = 0;
+	uint32_t i;
+	int ret = 0;
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if) {
@@ -427,7 +428,7 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	int i;
+	uint32_t i;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -465,7 +466,7 @@ static void tt_local_table_free(struct bat_priv *bat_priv)
 	struct tt_local_entry *tt_local_entry;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	int i;
+	uint32_t i;
 
 	if (!bat_priv->tt_local_hash)
 		return;
@@ -592,7 +593,8 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	struct hlist_head *head;
 	size_t buf_size, pos;
 	char *buff;
-	int i, ret = 0;
+	uint32_t i;
+	int ret = 0;
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if) {
@@ -716,7 +718,7 @@ void tt_global_del_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node, const char *message)
 {
 	struct tt_global_entry *tt_global_entry;
-	int i;
+	uint32_t i;
 	struct hashtable_t *hash = bat_priv->tt_global_hash;
 	struct hlist_node *node, *safe;
 	struct hlist_head *head;
@@ -755,7 +757,7 @@ static void tt_global_roam_purge(struct bat_priv *bat_priv)
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	int i;
+	uint32_t i;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -789,7 +791,7 @@ static void tt_global_table_free(struct bat_priv *bat_priv)
 	struct tt_global_entry *tt_global_entry;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	int i;
+	uint32_t i;
 
 	if (!bat_priv->tt_global_hash)
 		return;
@@ -875,7 +877,8 @@ uint16_t tt_global_crc(struct bat_priv *bat_priv, struct orig_node *orig_node)
 	struct tt_global_entry *tt_global_entry;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	int i, j;
+	uint32_t i;
+	int j;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -912,7 +915,8 @@ uint16_t tt_local_crc(struct bat_priv *bat_priv)
 	struct tt_local_entry *tt_local_entry;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	int i, j;
+	uint32_t i;
+	int j;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1049,7 +1053,7 @@ static struct sk_buff *tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 	struct sk_buff *skb = NULL;
 	uint16_t tt_tot, tt_count;
 	ssize_t tt_query_size = sizeof(struct tt_query_packet);
-	int i;
+	uint32_t i;
 
 	if (tt_query_size + tt_len > primary_if->soft_iface->mtu) {
 		tt_len = primary_if->soft_iface->mtu - tt_query_size;
@@ -1726,7 +1730,7 @@ void tt_free(struct bat_priv *bat_priv)
  * entry */
 static void tt_local_reset_flags(struct bat_priv *bat_priv, uint16_t flags)
 {
-	int i;
+	uint32_t i;
 	struct hashtable_t *hash = bat_priv->tt_local_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
@@ -1759,7 +1763,7 @@ static void tt_local_purge_pending_clients(struct bat_priv *bat_priv)
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
-	int i;
+	uint32_t i;
 
 	if (!hash)
 		return;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index f81a6b6..7445413 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -66,7 +66,7 @@ static int vis_info_cmp(const struct hlist_node *node, const void *data2)
 
 /* hash function to choose an entry in a hash table of given size */
 /* hash algorithm from http://en.wikipedia.org/wiki/Hash_table */
-static int vis_info_choose(const void *data, int size)
+static uint32_t vis_info_choose(const void *data, uint32_t size)
 {
 	const struct vis_info *vis_info = data;
 	const struct vis_packet *packet;
@@ -96,7 +96,7 @@ static struct vis_info *vis_hash_find(struct bat_priv *bat_priv,
 	struct hlist_head *head;
 	struct hlist_node *node;
 	struct vis_info *vis_info, *vis_info_tmp = NULL;
-	int index;
+	uint32_t index;
 
 	if (!hash)
 		return NULL;
@@ -202,7 +202,8 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 	HLIST_HEAD(vis_if_list);
 	struct if_list_entry *entry;
 	struct hlist_node *pos, *n;
-	int i, j, ret = 0;
+	uint32_t i;
+	int j, ret = 0;
 	int vis_server = atomic_read(&bat_priv->vis_mode);
 	size_t buff_pos, buf_size;
 	char *buff;
@@ -556,7 +557,8 @@ static int find_best_vis_server(struct bat_priv *bat_priv,
 	struct hlist_head *head;
 	struct orig_node *orig_node;
 	struct vis_packet *packet;
-	int best_tq = -1, i;
+	int best_tq = -1;
+	uint32_t i;
 
 	packet = (struct vis_packet *)info->skb_packet->data;
 
@@ -608,7 +610,8 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	struct vis_packet *packet = (struct vis_packet *)info->skb_packet->data;
 	struct vis_info_entry *entry;
 	struct tt_local_entry *tt_local_entry;
-	int best_tq = -1, i;
+	int best_tq = -1;
+	uint32_t i;
 
 	info->first_seen = jiffies;
 	packet->vis_type = atomic_read(&bat_priv->vis_mode);
@@ -696,7 +699,7 @@ unlock:
  * held */
 static void purge_vis_packets(struct bat_priv *bat_priv)
 {
-	int i;
+	uint32_t i;
 	struct hashtable_t *hash = bat_priv->vis_hash;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
@@ -733,7 +736,7 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 	struct sk_buff *skb;
 	struct hard_iface *hard_iface;
 	uint8_t dstaddr[ETH_ALEN];
-	int i;
+	uint32_t i;
 
 
 	packet = (struct vis_packet *)info->skb_packet->data;
-- 
1.7.5.4
