From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] pppoe: handle !PROC_FS
Date: Mon, 23 Feb 2004 13:40:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223134050.43d604d3.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.3-current.

--
~Randy


From: Luiz Fernando Capitulino <lcapitulino@prefeitura.sp.gov.br>



Hi all,

here is the version 23.7 with Francois tips, actually I'm not
testing against (err < 0), because it is not necessary.

diff -Nru linux-2.6.2/drivers/net/pppoe.c linux-2.6.2~/drivers/net/pppoe.c


 linux-263-kj1-rddunlap/drivers/net/pppoe.c |   34 +++++++++++++++++------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff -puN drivers/net/pppoe.c~net_pppoe_noprocfs2 drivers/net/pppoe.c
--- linux-263-kj1/drivers/net/pppoe.c~net_pppoe_noprocfs2	2004-02-18 14:45:48.000000000 -0800
+++ linux-263-kj1-rddunlap/drivers/net/pppoe.c	2004-02-18 14:45:48.000000000 -0800
@@ -1076,6 +1076,20 @@ static struct file_operations pppoe_seq_
 	.llseek		= seq_lseek,
 	.release	= seq_release,
 };
+
+static int __init pppoe_proc_init(void)
+{
+	struct proc_dir_entry *p;
+
+	p = create_proc_entry("pppoe", S_IRUGO, proc_net);
+	if (!p)
+		return -ENOMEM;
+
+	p->proc_fops = &pppoe_seq_fops;
+	return 0;
+}
+#else /* CONFIG_PROC_FS */
+static inline int pppoe_proc_init(void) { return 0; }
 #endif /* CONFIG_PROC_FS */
 
 /* ->ioctl are set at pppox_create */
@@ -1112,26 +1126,18 @@ static int __init pppoe_init(void)
 
 	if (err)
 		goto out;
-#ifdef CONFIG_PROC_FS
-{
-	struct proc_dir_entry *p = create_proc_entry("pppoe", S_IRUGO,
-						     proc_net);
-	err = -ENOMEM;
-	if (!p)
-		goto out_unregister;
+
+	err = pppoe_proc_init();
+	if (err) {
+		unregister_pppox_proto(PX_PROTO_OE);
+		goto out;
+	}
 	
-	p->proc_fops = &pppoe_seq_fops;
-	err = 0;
-}
-#endif /* CONFIG_PROC_FS */
 	dev_add_pack(&pppoes_ptype);
 	dev_add_pack(&pppoed_ptype);
 	register_netdevice_notifier(&pppoe_notifier);
 out:
 	return err;
-out_unregister:
-	unregister_pppox_proto(PX_PROTO_OE);
-	goto out;
 }
 
 static void __exit pppoe_exit(void)

_
