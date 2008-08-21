From: adobriyan@gmail.com
Subject: [PATCH 13/38] netns ct: pass netns to L4 protocol's ->error hook
Date: Fri, 22 Aug 2008 02:02:04 +0400
Message-ID: <20080821220204.GM31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again, netns is deducible in every single ->error hook, but we're going
to use it everywhere for nf_conntrack_checksum and stats, so pass it from
upper layer.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_l4proto.h   |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    8 ++++----
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    8 ++++----
 net/netfilter/nf_conntrack_core.c              |    2 +-
 net/netfilter/nf_conntrack_proto_dccp.c        |    6 +++---
 net/netfilter/nf_conntrack_proto_tcp.c         |    2 +-
 net/netfilter/nf_conntrack_proto_udp.c         |    2 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |    4 ++--
 8 files changed, 17 insertions(+), 17 deletions(-)

--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -50,7 +50,7 @@ struct nf_conntrack_l4proto
 	/* Called when a conntrack entry is destroyed */
 	void (*destroy)(struct nf_conn *ct);
 
-	int (*error)(struct sk_buff *skb, unsigned int dataoff,
+	int (*error)(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 		     enum ip_conntrack_info *ctinfo,
 		     int pf, unsigned int hooknum);
 
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -123,7 +123,7 @@ static bool icmp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 /* Returns conntrack if it dealt with ICMP, and filled in skb fields */
 static int
-icmp_error_message(struct sk_buff *skb,
+icmp_error_message(struct net *net, struct sk_buff *skb,
 		 enum ip_conntrack_info *ctinfo,
 		 unsigned int hooknum)
 {
@@ -155,7 +155,7 @@ icmp_error_message(struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(&init_net, &innertuple);
+	h = nf_conntrack_find_get(net, &innertuple);
 	if (!h) {
 		pr_debug("icmp_error_message: no match\n");
 		return -NF_ACCEPT;
@@ -172,7 +172,7 @@ icmp_error_message(struct sk_buff *skb,
 
 /* Small and modified version of icmp_rcv */
 static int
-icmp_error(struct sk_buff *skb, unsigned int dataoff,
+icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	   enum ip_conntrack_info *ctinfo, int pf, unsigned int hooknum)
 {
 	const struct icmphdr *icmph;
@@ -217,7 +217,7 @@ icmp_error(struct sk_buff *skb, unsigned int dataoff,
 	    && icmph->type != ICMP_REDIRECT)
 		return NF_ACCEPT;
 
-	return icmp_error_message(skb, ctinfo, hooknum);
+	return icmp_error_message(net, skb, ctinfo, hooknum);
 }
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -122,7 +122,7 @@ static bool icmpv6_new(struct nf_conn *ct, const struct sk_buff *skb,
 }
 
 static int
-icmpv6_error_message(struct sk_buff *skb,
+icmpv6_error_message(struct net *net, struct sk_buff *skb,
 		     unsigned int icmp6off,
 		     enum ip_conntrack_info *ctinfo,
 		     unsigned int hooknum)
@@ -156,7 +156,7 @@ icmpv6_error_message(struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(&init_net, &intuple);
+	h = nf_conntrack_find_get(net, &intuple);
 	if (!h) {
 		pr_debug("icmpv6_error: no match\n");
 		return -NF_ACCEPT;
@@ -172,7 +172,7 @@ icmpv6_error_message(struct sk_buff *skb,
 }
 
 static int
-icmpv6_error(struct sk_buff *skb, unsigned int dataoff,
+icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	     enum ip_conntrack_info *ctinfo, int pf, unsigned int hooknum)
 {
 	const struct icmp6hdr *icmp6h;
@@ -197,7 +197,7 @@ icmpv6_error(struct sk_buff *skb, unsigned int dataoff,
 	if (icmp6h->icmp6_type >= 128)
 		return NF_ACCEPT;
 
-	return icmpv6_error_message(skb, dataoff, ctinfo, hooknum);
+	return icmpv6_error_message(net, skb, dataoff, ctinfo, hooknum);
 }
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -701,7 +701,7 @@ nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *s
 	 * inverse of the return code tells to the netfilter
 	 * core what to do with the packet. */
 	if (l4proto->error != NULL &&
-	    (ret = l4proto->error(skb, dataoff, &ctinfo, pf, hooknum)) <= 0) {
+	    (ret = l4proto->error(net, skb, dataoff, &ctinfo, pf, hooknum)) <= 0) {
 		NF_CT_STAT_INC_ATOMIC(error);
 		NF_CT_STAT_INC_ATOMIC(invalid);
 		return -ret;
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -545,9 +545,9 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-static int dccp_error(struct sk_buff *skb, unsigned int dataoff,
-		      enum ip_conntrack_info *ctinfo, int pf,
-		      unsigned int hooknum)
+static int dccp_error(struct net *net, struct sk_buff *skb,
+		      unsigned int dataoff, enum ip_conntrack_info *ctinfo,
+		      int pf, unsigned int hooknum)
 {
 	struct dccp_hdr _dh, *dh;
 	unsigned int dccp_len = skb->len - dataoff;
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -746,7 +746,7 @@ static const u8 tcp_valid_flags[(TH_FIN|TH_SYN|TH_RST|TH_ACK|TH_URG) + 1] =
 };
 
 /* Protect conntrack agaist broken packets. Code taken from ipt_unclean.c.  */
-static int tcp_error(struct sk_buff *skb,
+static int tcp_error(struct net *net, struct sk_buff *skb,
 		     unsigned int dataoff,
 		     enum ip_conntrack_info *ctinfo,
 		     int pf,
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -89,7 +89,7 @@ static bool udp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
-static int udp_error(struct sk_buff *skb, unsigned int dataoff,
+static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 		     enum ip_conntrack_info *ctinfo,
 		     int pf,
 		     unsigned int hooknum)
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -89,7 +89,8 @@ static bool udplite_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
-static int udplite_error(struct sk_buff *skb, unsigned int dataoff,
+static int udplite_error(struct net *net, struct sk_buff *skb,
+			 unsigned int dataoff,
 			 enum ip_conntrack_info *ctinfo,
 			 int pf,
 			 unsigned int hooknum)
-- 
1.5.6.3


