From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/3] NET: Use proc_net_fops_create() and proc_net_remove()
 in net/ipv4
Date: Mon, 08 Sep 2003 03:41:05 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908.034105.113815606.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[2/3] Use proc_net_fops_create() and proc_net_remove() in net/ipv4.

Index: linux-2.6/net/ipv4/arp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/arp.c,v
retrieving revision 1.27
diff -u -r1.27 arp.c
--- linux-2.6/net/ipv4/arp.c	20 Aug 2003 04:27:26 -0000	1.27
+++ linux-2.6/net/ipv4/arp.c	7 Sep 2003 16:51:04 -0000
@@ -1416,14 +1416,9 @@
 
 static int __init arp_proc_init(void)
 {
-	int rc = 0;
-	struct proc_dir_entry *p = create_proc_entry("arp", S_IRUGO, proc_net);
-
-        if (p)
-		p->proc_fops = &arp_seq_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	if (!proc_net_fops_create("arp", S_IRUGO, &arp_seq_fops))
+		return -ENOMEM;
+	return 0;
 }
 
 #else /* CONFIG_PROC_FS */
Index: linux-2.6/net/ipv4/fib_hash.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/fib_hash.c,v
retrieving revision 1.16
diff -u -r1.16 fib_hash.c
--- linux-2.6/net/ipv4/fib_hash.c	26 May 2003 05:17:28 -0000	1.16
+++ linux-2.6/net/ipv4/fib_hash.c	7 Sep 2003 16:51:04 -0000
@@ -1096,19 +1096,13 @@
 
 int __init fib_proc_init(void)
 {
-	struct proc_dir_entry *p;
-	int rc = 0;
-
-	p = create_proc_entry("route", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &fib_seq_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	if (!proc_net_fops_create("route", S_IRUGO, &fib_seq_fops))
+		return -ENOMEM;
+	return 0;
 }
 
 void __init fib_proc_exit(void)
 {
-	remove_proc_entry("route", proc_net);
+	proc_net_remove("route");
 }
 #endif /* CONFIG_PROC_FS */
Index: linux-2.6/net/ipv4/igmp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/igmp.c,v
retrieving revision 1.34
diff -u -r1.34 igmp.c
--- linux-2.6/net/ipv4/igmp.c	1 Sep 2003 05:52:50 -0000	1.34
+++ linux-2.6/net/ipv4/igmp.c	7 Sep 2003 16:51:04 -0000
@@ -2430,15 +2430,8 @@
 
 int __init igmp_mc_proc_init(void)
 {
-	struct proc_dir_entry *p;
-
-	p = create_proc_entry("igmp", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &igmp_mc_seq_fops;
-
-	p = create_proc_entry("mcfilter", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &igmp_mcf_seq_fops;
+	proc_net_fops_create("igmp", S_IRUGO, &igmp_mc_seq_fops);
+	proc_net_fops_create("mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
 	return 0;
 }
 #endif
Index: linux-2.6/net/ipv4/proc.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/proc.c,v
retrieving revision 1.14
diff -u -r1.14 proc.c
--- linux-2.6/net/ipv4/proc.c	22 May 2003 08:13:13 -0000	1.14
+++ linux-2.6/net/ipv4/proc.c	7 Sep 2003 16:51:04 -0000
@@ -238,28 +238,21 @@
 int __init ip_misc_proc_init(void)
 {
 	int rc = 0;
-	struct proc_dir_entry *p;
 
-	p = create_proc_entry("netstat", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("netstat", S_IRUGO, &netstat_seq_fops))
 		goto out_netstat;
-	p->proc_fops = &netstat_seq_fops;
 
-	p = create_proc_entry("snmp", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("snmp", S_IRUGO, &snmp_seq_fops))
 		goto out_snmp;
-	p->proc_fops = &snmp_seq_fops;
 
-	p = create_proc_entry("sockstat", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("sockstat", S_IRUGO, &sockstat_seq_fops))
 		goto out_sockstat;
-	p->proc_fops = &sockstat_seq_fops;
 out:
 	return rc;
 out_sockstat:
-	remove_proc_entry("snmp", proc_net);
+	proc_net_remove("snmp");
 out_snmp:
-	remove_proc_entry("netstat", proc_net);
+	proc_net_remove("netstat");
 out_netstat:
 	rc = -ENOMEM;
 	goto out;
Index: linux-2.6/net/ipv4/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/raw.c,v
retrieving revision 1.35
diff -u -r1.35 raw.c
--- linux-2.6/net/ipv4/raw.c	11 Jul 2003 04:06:16 -0000	1.35
+++ linux-2.6/net/ipv4/raw.c	7 Sep 2003 16:51:04 -0000
@@ -831,19 +831,13 @@
 
 int __init raw_proc_init(void)
 {
-	struct proc_dir_entry *p;
-	int rc = 0;
-
-	p = create_proc_entry("raw", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &raw_seq_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	if (!proc_net_fops_create("raw", S_IRUGO, &raw_seq_fops))
+		return -ENOMEM;
+	return 0;
 }
 
 void __init raw_proc_exit(void)
 {
-	remove_proc_entry("raw", proc_net);
+	proc_net_remove("raw");
 }
 #endif /* CONFIG_PROC_FS */
Index: linux-2.6/net/ipv4/tcp_ipv4.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/tcp_ipv4.c,v
retrieving revision 1.56
diff -u -r1.56 tcp_ipv4.c
--- linux-2.6/net/ipv4/tcp_ipv4.c	18 Aug 2003 07:06:49 -0000	1.56
+++ linux-2.6/net/ipv4/tcp_ipv4.c	7 Sep 2003 16:51:05 -0000
@@ -2413,11 +2413,15 @@
 {
 	struct tcp_seq_afinfo *afinfo = PDE(inode)->data;
 	struct seq_file *seq;
-	int rc = -ENOMEM;
-	struct tcp_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+	struct tcp_iter_state *s;
+	int rc;
 
+	if (unlikely(afinfo == NULL))
+		return -EINVAL;
+
+	s = kmalloc(sizeof(*s), GFP_KERNEL);
 	if (!s)
-		goto out;
+		return -ENOMEM;
 	memset(s, 0, sizeof(*s));
 	s->family		= afinfo->family;
 	s->seq_ops.start	= tcp_seq_start;
@@ -2450,11 +2454,10 @@
 	afinfo->seq_fops->llseek	= seq_lseek;
 	afinfo->seq_fops->release	= seq_release_private;
 	
-	p = create_proc_entry(afinfo->name, S_IRUGO, proc_net);
-	if (p) {
+	p = proc_net_fops_create(afinfo->name, S_IRUGO, afinfo->seq_fops);
+	if (p)
 		p->data = afinfo;
-		p->proc_fops = afinfo->seq_fops;
-	} else
+	else
 		rc = -ENOMEM;
 	return rc;
 }
@@ -2463,7 +2466,7 @@
 {
 	if (!afinfo)
 		return;
-	remove_proc_entry(afinfo->name, proc_net);
+	proc_net_remove(afinfo->name);
 	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops)); 
 }
 
Index: linux-2.6/net/ipv4/udp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/udp.c,v
retrieving revision 1.39
diff -u -r1.39 udp.c
--- linux-2.6/net/ipv4/udp.c	4 Sep 2003 15:47:07 -0000	1.39
+++ linux-2.6/net/ipv4/udp.c	7 Sep 2003 16:51:05 -0000
@@ -1460,11 +1460,10 @@
 	afinfo->seq_fops->llseek	= seq_lseek;
 	afinfo->seq_fops->release	= seq_release_private;
 
-	p = create_proc_entry(afinfo->name, S_IRUGO, proc_net);
-	if (p) {
+	p = proc_net_fops_create(afinfo->name, S_IRUGO, afinfo->seq_fops);
+	if (p)
 		p->data = afinfo;
-		p->proc_fops = afinfo->seq_fops;
-	} else
+	else
 		rc = -ENOMEM;
 	return rc;
 }
@@ -1473,7 +1472,7 @@
 {
 	if (!afinfo)
 		return;
-	remove_proc_entry(afinfo->name, proc_net);
+	proc_net_remove(afinfo->name);
 	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
