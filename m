From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 6/8][IPIP]: Use proper net in (mostly) routing
 calls.
Date: Tue, 15 Apr 2008 16:38:35 +0400
Message-ID: <4804A1CB.4010802@openvz.org>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47536 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375AbYDOMEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:04:15 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some ip_route_output_key() calls in there that require
a proper net so give one to them.

Besides - give a proper net to a single __get_dev_by_index call 
in ipip_tunnel_bind_dev().

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipip.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 9c2939b..1de39e1 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -415,7 +415,7 @@ out:
 	fl.fl4_daddr = eiph->saddr;
 	fl.fl4_tos = RT_TOS(eiph->tos);
 	fl.proto = IPPROTO_IPIP;
-	if (ip_route_output_key(&init_net, &rt, &key)) {
+	if (ip_route_output_key(dev_net(skb->dev), &rt, &key)) {
 		kfree_skb(skb2);
 		return 0;
 	}
@@ -428,7 +428,7 @@ out:
 		fl.fl4_daddr = eiph->daddr;
 		fl.fl4_src = eiph->saddr;
 		fl.fl4_tos = eiph->tos;
-		if (ip_route_output_key(&init_net, &rt, &fl) ||
+		if (ip_route_output_key(dev_net(skb->dev), &rt, &fl) ||
 		    rt->u.dst.dev->type != ARPHRD_TUNNEL) {
 			ip_rt_put(rt);
 			kfree_skb(skb2);
@@ -558,7 +558,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 						.saddr = tiph->saddr,
 						.tos = RT_TOS(tos) } },
 				    .proto = IPPROTO_IPIP };
-		if (ip_route_output_key(&init_net, &rt, &fl)) {
+		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tunnel->stat.tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
@@ -679,7 +679,7 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 						.tos = RT_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
 		struct rtable *rt;
-		if (!ip_route_output_key(&init_net, &rt, &fl)) {
+		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
@@ -687,7 +687,7 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 	}
 
 	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(&init_net, tunnel->parms.link);
+		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
 
 	if (tdev) {
 		dev->hard_header_len = tdev->hard_header_len + sizeof(struct iphdr);
-- 
1.5.3.4

