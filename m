From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/09: bridge: Fix handling of non-IP packets in FORWARD/POST_ROUTING
Date: Mon, 12 Jan 2009 11:06:02 +0100 (MET)
Message-ID: <20090112100602.9280.31548.sendpatchset@x2.localnet>
References: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60692 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbZALKGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 05:06:03 -0500
In-Reply-To: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9fa76a65a6b84254d31a8f8f5274c130737b4233
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Jan 12 06:25:50 2009 +0100

    netfilter: bridge: Fix handling of non-IP packets in FORWARD/POST_ROUTING
    
    Currently the bridge FORWARD/POST_ROUTING chains treats all
    non-IPv4 packets as IPv6.  This packet fixes that by returning
    NF_ACCEPT on non-IP packets instead, just as is done in PRE_ROUTING.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a65e43a..9a1cd75 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -686,8 +686,11 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb) ||
 	    IS_PPPOE_IP(skb))
 		pf = PF_INET;
-	else
+	else if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
+		 IS_PPPOE_IPV6(skb))
 		pf = PF_INET6;
+	else
+		return NF_ACCEPT;
 
 	nf_bridge_pull_encap_header(skb);
 
@@ -828,8 +831,11 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb) ||
 	    IS_PPPOE_IP(skb))
 		pf = PF_INET;
-	else
+	else if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
+		 IS_PPPOE_IPV6(skb))
 		pf = PF_INET6;
+	else
+		return NF_ACCEPT;
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	if (skb->dst == NULL) {
