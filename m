From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 3/3] xfrm4: Invalidate all ipv4 routes on IPsec pmtu
 events
Date: Fri, 18 Jan 2013 09:16:01 +0100
Message-ID: <20130118081601.GE24987@secunet.com>
References: <50D1BCC0.2000208@oktetlabs.ru>
 <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com>
 <50D1CECE.7090706@oktetlabs.ru>
 <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com>
 <20121220073445.GM18940@secunet.com>
 <50D2F4E5.4050904@oktetlabs.ru>
 <20121220123535.GN18940@secunet.com>
 <20121221102253.GO18940@secunet.com>
 <50F3C153.9030204@oktetlabs.ru>
 <20130118081145.GB24987@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44949 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab3ARIQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 03:16:04 -0500
Content-Disposition: inline
In-Reply-To: <20130118081145.GB24987@secunet.com>
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
index a0d8392..612ecc9 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -413,9 +413,12 @@ static void ah4_err(struct sk_buff *skb, u32 info)
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
index b61e9de..2d32ae5 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -499,9 +499,12 @@ static void esp4_err(struct sk_buff *skb, u32 info)
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
