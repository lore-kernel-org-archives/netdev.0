From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] bridge: Pseudo-header required for the checksum of ICMPv6
Date: Wed, 24 Aug 2011 16:54:33 +0800
Message-ID: <4E54BC49.6090506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wcang@sfc.wide.ad.jp, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23550 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756659Ab1HXIyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 04:54:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checksum of ICMPv6 is not properly computed because the pseudo header is not used.
Thus, the MLD packet gets dropped by the bridge.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
Reported-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>

---
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d85ca7..22d2d1a 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1520,16 +1520,23 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		err = pskb_trim_rcsum(skb2, len);
 		if (err)
 			goto out;
+		err = -EINVAL;
 	}
 
+	ip6h = ipv6_hdr(skb2);
+
 	switch (skb2->ip_summed) {
 	case CHECKSUM_COMPLETE:
-		if (!csum_fold(skb2->csum))
+		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr, skb2->len,
+					IPPROTO_ICMPV6, skb2->csum))
 			break;
 		/*FALLTHROUGH*/
 	case CHECKSUM_NONE:
-		skb2->csum = 0;
-		if (skb_checksum_complete(skb2))
+		skb2->csum = ~csum_unfold(csum_ipv6_magic(&ip6h->saddr,
+							&ip6h->daddr,
+							skb2->len,
+							IPPROTO_ICMPV6, 0));
+		if (__skb_checksum_complete(skb2))
 			goto out;
 	}
 
