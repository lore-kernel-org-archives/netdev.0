From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 11/13] vti6: Support inter address family tunneling.
Date: Tue, 18 Mar 2014 08:21:36 +0100
Message-ID: <1395127298-24083-12-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53283 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544AbaCRHV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:58 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch we can tunnel ipv4 traffic via a vti6
interface. A vti6 interface can now have an ipv4 address
and ipv4 traffic can be routed via a vti6 interface.
The resulting traffic is xfrm transformed and tunneled
through ipv6 if matching IPsec policies and states are
present.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c |   49 ++++++++++++++++++++++++++++++++++---------------
 1 file changed, 34 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 226854a..8d189aa 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -380,30 +380,22 @@ vti6_addr_conflict(const struct ip6_tnl *t, const struct ipv6hdr *hdr)
  * vti6_xmit - send a packet
  *   @skb: the outgoing socket buffer
  *   @dev: the outgoing tunnel device
+ *   @fl: the flow informations for the xfrm_lookup
  **/
-static int vti6_xmit(struct sk_buff *skb, struct net_device *dev)
+static int
+vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net_device_stats *stats = &t->dev->stats;
 	struct dst_entry *dst = skb_dst(skb);
-	struct flowi fl;
-	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	struct net_device *tdev;
 	int err = -1;
 
-	if ((t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) ||
-	    !ip6_tnl_xmit_ctl(t) || vti6_addr_conflict(t, ipv6h))
-		return err;
-
-	memset(&fl, 0, sizeof(fl));
-	skb->mark = be32_to_cpu(t->parms.o_key);
-	xfrm_decode_session(skb, &fl, AF_INET6);
-
 	if (!dst)
 		goto tx_err_link_failure;
 
 	dst_hold(dst);
-	dst = xfrm_lookup(t->net, dst, &fl, NULL, 0);
+	dst = xfrm_lookup(t->net, dst, fl, NULL, 0);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		dst = NULL;
@@ -422,12 +414,22 @@ static int vti6_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_err_dst_release;
 	}
 
-	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
 	skb_scrub_packet(skb, !net_eq(t->net, dev_net(dev)));
 	skb_dst_set(skb, dst);
 	skb->dev = skb_dst(skb)->dev;
 
-	ip6tunnel_xmit(skb, dev);
+	err = dst_output(skb);
+	if (net_xmit_eval(err) == 0) {
+		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
+
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += skb->len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		stats->tx_errors++;
+		stats->tx_aborted_errors++;
+	}
 
 	return 0;
 tx_err_link_failure:
@@ -443,16 +445,33 @@ vti6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net_device_stats *stats = &t->dev->stats;
+	struct ipv6hdr *ipv6h;
+	struct flowi fl;
 	int ret;
 
+	memset(&fl, 0, sizeof(fl));
+	skb->mark = be32_to_cpu(t->parms.o_key);
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IPV6):
-		ret = vti6_xmit(skb, dev);
+		ipv6h = ipv6_hdr(skb);
+
+		if ((t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) ||
+		    !ip6_tnl_xmit_ctl(t) || vti6_addr_conflict(t, ipv6h))
+			goto tx_err;
+
+		xfrm_decode_session(skb, &fl, AF_INET6);
+		memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
+		break;
+	case htons(ETH_P_IP):
+		xfrm_decode_session(skb, &fl, AF_INET);
+		memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 		break;
 	default:
 		goto tx_err;
 	}
 
+	ret = vti6_xmit(skb, dev, &fl);
 	if (ret < 0)
 		goto tx_err;
 
-- 
1.7.9.5
