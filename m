From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v2 net-next] ipv6: Implement limits on Hop-by-Hop and Destination options
Date: Mon, 30 Oct 2017 14:16:00 -0700
Message-ID: <20171030211600.6491-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:44518 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752692AbdJ3VQS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:16:18 -0400
Received: by mail-pg0-f66.google.com with SMTP id j3so12761482pga.1
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 14:16:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 8200 (IPv6) defines Hop-by-Hop options and Destination options
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

This patch adds configurable limits to Destination and Hop-by-Hop
options. There are three limits that may be set:
  - Limit the number of options in a Hop-by-Hop or Destination options
    extension header.
  - Limit the byte length of a Hop-by-Hop or Destination options
    extension header.
  - Disallow unrecognized options in a Hop-by-Hop or Destination
    options extension header.

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

These limits have being proposed in draft-ietf-6man-rfc6434-bis.

Tested (by Martin Lau)

I tested out 1 thread (i.e. one raw_udp process).

I changed the net.ipv6.max_dst_(opts|hbh)_number between 8 to 2048.
With sysctls setting to 2048, the softirq% is packed to 100%.
With 8, the softirq% is almost unnoticable from mpstat.

v2;
  - Code and documention cleanup.
  - Change references of RFC2460 to be RFC8200.
  - Add reference to RFC6434-bis where the limits will be in standard.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 Documentation/networking/ip-sysctl.txt | 24 ++++++++++++
 include/net/ipv6.h                     | 40 ++++++++++++++++++++
 include/net/netns/ipv6.h               |  4 ++
 net/ipv6/af_inet6.c                    |  4 ++
 net/ipv6/exthdrs.c                     | 67 ++++++++++++++++++++++++++++------
 net/ipv6/sysctl_net_ipv6.c             | 32 ++++++++++++++++
 6 files changed, 159 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 77f4de59dc9c..e6661b205f72 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1385,6 +1385,30 @@ mld_qrv - INTEGER
 	Default: 2 (as specified by RFC3810 9.1)
 	Minimum: 1 (as specified by RFC6636 4.5)
 
+max_dst_opts_cnt - INTEGER
+	Maximum number of non-padding TLVs allowed in a Destination
+	options extension header. If this value is less than zero
+	then unknown options are disallowed and the number of known
+	TLVs allowed is the absolute value of this number.
+	Default: 8
+
+max_hbh_opts_cnt - INTEGER
+	Maximum number of non-padding TLVs allowed in a Hop-by-Hop
+	options extension header. If this value is less than zero
+	then unknown options are disallowed and the number of known
+	TLVs allowed is the absolute value of this number.
+	Default: 8
+
+max dst_opts_len - INTEGER
+	Maximum length allowed for a Destination options extension
+	header.
+	Default: INT_MAX (unlimited)
+
+max hbh_opts_len - INTEGER
+	Maximum length allowed for a Hop-by-Hop options extension
+	header.
+	Default: INT_MAX (unlimited)
+
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 3cda3b521c36..fb6d67012de6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -51,6 +51,46 @@
 #define IPV6_DEFAULT_HOPLIMIT   64
 #define IPV6_DEFAULT_MCASTHOPS	1
 
+/* Limits on Hop-by-Hop and Destination options.
+ *
+ * Per RFC8200 there is no limit on the maximum number or lengths of options in
+ * Hop-by-Hop or Destination options other then the packet must fit in an MTU.
+ * We allow configurable limits in order to mitigate potential denial of
+ * service attacks.
+ *
+ * There are three limits that may be set:
+ *   - Limit the number of options in a Hop-by-Hop or Destination options
+ *     extension header
+ *   - Limit the byte length of a Hop-by-Hop or Destination options extension
+ *     header
+ *   - Disallow unknown options
+ *
+ * The limits are expressed in corresponding sysctls:
+ *
+ * ipv6.sysctl.max_dst_opts_cnt
+ * ipv6.sysctl.max_hbh_opts_cnt
+ * ipv6.sysctl.max_dst_opts_len
+ * ipv6.sysctl.max_hbh_opts_len
+ *
+ * max_*_opts_cnt is the number of TLVs that are allowed for Destination
+ * options or Hop-by-Hop options. If the number is less than zero then unknown
+ * TLVs are disallowed and the number of known options that are allowed is the
+ * absolute value. Setting the value to INT_MAX indicates no limit.
+ *
+ * max_*_opts_len is the length limit in bytes of a Destination or
+ * Hop-by-Hop options extension header. Setting the value to INT_MAX
+ * indicates no length limit.
+ *
+ * If a limit is exceeded when processing an extension header the packet is
+ * silently discarded.
+ */
+
+/* Default limits for Hop-by-Hop and Destination options */
+#define IP6_DEFAULT_MAX_DST_OPTS_CNT	 8
+#define IP6_DEFAULT_MAX_HBH_OPTS_CNT	 8
+#define IP6_DEFAULT_MAX_DST_OPTS_LEN	 INT_MAX /* No limit */
+#define IP6_DEFAULT_MAX_HBH_OPTS_LEN	 INT_MAX /* No limit */
+
 /*
  *	Addr type
  *	
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 2ea1ed341ef8..600ba1c1befc 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -37,6 +37,10 @@ struct netns_sysctl_ipv6 {
 	int idgen_delay;
 	int flowlabel_state_ranges;
 	int flowlabel_reflect;
+	int max_dst_opts_cnt;
+	int max_hbh_opts_cnt;
+	int max_dst_opts_len;
+	int max_hbh_opts_len;
 };
 
 struct netns_ipv6 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index fe5262fd6aa5..c26f71234b9c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -810,6 +810,10 @@ static int __net_init inet6_net_init(struct net *net)
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
index 9f918a770f87..83bd75713535 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -74,8 +74,20 @@ struct tlvtype_proc {
 
 /* An unknown option is detected, decide what to do */
 
-static bool ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
+static bool ip6_tlvopt_unknown(struct sk_buff *skb, int optoff,
+			       bool disallow_unknowns)
 {
+	if (disallow_unknowns) {
+		/* If unknown TLVs are disallowed by configuration
+		 * then always silently drop packet. Note this also
+		 * means no ICMP parameter problem is sent which
+		 * could be a good property to mitigate a reflection DOS
+		 * attack.
+		 */
+
+		goto drop;
+	}
+
 	switch ((skb_network_header(skb)[optoff] & 0xC0) >> 6) {
 	case 0: /* ignore */
 		return true;
@@ -95,20 +107,30 @@ static bool ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
 		return false;
 	}
 
+drop:
 	kfree_skb(skb);
 	return false;
 }
 
 /* Parse tlv encoded option header (hop-by-hop or destination) */
 
-static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
+static bool ip6_parse_tlv(const struct tlvtype_proc *procs,
+			  struct sk_buff *skb,
+			  int max_count)
 {
-	const struct tlvtype_proc *curr;
+	int len = (skb_transport_header(skb)[1] + 1) << 3;
 	const unsigned char *nh = skb_network_header(skb);
 	int off = skb_network_header_len(skb);
-	int len = (skb_transport_header(skb)[1] + 1) << 3;
+	const struct tlvtype_proc *curr;
+	bool disallow_unknowns = false;
+	int tlv_count = 0;
 	int padlen = 0;
 
+	if (unlikely(max_count < 0)) {
+		disallow_unknowns = true;
+		max_count = -max_count;
+	}
+
 	if (skb_transport_offset(skb) + len > skb_headlen(skb))
 		goto bad;
 
@@ -149,6 +171,11 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
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
@@ -159,10 +186,10 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 					break;
 				}
 			}
-			if (curr->type < 0) {
-				if (ip6_tlvopt_unknown(skb, off) == 0)
-					return false;
-			}
+			if (curr->type < 0 &&
+			    !ip6_tlvopt_unknown(skb, off, disallow_unknowns))
+				return false;
+
 			padlen = 0;
 			break;
 		}
@@ -258,23 +285,31 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	__u16 dstbuf;
 #endif
 	struct dst_entry *dst = skb_dst(skb);
+	struct net *net = dev_net(skb->dev);
+	int extlen;
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
 		__IP6_INC_STATS(dev_net(dst->dev), ip6_dst_idev(dst),
 				IPSTATS_MIB_INHDRERRORS);
+fail_and_free:
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
@@ -803,6 +838,8 @@ static const struct tlvtype_proc tlvprochopopt_lst[] = {
 int ipv6_parse_hopopts(struct sk_buff *skb)
 {
 	struct inet6_skb_parm *opt = IP6CB(skb);
+	struct net *net = dev_net(skb->dev);
+	int extlen;
 
 	/*
 	 * skb_network_header(skb) is equal to skb->data, and
@@ -813,13 +850,19 @@ int ipv6_parse_hopopts(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr) + 8) ||
 	    !pskb_may_pull(skb, (sizeof(struct ipv6hdr) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
+fail_and_free:
 		kfree_skb(skb);
 		return -1;
 	}
 
+	extlen = (skb_transport_header(skb)[1] + 1) << 3;
+	if (extlen > net->ipv6.sysctl.max_hbh_opts_len)
+		goto fail_and_free;
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
index 6fbf8ae5e52c..4a2f0fd870bc 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -97,6 +97,34 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
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
 
@@ -157,6 +185,10 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[7].data = &net->ipv6.sysctl.flowlabel_state_ranges;
 	ipv6_table[8].data = &net->ipv6.sysctl.ip_nonlocal_bind;
 	ipv6_table[9].data = &net->ipv6.sysctl.flowlabel_reflect;
+	ipv6_table[10].data = &net->ipv6.sysctl.max_dst_opts_cnt;
+	ipv6_table[11].data = &net->ipv6.sysctl.max_hbh_opts_cnt;
+	ipv6_table[12].data = &net->ipv6.sysctl.max_dst_opts_len;
+	ipv6_table[13].data = &net->ipv6.sysctl.max_hbh_opts_len;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
2.11.0
