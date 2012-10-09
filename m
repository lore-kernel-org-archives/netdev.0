From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/6] vxlan: use ip_route_output
Date: Tue, 09 Oct 2012 10:56:39 -0700
Message-ID: <20121009175714.538033361@vyatta.com>
References: <20121009175637.048993312@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:51696 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756572Ab2JISB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 14:01:28 -0400
Content-Disposition: inline; filename=vxlan-route-output.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Select source address for VXLAN packet based on route destination
and don't lie to route code: VXLAN is not GRE.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/vxlan.c	2012-10-09 10:48:56.546879617 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 10:49:01.334832146 -0700
@@ -676,9 +676,11 @@ static netdev_tx_t vxlan_xmit(struct sk_
 
 	hash = skb_get_rxhash(skb);
 
-	rt = ip_route_output_gre(dev_net(dev), &fl4, dst,
-				 vxlan->saddr, vxlan->vni,
-				 RT_TOS(tos), vxlan->link);
+	fl4.flowi4_oif = vxlan->link;
+	fl4.flowi4_tos = RT_TOS(tos);
+	fl4.daddr = dst;
+	fl4.saddr = vxlan->saddr;
+	rt = ip_route_output_key(dev_net(dev), &fl4);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to %pI4\n", &dst);
 		dev->stats.tx_carrier_errors++;
@@ -720,7 +722,7 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	iph->frag_off	= df;
 	iph->protocol	= IPPROTO_UDP;
 	iph->tos	= vxlan_ecn_encap(tos, old_iph, skb);
-	iph->daddr	= fl4.daddr;
+	iph->daddr	= dst;
 	iph->saddr	= fl4.saddr;
 	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
 
