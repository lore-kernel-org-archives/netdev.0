From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/5] xfrm4: Invalidate all ipv4 routes on IPsec pmtu events
Date: Tue, 22 Jan 2013 10:06:36 +0100
Message-ID: <1358845596-2066-6-git-send-email-steffen.klassert@secunet.com>
References: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33540 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064Ab3AVJHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 04:07:20 -0500
In-Reply-To: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On IPsec pmtu events we can't access the transport headers of
the original packet, so we can't find the socket that sent
the packet. The only chance to notify the socket about the
pmtu change is to force a relookup for all routes. This
patch implenents this for the IPsec protocols.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ah4.c    |    7 +++++--
 net/ipv4/esp4.c   |    7 +++++--
 net/ipv4/ipcomp.c |    7 +++++--
 3 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index a154d0a..a69b4e4 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -420,9 +420,12 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 	if (!x)
 		return;
 
-	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
+	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH) {
+		atomic_inc(&flow_cache_genid);
+		rt_genid_bump(net);
+
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_AH, 0);
-	else
+	} else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_AH, 0);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index fd26ff4..3b4f0cd 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -502,9 +502,12 @@ static void esp4_err(struct sk_buff *skb, u32 info)
 	if (!x)
 		return;
 
-	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
+	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH) {
+		atomic_inc(&flow_cache_genid);
+		rt_genid_bump(net);
+
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_ESP, 0);
-	else
+	} else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_ESP, 0);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index d3ab47e..9a46dae 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -47,9 +47,12 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 	if (!x)
 		return;
 
-	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
+	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH) {
+		atomic_inc(&flow_cache_genid);
+		rt_genid_bump(net);
+
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_COMP, 0);
-	else
+	} else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_COMP, 0);
 	xfrm_state_put(x);
 }
-- 
1.7.9.5
