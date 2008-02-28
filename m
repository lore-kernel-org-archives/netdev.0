From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 02/15] [ATM]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:55:23 +0800
Message-ID: <47C6931B.70204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58364 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbYB1K5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:57:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/atm/br2684.c    |    4 ++--
 net/atm/clip.c      |    4 +---
 net/atm/lec.c       |    4 +---
 net/atm/mpoa_proc.c |    3 +--
 net/atm/proc.c      |    8 ++++----
 5 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 574d9a9..1b22806 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -742,9 +742,9 @@ static int __init br2684_init(void)
 {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *p;
-	if ((p = create_proc_entry("br2684", 0, atm_proc_root)) == NULL)
+	p = proc_create("br2684", 0, atm_proc_root, &br2684_proc_ops);
+	if (p == NULL)
 		return -ENOMEM;
-	p->proc_fops = &br2684_proc_ops;
 #endif
 	register_atm_ioctl(&br2684_ioctl_ops);
 	return 0;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 86b885e..d30167c 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -962,9 +962,7 @@ static int __init atm_clip_init(void)
 	{
 		struct proc_dir_entry *p;
 
-		p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
-		if (p)
-			p->proc_fops = &arp_seq_fops;
+		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
 	}
 #endif
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 1a8c4c6..0e450d1 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1249,9 +1249,7 @@ static int __init lane_module_init(void)
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *p;
 
-	p = create_proc_entry("lec", S_IRUGO, atm_proc_root);
-	if (p)
-		p->proc_fops = &lec_seq_fops;
+	p = proc_create("lec", S_IRUGO, atm_proc_root, &lec_seq_fops);
 #endif
 
 	register_atm_ioctl(&lane_ioctl_ops);
diff --git a/net/atm/mpoa_proc.c b/net/atm/mpoa_proc.c
index 91f3ffc..4990541 100644
--- a/net/atm/mpoa_proc.c
+++ b/net/atm/mpoa_proc.c
@@ -276,12 +276,11 @@ int mpc_proc_init(void)
 {
 	struct proc_dir_entry *p;
 
-	p = create_proc_entry(STAT_FILE_NAME, 0, atm_proc_root);
+	p = proc_create(STAT_FILE_NAME, 0, atm_proc_root, &mpc_file_operations);
 	if (!p) {
 		printk(KERN_ERR "Unable to initialize /proc/atm/%s\n", STAT_FILE_NAME);
 		return -ENOMEM;
 	}
-	p->proc_fops = &mpc_file_operations;
 	p->owner = THIS_MODULE;
 	return 0;
 }
diff --git a/net/atm/proc.c b/net/atm/proc.c
index 4912511..e9693ae 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -435,11 +435,11 @@ int atm_proc_dev_register(struct atm_dev *dev)
 		goto err_out;
 	sprintf(dev->proc_name,"%s:%d",dev->type, dev->number);
 
-	dev->proc_entry = create_proc_entry(dev->proc_name, 0, atm_proc_root);
+	dev->proc_entry = proc_create(dev->proc_name, 0, atm_proc_root,
+				      &proc_atm_dev_ops);
 	if (!dev->proc_entry)
 		goto err_free_name;
 	dev->proc_entry->data = dev;
-	dev->proc_entry->proc_fops = &proc_atm_dev_ops;
 	dev->proc_entry->owner = THIS_MODULE;
 	return 0;
 err_free_name:
@@ -492,10 +492,10 @@ int __init atm_proc_init(void)
 	for (e = atm_proc_ents; e->name; e++) {
 		struct proc_dir_entry *dirent;
 
-		dirent = create_proc_entry(e->name, S_IRUGO, atm_proc_root);
+		dirent = proc_create(e->name, S_IRUGO,
+				     atm_proc_root, e->proc_fops);
 		if (!dirent)
 			goto err_out_remove;
-		dirent->proc_fops = e->proc_fops;
 		dirent->owner = THIS_MODULE;
 		e->dirent = dirent;
 	}
-- 
WCN


