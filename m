From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v2 5/6] netns ct: per-netns
	net.netfilter.nf_conntrack_log_invalid sysctl
Date: Sat, 13 Sep 2008 14:53:19 +0400
Message-ID: <20080913105319.GF7440@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48C62B1C.7070104@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_l4proto.h   |   15 +++++++--------
 include/net/netns/conntrack.h                  |    1 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    6 +++---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/netfilter/nf_conntrack_core.c              |    1 -
 net/netfilter/nf_conntrack_proto_dccp.c        |   10 ++++++----
 net/netfilter/nf_conntrack_proto_tcp.c         |   18 ++++++++++--------
 net/netfilter/nf_conntrack_proto_udp.c         |    6 +++---
 net/netfilter/nf_conntrack_proto_udplite.c     |    8 ++++----
 net/netfilter/nf_conntrack_standalone.c        |    6 +++---
 11 files changed, 39 insertions(+), 36 deletions(-)

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
@@ -18,6 +18,7 @@ struct netns_ct {
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
@@ -181,7 +181,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	/* Not enough header? */
 	icmph = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_ih), &_ih);
 	if (icmph == NULL) {
-		if (LOG_INVALID(IPPROTO_ICMP))
+		if (LOG_INVALID(net, IPPROTO_ICMP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_icmp: short packet ");
 		return -NF_ACCEPT;
@@ -190,7 +190,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	/* See ip_conntrack_proto_tcp.c */
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip_checksum(skb, hooknum, dataoff, 0)) {
-		if (LOG_INVALID(IPPROTO_ICMP))
+		if (LOG_INVALID(net, IPPROTO_ICMP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_icmp: bad HW ICMP checksum ");
 		return -NF_ACCEPT;
@@ -203,7 +203,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
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
@@ -181,7 +181,7 @@ icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 
 	icmp6h = skb_header_pointer(skb, dataoff, sizeof(_ih), &_ih);
 	if (icmp6h == NULL) {
-		if (LOG_INVALID(IPPROTO_ICMPV6))
+		if (LOG_INVALID(net, IPPROTO_ICMPV6))
 		nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
 			      "nf_ct_icmpv6: short packet ");
 		return -NF_ACCEPT;
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -53,7 +53,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 
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
 		       u_int8_t pf, unsigned int hooknum)
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
@@ -488,6 +488,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 			  const struct tcphdr *tcph,
 			  u_int8_t pf)
 {
+	struct net *net = nf_ct_net(ct);
 	struct ip_ct_tcp_state *sender = &state->seen[dir];
 	struct ip_ct_tcp_state *receiver = &state->seen[!dir];
 	const struct nf_conntrack_tuple *tuple = &ct->tuplehash[dir].tuple;
@@ -668,7 +669,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		if (sender->flags & IP_CT_TCP_FLAG_BE_LIBERAL ||
 		    nf_ct_tcp_be_liberal)
 			res = true;
-		if (!res && LOG_INVALID(IPPROTO_TCP))
+		if (!res && LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 			"nf_ct_tcp: %s ",
 			before(seq, sender->td_maxend + 1) ?
@@ -761,7 +762,7 @@ static int tcp_error(struct net *net,
 	/* Smaller that minimal TCP header? */
 	th = skb_header_pointer(skb, dataoff, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_tcp: short packet ");
 		return -NF_ACCEPT;
@@ -769,7 +770,7 @@ static int tcp_error(struct net *net,
 
 	/* Not whole TCP header or malformed packet */
 	if (th->doff*4 < sizeof(struct tcphdr) || tcplen < th->doff*4) {
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_tcp: truncated/malformed packet ");
 		return -NF_ACCEPT;
@@ -782,7 +783,7 @@ static int tcp_error(struct net *net,
 	/* FIXME: Source route IP option packets --RR */
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_TCP, pf)) {
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: bad TCP checksum ");
 		return -NF_ACCEPT;
@@ -791,7 +792,7 @@ static int tcp_error(struct net *net,
 	/* Check TCP flags. */
 	tcpflags = (((u_int8_t *)th)[13] & ~(TH_ECE|TH_CWR|TH_PUSH));
 	if (!tcp_valid_flags[tcpflags]) {
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid TCP flag combination ");
 		return -NF_ACCEPT;
@@ -808,6 +809,7 @@ static int tcp_packet(struct nf_conn *ct,
 		      u_int8_t pf,
 		      unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_tuple *tuple;
 	enum tcp_conntrack new_state, old_state;
 	enum ip_conntrack_dir dir;
@@ -886,7 +888,7 @@ static int tcp_packet(struct nf_conn *ct,
 			 * thus initiate a clean new session.
 			 */
 			write_unlock_bh(&tcp_lock);
-			if (LOG_INVALID(IPPROTO_TCP))
+			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: killing out of sync session ");
 			nf_ct_kill(ct);
@@ -899,7 +901,7 @@ static int tcp_packet(struct nf_conn *ct,
 		    segment_seq_plus_len(ntohl(th->seq), skb->len, dataoff, th);
 
 		write_unlock_bh(&tcp_lock);
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid packet ignored ");
 		return NF_ACCEPT;
@@ -908,7 +910,7 @@ static int tcp_packet(struct nf_conn *ct,
 		pr_debug("nf_ct_tcp: Invalid dir=%i index=%u ostate=%u\n",
 			 dir, get_conntrack_index(th), old_state);
 		write_unlock_bh(&tcp_lock);
-		if (LOG_INVALID(IPPROTO_TCP))
+		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				  "nf_ct_tcp: invalid state ");
 		return -NF_ACCEPT;
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -101,7 +101,7 @@ static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	/* Header is too small? */
 	hdr = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
 	if (hdr == NULL) {
-		if (LOG_INVALID(IPPROTO_UDP))
+		if (LOG_INVALID(net, IPPROTO_UDP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udp: short packet ");
 		return -NF_ACCEPT;
@@ -109,7 +109,7 @@ static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 
 	/* Truncated/malformed packets */
 	if (ntohs(hdr->len) > udplen || ntohs(hdr->len) < sizeof(*hdr)) {
-		if (LOG_INVALID(IPPROTO_UDP))
+		if (LOG_INVALID(net, IPPROTO_UDP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_udp: truncated/malformed packet ");
 		return -NF_ACCEPT;
@@ -125,7 +125,7 @@ static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
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
@@ -104,7 +104,7 @@ static int udplite_error(struct net *net,
 	/* Header is too small? */
 	hdr = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
 	if (hdr == NULL) {
-		if (LOG_INVALID(IPPROTO_UDPLITE))
+		if (LOG_INVALID(net, IPPROTO_UDPLITE))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: short packet ");
 		return -NF_ACCEPT;
@@ -114,7 +114,7 @@ static int udplite_error(struct net *net,
 	if (cscov == 0)
 		cscov = udplen;
 	else if (cscov < sizeof(*hdr) || cscov > udplen) {
-		if (LOG_INVALID(IPPROTO_UDPLITE))
+		if (LOG_INVALID(net, IPPROTO_UDPLITE))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				"nf_ct_udplite: invalid checksum coverage ");
 		return -NF_ACCEPT;
@@ -122,7 +122,7 @@ static int udplite_error(struct net *net,
 
 	/* UDPLITE mandates checksums */
 	if (!hdr->check) {
-		if (LOG_INVALID(IPPROTO_UDPLITE))
+		if (LOG_INVALID(net, IPPROTO_UDPLITE))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 				      "nf_ct_udplite: checksum missing ");
 		return -NF_ACCEPT;
@@ -132,7 +132,7 @@ static int udplite_error(struct net *net,
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
@@ -423,6 +421,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 
 	table[1].data = &net->ct.count;
 	table[3].data = &net->ct.sysctl_checksum;
+	table[4].data = &net->ct.sysctl_log_invalid;
 
 	net->ct.sysctl_header = register_net_sysctl_table(net,
 					nf_net_netfilter_sysctl_path, table);
@@ -473,6 +472,7 @@ static int nf_conntrack_net_init(struct net *net)
 	if (ret < 0)
 		goto out_proc;
 	net->ct.sysctl_checksum = 1;
+	net->ct.sysctl_log_invalid = 0;
 	ret = nf_conntrack_standalone_init_sysctl(net);
 	if (ret < 0)
 		goto out_sysctl;
