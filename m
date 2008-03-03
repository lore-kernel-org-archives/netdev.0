From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: take#2: [PATCH] [ATM]: Add error handling for proc_create fail
Date: Mon, 03 Mar 2008 10:44:33 +0800
Message-ID: <47CB6611.30004@cn.fujitsu.com>
References: <47C7B79C.2010304@cn.fujitsu.com> <20080229.103803.151963676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas3@users.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60514 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755894AbYCCCrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2008 21:47:36 -0500
In-Reply-To: <20080229.103803.151963676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-3-1 2:38:
> This is not sufficient.  If this fails you need to unregister
> the ioctl and all of the other things that get registered
> before this procfs registry runs.
> 

When proc_create() fail, we return -ENOMEM.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/atm/clip.c |   18 ++++++++++--------
 net/atm/lec.c  |    4 ++++
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index d30167c..66e5a91 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -949,6 +949,16 @@ static const struct file_operations arp_seq_fops = {
 
 static int __init atm_clip_init(void)
 {
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *p;
+
+	p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
+	if (!p) {
+		printk(KERN_ERR "Unable to initialize /proc/net/atm/arp\n");
+		return -ENOMEM;
+	}
+#endif
+
 	neigh_table_init_no_netlink(&clip_tbl);
 
 	clip_tbl_hook = &clip_tbl;
@@ -958,14 +968,6 @@ static int __init atm_clip_init(void)
 
 	setup_timer(&idle_timer, idle_timer_check, 0);
 
-#ifdef CONFIG_PROC_FS
-	{
-		struct proc_dir_entry *p;
-
-		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
-	}
-#endif
-
 	return 0;
 }
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 0e450d1..a2efa7f 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1250,6 +1250,10 @@ static int __init lane_module_init(void)
 	struct proc_dir_entry *p;
 
 	p = proc_create("lec", S_IRUGO, atm_proc_root, &lec_seq_fops);
+	if (!p) {
+		printk(KERN_ERR "Unable to initialize /proc/net/atm/lec\n");
+		return -ENOMEM;
+	}
 #endif
 
 	register_atm_ioctl(&lane_ioctl_ops);
-- 
WCN

