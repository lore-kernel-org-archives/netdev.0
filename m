From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/2] [IPV6]: Consolidate common SNMP code
Date: Wed, 25 Apr 2007 14:06:37 +1000
Message-ID: <20070425040637.GA4838@gondor.apana.org.au>
References: <20070425040409.GA4807@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1860 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161591AbXDYEGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 00:06:43 -0400
Content-Disposition: inline
In-Reply-To: <20070425040409.GA4807@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[IPV6]: Consolidate common SNMP code

This patch moves the non-proc SNMP code into addrconf.c and reuses
IPv4 SNMP code where applicable.

As a result we can skip proc.o if /proc is disabled.

Note that I've made a number of functions static since they're only
used by addrconf.c for now.  If they ever get used elsewhere we can
always remove the static.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4408def..f70afef 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -166,14 +166,6 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
 	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
 
-int snmp6_register_dev(struct inet6_dev *idev);
-int snmp6_unregister_dev(struct inet6_dev *idev);
-int snmp6_alloc_dev(struct inet6_dev *idev);
-int snmp6_free_dev(struct inet6_dev *idev);
-int snmp6_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
-void snmp6_mib_free(void *ptr[2]);
-void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype, int bytes);
-
 struct ip6_ra_chain
 {
 	struct ip6_ra_chain	*next;
@@ -606,8 +598,20 @@ extern int  udplite6_proc_init(void);
 extern void udplite6_proc_exit(void);
 extern int  ipv6_misc_proc_init(void);
 extern void ipv6_misc_proc_exit(void);
+extern int snmp6_register_dev(struct inet6_dev *idev);
+extern int snmp6_unregister_dev(struct inet6_dev *idev);
 
 extern struct rt6_statistics rt6_stats;
+#else
+static inline int snmp6_register_dev(struct inet6_dev *idev)
+{
+	return 0;
+}
+
+static inline int snmp6_unregister_dev(struct inet6_dev *idev)
+{
+	return 0;
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index e947868..0acf64d 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_IPV6) += ipv6.o
 ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
-		exthdrs.o sysctl_net_ipv6.o datagram.o proc.o \
+		exthdrs.o sysctl_net_ipv6.o datagram.o \
 		ip6_flowlabel.o inet6_connection_sock.o
 
 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
@@ -28,6 +28,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
 obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
+obj-$(CONFIG_PROC_FS) += proc.o
 
 obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6a702ff..eea7ef4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -81,6 +81,7 @@
 #endif
 
 #include <asm/uaccess.h>
+#include <asm/unaligned.h>
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -246,6 +247,37 @@ static void addrconf_mod_timer(struct inet6_ifaddr *ifp,
 	add_timer(&ifp->timer);
 }
 
+static int snmp6_alloc_dev(struct inet6_dev *idev)
+{
+	int err = -ENOMEM;
+
+	if (!idev || !idev->dev)
+		return -EINVAL;
+
+	if (snmp_mib_init((void **)idev->stats.ipv6,
+			  sizeof(struct ipstats_mib),
+			  __alignof__(struct ipstats_mib)) < 0)
+		goto err_ip;
+	if (snmp_mib_init((void **)idev->stats.icmpv6,
+			  sizeof(struct icmpv6_mib),
+			  __alignof__(struct icmpv6_mib)) < 0)
+		goto err_icmp;
+
+	return 0;
+
+err_icmp:
+	snmp_mib_free((void **)idev->stats.ipv6);
+err_ip:
+	return err;
+}
+
+static int snmp6_free_dev(struct inet6_dev *idev)
+{
+	snmp_mib_free((void **)idev->stats.icmpv6);
+	snmp_mib_free((void **)idev->stats.ipv6);
+	return 0;
+}
+
 /* Nobody refers to this device, we may destroy it. */
 
 static void in6_dev_finish_destroy_rcu(struct rcu_head *head)
@@ -3438,6 +3470,34 @@ static inline size_t inet6_if_nlmsg_size(void)
 		 );
 }
 
+static inline void __snmp6_fill_stats(u64 *stats, void **mib, int items,
+				      int bytes)
+{
+	int i;
+	int pad = bytes - sizeof(u64) * items;
+	BUG_ON(pad < 0);
+
+	/* Use put_unaligned() because stats may not be aligned for u64. */
+	put_unaligned(items, &stats[0]);
+	for (i = 1; i < items; i++)
+		put_unaligned(snmp_fold_field(mib, i), &stats[i]);
+
+	memset(&stats[items], 0, pad);
+}
+
+static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
+			     int bytes)
+{
+	switch(attrtype) {
+	case IFLA_INET6_STATS:
+		__snmp6_fill_stats(stats, (void **)idev->stats.ipv6, IPSTATS_MIB_MAX, bytes);
+		break;
+	case IFLA_INET6_ICMP6STATS:
+		__snmp6_fill_stats(stats, (void **)idev->stats.icmpv6, ICMP6_MIB_MAX, bytes);
+		break;
+	}
+}
+
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 825d03e..18cb928 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -714,26 +714,26 @@ EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
 static int __init init_ipv6_mibs(void)
 {
-	if (snmp6_mib_init((void **)ipv6_statistics, sizeof (struct ipstats_mib),
-			   __alignof__(struct ipstats_mib)) < 0)
+	if (snmp_mib_init((void **)ipv6_statistics, sizeof (struct ipstats_mib),
+			  __alignof__(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
-	if (snmp6_mib_init((void **)icmpv6_statistics, sizeof (struct icmpv6_mib),
-			   __alignof__(struct icmpv6_mib)) < 0)
+	if (snmp_mib_init((void **)icmpv6_statistics, sizeof (struct icmpv6_mib),
+			  __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp_mib;
-	if (snmp6_mib_init((void **)udp_stats_in6, sizeof (struct udp_mib),
-			   __alignof__(struct udp_mib)) < 0)
+	if (snmp_mib_init((void **)udp_stats_in6, sizeof (struct udp_mib),
+			  __alignof__(struct udp_mib)) < 0)
 		goto err_udp_mib;
-	if (snmp6_mib_init((void **)udplite_stats_in6, sizeof (struct udp_mib),
-			   __alignof__(struct udp_mib)) < 0)
+	if (snmp_mib_init((void **)udplite_stats_in6, sizeof (struct udp_mib),
+			  __alignof__(struct udp_mib)) < 0)
 		goto err_udplite_mib;
 	return 0;
 
 err_udplite_mib:
-	snmp6_mib_free((void **)udp_stats_in6);
+	snmp_mib_free((void **)udp_stats_in6);
 err_udp_mib:
-	snmp6_mib_free((void **)icmpv6_statistics);
+	snmp_mib_free((void **)icmpv6_statistics);
 err_icmp_mib:
-	snmp6_mib_free((void **)ipv6_statistics);
+	snmp_mib_free((void **)ipv6_statistics);
 err_ip_mib:
 	return -ENOMEM;
 
@@ -741,10 +741,10 @@ err_ip_mib:
 
 static void cleanup_ipv6_mibs(void)
 {
-	snmp6_mib_free((void **)ipv6_statistics);
-	snmp6_mib_free((void **)icmpv6_statistics);
-	snmp6_mib_free((void **)udp_stats_in6);
-	snmp6_mib_free((void **)udplite_stats_in6);
+	snmp_mib_free((void **)ipv6_statistics);
+	snmp_mib_free((void **)icmpv6_statistics);
+	snmp_mib_free((void **)udp_stats_in6);
+	snmp_mib_free((void **)udplite_stats_in6);
 }
 
 static int __init inet6_init(void)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 7a00bed..acb306a 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -23,13 +23,12 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/stddef.h>
-#include <asm/unaligned.h>
+#include <net/ip.h>
 #include <net/sock.h>
 #include <net/tcp.h>
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
 
-#ifdef CONFIG_PROC_FS
 static struct proc_dir_entry *proc_net_devsnmp6;
 
 static int fold_prot_inuse(struct proto *proto)
@@ -142,29 +141,14 @@ static struct snmp_mib snmp6_udplite6_list[] = {
 	SNMP_MIB_ITEM("UdpLite6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_SENTINEL
 };
-#endif	/* CONFIG_PROC_FS */
 
-static unsigned long
-fold_field(void *mib[], int offt)
-{
-	unsigned long res = 0;
-	int i;
-
-	for_each_possible_cpu(i) {
-		res += *(((unsigned long *)per_cpu_ptr(mib[0], i)) + offt);
-		res += *(((unsigned long *)per_cpu_ptr(mib[1], i)) + offt);
-	}
-	return res;
-}
-
-#ifdef CONFIG_PROC_FS
 static inline void
 snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp_mib *itemlist)
 {
 	int i;
 	for (i=0; itemlist[i].name; i++)
 		seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name,
-				fold_field(mib, itemlist[i].entry));
+			   snmp_fold_field(mib, itemlist[i].entry));
 }
 
 static int snmp6_seq_show(struct seq_file *seq, void *v)
@@ -209,37 +193,7 @@ static const struct file_operations snmp6_seq_fops = {
 	.llseek	 = seq_lseek,
 	.release = single_release,
 };
-#endif	/* CONFIG_PROC_FS */
 
-static inline void
-__snmp6_fill_stats(u64 *stats, void **mib, int items, int bytes)
-{
-	int i;
-	int pad = bytes - sizeof(u64) * items;
-	BUG_ON(pad < 0);
-
-	/* Use put_unaligned() because stats may not be aligned for u64. */
-	put_unaligned(items, &stats[0]);
-	for (i = 1; i < items; i++)
-		put_unaligned(fold_field(mib, i), &stats[i]);
-
-	memset(&stats[items], 0, pad);
-}
-
-void
-snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype, int bytes)
-{
-	switch(attrtype) {
-	case IFLA_INET6_STATS:
-		__snmp6_fill_stats(stats, (void **)idev->stats.ipv6, IPSTATS_MIB_MAX, bytes);
-		break;
-	case IFLA_INET6_ICMP6STATS:
-		__snmp6_fill_stats(stats, (void **)idev->stats.icmpv6, ICMP6_MIB_MAX, bytes);
-		break;
-	}
-}
-
-#ifdef CONFIG_PROC_FS
 int snmp6_register_dev(struct inet6_dev *idev)
 {
 	struct proc_dir_entry *p;
@@ -304,78 +258,3 @@ void ipv6_misc_proc_exit(void)
 	proc_net_remove("snmp6");
 }
 
-#else	/* CONFIG_PROC_FS */
-
-
-int snmp6_register_dev(struct inet6_dev *idev)
-{
-	return 0;
-}
-
-int snmp6_unregister_dev(struct inet6_dev *idev)
-{
-	return 0;
-}
-
-#endif	/* CONFIG_PROC_FS */
-
-int snmp6_alloc_dev(struct inet6_dev *idev)
-{
-	int err = -ENOMEM;
-
-	if (!idev || !idev->dev)
-		return -EINVAL;
-
-	if (snmp6_mib_init((void **)idev->stats.ipv6, sizeof(struct ipstats_mib),
-			   __alignof__(struct ipstats_mib)) < 0)
-		goto err_ip;
-	if (snmp6_mib_init((void **)idev->stats.icmpv6, sizeof(struct icmpv6_mib),
-			   __alignof__(struct icmpv6_mib)) < 0)
-		goto err_icmp;
-
-	return 0;
-
-err_icmp:
-	snmp6_mib_free((void **)idev->stats.ipv6);
-err_ip:
-	return err;
-}
-
-int snmp6_free_dev(struct inet6_dev *idev)
-{
-	snmp6_mib_free((void **)idev->stats.icmpv6);
-	snmp6_mib_free((void **)idev->stats.ipv6);
-	return 0;
-}
-
-int snmp6_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
-{
-	if (ptr == NULL)
-		return -EINVAL;
-
-	ptr[0] = __alloc_percpu(mibsize);
-	if (!ptr[0])
-		goto err0;
-
-	ptr[1] = __alloc_percpu(mibsize);
-	if (!ptr[1])
-		goto err1;
-
-	return 0;
-
-err1:
-	free_percpu(ptr[0]);
-	ptr[0] = NULL;
-err0:
-	return -ENOMEM;
-}
-
-void snmp6_mib_free(void *ptr[2])
-{
-	if (ptr == NULL)
-		return;
-	free_percpu(ptr[0]);
-	free_percpu(ptr[1]);
-	ptr[0] = ptr[1] = NULL;
-}
-
