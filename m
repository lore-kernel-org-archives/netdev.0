From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 20/29: xt_recent: don't save proc dirs
Date: Thu, 27 Nov 2008 17:15:30 +0100 (MET)
Message-ID: <20081127161530.13891.67761.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit b0ceb560a4119f187dc50da655be389cb54ae4f9
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Thu Nov 20 09:57:01 2008 +0100

    netfilter: xt_recent: don't save proc dirs
    
    Not needed, since creation and removal are done by name.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 3c3dd22..fe80b61 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -72,9 +72,6 @@ struct recent_entry {
 struct recent_table {
 	struct list_head	list;
 	char			name[XT_RECENT_NAME_LEN];
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry	*proc_old, *proc;
-#endif
 	unsigned int		refcnt;
 	unsigned int		entries;
 	struct list_head	lru_list;
@@ -284,6 +281,9 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_recent_mtinfo *info = par->matchinfo;
 	struct recent_table *t;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *pde;
+#endif
 	unsigned i;
 	bool ret = false;
 
@@ -318,25 +318,25 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	for (i = 0; i < ip_list_hash_size; i++)
 		INIT_LIST_HEAD(&t->iphash[i]);
 #ifdef CONFIG_PROC_FS
-	t->proc = proc_create_data(t->name, ip_list_perms, recent_proc_dir,
+	pde = proc_create_data(t->name, ip_list_perms, recent_proc_dir,
 		  &recent_mt_fops, t);
-	if (t->proc == NULL) {
+	if (pde == NULL) {
 		kfree(t);
 		goto out;
 	}
+	pde->uid = ip_list_uid;
+	pde->gid = ip_list_gid;
 #ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	t->proc_old = proc_create_data(t->name, ip_list_perms, proc_old_dir,
+	pde = proc_create_data(t->name, ip_list_perms, proc_old_dir,
 		      &recent_old_fops, t);
-	if (t->proc_old == NULL) {
+	if (pde == NULL) {
 		remove_proc_entry(t->name, proc_old_dir);
 		kfree(t);
 		goto out;
 	}
-	t->proc_old->uid   = ip_list_uid;
-	t->proc_old->gid   = ip_list_gid;
+	pde->uid = ip_list_uid;
+	pde->gid = ip_list_gid;
 #endif
-	t->proc->uid       = ip_list_uid;
-	t->proc->gid       = ip_list_gid;
 #endif
 	spin_lock_bh(&recent_lock);
 	list_add_tail(&t->list, &tables);
