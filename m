From: Dave Jones <davej@redhat.com>
Subject: !CONFIG_PROC_FS fix for ipv6
Date: Tue, 9 Sep 2003 10:22:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030909092247.GA23468@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Against 2.6.test5


diff -urpN --exclude-from=/home/davej/.exclude bk-linus/net/ipv6/proc.c linux-2.5/net/ipv6/proc.c
--- bk-linus/net/ipv6/proc.c	2003-09-08 00:48:56.000000000 +0100
+++ linux-2.5/net/ipv6/proc.c	2003-09-08 22:29:05.000000000 +0100
@@ -32,7 +32,6 @@
 
 #ifdef CONFIG_PROC_FS
 static struct proc_dir_entry *proc_net_devsnmp6;
-#endif
 
 static int fold_prot_inuse(struct proto *proto)
 {
@@ -58,7 +57,6 @@ static int sockstat6_seq_show(struct seq
 	return 0;
 }
 
-
 struct snmp6_item
 {
 	char *name;
@@ -221,9 +219,7 @@ static struct file_operations snmp6_seq_
 int snmp6_register_dev(struct inet6_dev *idev)
 {
 	int err = -ENOMEM;
-#ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *p;
-#endif
 
 	if (!idev || !idev->dev)
 		return -EINVAL;
@@ -232,7 +228,6 @@ int snmp6_register_dev(struct inet6_dev 
 			   __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp;
 
-#ifdef CONFIG_PROC_FS
 	if (!proc_net_devsnmp6) {
 		err = -ENOENT;
 		goto err_proc;
@@ -244,27 +239,22 @@ int snmp6_register_dev(struct inet6_dev 
 	p->proc_fops = &snmp6_seq_fops;
 
 	idev->stats.proc_dir_entry = p;
-#endif
 	return 0;
 
-#ifdef CONFIG_PROC_FS
 err_proc:
 	snmp6_mib_free((void **)idev->stats.icmpv6);
-#endif
 err_icmp:
 	return err;
 }
 
 int snmp6_unregister_dev(struct inet6_dev *idev)
 {
-#ifdef CONFIG_PROC_FS
 	if (!proc_net_devsnmp6)
 		return -ENOENT;
 	if (!idev || !idev->stats.proc_dir_entry)
 		return -EINVAL;
 	remove_proc_entry(idev->stats.proc_dir_entry->name,
 			  proc_net_devsnmp6);
-#endif
 	snmp6_mib_free((void **)idev->stats.icmpv6);
 
 	return 0;
@@ -307,3 +297,31 @@ void ipv6_misc_proc_exit(void)
 	proc_net_remove("snmp6");
 }
 
+#else	/* CONFIG_PROC_FS */
+
+
+int snmp6_register_dev(struct inet6_dev *idev)
+{
+	int err = -ENOMEM;
+
+	if (!idev || !idev->dev)
+		return -EINVAL;
+
+	if (snmp6_mib_init((void **)idev->stats.icmpv6, sizeof(struct icmpv6_mib),
+			   __alignof__(struct icmpv6_mib)) < 0)
+		goto err_icmp;
+
+	return 0;
+
+err_icmp:
+	return err;
+}
+
+int snmp6_unregister_dev(struct inet6_dev *idev)
+{
+	snmp6_mib_free((void **)idev->stats.icmpv6);
+	return 0;
+}
+
+#endif
+
diff -urpN --exclude-from=/home/davej/.exclude bk-linus/net/ipv6/tcp_ipv6.c linux-2.5/net/ipv6/tcp_ipv6.c
--- bk-linus/net/ipv6/tcp_ipv6.c	2003-09-08 00:48:56.000000000 +0100
+++ linux-2.5/net/ipv6/tcp_ipv6.c	2003-09-08 22:29:06.000000000 +0100
@@ -2023,6 +2023,7 @@ static void get_timewait6_sock(struct se
 		   atomic_read(&tw->tw_refcnt), tw);
 }
 
+#ifdef CONFIG_PROC_FS
 static int tcp6_seq_show(struct seq_file *seq, void *v)
 {
 	struct tcp_iter_state *st;
@@ -2072,6 +2073,7 @@ void tcp6_proc_exit(void)
 {
 	tcp_proc_unregister(&tcp6_seq_afinfo);
 }
+#endif
 
 struct proto tcpv6_prot = {
 	.name		=	"TCPv6",

-- 
 Dave Jones     http://www.codemonkey.org.uk
