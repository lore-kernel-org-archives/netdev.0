From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/05: nf_conntrack_ipv6: don't track ICMPv6 negotiation message
Date: Mon,  9 Feb 2009 17:39:29 +0100 (MET)
Message-ID: <20090209163928.13918.81066.sendpatchset@x2.localnet>
References: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 422b9bbd900dbb89dd3afaa8180daed4dae69eea
Author: Eric Leblond <eric@inl.fr>
Date:   Mon Feb 9 14:24:44 2009 +0100

    netfilter: nf_conntrack_ipv6: don't track ICMPv6 negotiation message
    
    This patch removes connection tracking handling for ICMPv6 messages
    related to Stateless Address Autoconfiguration, MLD, and MLDv2. They
    can not be tracked because they are massively using multicast (on
    pre-defined address). But they are not invalid and should not be
    detected as such.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 114a92e..c323643 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -53,6 +53,17 @@ static const u_int8_t invmap[] = {
 	[ICMPV6_NI_REPLY - 128]		= ICMPV6_NI_QUERY +1
 };
 
+static const u_int8_t noct_valid_new[] = {
+	[ICMPV6_MGM_QUERY - 130] = 1,
+	[ICMPV6_MGM_REPORT -130] = 1,
+	[ICMPV6_MGM_REDUCTION - 130] = 1,
+	[NDISC_ROUTER_SOLICITATION - 130] = 1,
+	[NDISC_ROUTER_ADVERTISEMENT - 130] = 1,
+	[NDISC_NEIGHBOUR_SOLICITATION - 130] = 1,
+	[NDISC_NEIGHBOUR_ADVERTISEMENT - 130] = 1,
+	[ICMPV6_MLD2_REPORT - 130] = 1
+};
+
 static bool icmpv6_invert_tuple(struct nf_conntrack_tuple *tuple,
 				const struct nf_conntrack_tuple *orig)
 {
@@ -178,6 +189,7 @@ icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 {
 	const struct icmp6hdr *icmp6h;
 	struct icmp6hdr _ih;
+	int type;
 
 	icmp6h = skb_header_pointer(skb, dataoff, sizeof(_ih), &_ih);
 	if (icmp6h == NULL) {
@@ -194,6 +206,15 @@ icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 		return -NF_ACCEPT;
 	}
 
+	type = icmp6h->icmp6_type - 130;
+	if (type >= 0 && type < sizeof(noct_valid_new) &&
+	    noct_valid_new[type]) {
+		skb->nfct = &nf_conntrack_untracked.ct_general;
+		skb->nfctinfo = IP_CT_NEW;
+		nf_conntrack_get(skb->nfct);
+		return NF_ACCEPT;
+	}
+
 	/* is not error message ? */
 	if (icmp6h->icmp6_type >= 128)
 		return NF_ACCEPT;
