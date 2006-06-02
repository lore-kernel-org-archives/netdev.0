From: akpm@osdl.org
Subject: [patch 16/17] recent match: fix "sleeping function called from invalid context"
Date: Thu, 01 Jun 2006 20:32:39 -0700
Message-ID: <200606020328.k523SKhS028868@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10165 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751206AbWFBD2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:33 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Patrick McHardy <kaber@trash.net>

create_proc_entry must not be called with locks held.  Use a mutex instead
to protect data only changed in user context.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/ipv4/netfilter/ipt_recent.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff -puN net/ipv4/netfilter/ipt_recent.c~recent-match-fix-sleeping-function-called-from-invalid-context net/ipv4/netfilter/ipt_recent.c
--- devel/net/ipv4/netfilter/ipt_recent.c~recent-match-fix-sleeping-function-called-from-invalid-context	2006-06-01 20:31:51.000000000 -0700
+++ devel-akpm/net/ipv4/netfilter/ipt_recent.c	2006-06-01 20:31:51.000000000 -0700
@@ -69,6 +69,7 @@ struct recent_table {
 
 static LIST_HEAD(tables);
 static DEFINE_SPINLOCK(recent_lock);
+static DEFINE_MUTEX(recent_mutex);
 
 #ifdef CONFIG_PROC_FS
 static struct proc_dir_entry	*proc_dir;
@@ -249,7 +250,7 @@ ipt_recent_checkentry(const char *tablen
 	    strnlen(info->name, IPT_RECENT_NAME_LEN) == IPT_RECENT_NAME_LEN)
 		return 0;
 
-	spin_lock_bh(&recent_lock);
+	mutex_lock(&recent_mutex);
 	t = recent_table_lookup(info->name);
 	if (t != NULL) {
 		t->refcnt++;
@@ -258,7 +259,7 @@ ipt_recent_checkentry(const char *tablen
 	}
 
 	t = kzalloc(sizeof(*t) + sizeof(t->iphash[0]) * ip_list_hash_size,
-		    GFP_ATOMIC);
+		    GFP_KERNEL);
 	if (t == NULL)
 		goto out;
 	strcpy(t->name, info->name);
@@ -274,10 +275,12 @@ ipt_recent_checkentry(const char *tablen
 	t->proc->proc_fops = &recent_fops;
 	t->proc->data      = t;
 #endif
+	spin_lock_bh(&recent_lock);
 	list_add_tail(&t->list, &tables);
+	spin_unlock_bh(&recent_lock);
 	ret = 1;
 out:
-	spin_unlock_bh(&recent_lock);
+	mutex_unlock(&recent_mutex);
 	return ret;
 }
 
@@ -288,17 +291,19 @@ ipt_recent_destroy(const struct xt_match
 	const struct ipt_recent_info *info = matchinfo;
 	struct recent_table *t;
 
-	spin_lock_bh(&recent_lock);
+	mutex_lock(&recent_mutex);
 	t = recent_table_lookup(info->name);
 	if (--t->refcnt == 0) {
+		spin_lock_bh(&recent_lock);
 		list_del(&t->list);
+		spin_unlock_bh(&recent_lock);
 		recent_table_flush(t);
 #ifdef CONFIG_PROC_FS
 		remove_proc_entry(t->name, proc_dir);
 #endif
 		kfree(t);
 	}
-	spin_unlock_bh(&recent_lock);
+	mutex_unlock(&recent_mutex);
 }
 
 #ifdef CONFIG_PROC_FS
_
