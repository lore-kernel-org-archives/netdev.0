From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 6/8][GRE]: Use proper net in routing calls.
Date: Tue, 15 Apr 2008 17:00:40 +0400
Message-ID: <4804A6F8.8070501@openvz.org>
References: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43450 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789AbYDOM0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:26:22 -0400
In-Reply-To: <4804A374.9040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As for the IPIP tunnel, there are some ip_route_output_key()
calls in there that require a proper net so give one to them.

And a proper net for the __get_dev_by_index hanging around.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 74d4c51..aa97381 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -493,7 +493,7 @@ out:
 	fl.fl4_dst = eiph->saddr;
 	fl.fl4_tos = RT_TOS(eiph->tos);
 	fl.proto = IPPROTO_GRE;
-	if (ip_route_output_key(&init_net, &rt, &fl)) {
+	if (ip_route_output_key(dev_net(skb->dev), &rt, &fl)) {
 		kfree_skb(skb2);
 		return;
 	}
@@ -506,7 +506,7 @@ out:
 		fl.fl4_dst = eiph->daddr;
 		fl.fl4_src = eiph->saddr;
 		fl.fl4_tos = eiph->tos;
-		if (ip_route_output_key(&init_net, &rt, &fl) ||
+		if (ip_route_output_key(dev_net(skb->dev), &rt, &fl) ||
 		    rt->u.dst.dev->type != ARPHRD_IPGRE) {
 			ip_rt_put(rt);
 			kfree_skb(skb2);
@@ -762,7 +762,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 						.saddr = tiph->saddr,
 						.tos = RT_TOS(tos) } },
 				    .proto = IPPROTO_GRE };
-		if (ip_route_output_key(&init_net, &rt, &fl)) {
+		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tunnel->stat.tx_carrier_errors++;
 			goto tx_error;
 		}
@@ -935,7 +935,7 @@ static void ipgre_tunnel_bind_dev(struct net_device *dev)
 						.tos = RT_TOS(iph->tos) } },
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
-		if (!ip_route_output_key(&init_net, &rt, &fl)) {
+		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
@@ -943,7 +943,7 @@ static void ipgre_tunnel_bind_dev(struct net_device *dev)
 	}
 
 	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(&init_net, tunnel->parms.link);
+		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
 
 	if (tdev) {
 		hlen = tdev->hard_header_len;
@@ -1193,7 +1193,7 @@ static int ipgre_open(struct net_device *dev)
 						.tos = RT_TOS(t->parms.iph.tos) } },
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
-		if (ip_route_output_key(&init_net, &rt, &fl))
+		if (ip_route_output_key(dev_net(dev), &rt, &fl))
 			return -EADDRNOTAVAIL;
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
-- 
1.5.3.4


