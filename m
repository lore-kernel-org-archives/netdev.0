From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: Re: Fw: [Kernel-janitors] net/atm/clip.c: check kmem_cache_create() #1
Date: Thu, 05 Feb 2004 07:22:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402051222.i15CMcRr029937@ginger.cmf.nrl.navy.mil>
References: <romieu@fr.zoreil.com>
Cc: davem@redhat.com, "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: Message from Francois Romieu <romieu@fr.zoreil.com>
   of "Wed, 04 Feb 2004 22:47:40 +0100." <20040204224740.B19321@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20040204224740.B19321@electric-eye.fr.zoreil.com>,Francois Romieu w
rites:
>One should probably apply the following patch on top of it btw.
>Unbalanced call to create_proc_entry() on error path.

how about the following instead?  we probably shouldnt register the
proc entry until clip_tbl is going to be ready for use anyway (the
arp table iterators should probably also use clip_tbl instead of
clip_tbl_hook).

===== net/atm/clip.c 1.30 vs edited =====
--- 1.30/net/atm/clip.c	Wed Feb  4 13:07:57 2004
+++ edited/net/atm/clip.c	Thu Feb  5 07:18:03 2004
@@ -1008,14 +1008,6 @@
 
 static int __init atm_clip_init(void)
 {
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *p;
-
-	p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
-	if (p)
-		p->proc_fops = &arp_seq_fops;
-#endif
-
 	/* we should use neigh_table_init() */
 	clip_tbl.lock = RW_LOCK_UNLOCKED;
 	clip_tbl.kmem_cachep = kmem_cache_create(clip_tbl.id,
@@ -1032,6 +1024,16 @@
 
 	clip_tbl_hook = &clip_tbl;
 	register_atm_ioctl(&clip_ioctl_ops);
+
+#ifdef CONFIG_PROC_FS
+{
+	struct proc_dir_entry *p;
+
+	p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
+	if (p)
+		p->proc_fops = &arp_seq_fops;
+}
+#endif
 
 	return 0;
 }
