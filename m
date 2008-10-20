From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/07: xt_recent: use proc_create_data()
Date: Mon, 20 Oct 2008 11:54:15 +0200 (MEST)
Message-ID: <20081020095415.25670.57830.sendpatchset@x2.localnet>
References: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2b86e1165f44022907ab31293a22286b6d783254
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Sat Oct 18 15:20:57 2008 +0200

    netfilter: xt_recent: use proc_create_data()
    
    Fixes a crash in recent_seq_start:
    
    BUG: unable to handle kernel NULL pointer dereference at 0000000000000100
    IP: [<ffffffffa002119c>] recent_seq_start+0x4c/0x90 [xt_recent]
    PGD 17d33c067 PUD 107afe067 PMD 0
    Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
    CPU 0
    Modules linked in: ipt_LOG xt_recent af_packet iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 xt_tcpudp iptable_filter ip_tables x_tables ext2 nls_utf8 fuse sr_mod cdrom [last unloaded: ntfs]
    Pid: 32373, comm: cat Not tainted 2.6.27-04ab591808565f968d4406f6435090ad671ebdab #6
    RIP: 0010:[<ffffffffa002119c>]  [<ffffffffa002119c>] recent_seq_start+0x4c/0x90 [xt_recent]
    RSP: 0018:ffff88015fed7e28  EFLAGS: 00010246
    ...
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 4ebd4ca..280c471 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -318,15 +318,15 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	for (i = 0; i < ip_list_hash_size; i++)
 		INIT_LIST_HEAD(&t->iphash[i]);
 #ifdef CONFIG_PROC_FS
-	t->proc = proc_create(t->name, ip_list_perms, recent_proc_dir,
-		  &recent_mt_fops);
+	t->proc = proc_create_data(t->name, ip_list_perms, recent_proc_dir,
+		  &recent_mt_fops, t);
 	if (t->proc == NULL) {
 		kfree(t);
 		goto out;
 	}
 #ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	t->proc_old = proc_create(t->name, ip_list_perms, proc_old_dir,
-		      &recent_old_fops);
+	t->proc_old = proc_create_data(t->name, ip_list_perms, proc_old_dir,
+		      &recent_old_fops, t);
 	if (t->proc_old == NULL) {
 		remove_proc_entry(t->name, proc_old_dir);
 		kfree(t);
@@ -334,11 +334,9 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	}
 	t->proc_old->uid   = ip_list_uid;
 	t->proc_old->gid   = ip_list_gid;
-	t->proc_old->data  = t;
 #endif
 	t->proc->uid       = ip_list_uid;
 	t->proc->gid       = ip_list_gid;
-	t->proc->data      = t;
 #endif
 	spin_lock_bh(&recent_lock);
 	list_add_tail(&t->list, &tables);
