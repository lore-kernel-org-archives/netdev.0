From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 3/4] misc: Rename the HASH_SIZE macro
Date: Wed,  1 Jun 2016 10:52:59 +0300
Message-ID: <1464767580-22732-4-git-send-email-kernel@kyup.com>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Cc: jack@suse.cz, linux-kernel@vger.kernel.org, gorcunov@openvz.org,
	avagin@openvz.org, netdev@vger.kernel.org,
	operations@siteground.com, Nikolay Borisov <kernel@kyup.com>
To: john@johnmccutchan.com, eparis@redhat.com, ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change is required since the inotify-per-namespace code added
hashtable.h to the include list of sched.h. This in turn causes
compiler warnings since HASH_SIZE is being defined in multiple
locations

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 fs/logfs/dir.c                           |  6 +++---
 net/ipv6/ip6_gre.c                       |  8 ++++----
 net/ipv6/ip6_tunnel.c                    | 10 +++++-----
 net/ipv6/ip6_vti.c                       | 10 +++++-----
 net/ipv6/sit.c                           | 10 +++++-----
 security/keys/encrypted-keys/encrypted.c | 32 ++++++++++++++++----------------
 6 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/fs/logfs/dir.c b/fs/logfs/dir.c
index 2d5336bd4efd..bcd754d216bd 100644
--- a/fs/logfs/dir.c
+++ b/fs/logfs/dir.c
@@ -95,7 +95,7 @@ static int beyond_eof(struct inode *inode, loff_t bix)
  * of each character and pick a prime nearby, preferably a bit-sparse
  * one.
  */
-static u32 hash_32(const char *s, int len, u32 seed)
+static u32 logfs_hash_32(const char *s, int len, u32 seed)
 {
 	u32 hash = seed;
 	int i;
@@ -159,7 +159,7 @@ static struct page *logfs_get_dd_page(struct inode *dir, struct dentry *dentry)
 	struct qstr *name = &dentry->d_name;
 	struct page *page;
 	struct logfs_disk_dentry *dd;
-	u32 hash = hash_32(name->name, name->len, 0);
+	u32 hash = logfs_hash_32(name->name, name->len, 0);
 	pgoff_t index;
 	int round;
 
@@ -370,7 +370,7 @@ static int logfs_write_dir(struct inode *dir, struct dentry *dentry,
 {
 	struct page *page;
 	struct logfs_disk_dentry *dd;
-	u32 hash = hash_32(dentry->d_name.name, dentry->d_name.len, 0);
+	u32 hash = logfs_hash_32(dentry->d_name.name, dentry->d_name.len, 0);
 	pgoff_t index;
 	int round, err;
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index af503f518278..b73b4dc5c7ad 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -62,11 +62,11 @@ module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 #define HASH_SIZE_SHIFT  5
-#define HASH_SIZE (1 << HASH_SIZE_SHIFT)
+#define IP6G_HASH_SIZE (1 << HASH_SIZE_SHIFT)
 
 static int ip6gre_net_id __read_mostly;
 struct ip6gre_net {
-	struct ip6_tnl __rcu *tunnels[4][HASH_SIZE];
+	struct ip6_tnl __rcu *tunnels[4][IP6G_HASH_SIZE];
 
 	struct net_device *fb_tunnel_dev;
 };
@@ -96,7 +96,7 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu);
    will match fallback tunnel.
  */
 
-#define HASH_KEY(key) (((__force u32)key^((__force u32)key>>4))&(HASH_SIZE - 1))
+#define HASH_KEY(key) (((__force u32)key^((__force u32)key>>4))&(IP6G_HASH_SIZE - 1))
 static u32 HASH_ADDR(const struct in6_addr *addr)
 {
 	u32 hash = ipv6_addr_hash(addr);
@@ -1086,7 +1086,7 @@ static void ip6gre_destroy_tunnels(struct net *net, struct list_head *head)
 
 	for (prio = 0; prio < 4; prio++) {
 		int h;
-		for (h = 0; h < HASH_SIZE; h++) {
+		for (h = 0; h < IP6G_HASH_SIZE; h++) {
 			struct ip6_tnl *t;
 
 			t = rtnl_dereference(ign->tunnels[prio][h]);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 7b0481e3738f..50b57a435f05 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -64,8 +64,8 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("ip6tnl");
 MODULE_ALIAS_NETDEV("ip6tnl0");
 
-#define HASH_SIZE_SHIFT  5
-#define HASH_SIZE (1 << HASH_SIZE_SHIFT)
+#define IP6_HASH_SIZE_SHIFT  5
+#define IP6_HASH_SIZE (1 << IP6_HASH_SIZE_SHIFT)
 
 static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
@@ -75,7 +75,7 @@ static u32 HASH(const struct in6_addr *addr1, const struct in6_addr *addr2)
 {
 	u32 hash = ipv6_addr_hash(addr1) ^ ipv6_addr_hash(addr2);
 
-	return hash_32(hash, HASH_SIZE_SHIFT);
+	return hash_32(hash, IP6_HASH_SIZE_SHIFT);
 }
 
 static int ip6_tnl_dev_init(struct net_device *dev);
@@ -87,7 +87,7 @@ struct ip6_tnl_net {
 	/* the IPv6 tunnel fallback device */
 	struct net_device *fb_tnl_dev;
 	/* lists for storing tunnels in use */
-	struct ip6_tnl __rcu *tnls_r_l[HASH_SIZE];
+	struct ip6_tnl __rcu *tnls_r_l[IP6_HASH_SIZE];
 	struct ip6_tnl __rcu *tnls_wc[1];
 	struct ip6_tnl __rcu **tnls[2];
 };
@@ -2031,7 +2031,7 @@ static void __net_exit ip6_tnl_destroy_tunnels(struct net *net)
 		if (dev->rtnl_link_ops == &ip6_link_ops)
 			unregister_netdevice_queue(dev, &list);
 
-	for (h = 0; h < HASH_SIZE; h++) {
+	for (h = 0; h < IP6_HASH_SIZE; h++) {
 		t = rtnl_dereference(ip6n->tnls_r_l[h]);
 		while (t) {
 			/* If dev is in the same netns, it has already
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d90a11f14040..30e242140909 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -50,14 +50,14 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
-#define HASH_SIZE_SHIFT  5
-#define HASH_SIZE (1 << HASH_SIZE_SHIFT)
+#define VTI_HASH_SIZE_SHIFT  5
+#define VTI_HASH_SIZE (1 << VTI_HASH_SIZE_SHIFT)
 
 static u32 HASH(const struct in6_addr *addr1, const struct in6_addr *addr2)
 {
 	u32 hash = ipv6_addr_hash(addr1) ^ ipv6_addr_hash(addr2);
 
-	return hash_32(hash, HASH_SIZE_SHIFT);
+	return hash_32(hash, VTI_HASH_SIZE_SHIFT);
 }
 
 static int vti6_dev_init(struct net_device *dev);
@@ -69,7 +69,7 @@ struct vti6_net {
 	/* the vti6 tunnel fallback device */
 	struct net_device *fb_tnl_dev;
 	/* lists for storing tunnels in use */
-	struct ip6_tnl __rcu *tnls_r_l[HASH_SIZE];
+	struct ip6_tnl __rcu *tnls_r_l[VTI_HASH_SIZE];
 	struct ip6_tnl __rcu *tnls_wc[1];
 	struct ip6_tnl __rcu **tnls[2];
 };
@@ -1040,7 +1040,7 @@ static void __net_exit vti6_destroy_tunnels(struct vti6_net *ip6n)
 	struct ip6_tnl *t;
 	LIST_HEAD(list);
 
-	for (h = 0; h < HASH_SIZE; h++) {
+	for (h = 0; h < VTI_HASH_SIZE; h++) {
 		t = rtnl_dereference(ip6n->tnls_r_l[h]);
 		while (t) {
 			unregister_netdevice_queue(t->dev, &list);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0a5a255277e5..757ec087ce01 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -62,7 +62,7 @@
    For comments look at net/ipv4/ip_gre.c --ANK
  */
 
-#define HASH_SIZE  16
+#define SIT_HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
 static bool log_ecn_error = true;
@@ -78,9 +78,9 @@ static struct rtnl_link_ops sit_link_ops __read_mostly;
 
 static int sit_net_id __read_mostly;
 struct sit_net {
-	struct ip_tunnel __rcu *tunnels_r_l[HASH_SIZE];
-	struct ip_tunnel __rcu *tunnels_r[HASH_SIZE];
-	struct ip_tunnel __rcu *tunnels_l[HASH_SIZE];
+	struct ip_tunnel __rcu *tunnels_r_l[SIT_HASH_SIZE];
+	struct ip_tunnel __rcu *tunnels_r[SIT_HASH_SIZE];
+	struct ip_tunnel __rcu *tunnels_l[SIT_HASH_SIZE];
 	struct ip_tunnel __rcu *tunnels_wc[1];
 	struct ip_tunnel __rcu **tunnels[4];
 
@@ -1773,7 +1773,7 @@ static void __net_exit sit_destroy_tunnels(struct net *net,
 
 	for (prio = 1; prio < 4; prio++) {
 		int h;
-		for (h = 0; h < HASH_SIZE; h++) {
+		for (h = 0; h < SIT_HASH_SIZE; h++) {
 			struct ip_tunnel *t;
 
 			t = rtnl_dereference(sitn->tunnels[prio][h]);
diff --git a/security/keys/encrypted-keys/encrypted.c b/security/keys/encrypted-keys/encrypted.c
index 5adbfc32242f..1c2271db2918 100644
--- a/security/keys/encrypted-keys/encrypted.c
+++ b/security/keys/encrypted-keys/encrypted.c
@@ -49,7 +49,7 @@ static int blksize;
 #define KEY_TRUSTED_PREFIX_LEN (sizeof (KEY_TRUSTED_PREFIX) - 1)
 #define KEY_USER_PREFIX_LEN (sizeof (KEY_USER_PREFIX) - 1)
 #define KEY_ECRYPTFS_DESC_LEN 16
-#define HASH_SIZE SHA256_DIGEST_SIZE
+#define E_HASH_SIZE SHA256_DIGEST_SIZE
 #define MAX_DATA_SIZE 4096
 #define MIN_DATA_SIZE  20
 
@@ -380,8 +380,8 @@ static int get_derived_key(u8 *derived_key, enum derived_key_type key_type,
 	int ret;
 
 	derived_buf_len = strlen("AUTH_KEY") + 1 + master_keylen;
-	if (derived_buf_len < HASH_SIZE)
-		derived_buf_len = HASH_SIZE;
+	if (derived_buf_len < E_HASH_SIZE)
+		derived_buf_len = E_HASH_SIZE;
 
 	derived_buf = kzalloc(derived_buf_len, GFP_KERNEL);
 	if (!derived_buf) {
@@ -517,7 +517,7 @@ out:
 static int datablob_hmac_append(struct encrypted_key_payload *epayload,
 				const u8 *master_key, size_t master_keylen)
 {
-	u8 derived_key[HASH_SIZE];
+	u8 derived_key[E_HASH_SIZE];
 	u8 *digest;
 	int ret;
 
@@ -529,7 +529,7 @@ static int datablob_hmac_append(struct encrypted_key_payload *epayload,
 	ret = calc_hmac(digest, derived_key, sizeof derived_key,
 			epayload->format, epayload->datablob_len);
 	if (!ret)
-		dump_hmac(NULL, digest, HASH_SIZE);
+		dump_hmac(NULL, digest, E_HASH_SIZE);
 out:
 	return ret;
 }
@@ -539,8 +539,8 @@ static int datablob_hmac_verify(struct encrypted_key_payload *epayload,
 				const u8 *format, const u8 *master_key,
 				size_t master_keylen)
 {
-	u8 derived_key[HASH_SIZE];
-	u8 digest[HASH_SIZE];
+	u8 derived_key[E_HASH_SIZE];
+	u8 digest[E_HASH_SIZE];
 	int ret;
 	char *p;
 	unsigned short len;
@@ -565,8 +565,8 @@ static int datablob_hmac_verify(struct encrypted_key_payload *epayload,
 		ret = -EINVAL;
 		dump_hmac("datablob",
 			  epayload->format + epayload->datablob_len,
-			  HASH_SIZE);
-		dump_hmac("calc", digest, HASH_SIZE);
+			  E_HASH_SIZE);
+		dump_hmac("calc", digest, E_HASH_SIZE);
 	}
 out:
 	return ret;
@@ -651,12 +651,12 @@ static struct encrypted_key_payload *encrypted_key_alloc(struct key *key,
 	    + strlen(datalen) + 1 + ivsize + 1 + encrypted_datalen;
 
 	ret = key_payload_reserve(key, payload_datalen + datablob_len
-				  + HASH_SIZE + 1);
+				  + E_HASH_SIZE + 1);
 	if (ret < 0)
 		return ERR_PTR(ret);
 
 	epayload = kzalloc(sizeof(*epayload) + payload_datalen +
-			   datablob_len + HASH_SIZE + 1, GFP_KERNEL);
+			   datablob_len + E_HASH_SIZE + 1, GFP_KERNEL);
 	if (!epayload)
 		return ERR_PTR(-ENOMEM);
 
@@ -670,7 +670,7 @@ static int encrypted_key_decrypt(struct encrypted_key_payload *epayload,
 				 const char *format, const char *hex_encoded_iv)
 {
 	struct key *mkey;
-	u8 derived_key[HASH_SIZE];
+	u8 derived_key[E_HASH_SIZE];
 	const u8 *master_key;
 	u8 *hmac;
 	const char *hex_encoded_data;
@@ -680,7 +680,7 @@ static int encrypted_key_decrypt(struct encrypted_key_payload *epayload,
 	int ret;
 
 	encrypted_datalen = roundup(epayload->decrypted_datalen, blksize);
-	asciilen = (ivsize + 1 + encrypted_datalen + HASH_SIZE) * 2;
+	asciilen = (ivsize + 1 + encrypted_datalen + E_HASH_SIZE) * 2;
 	if (strlen(hex_encoded_iv) != asciilen)
 		return -EINVAL;
 
@@ -695,7 +695,7 @@ static int encrypted_key_decrypt(struct encrypted_key_payload *epayload,
 
 	hmac = epayload->format + epayload->datablob_len;
 	ret = hex2bin(hmac, hex_encoded_data + (encrypted_datalen * 2),
-		      HASH_SIZE);
+		      E_HASH_SIZE);
 	if (ret < 0)
 		return -EINVAL;
 
@@ -918,7 +918,7 @@ static long encrypted_read(const struct key *key, char __user *buffer,
 	struct key *mkey;
 	const u8 *master_key;
 	size_t master_keylen;
-	char derived_key[HASH_SIZE];
+	char derived_key[E_HASH_SIZE];
 	char *ascii_buf;
 	size_t asciiblob_len;
 	int ret;
@@ -928,7 +928,7 @@ static long encrypted_read(const struct key *key, char __user *buffer,
 	/* returns the hex encoded iv, encrypted-data, and hmac as ascii */
 	asciiblob_len = epayload->datablob_len + ivsize + 1
 	    + roundup(epayload->decrypted_datalen, blksize)
-	    + (HASH_SIZE * 2);
+	    + (E_HASH_SIZE * 2);
 
 	if (!buffer || buflen < asciiblob_len)
 		return asciiblob_len;
-- 
2.5.0
