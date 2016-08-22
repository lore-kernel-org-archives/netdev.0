From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] xen-netback: using kfree_rcu() to simplify the code
Date: Mon, 22 Aug 2016 23:01:29 +0000
Message-ID: <1471906889-20132-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36095 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752572AbcHVXBz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 19:01:55 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so7063879pfg.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 16:01:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

The callback function of call_rcu() just calls a kfree(), so we
can use kfree_rcu() instead of call_rcu() + callback function.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/xen-netback/hash.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/xen-netback/hash.c b/drivers/net/xen-netback/hash.c
index 282b16d..e8c5ddd 100644
--- a/drivers/net/xen-netback/hash.c
+++ b/drivers/net/xen-netback/hash.c
@@ -32,15 +32,6 @@
 #include <linux/vmalloc.h>
 #include <linux/rculist.h>
 
-static void xenvif_del_hash(struct rcu_head *rcu)
-{
-	struct xenvif_hash_cache_entry *entry;
-
-	entry = container_of(rcu, struct xenvif_hash_cache_entry, rcu);
-
-	kfree(entry);
-}
-
 static void xenvif_add_hash(struct xenvif *vif, const u8 *tag,
 			    unsigned int len, u32 val)
 {
@@ -76,7 +67,7 @@ static void xenvif_add_hash(struct xenvif *vif, const u8 *tag,
 		if (++vif->hash.cache.count > xenvif_hash_cache_size) {
 			list_del_rcu(&oldest->link);
 			vif->hash.cache.count--;
-			call_rcu(&oldest->rcu, xenvif_del_hash);
+			kfree_rcu(oldest, rcu);
 		}
 	}
 
@@ -114,7 +105,7 @@ static void xenvif_flush_hash(struct xenvif *vif)
 	list_for_each_entry_rcu(entry, &vif->hash.cache.list, link) {
 		list_del_rcu(&entry->link);
 		vif->hash.cache.count--;
-		call_rcu(&entry->rcu, xenvif_del_hash);
+		kfree_rcu(entry, rcu);
 	}
 
 	spin_unlock_irqrestore(&vif->hash.cache.lock, flags);
