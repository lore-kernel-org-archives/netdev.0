From: kaber@trash.net
Subject: [PATCH 14/84] netfilter: xt_recent: remove old proc directory
Date: Mon, 10 May 2010 22:17:45 +0200
Message-ID: <1273522735-24672-15-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756666Ab0EJUTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:00 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

The compat option was introduced in October 2008.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 Documentation/feature-removal-schedule.txt |   10 ---
 net/netfilter/Kconfig                      |    7 --
 net/netfilter/xt_recent.c                  |  105 ----------------------------
 3 files changed, 0 insertions(+), 122 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index fa327f6..ea227e3 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -241,16 +241,6 @@ Who:	Thomas Gleixner <tglx@linutronix.de>
 
 ---------------------------
 
-What (Why):
-	- xt_recent: the old ipt_recent proc dir
-	  (superseded by /proc/net/xt_recent)
-
-When:	January 2009 or Linux 2.7.0, whichever comes first
-Why:	Superseded by newer revisions or modules
-Who:	Jan Engelhardt <jengelh@medozas.de>
-
----------------------------
-
 What:	GPIO autorequest on gpio_direction_{input,output}() in gpiolib
 When:	February 2010
 Why:	All callers should use explicit gpio_request()/gpio_free().
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8550dfd..6ac28ef 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -859,13 +859,6 @@ config NETFILTER_XT_MATCH_RECENT
 	Short options are available by using 'iptables -m recent -h'
 	Official Website: <http://snowman.net/projects/ipt_recent/>
 
-config NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	bool 'Enable obsolete /proc/net/ipt_recent'
-	depends on NETFILTER_XT_MATCH_RECENT && PROC_FS
-	---help---
-	This option enables the old /proc/net/ipt_recent interface,
-	which has been obsoleted by /proc/net/xt_recent.
-
 config NETFILTER_XT_MATCH_SCTP
 	tristate  '"sctp" protocol match support (EXPERIMENTAL)'
 	depends on EXPERIMENTAL
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index bcabfbc..2ff8aae 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -83,9 +83,6 @@ struct recent_net {
 	struct list_head	tables;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry	*xt_recent;
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	struct proc_dir_entry	*ipt_recent;
-#endif
 #endif
 };
 
@@ -342,17 +339,6 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	}
 	pde->uid = ip_list_uid;
 	pde->gid = ip_list_gid;
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	pde = proc_create_data(t->name, ip_list_perms, recent_net->ipt_recent,
-		      &recent_old_fops, t);
-	if (pde == NULL) {
-		remove_proc_entry(t->name, recent_net->xt_recent);
-		kfree(t);
-		goto out;
-	}
-	pde->uid = ip_list_uid;
-	pde->gid = ip_list_gid;
-#endif
 #endif
 	spin_lock_bh(&recent_lock);
 	list_add_tail(&t->list, &recent_net->tables);
@@ -376,9 +362,6 @@ static void recent_mt_destroy(const struct xt_mtdtor_param *par)
 		list_del(&t->list);
 		spin_unlock_bh(&recent_lock);
 #ifdef CONFIG_PROC_FS
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-		remove_proc_entry(t->name, recent_net->ipt_recent);
-#endif
 		remove_proc_entry(t->name, recent_net->xt_recent);
 #endif
 		recent_table_flush(t);
@@ -470,84 +453,6 @@ static int recent_seq_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-static int recent_old_seq_open(struct inode *inode, struct file *filp)
-{
-	static bool warned_of_old;
-
-	if (unlikely(!warned_of_old)) {
-		printk(KERN_INFO KBUILD_MODNAME ": Use of /proc/net/ipt_recent"
-		       " is deprecated; use /proc/net/xt_recent.\n");
-		warned_of_old = true;
-	}
-	return recent_seq_open(inode, filp);
-}
-
-static ssize_t recent_old_proc_write(struct file *file,
-				     const char __user *input,
-				     size_t size, loff_t *loff)
-{
-	const struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	struct recent_table *t = pde->data;
-	struct recent_entry *e;
-	char buf[sizeof("+255.255.255.255")], *c = buf;
-	union nf_inet_addr addr = {};
-	int add;
-
-	if (size > sizeof(buf))
-		size = sizeof(buf);
-	if (copy_from_user(buf, input, size))
-		return -EFAULT;
-
-	c = skip_spaces(c);
-
-	if (size - (c - buf) < 5)
-		return c - buf;
-	if (!strncmp(c, "clear", 5)) {
-		c += 5;
-		spin_lock_bh(&recent_lock);
-		recent_table_flush(t);
-		spin_unlock_bh(&recent_lock);
-		return c - buf;
-	}
-
-	switch (*c) {
-	case '-':
-		add = 0;
-		c++;
-		break;
-	case '+':
-		c++;
-	default:
-		add = 1;
-		break;
-	}
-	addr.ip = in_aton(c);
-
-	spin_lock_bh(&recent_lock);
-	e = recent_entry_lookup(t, &addr, NFPROTO_IPV4, 0);
-	if (e == NULL) {
-		if (add)
-			recent_entry_init(t, &addr, NFPROTO_IPV4, 0);
-	} else {
-		if (add)
-			recent_entry_update(t, e);
-		else
-			recent_entry_remove(t, e);
-	}
-	spin_unlock_bh(&recent_lock);
-	return size;
-}
-
-static const struct file_operations recent_old_fops = {
-	.open		= recent_old_seq_open,
-	.read		= seq_read,
-	.write		= recent_old_proc_write,
-	.release	= seq_release_private,
-	.owner		= THIS_MODULE,
-};
-#endif
-
 static ssize_t
 recent_mt_proc_write(struct file *file, const char __user *input,
 		     size_t size, loff_t *loff)
@@ -636,21 +541,11 @@ static int __net_init recent_proc_net_init(struct net *net)
 	recent_net->xt_recent = proc_mkdir("xt_recent", net->proc_net);
 	if (!recent_net->xt_recent)
 		return -ENOMEM;
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	recent_net->ipt_recent = proc_mkdir("ipt_recent", net->proc_net);
-	if (!recent_net->ipt_recent) {
-		proc_net_remove(net, "xt_recent");
-		return -ENOMEM;
-	}
-#endif
 	return 0;
 }
 
 static void __net_exit recent_proc_net_exit(struct net *net)
 {
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	proc_net_remove(net, "ipt_recent");
-#endif
 	proc_net_remove(net, "xt_recent");
 }
 #else
-- 
1.7.0.4

