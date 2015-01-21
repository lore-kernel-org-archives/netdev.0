From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v2] rhashtable: rhashtable_remove() must unlink in
 both tbl and future_tbl
Date: Wed, 21 Jan 2015 11:54:01 +0000
Message-ID: <20150121115401.GA12570@casper.infradead.org>
References: <54BCBA35.2080103@windriver.com>
 <20150119125928.GB7672@casper.infradead.org>
 <54BDC30D.5000606@windriver.com>
 <20150120165826.GK20315@casper.infradead.org>
 <54BEA1F9.1050908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>,
	"richard.alpe@ericsson.com >> Richard Alpe"
	<richard.alpe@ericsson.com>, Netdev <netdev@vger.kernel.org>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36274 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbbAULyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 06:54:04 -0500
Content-Disposition: inline
In-Reply-To: <54BEA1F9.1050908@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As removals can occur during resizes, entries may be referred to from
both tbl and future_tbl when the removal is requested. Therefore
rhashtable_remove() must unlink the entry in both tables if this is
the case. The existing code did search both tables but stopped when it
hit the first match.

Failing to unlink in both tables resulted in use after free.

Fixes: 97defe1ecf86 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
Reported-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v2: 12 digit commit reference, commit msg clarification as pointed
    out by Sergei.

 lib/rhashtable.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 84a78e3..bc2d0d8 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -585,6 +585,7 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 	struct rhash_head *he;
 	spinlock_t *lock;
 	unsigned int hash;
+	bool ret = false;
 
 	rcu_read_lock();
 	tbl = rht_dereference_rcu(ht->tbl, ht);
@@ -602,17 +603,16 @@ restart:
 		}
 
 		rcu_assign_pointer(*pprev, obj->next);
-		atomic_dec(&ht->nelems);
-
-		spin_unlock_bh(lock);
-
-		rhashtable_wakeup_worker(ht);
-
-		rcu_read_unlock();
 
-		return true;
+		ret = true;
+		break;
 	}
 
+	/* The entry may be linked in either 'tbl', 'future_tbl', or both.
+	 * 'future_tbl' only exists for a short period of time during
+	 * resizing. Thus traversing both is fine and the added cost is
+	 * very rare.
+	 */
 	if (tbl != rht_dereference_rcu(ht->future_tbl, ht)) {
 		spin_unlock_bh(lock);
 
@@ -625,9 +625,15 @@ restart:
 	}
 
 	spin_unlock_bh(lock);
+
+	if (ret) {
+		atomic_dec(&ht->nelems);
+		rhashtable_wakeup_worker(ht);
+	}
+
 	rcu_read_unlock();
 
-	return false;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(rhashtable_remove);
 
-- 
1.9.3
