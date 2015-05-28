From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/7] ip_vti/ip6_vti: Do not touch skb->mark on xmit
Date: Thu, 28 May 2015 09:28:08 +0200
Message-ID: <1432798090-20657-6-git-send-email-steffen.klassert@secunet.com>
References: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51251 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515AbbE1H2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 03:28:32 -0400
In-Reply-To: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

Instead of modifying skb->mark we can simply modify the flowi_mark that is
generated as a result of the xfrm_decode_session.  By doing this we don't
need to actually touch the skb->mark and it can be preserved as it passes
out through the tunnel.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c  | 5 +++--
 net/ipv6/ip6_vti.c | 4 +++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 9f7269f..4c318e1 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -216,8 +216,6 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	memset(&fl, 0, sizeof(fl));
 
-	skb->mark = be32_to_cpu(tunnel->parms.o_key);
-
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		xfrm_decode_session(skb, &fl, AF_INET);
@@ -233,6 +231,9 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
+	/* override mark with tunnel output key */
+	fl.flowi_mark = be32_to_cpu(tunnel->parms.o_key);
+
 	return vti_xmit(skb, dev, &fl);
 }
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ed9d681..104de4d 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -495,7 +495,6 @@ vti6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	int ret;
 
 	memset(&fl, 0, sizeof(fl));
-	skb->mark = be32_to_cpu(t->parms.o_key);
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IPV6):
@@ -516,6 +515,9 @@ vti6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_err;
 	}
 
+	/* override mark with tunnel output key */
+	fl.flowi_mark = be32_to_cpu(t->parms.o_key);
+
 	ret = vti6_xmit(skb, dev, &fl);
 	if (ret < 0)
 		goto tx_err;
-- 
1.9.1
