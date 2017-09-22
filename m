From: Aaron Wood <aaronjwood@gmail.com>
Subject: [PATCH] Switch to use the new hashtable implementation. This reduces the code and need for yet another hashtable implementation.
Date: Fri, 22 Sep 2017 12:25:03 -0400
Message-ID: <20170922162503.3744-1-aaronjwood@gmail.com>
Cc: Aaron Wood <aaronjwood@gmail.com>
To: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
        davem@davemloft.net, v9fs-developer@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Aaron Wood <aaronjwood@gmail.com>
---
 net/9p/error.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/9p/error.c b/net/9p/error.c
index 126fd0dceea2..2e966fcc5cbb 100644
--- a/net/9p/error.c
+++ b/net/9p/error.c
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/list.h>
 #include <linux/jhash.h>
+#include <linux/hashtable.h>
 #include <linux/errno.h>
 #include <net/9p/9p.h>
 
@@ -50,8 +51,8 @@ struct errormap {
 	struct hlist_node list;
 };
 
-#define ERRHASHSZ		32
-static struct hlist_head hash_errmap[ERRHASHSZ];
+#define ERR_HASH_BITS		5
+static DEFINE_HASHTABLE(hash_errmap, ERR_HASH_BITS);
 
 /* FixMe - reduce to a reasonable size */
 static struct errormap errmap[] = {
@@ -193,18 +194,14 @@ static struct errormap errmap[] = {
 int p9_error_init(void)
 {
 	struct errormap *c;
-	int bucket;
-
-	/* initialize hash table */
-	for (bucket = 0; bucket < ERRHASHSZ; bucket++)
-		INIT_HLIST_HEAD(&hash_errmap[bucket]);
+	int key;
 
 	/* load initial error map into hash table */
 	for (c = errmap; c->name != NULL; c++) {
 		c->namelen = strlen(c->name);
-		bucket = jhash(c->name, c->namelen, 0) % ERRHASHSZ;
+		key = jhash(c->name, c->namelen, 0);
 		INIT_HLIST_NODE(&c->list);
-		hlist_add_head(&c->list, &hash_errmap[bucket]);
+		hash_add(hash_errmap, &c->list, key);
 	}
 
 	return 1;
@@ -222,12 +219,12 @@ int p9_errstr2errno(char *errstr, int len)
 {
 	int errno;
 	struct errormap *c;
-	int bucket;
+	int key;
 
 	errno = 0;
 	c = NULL;
-	bucket = jhash(errstr, len, 0) % ERRHASHSZ;
-	hlist_for_each_entry(c, &hash_errmap[bucket], list) {
+	key = jhash(errstr, len, 0);
+	hash_for_each_possible(hash_errmap, c, list, key) {
 		if (c->namelen == len && !memcmp(c->name, errstr, len)) {
 			errno = c->val;
 			break;
-- 
2.11.0
