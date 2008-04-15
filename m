From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 6/8][SIT]: Use proper net in routing calls.
Date: Tue, 15 Apr 2008 17:36:19 +0400
Message-ID: <4804AF53.60005@openvz.org>
References: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55359 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760030AbYDONCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:02:05 -0400
In-Reply-To: <4804ACFA.1040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I.e. replace init_net stubs in ip_route_output_key() calls.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sit.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index f82494b..7badac6 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -527,11 +527,12 @@ out:
 	skb_reset_network_header(skb2);
 
 	/* Try to guess incoming interface */
-	rt6i = rt6_lookup(&init_net, &iph6->saddr, NULL, NULL, 0);
+	rt6i = rt6_lookup(dev_net(skb->dev), &iph6->saddr, NULL, NULL, 0);
 	if (rt6i && rt6i->rt6i_dev) {
 		skb2->dev = rt6i->rt6i_dev;
 
-		rt6i = rt6_lookup(&init_net, &iph6->daddr, &iph6->saddr, NULL, 0);
+		rt6i = rt6_lookup(dev_net(skb->dev),
+				&iph6->daddr, &iph6->saddr, NULL, 0);
 
 		if (rt6i && rt6i->rt6i_dev && rt6i->rt6i_dev->type == ARPHRD_SIT) {
 			struct ip_tunnel *t = netdev_priv(rt6i->rt6i_dev);
@@ -701,7 +702,7 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 						.tos = RT_TOS(tos) } },
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
-		if (ip_route_output_key(&init_net, &rt, &fl)) {
+		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tunnel->stat.tx_carrier_errors++;
 			goto tx_error_icmp;
 		}
@@ -830,7 +831,7 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
 		struct rtable *rt;
-		if (!ip_route_output_key(&init_net, &rt, &fl)) {
+		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
@@ -838,7 +839,7 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 	}
 
 	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(&init_net, tunnel->parms.link);
+		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
 
 	if (tdev) {
 		dev->hard_header_len = tdev->hard_header_len + sizeof(struct iphdr);
-- 
1.5.3.4

