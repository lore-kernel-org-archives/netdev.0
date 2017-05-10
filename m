From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ipv6: Implement limits on hop by hop and destination options
Date: Wed, 10 May 2017 14:33:19 -0700
Message-ID: <1494451999-19031-1-git-send-email-tom@herbertland.com>
Cc: kafai@fb.com, Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34289 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751069AbdEJVe0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 17:34:26 -0400
Received: by mail-pf0-f195.google.com with SMTP id w69so835528pfk.1
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 14:34:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 2460 (IPv6) defines hop by hop options and destination options
extension headers. Both of these carry a list of TLVs which is
only limited by the maximum length of the extension header (2048
bytes). By the spec a host must process all the TLVs in these
options, however these could be used as a fairly obvious
denial of service attack. I think this could in fact be
a significant DOS vector on the Internet, one mitigating
factor might be that many FWs drop all packets with EH (and
obviously this is only IPv6) so an Internet wide attack might not
be so effective (yet!).

By my calculation, the worse case packet with TLVs in a standard
1500 byte MTU packet that would be processed by the stack contains
1282 invidual TLVs (including pad TLVS) or 724 two byte TLVs. I
wrote a quick test program that floods a whole bunch of these
packets to a host and sure enough there is substantial time spent
in ip6_parse_tlv. These packets contain nothing but unknown TLVS
(that are ignored), TLV padding, and bogus UDP header with zero
payload length.

  25.38%  [kernel]                    [k] __fib6_clean_all
  21.63%  [kernel]                    [k] ip6_parse_tlv
   4.21%  [kernel]                    [k] __local_bh_enable_ip
   2.18%  [kernel]                    [k] ip6_pol_route.isra.39
   1.98%  [kernel]                    [k] fib6_walk_continue
   1.88%  [kernel]                    [k] _raw_write_lock_bh
   1.65%  [kernel]                    [k] dst_release

This patches adds configurable limits to destination and hop by hop
options. There are three limits that may be set:
  - Limit the number of non-padding TLVs that may be in an extension header
  - Limit the length of a hop by hop or destination options extension header
  - Disallow unknown options

The limits are set in corresponding sysctls:

  ipv6.sysctl.max_dst_opts_cnt
  ipv6.sysctl.max_hbh_opts_cnt
  ipv6.sysctl.max_dst_opts_len
  ipv6.sysctl.max_hbh_opts_len

If a max_*_opts_cnt is less than zero then unknown TLVs are disallowed.
The number of known TLVs that are allowed is the absolute value of
this number.

If a limit is exceeded when processing an extension header the packet is
dropped.

Default values are set to 8 for options counts, and set to INT_MAX
for maximum length. Note the choice to limit options to 8 is an
arbitrary guess (roughly based on the fact that the stack supports
three HBH options and just one destination option).

Tested: I've only complied this code, working on getting a test
environment set up which is why RFC. If anyone has resources and time
to do some testing or development, let me know!

Tested:

Martin Lau was kind enough to test this on real HW. He verified
that processing IPv6 TLVs CPU intensive and could very well be a
DDOS, and he verified that the patch drops packets that exceed the
limits to avoid the issue:

I tested out 1 thread (i.e. one raw_udp process).

I changed the net.ipv6.max_dst_(opts|hbh)_number between 8 to 2048.
With sysctls setting to 2048, the softirq% is packed to 100%.
With 8, the softirq% is almost unnoticable from mpstat.
---
 Documentation/networking/ip-sysctl.txt | 22 +++++++++++++++++
 include/net/ipv6.h                     | 33 +++++++++++++++++++++++++
 include/net/netns/ipv6.h               |  4 ++++
 net/ipv6/af_inet6.c                    |  4 ++++
 net/ipv6/exthdrs.c                     | 44 ++++++++++++++++++++++++++++++----
 net/ipv6/sysctl_net_ipv6.c             | 32 +++++++++++++++++++++++++
 6 files changed, 134 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 974ab47..476a5c5 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1379,6 +1379,28 @@ mld_qrv - INTEGER
 	Default: 2 (as specified by RFC3810 9.1)
 	Minimum: 1 (as specified by RFC6636 4.5)
 
+max_dst_opts_cnt - INTEGER
+	Maximum number of non-padding TLVs allowed in a destination
+	options extension header. If this value is less than zero
+	then unknown options are disallowed and the number of known
+	TLVs allowed are the absolute value of this numer.
+
+	Default: 8
+
+max_hbh_opts_cnt - INTEGER
+	Maximum number of non-padding TLVs allowed in a hop by hop
+	options extension header. If this value is less than zero
+	then unknown options are disallowed and the number of known
+	TLVs allowed are the absolute value of this number.
+
+max dst_opts_len - INTEGER
+	Maximum length allowed for a destination options extension
+	header.
+
+max hbh_opts_len - INTEGER
+	Maximum length allowed for a hop by hop options extension
+	header.
+
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index dbf0abb..9f724ae 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -50,6 +50,39 @@
 #define IPV6_DEFAULT_HOPLIMIT   64
 #define IPV6_DEFAULT_MCASTHOPS	1
 
+/* Limits on hop by hop and destination options.
+ *
+ * Per RFC2640 there is no limit on the maximum number or lengths of TLVs in
+ * hop by hop or destination options other then the packet must fit in an MTU.
+ * We allow configurable limits in order to mitigate potential denial of
+ * service attacks.
+ *
+ * There are three limits that may be set:
+ *   - Limit the number of non-padding TLVs that may be in an extension header
+ *   - Limit the length of a hop by hop or destination options extension header
+ *   - Disallow unknown options
+ *
+ * The limits are set in corresponding sysctls:
+ *
+ * ipv6.sysctl.max_dst_opts_cnt
+ * ipv6.sysctl.max_hbh_opts_cnt
+ * ipv6.sysctl.max_dst_opts_len
+ * ipv6.sysctl.max_hbh_opts_len
+ *
+ * If a max_*_opts_cnt is less than zero then unknown TLVs are disallowed.
+ * The number of known TLVs that are allowed is the absolute value of
+ * this number.
+ *
+ * If a limit is exceeded when processing an extension header the packet is
+ * dropped.
+ */
+
+/* Default limits for hop by hop and destination options */
+#define IP6_DEFAULT_MAX_DST_OPTS_CNT	8
+#define IP6_DEFAULT_MAX_HBH_OPTS_CNT	8
+#define IP6_DEFAULT_MAX_DST_OPTS_LEN	INT_MAX /* No limit */
+#define IP6_DEFAULT_MAX_HBH_OPTS_LEN	INT_MAX /* No limit */
+
 /*
  *	Addr type
  *	
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index de7745e..655bd236 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -36,6 +36,10 @@ struct netns_sysctl_ipv6 {
 	int idgen_retries;
 	int idgen_delay;
 	int flowlabel_state_ranges;
+	int max_dst_opts_cnt;
+	int max_hbh_opts_cnt;
+	int max_dst_opts_len;
+	int max_hbh_opts_len;
 };
 
 struct netns_ipv6 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a88b5b5..38e1079 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -807,6 +807,10 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.idgen_retries = 3;
 	net->ipv6.sysctl.idgen_delay = 1 * HZ;
 	net->ipv6.sysctl.flowlabel_state_ranges = 0;
+	net->ipv6.sysctl.max_dst_opts_cnt = IP6_DEFAULT_MAX_DST_OPTS_CNT;
+	net->ipv6.sysctl.max_hbh_opts_cnt = IP6_DEFAULT_MAX_HBH_OPTS_CNT;
+	net->ipv6.sysctl.max_dst_opts_len = IP6_DEFAULT_MAX_DST_OPTS_LEN;
+	net->ipv6.sysctl.max_hbh_opts_len = IP6_DEFAULT_MAX_HBH_OPTS_LEN;
 	atomic_set(&net->ipv6.fib6_sernum, 1);
 
 	err = ipv6_init_mibs(net);
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index b636f1da..9cb09e1 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -100,13 +100,22 @@ static bool ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
 
 /* Parse tlv encoded option header (hop-by-hop or destination) */
 
-static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
+static bool ip6_parse_tlv(const struct tlvtype_proc *procs,
+			  struct sk_buff *skb,
+			  int max_count)
 {
 	const struct tlvtype_proc *curr;
 	const unsigned char *nh = skb_network_header(skb);
 	int off = skb_network_header_len(skb);
 	int len = (skb_transport_header(skb)[1] + 1) << 3;
 	int padlen = 0;
+	int tlv_count = 0;
+	bool disallow_unknowns = false;
+
+	if (unlikely(max_count < 0)) {
+		disallow_unknowns = true;
+		max_count = -max_count;
+	}
 
 	if (skb_transport_offset(skb) + len > skb_headlen(skb))
 		goto bad;
@@ -148,6 +157,11 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 		default: /* Other TLV code so scan list */
 			if (optlen > len)
 				goto bad;
+
+			tlv_count++;
+			if (tlv_count > max_count)
+				goto bad;
+
 			for (curr = procs; curr->type >= 0; curr++) {
 				if (curr->type == nh[off]) {
 					/* type specific length/alignment
@@ -161,7 +175,10 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 			if (curr->type < 0) {
 				if (ip6_tlvopt_unknown(skb, off) == 0)
 					return false;
+				if (disallow_unknowns)
+					goto bad;
 			}
+
 			padlen = 0;
 			break;
 		}
@@ -260,23 +277,31 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	__u16 dstbuf;
 #endif
 	struct dst_entry *dst = skb_dst(skb);
+	struct net *net = dev_net(skb->dev);
+	int extlen;
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
+fail_and_free:
 		__IP6_INC_STATS(dev_net(dst->dev), ip6_dst_idev(dst),
 				IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
 
+	extlen = (skb_transport_header(skb)[1] + 1) << 3;
+	if (extlen > net->ipv6.sysctl.max_dst_opts_len)
+		goto fail_and_free;
+
 	opt->lastopt = opt->dst1 = skb_network_header_len(skb);
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 	dstbuf = opt->dst1;
 #endif
 
-	if (ip6_parse_tlv(tlvprocdestopt_lst, skb)) {
-		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
+	if (ip6_parse_tlv(tlvprocdestopt_lst, skb,
+			  init_net.ipv6.sysctl.max_dst_opts_cnt)) {
+		skb->transport_header += extlen;
 		opt = IP6CB(skb);
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 		opt->nhoff = dstbuf;
@@ -804,6 +829,8 @@ static const struct tlvtype_proc tlvprochopopt_lst[] = {
 int ipv6_parse_hopopts(struct sk_buff *skb)
 {
 	struct inet6_skb_parm *opt = IP6CB(skb);
+	struct net *net = dev_net(skb->dev);
+	int extlen;
 
 	/*
 	 * skb_network_header(skb) is equal to skb->data, and
@@ -818,9 +845,16 @@ int ipv6_parse_hopopts(struct sk_buff *skb)
 		return -1;
 	}
 
+	extlen = (skb_transport_header(skb)[1] + 1) << 3;
+	if (extlen > net->ipv6.sysctl.max_dst_opts_len) {
+		kfree_skb(skb);
+		return -1;
+	}
+
 	opt->flags |= IP6SKB_HOPBYHOP;
-	if (ip6_parse_tlv(tlvprochopopt_lst, skb)) {
-		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
+	if (ip6_parse_tlv(tlvprochopopt_lst, skb,
+			  init_net.ipv6.sysctl.max_hbh_opts_cnt)) {
+		skb->transport_header += extlen;
 		opt = IP6CB(skb);
 		opt->nhoff = sizeof(struct ipv6hdr);
 		return 1;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 69c50e7..054cabe 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -90,6 +90,34 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "max_dst_opts_number",
+		.data		= &init_net.ipv6.sysctl.max_dst_opts_cnt,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "max_hbh_opts_number",
+		.data		= &init_net.ipv6.sysctl.max_hbh_opts_cnt,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "max_dst_opts_length",
+		.data		= &init_net.ipv6.sysctl.max_dst_opts_len,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "max_hbh_length",
+		.data		= &init_net.ipv6.sysctl.max_hbh_opts_len,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -149,6 +177,10 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[6].data = &net->ipv6.sysctl.idgen_delay;
 	ipv6_table[7].data = &net->ipv6.sysctl.flowlabel_state_ranges;
 	ipv6_table[8].data = &net->ipv6.sysctl.ip_nonlocal_bind;
+	ipv6_table[9].data = &net->ipv6.sysctl.max_dst_opts_cnt;
+	ipv6_table[10].data = &net->ipv6.sysctl.max_hbh_opts_cnt;
+	ipv6_table[11].data = &net->ipv6.sysctl.max_dst_opts_len;
+	ipv6_table[12].data = &net->ipv6.sysctl.max_hbh_opts_len;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
2.7.4
