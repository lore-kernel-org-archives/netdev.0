From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 3/8] vxlan: use ip_route_output
Date: Tue, 09 Oct 2012 23:35:48 -0700
Message-ID: <20121010063623.533119759@vyatta.com>
References: <20121010063545.453368147@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52280 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148Ab2JJGjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 02:39:23 -0400
Content-Disposition: inline; filename=vxlan-route-output.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Select source address for VXLAN packet based on route destination
and don't lie to route code. VXLAN is not GRE.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
v2 - zero flow structure

--- a/drivers/net/vxlan.c	2012-10-09 18:08:32.630456072 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 18:08:33.466447793 -0700
@@ -680,9 +680,13 @@ static netdev_tx_t vxlan_xmit(struct sk_
 
 	hash = skb_get_rxhash(skb);
 
-	rt = ip_route_output_gre(dev_net(dev), &fl4, dst,
-				 vxlan->saddr, vxlan->vni,
-				 RT_TOS(tos), vxlan->link);
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.flowi4_oif = vxlan->link;
+	fl4.flowi4_tos = RT_TOS(tos);
+	fl4.daddr = dst;
+	fl4.saddr = vxlan->saddr;
+
+	rt = ip_route_output_key(dev_net(dev), &fl4);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to %pI4\n", &dst);
 		dev->stats.tx_carrier_errors++;
@@ -724,7 +728,7 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	iph->frag_off	= df;
 	iph->protocol	= IPPROTO_UDP;
 	iph->tos	= vxlan_ecn_encap(tos, old_iph, skb);
-	iph->daddr	= fl4.daddr;
+	iph->daddr	= dst;
 	iph->saddr	= fl4.saddr;
 	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
 
