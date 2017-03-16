From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 8/9] net, ipv4: convert cipso_v4_doi.refcount from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:30 +0200
Message-ID: <1489688611-4542-9-git-send-email-elena.reshetova@intel.com>
References: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/cipso_ipv4.h |  3 ++-
 net/ipv4/cipso_ipv4.c    | 12 ++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a34b141..880adb2 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -41,6 +41,7 @@
 #include <net/netlabel.h>
 #include <net/request_sock.h>
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <asm/unaligned.h>
 
 /* known doi values */
@@ -85,7 +86,7 @@ struct cipso_v4_doi {
 	} map;
 	u8 tags[CIPSO_V4_TAG_MAXCNT];
 
-	atomic_t refcount;
+	refcount_t refcount;
 	struct list_head list;
 	struct rcu_head rcu;
 };
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index ae20616..0d8e309 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -375,7 +375,7 @@ static struct cipso_v4_doi *cipso_v4_doi_search(u32 doi)
 	struct cipso_v4_doi *iter;
 
 	list_for_each_entry_rcu(iter, &cipso_v4_doi_list, list)
-		if (iter->doi == doi && atomic_read(&iter->refcount))
+		if (iter->doi == doi && refcount_read(&iter->refcount))
 			return iter;
 	return NULL;
 }
@@ -429,7 +429,7 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def,
 		}
 	}
 
-	atomic_set(&doi_def->refcount, 1);
+	refcount_set(&doi_def->refcount, 1);
 
 	spin_lock(&cipso_v4_doi_list_lock);
 	if (cipso_v4_doi_search(doi_def->doi)) {
@@ -533,7 +533,7 @@ int cipso_v4_doi_remove(u32 doi, struct netlbl_audit *audit_info)
 		ret_val = -ENOENT;
 		goto doi_remove_return;
 	}
-	if (!atomic_dec_and_test(&doi_def->refcount)) {
+	if (!refcount_dec_and_test(&doi_def->refcount)) {
 		spin_unlock(&cipso_v4_doi_list_lock);
 		ret_val = -EBUSY;
 		goto doi_remove_return;
@@ -576,7 +576,7 @@ struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi)
 	doi_def = cipso_v4_doi_search(doi);
 	if (!doi_def)
 		goto doi_getdef_return;
-	if (!atomic_inc_not_zero(&doi_def->refcount))
+	if (!refcount_inc_not_zero(&doi_def->refcount))
 		doi_def = NULL;
 
 doi_getdef_return:
@@ -597,7 +597,7 @@ void cipso_v4_doi_putdef(struct cipso_v4_doi *doi_def)
 	if (!doi_def)
 		return;
 
-	if (!atomic_dec_and_test(&doi_def->refcount))
+	if (!refcount_dec_and_test(&doi_def->refcount))
 		return;
 	spin_lock(&cipso_v4_doi_list_lock);
 	list_del_rcu(&doi_def->list);
@@ -630,7 +630,7 @@ int cipso_v4_doi_walk(u32 *skip_cnt,
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(iter_doi, &cipso_v4_doi_list, list)
-		if (atomic_read(&iter_doi->refcount) > 0) {
+		if (refcount_read(&iter_doi->refcount) > 0) {
 			if (doi_cnt++ < *skip_cnt)
 				continue;
 			ret_val = callback(iter_doi, cb_arg);
-- 
2.7.4
