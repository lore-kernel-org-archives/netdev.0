From: Shaohua Li <shli@fb.com>
Subject: net_test_tools: add ipv6 support for kbench_mod
Date: Tue, 13 Jan 2015 21:45:48 -0800
Message-ID: <20150114054548.GA2683397@devbig257.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <kafai@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:29438 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041AbbANFp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 00:45:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds ipv6 support for kbench_mod test module

diff --git a/kbench_mod.c b/kbench_mod.c
index fc3765c..05425df 100644
--- a/kbench_mod.c
+++ b/kbench_mod.c
@@ -3,9 +3,11 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/inet.h>
+#include <linux/in6.h>
 
 #include <net/route.h>
 #include <net/ip_fib.h>
+#include <net/ip6_route.h>
 
 #include <linux/timex.h>
 
@@ -66,9 +68,13 @@ extern int ip_route_output_cycles_7;
 static int flow_oif = DEFAULT_OIF;
 static int flow_iif = DEFAULT_IIF;
 static u32 flow_mark = DEFAULT_MARK;
-static u32 flow_dst_ip_addr = DEFAULT_DST_IP_ADDR;
-static u32 flow_src_ip_addr = DEFAULT_SRC_IP_ADDR;
+static u32 ip4_flow_dst_ip_addr = DEFAULT_DST_IP_ADDR;
+static u32 ip4_flow_src_ip_addr = DEFAULT_SRC_IP_ADDR;
+static struct in6_addr ip6_flow_dst_ip_addr;
+static struct in6_addr ip6_flow_src_ip_addr;
 static int flow_tos = DEFAULT_TOS;
+static int ip6_bench;
+module_param(ip6_bench, int, 0);
 
 static char dst_string[64];
 static char src_string[64];
@@ -76,12 +82,29 @@ static char src_string[64];
 module_param_string(dst, dst_string, sizeof(dst_string), 0);
 module_param_string(src, src_string, sizeof(src_string), 0);
 
-static void __init flow_setup(void)
+static int __init flow_setup(void)
 {
+	if (ip6_bench) {
+		if (dst_string[0] &&
+		    !in6_pton(dst_string, -1, ip6_flow_dst_ip_addr.s6_addr, -1, NULL)) {
+			pr_info("cannot parse \"%s\"\n", dst_string);
+			return -1;
+		}
+
+		if (src_string[0] &&
+		    !in6_pton(src_string, -1, ip6_flow_src_ip_addr.s6_addr, -1, NULL)) {
+			pr_info("cannot parse \"%s\"\n", src_string);
+			return -1;
+		}
+
+		return 0;
+	}
+
 	if (dst_string[0])
-		flow_dst_ip_addr = in_aton(dst_string);
+		ip4_flow_dst_ip_addr = in_aton(dst_string);
 	if (src_string[0])
-		flow_src_ip_addr = in_aton(src_string);
+		ip4_flow_src_ip_addr = in_aton(src_string);
+	return 0;
 }
 
 module_param_named(oif, flow_oif, int, 0);
@@ -92,15 +115,70 @@ module_param_named(tos, flow_tos, int, 0);
 static int warmup_count = DEFAULT_WARMUP_COUNT;
 module_param_named(count, warmup_count, int, 0);
 
-static void flow_init(struct flowi4 *fl4)
+#define flow_init(fl, gen) 				\
+do {							\
+	memset((fl), 0, sizeof(*(fl)));			\
+	(fl)->flowi##gen##_oif = flow_oif;		\
+	(fl)->flowi##gen##_iif = flow_iif;		\
+	(fl)->flowi##gen##_mark = flow_mark;		\
+	(fl)->flowi##gen##_tos = flow_tos;		\
+	(fl)->daddr = ip##gen##_flow_dst_ip_addr;	\
+	(fl)->saddr = ip##gen##_flow_src_ip_addr;	\
+} while (0)
+
+#define flow_init_ip6(fl) 				\
+do {							\
+	flow_init(fl, 6);				\
+	(fl)->flowi6_proto = IPPROTO_ICMPV6;		\
+} while(0)
+
+static int skb_init_ip6(struct sk_buff *skb)
+{
+	struct ipv6hdr *hdr;
+	struct net_device *dev;
+
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
+	hdr = ipv6_hdr(skb);
+
+	hdr->priority = 0;
+	hdr->version = 6;
+	memset(hdr->flow_lbl, 0, sizeof(hdr->flow_lbl));
+	hdr->payload_len = htons(sizeof(struct icmp6hdr));
+	hdr->nexthdr = IPPROTO_ICMPV6;
+	hdr->saddr = ip6_flow_src_ip_addr;
+	hdr->daddr = ip6_flow_dst_ip_addr;
+
+	dev = __dev_get_by_index(&init_net, flow_iif);
+	if (dev == NULL) {
+		pr_info("Input device does not exist\n");
+		return -ENODEV;
+	}
+	skb->protocol = htons(ETH_P_IPV6);
+	skb->dev = dev;
+	skb->mark = flow_mark;
+	return 0;
+}
+
+static int skb_init_ip4(struct sk_buff *skb)
 {
-	memset(fl4, 0, sizeof(*fl4));
-	fl4->flowi4_oif = flow_oif;
-	fl4->flowi4_iif = flow_iif;
-	fl4->flowi4_mark = flow_mark;
-	fl4->flowi4_tos = flow_tos;
-	fl4->daddr = flow_dst_ip_addr;
-	fl4->saddr = flow_src_ip_addr;
+	struct net_device *dev;
+
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	ip_hdr(skb)->protocol = IPPROTO_ICMP;
+	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
+
+	dev = __dev_get_by_index(&init_net, flow_iif);
+	if (dev == NULL) {
+		pr_info("Input device does not exist\n");
+		return -ENODEV;
+	}
+	skb->protocol = htons(ETH_P_IP);
+	skb->dev = dev;
+	skb->mark = flow_mark;
+	return 0;
 }
 
 static struct rtable *route_output(struct net *net, struct flowi4 *fl4)
@@ -108,7 +186,7 @@ static struct rtable *route_output(struct net *net, struct flowi4 *fl4)
 	return ip_route_output_key(net, fl4);
 }
 
-static void do_full_output_lookup_bench(void)
+static void do_full_output_lookup_bench_ip4(void)
 {
 	unsigned long long t1, t2, tdiff;
 	struct rtable *rt;
@@ -118,7 +196,7 @@ static void do_full_output_lookup_bench(void)
 	rt = NULL;
 
 	for (i = 0; i < warmup_count; i++) {
-		flow_init(&fl4);
+		flow_init(&fl4, 4);
 
 		rt = route_output(&init_net, &fl4);
 		if (IS_ERR(rt))
@@ -140,7 +218,7 @@ static void do_full_output_lookup_bench(void)
 	ip_route_output_cycles_7 = 0;
 #endif
 
-	flow_init(&fl4);
+	flow_init(&fl4, 4);
 
 	t1 = get_tick();
 	rt = route_output(&init_net, &fl4);
@@ -161,11 +239,45 @@ static void do_full_output_lookup_bench(void)
 #endif
 }
 
+static void do_full_output_lookup_bench_ip6(void)
+{
+	unsigned long long t1, t2, tdiff;
+	struct rt6_info *rt;
+	struct flowi6 fl6;
+	int i;
+
+	rt = NULL;
+
+	for (i = 0; i < warmup_count; i++) {
+		flow_init_ip6(&fl6);
+
+		rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl6);
+		if (IS_ERR(rt))
+			break;
+		ip6_rt_put(rt);
+	}
+	if (IS_ERR(rt)) {
+		pr_info("ip6_route_output: err=%ld\n", PTR_ERR(rt));
+		return;
+	}
+
+	flow_init_ip6(&fl6);
+
+	t1 = get_tick();
+	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl6);
+	t2 = get_tick();
+	if (!IS_ERR(rt))
+		ip6_rt_put(rt);
+
+	tdiff = t2 - t1;
+	pr_info("ip6_route_output tdiff: %llu\n", tdiff);
+}
+
 static void do_full_input_lookup_bench(void)
 {
 	unsigned long long t1, t2, tdiff;
-	struct net_device *dev;
 	struct sk_buff *skb;
+	struct rt6_info *rt;
 	int err, i;
 
 	skb = alloc_skb(4096, GFP_KERNEL);
@@ -173,23 +285,22 @@ static void do_full_input_lookup_bench(void)
 		pr_info("Cannot alloc SKB for test\n");
 		return;
 	}
-	skb_reset_mac_header(skb);
-	skb_reset_network_header(skb);
-	ip_hdr(skb)->protocol = IPPROTO_ICMP;
-	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
-
-	dev = __dev_get_by_index(&init_net, flow_iif);
-	if (dev == NULL) {
-		pr_info("Input device does not exist\n");
+	if (ip6_bench)
+		err = skb_init_ip6(skb);
+	else
+		err = skb_init_ip4(skb);
+	if (err)
 		goto out_free;
-	}
-	skb->protocol = htons(ETH_P_IP);
-	skb->dev = dev;
-	skb->mark = flow_mark;
+
 	local_bh_disable();
 	err = 0;
 	for (i = 0; i < warmup_count; i++) {
-		err = ip_route_input(skb, flow_dst_ip_addr, flow_src_ip_addr, flow_tos, dev);
+		if (ip6_bench) {
+			ip6_route_input(skb);
+			rt = (struct rt6_info *)skb_dst(skb);
+			err = (!rt || rt == init_net.ipv6.ip6_null_entry);
+		} else
+			err = ip_route_input(skb, ip4_flow_dst_ip_addr, ip4_flow_src_ip_addr, flow_tos, skb->dev);
 		if (err)
 			break;
 		skb_dst_drop(skb);
@@ -203,7 +314,12 @@ static void do_full_input_lookup_bench(void)
 
 	local_bh_disable();
 	t1 = get_tick();
-	err = ip_route_input(skb, flow_dst_ip_addr, flow_src_ip_addr, flow_tos, dev);
+	if (ip6_bench) {
+		ip6_route_input(skb);
+		rt = (struct rt6_info *)skb_dst(skb);
+		err = (!rt || rt == init_net.ipv6.ip6_null_entry);
+	} else
+		err = ip_route_input(skb, ip4_flow_dst_ip_addr, ip4_flow_src_ip_addr, flow_tos, skb->dev);
 	t2 = get_tick();
 	local_bh_enable();
 
@@ -215,7 +331,10 @@ static void do_full_input_lookup_bench(void)
 	skb_dst_drop(skb);
 
 	tdiff = t2 - t1;
-	pr_info("ip_route_input tdiff: %llu\n", tdiff);
+	if (ip6_bench)
+		pr_info("ip6_route_input tdiff: %llu\n", tdiff);
+	else
+		pr_info("ip_route_input tdiff: %llu\n", tdiff);
 
 out_free:
 	kfree_skb(skb);
@@ -223,9 +342,12 @@ static void do_full_input_lookup_bench(void)
 
 static void do_full_lookup_bench(void)
 {
-	if (!flow_iif)
-		do_full_output_lookup_bench();
-	else
+	if (!flow_iif) {
+		if (ip6_bench)
+			do_full_output_lookup_bench_ip6();
+		else
+			do_full_output_lookup_bench_ip4();
+	} else
 		do_full_input_lookup_bench();
 }
 
@@ -240,7 +362,7 @@ static void do_full_lookup_prealloc_bench(void)
 	err = 0;
 
 	for (i = 0; i < warmup_count; i++) {
-		flow_init(&fl4);
+		flow_init(&fl4, 4);
 
 		rt = ip_route_output_flow_prealloc(&init_net, &fl4, NULL, &rt_stack.dst);
 		if (IS_ERR(rt)) {
@@ -264,7 +386,7 @@ static void do_full_lookup_prealloc_bench(void)
 	ip_route_output_cycles_7 = 0;
 #endif
 
-	flow_init(&fl4);
+	flow_init(&fl4, 4);
 
 	t1 = get_tick();
 	rt = ip_route_output_flow_prealloc(&init_net, &fl4, NULL, &rt_stack.dst);
@@ -295,7 +417,7 @@ static void do_fib_lookup_bench(void)
 	struct flowi4 fl4;
 	int err, i;
 
-	flow_init(&fl4);
+	flow_init(&fl4, 4);
 
 	for (i = 0; i < warmup_count; i++) {
 		struct fib_table *table;
@@ -398,7 +520,7 @@ static void do_new_lookup_bench(void)
 	struct flowi fl;
 	int err, i;
 
-	flow_init(&fl);
+	flow_init(&fl, 4);
 
 	for (i = 0; i < warmup_count; i++) {
 		err = new_output_lookup(&fl, &rt);
@@ -428,6 +550,8 @@ static void do_bench(void)
 	do_full_lookup_bench();
 	do_full_lookup_bench();
 
+	if (ip6_bench)
+		return;
 #ifdef IP_ROUTE_HAVE_PREALLOC
 	do_full_lookup_prealloc_bench();
 	do_full_lookup_prealloc_bench();
@@ -452,10 +576,19 @@ static int __init kbench_init(void)
 {
 	flow_setup();
 
-	pr_info("flow [IIF(%d),OIF(%d),MARK(0x%08x),D(%pI4),S(%pI4),TOS(0x%02x)]\n",
-		flow_iif, flow_oif, flow_mark,
-		&flow_dst_ip_addr,
-		&flow_src_ip_addr, flow_tos);
+	if (!ip6_bench) {
+		pr_info("flow [IIF(%d),OIF(%d),MARK(0x%08x),D(%pI4),S(%pI4),TOS(0x%02x)]\n",
+			flow_iif, flow_oif, flow_mark,
+			&ip4_flow_dst_ip_addr,
+			&ip4_flow_src_ip_addr, flow_tos);
+	} else {
+		pr_info("flow [IIF(%d),OIF(%d),MARK(0x%08x),D(%pI6),"
+			"S(%pI6),TOS(0x%02x)]\n",
+			flow_iif, flow_oif, flow_mark,
+			&ip6_flow_dst_ip_addr,
+			&ip6_flow_src_ip_addr,
+			flow_tos);
+	}
 
 #if defined(CONFIG_X86)
 	if (!cpu_has_tsc) {
