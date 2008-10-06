From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH v7 01/17] netlabel: Fix some sparse warnings
Date: Mon, 06 Oct 2008 15:19:48 -0400
Message-ID: <20081006191948.15686.24567.stgit@flek.lan>
References: <20081006191516.15686.80823.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20081006191516.15686.80823.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a few sparse warnings.  One dealt with a RCU lock being held on error,
another dealt with an improper type caused by a signed/unsigned mixup while
the rest appeared to be caused by using rcu_dereference() in a
list_for_each_entry_rcu() call.  The latter probably isn't a big deal, but
I derive a certain pleasure from knowing that the net/netlabel is nice and
clean.

Thanks to James Morris for pointing out the issues and demonstrating how
to run sparse.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/netlabel/netlabel_cipso_v4.c   |    4 ++--
 net/netlabel/netlabel_domainhash.c |   12 ++++++------
 net/netlabel/netlabel_unlabeled.c  |   12 ++++++------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 0aec318..aaf5003 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -491,7 +491,7 @@ list_start:
 	doi_def = cipso_v4_doi_getdef(doi);
 	if (doi_def == NULL) {
 		ret_val = -EINVAL;
-		goto list_failure;
+		goto list_failure_lock;
 	}
 
 	ret_val = nla_put_u32(ans_skb, NLBL_CIPSOV4_A_MTYPE, doi_def->type);
@@ -655,7 +655,7 @@ static int netlbl_cipsov4_listall(struct sk_buff *skb,
 				  struct netlink_callback *cb)
 {
 	struct netlbl_cipsov4_doiwalk_arg cb_arg;
-	int doi_skip = cb->args[0];
+	u32 doi_skip = cb->args[0];
 
 	cb_arg.nl_cb = cb;
 	cb_arg.skb = skb;
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 643c032..dc42206 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -115,13 +115,13 @@ static u32 netlbl_domhsh_hash(const char *key)
 static struct netlbl_dom_map *netlbl_domhsh_search(const char *domain)
 {
 	u32 bkt;
+	struct list_head *bkt_list;
 	struct netlbl_dom_map *iter;
 
 	if (domain != NULL) {
 		bkt = netlbl_domhsh_hash(domain);
-		list_for_each_entry_rcu(iter,
-				     &rcu_dereference(netlbl_domhsh)->tbl[bkt],
-				     list)
+		bkt_list = &rcu_dereference(netlbl_domhsh)->tbl[bkt];
+		list_for_each_entry_rcu(iter, bkt_list, list)
 			if (iter->valid && strcmp(iter->domain, domain) == 0)
 				return iter;
 	}
@@ -410,6 +410,7 @@ int netlbl_domhsh_walk(u32 *skip_bkt,
 {
 	int ret_val = -ENOENT;
 	u32 iter_bkt;
+	struct list_head *iter_list;
 	struct netlbl_dom_map *iter_entry;
 	u32 chain_cnt = 0;
 
@@ -417,9 +418,8 @@ int netlbl_domhsh_walk(u32 *skip_bkt,
 	for (iter_bkt = *skip_bkt;
 	     iter_bkt < rcu_dereference(netlbl_domhsh)->size;
 	     iter_bkt++, chain_cnt = 0) {
-		list_for_each_entry_rcu(iter_entry,
-				&rcu_dereference(netlbl_domhsh)->tbl[iter_bkt],
-				list)
+		iter_list = &rcu_dereference(netlbl_domhsh)->tbl[iter_bkt];
+		list_for_each_entry_rcu(iter_entry, iter_list, list)
 			if (iter_entry->valid) {
 				if (chain_cnt++ < *skip_chain)
 					continue;
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 921c118..cc105a1 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -381,12 +381,12 @@ static struct netlbl_unlhsh_addr6 *netlbl_unlhsh_search_addr6(
 static struct netlbl_unlhsh_iface *netlbl_unlhsh_search_iface(int ifindex)
 {
 	u32 bkt;
+	struct list_head *bkt_list;
 	struct netlbl_unlhsh_iface *iter;
 
 	bkt = netlbl_unlhsh_hash(ifindex);
-	list_for_each_entry_rcu(iter,
-				&rcu_dereference(netlbl_unlhsh)->tbl[bkt],
-				list)
+	bkt_list = &rcu_dereference(netlbl_unlhsh)->tbl[bkt];
+	list_for_each_entry_rcu(iter, bkt_list, list)
 		if (iter->valid && iter->ifindex == ifindex)
 			return iter;
 
@@ -1427,6 +1427,7 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 	struct netlbl_unlhsh_iface *iface;
 	struct netlbl_unlhsh_addr4 *addr4;
 	struct netlbl_unlhsh_addr6 *addr6;
+	struct list_head *iter_list;
 
 	cb_arg.nl_cb = cb;
 	cb_arg.skb = skb;
@@ -1436,9 +1437,8 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 	for (iter_bkt = skip_bkt;
 	     iter_bkt < rcu_dereference(netlbl_unlhsh)->size;
 	     iter_bkt++, iter_chain = 0, iter_addr4 = 0, iter_addr6 = 0) {
-		list_for_each_entry_rcu(iface,
-			        &rcu_dereference(netlbl_unlhsh)->tbl[iter_bkt],
-				list) {
+		iter_list = &rcu_dereference(netlbl_unlhsh)->tbl[iter_bkt];
+		list_for_each_entry_rcu(iface, iter_list, list) {
 			if (!iface->valid ||
 			    iter_chain++ < skip_chain)
 				continue;

