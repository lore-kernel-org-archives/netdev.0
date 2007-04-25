From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] [IPV4]: Consolidate common SNMP code
Date: Wed, 25 Apr 2007 14:04:09 +1000
Message-ID: <20070425040409.GA4807@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1842 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161578AbXDYEER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 00:04:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[IPV4]: Consolidate common SNMP code

This patch moves the SNMP code shared between IPv4/IPv6 from proc.c
into net/ipv4/af_inet.c.  This makes sense because these functions
aren't specific to /proc.

As a result we can again skip proc.o if /proc is disabled.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/ip.h b/include/net/ip.h
index f41ce07..bb207db 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -166,6 +166,7 @@ DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_ADD_STATS_BH(field, adnd)	SNMP_ADD_STATS_BH(net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(field, adnd)	SNMP_ADD_STATS_USER(net_statistics, field, adnd)
 
+extern unsigned long snmp_fold_field(void *mib[], int offt);
 extern int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
 extern void snmp_mib_free(void *ptr[2]);
 
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 3bd25f5..4ff6c15 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -10,11 +10,11 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_minisocks.o tcp_cong.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
-	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o \
-	     proc.o
+	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
 
 obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
 obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
+obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index a33ca7e..16aae8e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1219,6 +1219,46 @@ out:
 	return segs;
 }
 
+unsigned long snmp_fold_field(void *mib[], int offt)
+{
+	unsigned long res = 0;
+	int i;
+
+	for_each_possible_cpu(i) {
+		res += *(((unsigned long *) per_cpu_ptr(mib[0], i)) + offt);
+		res += *(((unsigned long *) per_cpu_ptr(mib[1], i)) + offt);
+	}
+	return res;
+}
+EXPORT_SYMBOL_GPL(snmp_fold_field);
+
+int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
+{
+	BUG_ON(ptr == NULL);
+	ptr[0] = __alloc_percpu(mibsize);
+	if (!ptr[0])
+		goto err0;
+	ptr[1] = __alloc_percpu(mibsize);
+	if (!ptr[1])
+		goto err1;
+	return 0;
+err1:
+	free_percpu(ptr[0]);
+	ptr[0] = NULL;
+err0:
+	return -ENOMEM;
+}
+EXPORT_SYMBOL_GPL(snmp_mib_init);
+
+void snmp_mib_free(void *ptr[2])
+{
+	BUG_ON(ptr == NULL);
+	free_percpu(ptr[0]);
+	free_percpu(ptr[1]);
+	ptr[0] = ptr[1] = NULL;
+}
+EXPORT_SYMBOL_GPL(snmp_mib_free);
+
 #ifdef CONFIG_IP_MULTICAST
 static struct net_protocol igmp_protocol = {
 	.handler =	igmp_rcv,
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index a236154..37ab580 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -45,7 +45,6 @@
 #include <net/sock.h>
 #include <net/raw.h>
 
-#ifdef CONFIG_PROC_FS
 static int fold_prot_inuse(struct proto *proto)
 {
 	int res = 0;
@@ -88,19 +87,6 @@ static const struct file_operations sockstat_seq_fops = {
 	.release = single_release,
 };
 
-static unsigned long
-fold_field(void *mib[], int offt)
-{
-	unsigned long res = 0;
-	int i;
-
-	for_each_possible_cpu(i) {
-		res += *(((unsigned long *) per_cpu_ptr(mib[0], i)) + offt);
-		res += *(((unsigned long *) per_cpu_ptr(mib[1], i)) + offt);
-	}
-	return res;
-}
-
 /* snmp items */
 static const struct snmp_mib snmp4_ipstats_list[] = {
 	SNMP_MIB_ITEM("InReceives", IPSTATS_MIB_INRECEIVES),
@@ -267,8 +253,8 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   fold_field((void **) ip_statistics,
-				      snmp4_ipstats_list[i].entry));
+			   snmp_fold_field((void **)ip_statistics,
+					   snmp4_ipstats_list[i].entry));
 
 	seq_puts(seq, "\nIcmp:");
 	for (i = 0; snmp4_icmp_list[i].name != NULL; i++)
@@ -277,8 +263,8 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nIcmp:");
 	for (i = 0; snmp4_icmp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   fold_field((void **) icmp_statistics,
-				      snmp4_icmp_list[i].entry));
+			   snmp_fold_field((void **)icmp_statistics,
+					   snmp4_icmp_list[i].entry));
 
 	seq_puts(seq, "\nTcp:");
 	for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
@@ -289,12 +275,12 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
 			seq_printf(seq, " %ld",
-				   fold_field((void **) tcp_statistics,
-					      snmp4_tcp_list[i].entry));
+				   snmp_fold_field((void **)tcp_statistics,
+						   snmp4_tcp_list[i].entry));
 		else
 			seq_printf(seq, " %lu",
-				   fold_field((void **) tcp_statistics,
-					      snmp4_tcp_list[i].entry));
+				   snmp_fold_field((void **)tcp_statistics,
+						   snmp4_tcp_list[i].entry));
 	}
 
 	seq_puts(seq, "\nUdp:");
@@ -304,8 +290,8 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdp:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   fold_field((void **) udp_statistics,
-				      snmp4_udp_list[i].entry));
+			   snmp_fold_field((void **)udp_statistics,
+					   snmp4_udp_list[i].entry));
 
 	/* the UDP and UDP-Lite MIBs are the same */
 	seq_puts(seq, "\nUdpLite:");
@@ -315,8 +301,8 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdpLite:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   fold_field((void **) udplite_statistics,
-				      snmp4_udp_list[i].entry)     );
+			   snmp_fold_field((void **)udplite_statistics,
+					   snmp4_udp_list[i].entry));
 
 	seq_putc(seq, '\n');
 	return 0;
@@ -349,8 +335,8 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nTcpExt:");
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   fold_field((void **) net_statistics,
-				      snmp4_net_list[i].entry));
+			   snmp_fold_field((void **)net_statistics,
+					   snmp4_net_list[i].entry));
 
 	seq_putc(seq, '\n');
 	return 0;
@@ -391,30 +377,4 @@ out_netstat:
 	rc = -ENOMEM;
 	goto out;
 }
-#endif
-
-int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
-{
-	BUG_ON(ptr == NULL);
-	ptr[0] = __alloc_percpu(mibsize);
-	if (!ptr[0])
-		goto err0;
-	ptr[1] = __alloc_percpu(mibsize);
-	if (!ptr[1])
-		goto err1;
-	return 0;
-err1:
-	free_percpu(ptr[0]);
-	ptr[0] = NULL;
-err0:
-	return -ENOMEM;
-}
-
-void snmp_mib_free(void *ptr[2])
-{
-	BUG_ON(ptr == NULL);
-	free_percpu(ptr[0]);
-	free_percpu(ptr[1]);
-	ptr[0] = ptr[1] = NULL;
-}
 
