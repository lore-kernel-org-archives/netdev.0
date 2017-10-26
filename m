From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipip: only increase err_count for some certain type icmp in ipip_err
Date: Thu, 26 Oct 2017 19:19:56 +0800
Message-ID: <335a3f6cef850b848452e6f1258039472dafc093.1509016796.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
        Pravin B Shelar <pshelar@nicira.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:50964 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdJZLUG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 07:20:06 -0400
Received: by mail-pg0-f65.google.com with SMTP id y5so2428448pgq.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 04:20:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

t->err_count is used to count the link failure on tunnel and an err
will be reported to user socket in tx path if t->err_count is not 0.
udp socket could even return EHOSTUNREACH to users.

Since commit fd58156e456d ("IPIP: Use ip-tunneling code.") removed
the 'switch check' for icmp type in ipip_err(), err_count would be
increased by the icmp packet with ICMP_EXC_FRAGTIME code. an link
failure would be reported out due to this.

In Jianlin's case, when receiving ICMP_EXC_FRAGTIME a icmp packet,
udp netperf failed with the err:
  send_data: data send error: No route to host (errno 113)

We expect this error reported from tunnel to socket when receiving
some certain type icmp, but not ICMP_EXC_FRAGTIME, ICMP_SR_FAILED
or ICMP_PARAMETERPROB ones.

This patch is to bring 'switch check' for icmp type back to ipip_err
so that it only reports link failure for the right type icmp, just as
in ipgre_err() and ipip6_err().

Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ipip.c | 59 ++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 42 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index fb1ad22..cdd6273 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -128,43 +128,68 @@ static struct rtnl_link_ops ipip_link_ops __read_mostly;
 
 static int ipip_err(struct sk_buff *skb, u32 info)
 {
-
-/* All the routers (except for Linux) return only
-   8 bytes of packet payload. It means, that precise relaying of
-   ICMP in the real Internet is absolutely infeasible.
- */
+	/* All the routers (except for Linux) return only
+	 * 8 bytes of packet payload. It means, that precise relaying of
+	 * ICMP in the real Internet is absolutely infeasible.
+	 */
 	struct net *net = dev_net(skb->dev);
 	struct ip_tunnel_net *itn = net_generic(net, ipip_net_id);
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
-	struct ip_tunnel *t;
-	int err;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
+	struct ip_tunnel *t;
+	int err = 0;
+
+	switch (type) {
+	case ICMP_DEST_UNREACH:
+		switch (code) {
+		case ICMP_SR_FAILED:
+			/* Impossible event. */
+			goto out;
+		default:
+			/* All others are translated to HOST_UNREACH.
+			 * rfc2003 contains "deep thoughts" about NET_UNREACH,
+			 * I believe they are just ether pollution. --ANK
+			 */
+			break;
+		}
+		break;
+
+	case ICMP_TIME_EXCEEDED:
+		if (code != ICMP_EXC_TTL)
+			goto out;
+		break;
+
+	case ICMP_REDIRECT:
+		break;
+
+	default:
+		goto out;
+	}
 
-	err = -ENOENT;
 	t = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 			     iph->daddr, iph->saddr, 0);
-	if (!t)
+	if (!t) {
+		err = -ENOENT;
 		goto out;
+	}
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->parms.link, 0, iph->protocol, 0);
-		err = 0;
+		ipv4_update_pmtu(skb, net, info, t->parms.link, 0,
+				 iph->protocol, 0);
 		goto out;
 	}
 
 	if (type == ICMP_REDIRECT) {
-		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
-			      iph->protocol, 0);
-		err = 0;
+		ipv4_redirect(skb, net, t->parms.link, 0, iph->protocol, 0);
 		goto out;
 	}
 
-	if (t->parms.iph.daddr == 0)
+	if (t->parms.iph.daddr == 0) {
+		err = -ENOENT;
 		goto out;
+	}
 
-	err = 0;
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;
 
-- 
2.1.0
