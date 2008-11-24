From: Patrick McHardy <kaber@trash.net>
Subject: bridge 03/03: netfilter: fix update_pmtu crash with GRE
Date: Mon, 24 Nov 2008 14:44:39 +0100 (MET)
Message-ID: <20081124134431.462.53634.sendpatchset@x2.localnet>
References: <20081124134427.462.77824.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63759 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbYKXNol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 08:44:41 -0500
In-Reply-To: <20081124134427.462.77824.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1e8768f064c00a4fbb42e87bc42b371bd9ca01c0
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Nov 24 13:31:14 2008 +0100

    bridge: netfilter: fix update_pmtu crash with GRE
    
    As GRE tries to call the update_pmtu function on skb->dst and
    bridge supplies an skb->dst that has a NULL ops field, all is
    not well.
    
    This patch fixes this by giving the bridge device an ops field
    with an update_pmtu function.  For the moment I've left all
    other fields blank but we can fill them in later should the
    need arise.
    
    Based on report and patch by Philip Craig.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index fa5cda4..45f61c3 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -101,6 +101,18 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 	 pppoe_proto(skb) == htons(PPP_IPV6) && \
 	 brnf_filter_pppoe_tagged)
 
+static void fake_update_pmtu(struct dst_entry *dst, u32 mtu)
+{
+}
+
+static struct dst_ops fake_dst_ops = {
+	.family =		AF_INET,
+	.protocol =		__constant_htons(ETH_P_IP),
+	.update_pmtu =		fake_update_pmtu,
+	.entry_size =		sizeof(struct rtable),
+	.entries =		ATOMIC_INIT(0),
+};
+
 /*
  * Initialize bogus route table used to keep netfilter happy.
  * Currently, we fill in the PMTU entry because netfilter
@@ -117,6 +129,7 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 	rt->u.dst.path = &rt->u.dst;
 	rt->u.dst.metrics[RTAX_MTU - 1] = 1500;
 	rt->u.dst.flags	= DST_NOXFRM;
+	rt->u.dst.ops = &fake_dst_ops;
 }
 
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
