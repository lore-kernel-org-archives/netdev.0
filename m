From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/3] NET: Use proc_net_fops_create() and proc_net_remove()
 in net/ipv6
Date: Mon, 08 Sep 2003 03:41:07 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908.034107.96819866.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[3/3] Use proc_net_fops_create() and proc_net_remove() in net/ipv6.

Index: linux-2.6/net/ipv6/addrconf.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/addrconf.c,v
retrieving revision 1.52
diff -u -r1.52 addrconf.c
--- linux-2.6/net/ipv6/addrconf.c	4 Sep 2003 15:47:07 -0000	1.52
+++ linux-2.6/net/ipv6/addrconf.c	7 Sep 2003 16:51:14 -0000
@@ -2266,16 +2266,11 @@
 
 int __init if6_proc_init(void)
 {
-	struct proc_dir_entry *p;
-	int rc = 0;
-
-	p = create_proc_entry("if_inet6", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &if6_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	if (!proc_net_fops_create("if_inet6", S_IRUGO, &if6_fops))
+		return -ENOMEM;
+	return 0;
 }
+
 void if6_proc_exit(void)
 {
 	proc_net_remove("if_inet6");
Index: linux-2.6/net/ipv6/anycast.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/anycast.c,v
retrieving revision 1.7
diff -u -r1.7 anycast.c
--- linux-2.6/net/ipv6/anycast.c	25 Jul 2003 17:11:54 -0000	1.7
+++ linux-2.6/net/ipv6/anycast.c	7 Sep 2003 16:51:14 -0000
@@ -581,11 +581,9 @@
 
 int __init ac6_proc_init(void)
 {
-	struct proc_dir_entry *p;
+	if (!proc_net_fops_create("anycast6", S_IRUGO, &ac6_seq_fops))
+		return -ENOMEM;
 
-	p = create_proc_entry("anycast6", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &ac6_seq_fops;
 	return 0;
 }
 
Index: linux-2.6/net/ipv6/ip6_flowlabel.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_flowlabel.c,v
retrieving revision 1.8
diff -u -r1.8 ip6_flowlabel.c
--- linux-2.6/net/ipv6/ip6_flowlabel.c	2 Sep 2003 14:48:07 -0000	1.8
+++ linux-2.6/net/ipv6/ip6_flowlabel.c	7 Sep 2003 16:51:14 -0000
@@ -695,12 +695,7 @@
 void ip6_flowlabel_init()
 {
 #ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *p;
-#endif
-#ifdef CONFIG_PROC_FS
-	p = create_proc_entry("ip6_flowlabel", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &ip6fl_seq_fops;
+	proc_net_fops_create("ip6_flowlabel", S_IRUGO, &ip6fl_seq_fops);
 #endif
 }
 
Index: linux-2.6/net/ipv6/mcast.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/mcast.c,v
retrieving revision 1.31
diff -u -r1.31 mcast.c
--- linux-2.6/net/ipv6/mcast.c	1 Sep 2003 05:52:50 -0000	1.31
+++ linux-2.6/net/ipv6/mcast.c	7 Sep 2003 16:51:14 -0000
@@ -2378,9 +2378,6 @@
 	struct ipv6_pinfo *np;
 	struct sock *sk;
 	int err;
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *p;
-#endif
 
 	err = sock_create(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6, &igmp6_socket);
 	if (err < 0) {
@@ -2399,12 +2396,8 @@
 	np->hop_limit = 1;
 
 #ifdef CONFIG_PROC_FS
-	p = create_proc_entry("igmp6", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &igmp6_mc_seq_fops;
-	p = create_proc_entry("mcfilter6", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &igmp6_mcf_seq_fops;
+	proc_net_fops_create("igmp6", S_IRUGO, &igmp6_mc_seq_fops);
+	proc_net_fops_create("mcfilter6", S_IRUGO, &igmp6_mcf_seq_fops);
 #endif
 
 	return 0;
@@ -2414,6 +2407,7 @@
 {
 	sock_release(igmp6_socket);
 	igmp6_socket = NULL; /* for safety */
+
 #ifdef CONFIG_PROC_FS
 	proc_net_remove("mcfilter6");
 	proc_net_remove("igmp6");
Index: linux-2.6/net/ipv6/proc.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/proc.c,v
retrieving revision 1.18
diff -u -r1.18 proc.c
--- linux-2.6/net/ipv6/proc.c	9 Jul 2003 05:55:17 -0000	1.18
+++ linux-2.6/net/ipv6/proc.c	7 Sep 2003 16:51:14 -0000
@@ -273,21 +273,16 @@
 int __init ipv6_misc_proc_init(void)
 {
 	int rc = 0;
-	struct proc_dir_entry *p;
 
-	p = create_proc_entry("snmp6", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("snmp6", S_IRUGO, &snmp6_seq_fops))
 		goto proc_snmp6_fail;
-	else
-		p->proc_fops = &snmp6_seq_fops;
+
 	proc_net_devsnmp6 = proc_mkdir("dev_snmp6", proc_net);
 	if (!proc_net_devsnmp6)
 		goto proc_dev_snmp6_fail;
-	p = create_proc_entry("sockstat6", S_IRUGO, proc_net);
-	if (!p)
+
+	if (!proc_net_fops_create("sockstat6", S_IRUGO, &sockstat6_seq_fops))
 		goto proc_sockstat6_fail;
-	else
-		p->proc_fops = &sockstat6_seq_fops;
 out:
 	return rc;
 
Index: linux-2.6/net/ipv6/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/raw.c,v
retrieving revision 1.37
diff -u -r1.37 raw.c
--- linux-2.6/net/ipv6/raw.c	18 Aug 2003 10:14:52 -0000	1.37
+++ linux-2.6/net/ipv6/raw.c	7 Sep 2003 16:51:14 -0000
@@ -1059,12 +1059,8 @@
 
 int __init raw6_proc_init(void)
 {
-	struct proc_dir_entry *p = create_proc_entry("raw6", S_IRUGO, proc_net);
-
-	if (!p)
+	if (!proc_net_fops_create("raw6", S_IRUGO, &raw6_seq_fops))
 		return -ENOMEM;
-	p->proc_fops = &raw6_seq_fops;
-
 	return 0;
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
