From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] vti: Add pmtu handling to vti_xmit.
Date: Wed, 4 May 2016 07:40:54 +0200
Message-ID: <1462340454-27922-4-git-send-email-steffen.klassert@secunet.com>
References: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56700 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383AbcEDFlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 01:41:11 -0400
In-Reply-To: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently rely on the PMTU discovery of xfrm.
However if a packet is locally sent, the PMTU mechanism
of xfrm tries to do local socket notification what
might not work for applications like ping that don't
check for this. So add pmtu handling to vti_xmit to
report MTU changes immediately.

Reported-by: Mark McKinstry <Mark.McKinstry@alliedtelesis.co.nz>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 5cf10b7..a917903 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -156,6 +156,7 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *tdev;	/* Device to other host */
 	int err;
+	int mtu;
 
 	if (!dst) {
 		dev->stats.tx_carrier_errors++;
@@ -192,6 +193,23 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 			tunnel->err_count = 0;
 	}
 
+	mtu = dst_mtu(dst);
+	if (skb->len > mtu) {
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
+		if (skb->protocol == htons(ETH_P_IP)) {
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+				  htonl(mtu));
+		} else {
+			if (mtu < IPV6_MIN_MTU)
+				mtu = IPV6_MIN_MTU;
+
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		}
+
+		dst_release(dst);
+		goto tx_error;
+	}
+
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(dev)));
 	skb_dst_set(skb, dst);
 	skb->dev = skb_dst(skb)->dev;
-- 
1.9.1
