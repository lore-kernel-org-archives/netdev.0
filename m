From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: take#3: [PATCH] [ATM]: Add error handling for proc_create fail
Date: Mon, 03 Mar 2008 16:46:16 +0800
Message-ID: <47CBBAD8.2010802@cn.fujitsu.com>
References: <47C7B79C.2010304@cn.fujitsu.com>	<20080229.103803.151963676.davem@davemloft.net>	<47CB6611.30004@cn.fujitsu.com> <20080302.210926.16120136.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas3@users.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63594 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753281AbYCCItD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 03:49:03 -0500
In-Reply-To: <20080302.210926.16120136.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-3-3 13:09:
> Sigh....
> 
> I know you want to avoid all of the error handling unwind code, but
> you can't do that in this situation.  It's not valid to register the
> ATM clip procfs file without first initializing the ATM clip neighbour
> table, so moving it up like this isn't going to work.
> 
> They way you've done it, a user can open the procfs file and access
> the datastructure before it's initialized properly.
> 
> Please, simply add the necessary unregister code and leave the procfs
> initialization where it currently is.
> 
> I get the sense you really aren't reading this code carefully and
> you're tossing these patches together as quickly as you can to just
> get it done.  Please don't do that, it wastes both my time and
> your's.
> 

No, I didn't read the code very carefully. Sorry for that.
However, I don't think it's necessary to put procfs init after ioctl,
although it's necessary to do clip procfs init after neighbour tbl init.
If i am wrong, please correct me.

But I still put clip profs init where it was, because all the unregister
can be done easily when I pick the code up to a static function called
atm_clip_exit_noproc().

Here is the new patch.

---
When proc_create() fails, do some error handling work and return -ENOMEM.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/atm/clip.c |   61 +++++++++++++++++++++++++++++++++-----------------------
 net/atm/lec.c  |    4 +++
 2 files changed, 40 insertions(+), 25 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index d30167c..24c60ba 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -947,34 +947,10 @@ static const struct file_operations arp_seq_fops = {
 };
 #endif
 
-static int __init atm_clip_init(void)
-{
-	neigh_table_init_no_netlink(&clip_tbl);
-
-	clip_tbl_hook = &clip_tbl;
-	register_atm_ioctl(&clip_ioctl_ops);
-	register_netdevice_notifier(&clip_dev_notifier);
-	register_inetaddr_notifier(&clip_inet_notifier);
-
-	setup_timer(&idle_timer, idle_timer_check, 0);
-
-#ifdef CONFIG_PROC_FS
-	{
-		struct proc_dir_entry *p;
-
-		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
-	}
-#endif
-
-	return 0;
-}
-
-static void __exit atm_clip_exit(void)
+static void atm_clip_exit_noproc(void)
 {
 	struct net_device *dev, *next;
 
-	remove_proc_entry("arp", atm_proc_root);
-
 	unregister_inetaddr_notifier(&clip_inet_notifier);
 	unregister_netdevice_notifier(&clip_dev_notifier);
 
@@ -1005,6 +981,41 @@ static void __exit atm_clip_exit(void)
 	clip_tbl_hook = NULL;
 }
 
+static int __init atm_clip_init(void)
+{
+	neigh_table_init_no_netlink(&clip_tbl);
+
+	clip_tbl_hook = &clip_tbl;
+	register_atm_ioctl(&clip_ioctl_ops);
+	register_netdevice_notifier(&clip_dev_notifier);
+	register_inetaddr_notifier(&clip_inet_notifier);
+
+	setup_timer(&idle_timer, idle_timer_check, 0);
+
+#ifdef CONFIG_PROC_FS
+	{
+		struct proc_dir_entry *p;
+
+		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
+		if (!p) {
+			printk(KERN_ERR "Unable to initialize "
+			       "/proc/net/atm/arp\n");
+			atm_clip_exit_noproc();
+			return -ENOMEM;
+		}
+	}
+#endif
+
+	return 0;
+}
+
+static void __exit atm_clip_exit(void)
+{
+	remove_proc_entry("arp", atm_proc_root);
+
+	atm_clip_exit_noproc();
+}
+
 module_init(atm_clip_init);
 module_exit(atm_clip_exit);
 MODULE_AUTHOR("Werner Almesberger");
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

