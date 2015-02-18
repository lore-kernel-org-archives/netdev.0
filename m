From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] cxgb4: Fix incorrect 'c' suffix to %pI4, use %pISc instead
Date: Wed, 18 Feb 2015 15:29:45 -0800
Message-ID: <1424302185-13460-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	dan.carpenter@gmail.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19322 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750770AbbBRXaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 18:30:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Issue caught by 0-day kernel test infrastructure. Code changed to use sockaddr
members so that %pISc can be used instead.

Fixes: b5a02f503caa ('cxgb4 : Update ipv6 address handling api')

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c | 57 ++++++++++++++-------------
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h |  6 ++-
 2 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
index 9062a84..c308429 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
@@ -35,10 +35,10 @@ static inline unsigned int ipv6_clip_hash(struct clip_tbl *d, const u32 *key)
 }
 
 static unsigned int clip_addr_hash(struct clip_tbl *ctbl, const u32 *addr,
-				   int addr_len)
+				   u8 v6)
 {
-	return addr_len == 4 ? ipv4_clip_hash(ctbl, addr) :
-				ipv6_clip_hash(ctbl, addr);
+	return v6 ? ipv6_clip_hash(ctbl, addr) :
+			ipv4_clip_hash(ctbl, addr);
 }
 
 static int clip6_get_mbox(const struct net_device *dev,
@@ -78,23 +78,22 @@ int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
 	struct clip_entry *ce, *cte;
 	u32 *addr = (u32 *)lip;
 	int hash;
-	int addr_len;
-	int ret = 0;
+	int ret = -1;
 
 	if (!ctbl)
 		return 0;
 
-	if (v6)
-		addr_len = 16;
-	else
-		addr_len = 4;
-
-	hash = clip_addr_hash(ctbl, addr, addr_len);
+	hash = clip_addr_hash(ctbl, addr, v6);
 
 	read_lock_bh(&ctbl->lock);
 	list_for_each_entry(cte, &ctbl->hash_list[hash], list) {
-		if (addr_len == cte->addr_len &&
-		    memcmp(lip, cte->addr, cte->addr_len) == 0) {
+		if (cte->addr6.sin6_family == AF_INET6 && v6)
+			ret = memcmp(lip, cte->addr6.sin6_addr.s6_addr,
+				     sizeof(struct in6_addr));
+		else if (cte->addr.sin_family == AF_INET && !v6)
+			ret = memcmp(lip, (char *)(&cte->addr.sin_addr),
+				     sizeof(struct in_addr));
+		if (!ret) {
 			ce = cte;
 			read_unlock_bh(&ctbl->lock);
 			goto found;
@@ -111,15 +110,20 @@ int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
 		spin_lock_init(&ce->lock);
 		atomic_set(&ce->refcnt, 0);
 		atomic_dec(&ctbl->nfree);
-		ce->addr_len = addr_len;
-		memcpy(ce->addr, lip, addr_len);
 		list_add_tail(&ce->list, &ctbl->hash_list[hash]);
 		if (v6) {
+			ce->addr6.sin6_family = AF_INET6;
+			memcpy(ce->addr6.sin6_addr.s6_addr,
+			       lip, sizeof(struct in6_addr));
 			ret = clip6_get_mbox(dev, (const struct in6_addr *)lip);
 			if (ret) {
 				write_unlock_bh(&ctbl->lock);
 				return ret;
 			}
+		} else {
+			ce->addr.sin_family = AF_INET;
+			memcpy((char *)(&ce->addr.sin_addr), lip,
+			       sizeof(struct in_addr));
 		}
 	} else {
 		write_unlock_bh(&ctbl->lock);
@@ -140,19 +144,19 @@ void cxgb4_clip_release(const struct net_device *dev, const u32 *lip, u8 v6)
 	struct clip_entry *ce, *cte;
 	u32 *addr = (u32 *)lip;
 	int hash;
-	int addr_len;
-
-	if (v6)
-		addr_len = 16;
-	else
-		addr_len = 4;
+	int ret = -1;
 
-	hash = clip_addr_hash(ctbl, addr, addr_len);
+	hash = clip_addr_hash(ctbl, addr, v6);
 
 	read_lock_bh(&ctbl->lock);
 	list_for_each_entry(cte, &ctbl->hash_list[hash], list) {
-		if (addr_len == cte->addr_len &&
-		    memcmp(lip, cte->addr, cte->addr_len) == 0) {
+		if (cte->addr6.sin6_family == AF_INET6 && v6)
+			ret = memcmp(lip, cte->addr6.sin6_addr.s6_addr,
+				     sizeof(struct in6_addr));
+		else if (cte->addr.sin_family == AF_INET && !v6)
+			ret = memcmp(lip, (char *)(&cte->addr.sin_addr),
+				     sizeof(struct in_addr));
+		if (!ret) {
 			ce = cte;
 			read_unlock_bh(&ctbl->lock);
 			goto found;
@@ -249,10 +253,7 @@ int clip_tbl_show(struct seq_file *seq, void *v)
 	for (i = 0 ; i < ctbl->clipt_size;  ++i) {
 		list_for_each_entry(ce, &ctbl->hash_list[i], list) {
 			ip[0] = '\0';
-			if (ce->addr_len == 16)
-				sprintf(ip, "%pI6c", ce->addr);
-			else
-				sprintf(ip, "%pI4c", ce->addr);
+			sprintf(ip, "%pISc", &ce->addr);
 			seq_printf(seq, "%-25s   %u\n", ip,
 				   atomic_read(&ce->refcnt));
 		}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h
index 2eaba01..35eb43c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h
@@ -14,8 +14,10 @@ struct clip_entry {
 	spinlock_t lock;	/* Hold while modifying clip reference */
 	atomic_t refcnt;
 	struct list_head list;
-	u32 addr[4];
-	int addr_len;
+	union {
+		struct sockaddr_in addr;
+		struct sockaddr_in6 addr6;
+	};
 };
 
 struct clip_tbl {
-- 
2.3.0
