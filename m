From: adobriyan@gmail.com
Subject: [PATCH 27/38] netns ct: per-netns net.netfilter.ip_conntrack_log_invalid
Date: Fri, 22 Aug 2008 02:08:02 +0400
Message-ID: <20080821220802.GA31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:7690 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756378AbYHUWGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:06:39 -0400
Received: by yw-out-2324.google.com with SMTP id 9so10203ywe.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:06:39 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_l4proto.h   |   15 +++++++--------
 include/net/netns/conntrack.h                  |    1 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    6 +++---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/netfilter/nf_conntrack_core.c              |    1 -
 net/netfilter/nf_conntrack_proto_dccp.c        |   10 ++++++----
 net/netfilter/nf_conntrack_proto_tcp.c         |   21 +++++++++++----------
 net/netfilter/nf_conntrack_proto_udp.c         |    6 +++---
 net/netfilter/nf_conntrack_proto_udplite.c     |    8 ++++----
 net/netfilter/nf_conntrack_standalone.c        |    7 +++----
 11 files changed, 40 insertions(+), 39 deletions(-)

--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -117,20 +117,19 @@ extern int nf_ct_port_nlattr_to_tuple(struct nlattr *tb[],
 				      struct nf_conntrack_tuple *t);
 extern const struct nla_policy nf_ct_port_nla_policy[];
 
-/* Log invalid packets */
-extern unsigned int nf_ct_log_invalid;
-
 #ifdef CONFIG_SYSCTL
 #ifdef DEBUG_INVALID_PACKETS
-#define LOG_INVALID(proto) \
-	(nf_ct_log_invalid == (proto) || nf_ct_log_invalid == IPPROTO_RAW)
+#define LOG_INVALID(net, proto)				\
+	((net)->ct.sysctl_log_invalid == (proto) ||	\
+	 (net)->ct.sysctl_log_invalid == IPPROTO_RAW)
 #else
-#define LOG_INVALID(proto) \
-	((nf_ct_log_invalid == (proto) || nf_ct_log_invalid == IPPROTO_RAW) \
+#define LOG_INVALID(net, proto)				\
+	(((net)->ct.sysctl_log_invalid == (proto) ||	\
+	  (net)->ct.sysctl_log_invalid == IPPROTO_RAW)	\
 	 && net_ratelimit())
 #endif
 #else
-#define LOG_INVALID(proto) 0
+#define LOG_INVALID(net, proto) 0
 #endif /* CONFIG_SYSCTL */
 
 #endif /*_NF_CONNTRACK_PROTOCOL_H*/
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -23,6 +23,7 @@ struct netns_ct {
 	struct nf_conntrack_ecache *ecache;
 #endif
 	int			sysctl_checksum;
+	unsigned int		sysctl_log_invalid; /* Log invalid packets */
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 #endif
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -278,7 +278,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_LOG_INVALID,
 		.procname	= "ip_conntrack_log_invalid",
-		.data		= &nf_ct_log_invalid,
+		.data		= &init_net.ct.sysctl_log_invalid,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -183,7 +183,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	/* Not enough header? */
 	icmph = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_ih), &_ih);
 	if (icmph == NULL) {
-		if (LOG_INVALID(IPPROTO_ICMP))
+		if (LOG_INVALID(net, IPPROTO_ICMP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_icmp: short packet ");
 		return -NF_ACCEPT;
@@ -192,7 +192,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	/* See ip_conntrack_proto_tcp.c */
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip_checksum(skb, hooknum, dataoff, 0)) {
-		if (LOG_INVALID(IPPROTO_ICMP))
+		if (LOG_INVALID(net, IPPROTO_ICMP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_icmp: bad HW ICMP checksum ");
 		return -NF_ACCEPT;
@@ -205,7 +205,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	 *		  discarded.
 	 */
 	if (icmph->type > NR_ICMP_TYPES) {
-		if (LOG_INVALID(IPPROTO_ICMP))
+		if (LOG_INVALID(net, IPPROTO_ICMP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_icmp: invalid ICMP type ");
 		return -NF_ACCEPT;
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -182,7 +182,7 @@ icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 
 	icmp6h = skb_header_pointer(skb, dataoff, sizeof(_ih), &_ih);
 	if (icmp6h == NULL) {
-		if (LOG_INVALID(IPPROTO_ICMPV6))
+		if (LOG_INVALID(net, IPPROTO_ICMPV6))
 		nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
 			      "nf_ct_icmpv6: short packet ");
 		return -NF_ACCEPT;
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -50,7 +50,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
 
-unsigned int nf_ct_log_invalid __read_mostly;
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
 
 static int nf_conntrack_hash_rnd_initted;
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -418,6 +418,7 @@ static bool dccp_invert_tuple(struct nf_conntrack_tuple *inv,
 static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 		     unsigned int dataoff)
 {
+	struct net *net = nf_ct_net(ct);
 	struct dccp_hdr _dh, *dh;
 	const char *msg;
 	u_int8_t state;
@@ -445,7 +446,7 @@ static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 
 out_invalid:
-	if (LOG_INVALID(IPPROTO_DCCP))
+	if (LOG_INVALID(net, IPPROTO_DCCP))
 		nf_log_packet(nf_ct_l3num(ct), 0, skb, NULL, NULL, NULL, msg);
 	return false;
 }
@@ -463,6 +464,7 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		       unsigned int dataoff, enum ip_conntrack_info ctinfo,
 		       int pf, unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	struct dccp_hdr _dh, *dh;
 	u_int8_t type, old_state, new_state;
@@ -524,13 +526,13 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		ct->proto.dccp.last_pkt = type;
 
 		write_unlock_bh(&dccp_lock);
-		if (LOG_INVALID(IPPROTO_DCCP))
+		if (LOG_INVALID(net, IPPROTO_DCCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_dccp: invalid packet ignored ");
 		return NF_ACCEPT;
 	case CT_DCCP_INVALID:
 		write_unlock_bh(&dccp_lock);
-		if (LOG_INVALID(IPPROTO_DCCP))
+		if (LOG_INVALID(net, IPPROTO_DCCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_dccp: invalid state transition ");
 		return -NF_ACCEPT;
@@ -590,7 +592,7 @@ static int dccp_error(struct net *net, struct sk_buff *skb,
 	return NF_ACCEPT;
 
 out_invalid:
-	if (LOG_INVALID(IPPROTO_DCCP))
+	if (LOG_INVALID(net, IPPROTO_DCCP))
 		nf_log_packet(pf, 0, skb, NULL, NULL, NULL, msg);
 	return -NF_ACCEPT;
 }
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -479,7 +479,8 @@ static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
 	}
 }
 
-static bool tcp_in_window(const struct nf_conn *ct,
+static bool tcp_in_window(struct net *net,
+			  const struct nf_conn *ct,
 			  struct ip_ct_tcp *state,
 			  enum ip_conntrack_dir dir,
 			  unsigned int index,
@@ -668,7 +669,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		if (sender->flags & IP_CT_TCP_FLAG_BE_LIBERAL ||
 		    nf_ct_tcp_be_liberal)
 			res = true;
-		if (!res && LOG_INVALID(IPPROTO_TCP))
+		if (!res && LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 			"nf_ct_tcp: %s ",
 			before(seq, sender->td_maxend + 1) ?
@@ -760,7 +761,7 @@ static int tcp_error(struct net *net, struct sk_buff *skb,
 	/* Smaller that minimal TCP header? */
 	th = skb_header_pointer(skb, dataoff, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_tcp: short packet ");
 		return -NF_ACCEPT;
@@ -768,7 +769,7 @@ static int tcp_error(struct net *net, struct sk_buff *skb,
 
 	/* Not whole TCP header or malformed packet */
 	if (th->doff*4 < sizeof(struct tcphdr) || tcplen < th->doff*4) {
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_tcp: truncated/malformed packet ");
 		return -NF_ACCEPT;
@@ -781,7 +782,7 @@ static int tcp_error(struct net *net, struct sk_buff *skb,
 	/* FIXME: Source route IP option packets --RR */
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_TCP, pf)) {
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: bad TCP checksum ");
 		return -NF_ACCEPT;
@@ -790,7 +791,7 @@ static int tcp_error(struct net *net, struct sk_buff *skb,
 	/* Check TCP flags. */
 	tcpflags = (((u_int8_t *)th)[13] & ~(TH_ECE|TH_CWR|TH_PUSH));
 	if (!tcp_valid_flags[tcpflags]) {
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid TCP flag combination ");
 		return -NF_ACCEPT;
@@ -886,7 +887,7 @@ static int tcp_packet(struct nf_conn *ct,
 			 * thus initiate a clean new session.
 			 */
 			write_unlock_bh(&tcp_lock);
-			if (LOG_INVALID(IPPROTO_TCP))
+			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: killing out of sync session ");
 			nf_ct_kill(ct);
@@ -899,7 +900,7 @@ static int tcp_packet(struct nf_conn *ct,
 		    segment_seq_plus_len(ntohl(th->seq), skb->len, dataoff, th);
 
 		write_unlock_bh(&tcp_lock);
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid packet ignored ");
 		return NF_ACCEPT;
@@ -908,7 +909,7 @@ static int tcp_packet(struct nf_conn *ct,
 		pr_debug("nf_ct_tcp: Invalid dir=%i index=%u ostate=%u\n",
 			 dir, get_conntrack_index(th), old_state);
 		write_unlock_bh(&tcp_lock);
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid state ");
 		return -NF_ACCEPT;
@@ -936,7 +937,7 @@ static int tcp_packet(struct nf_conn *ct,
 		break;
 	}
 
-	if (!tcp_in_window(ct, &ct->proto.tcp, dir, index,
+	if (!tcp_in_window(net, ct, &ct->proto.tcp, dir, index,
 			   skb, dataoff, th, pf)) {
 		write_unlock_bh(&tcp_lock);
 		return -NF_ACCEPT;
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -103,7 +103,7 @@ static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	/* Header is too small? */
 	hdr = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
 	if (hdr == NULL) {
-		if (LOG_INVALID(IPPROTO_UDP))
+		if (LOG_INVALID(net, IPPROTO_UDP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udp: short packet ");
 		return -NF_ACCEPT;
@@ -111,7 +111,7 @@ static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 
 	/* Truncated/malformed packets */
 	if (ntohs(hdr->len) > udplen || ntohs(hdr->len) < sizeof(*hdr)) {
-		if (LOG_INVALID(IPPROTO_UDP))
+		if (LOG_INVALID(net, IPPROTO_UDP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_udp: truncated/malformed packet ");
 		return -NF_ACCEPT;
@@ -127,7 +127,7 @@ static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	 * FIXME: Source route IP option packets --RR */
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_UDP, pf)) {
-		if (LOG_INVALID(IPPROTO_UDP))
+		if (LOG_INVALID(net, IPPROTO_UDP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_udp: bad UDP checksum ");
 		return -NF_ACCEPT;
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -105,7 +105,7 @@ static int udplite_error(struct net *net, struct sk_buff *skb,
 	/* Header is too small? */
 	hdr = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
 	if (hdr == NULL) {
-		if (LOG_INVALID(IPPROTO_UDPLITE))
+		if (LOG_INVALID(net, IPPROTO_UDPLITE))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: short packet ");
 		return -NF_ACCEPT;
@@ -115,7 +115,7 @@ static int udplite_error(struct net *net, struct sk_buff *skb,
 	if (cscov == 0)
 		cscov = udplen;
 	else if (cscov < sizeof(*hdr) || cscov > udplen) {
-		if (LOG_INVALID(IPPROTO_UDPLITE))
+		if (LOG_INVALID(net, IPPROTO_UDPLITE))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_udplite: invalid checksum coverage ");
 		return -NF_ACCEPT;
@@ -123,7 +123,7 @@ static int udplite_error(struct net *net, struct sk_buff *skb,
 
 	/* UDPLITE mandates checksums */
 	if (!hdr->check) {
-		if (LOG_INVALID(IPPROTO_UDPLITE))
+		if (LOG_INVALID(net, IPPROTO_UDPLITE))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: checksum missing ");
 		return -NF_ACCEPT;
@@ -133,7 +133,7 @@ static int udplite_error(struct net *net, struct sk_buff *skb,
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum_partial(skb, hooknum, dataoff, cscov, IPPROTO_UDP,
 	    			pf)) {
-		if (LOG_INVALID(IPPROTO_UDPLITE))
+		if (LOG_INVALID(net, IPPROTO_UDPLITE))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: bad UDPLite checksum ");
 		return -NF_ACCEPT;
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -365,7 +365,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_NF_CONNTRACK_LOG_INVALID,
 		.procname	= "nf_conntrack_log_invalid",
-		.data		= &nf_ct_log_invalid,
+		.data		= &init_net.ct.sysctl_log_invalid,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
@@ -403,8 +403,6 @@ static struct ctl_path nf_ct_path[] = {
 	{ }
 };
 
-EXPORT_SYMBOL_GPL(nf_ct_log_invalid);
-
 static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
 	struct ctl_table *table;
@@ -422,6 +420,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 
 	table[1].data = &net->ct.count;
 	table[3].data = &net->ct.sysctl_checksum;
+	table[4].data = &net->ct.sysctl_log_invalid;
 
 	net->ct.sysctl_header = register_net_sysctl_table(net,
 					nf_net_netfilter_sysctl_path, table);
@@ -472,6 +471,7 @@ static int nf_conntrack_net_init(struct net *net)
 	if (ret < 0)
 		goto out_proc;
 	net->ct.sysctl_checksum = 1;
+	net->ct.sysctl_log_invalid = 0;
 	ret = nf_conntrack_standalone_init_sysctl(net);
 	if (ret < 0)
 		goto out_sysctl;
-- 
1.5.6.3


