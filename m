From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 11/29: nf_nat: remove warn_if_extra_mangle
Date: Thu, 27 Nov 2008 17:15:18 +0100 (MET)
Message-ID: <20081127161518.13891.2929.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 6e3354c1e9946fa585de40e93ad917ec7abd006e
Author: Simon Arlott <simon@fire.lp0.eu>
Date:   Tue Nov 4 14:35:39 2008 +0100

    netfilter: nf_nat: remove warn_if_extra_mangle
    
    In net/ipv4/netfilter/nf_nat_rule.c, the function warn_if_extra_mangle was added
    in commit 5b1158e909ecbe1a052203e0d8df15633f829930 (2006-12-02). I have a DNAT
    target in the OUTPUT chain than changes connections with dst 2.0.0.1 to another
    address which I'll substitute with 66.102.9.99 below.
    
    On every boot I get the following message:
    [  146.252505] NAT: no longer support implicit source local NAT
    [  146.252517] NAT: packet src 66.102.9.99 -> dst 2.0.0.1
    
    As far as I can tell from reading the function doing this, it should warn if the
    source IP for the route to 66.102.9.99 is different from 2.0.0.1 but that is not
    the case. It doesn't make sense to check the DNAT target against the local route
    source.
    
    Either the function should be changed to correctly check the route, or it should
    be removed entirely as it's been nearly 2 years since it was added.
    
    Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index a4f1c34..cf95469 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -86,24 +86,6 @@ ipt_snat_target(struct sk_buff *skb, const struct xt_target_param *par)
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_SRC);
 }
 
-/* Before 2.6.11 we did implicit source NAT if required. Warn about change. */
-static void warn_if_extra_mangle(struct net *net, __be32 dstip, __be32 srcip)
-{
-	static int warned = 0;
-	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = dstip } } };
-	struct rtable *rt;
-
-	if (ip_route_output_key(net, &rt, &fl) != 0)
-		return;
-
-	if (rt->rt_src != srcip && !warned) {
-		printk("NAT: no longer support implicit source local NAT\n");
-		printk("NAT: packet src %pI4 -> dst %pI4\n", &srcip, &dstip);
-		warned = 1;
-	}
-	ip_rt_put(rt);
-}
-
 static unsigned int
 ipt_dnat_target(struct sk_buff *skb, const struct xt_target_param *par)
 {
@@ -119,11 +101,6 @@ ipt_dnat_target(struct sk_buff *skb, const struct xt_target_param *par)
 	/* Connection must be valid and new. */
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
 
-	if (par->hooknum == NF_INET_LOCAL_OUT &&
-	    mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)
-		warn_if_extra_mangle(dev_net(par->out), ip_hdr(skb)->daddr,
-				     mr->range[0].min_ip);
-
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_DST);
 }
 
