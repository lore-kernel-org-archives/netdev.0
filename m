From: Changli Gao <xiaosuo@gmail.com>
Subject: net: rps: support 802.1Q
Date: Fri, 19 Aug 2011 13:05:53 +0800
Message-ID: <1313730353-25379-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:40317 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab1HSFGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 01:06:45 -0400
Received: by pzk37 with SMTP id 37so4216128pzk.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 22:06:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the 802.1Q packets, if the NIC doesn't support hw-accel-vlan-rx, RPS
won't inspect the internal 4 tuples to generate skb->rxhash, so this kind
of traffic can't get any benefit from RPS.

This patch adds the support for 802.1Q to RPS.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |    8 ++++++++
 1 file changed, 8 insertions(+)
diff --git a/net/core/dev.c b/net/core/dev.c
index ead0366..be7ee50 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2529,6 +2529,7 @@ void __skb_get_rxhash(struct sk_buff *skb)
 	int nhoff, hash = 0, poff;
 	const struct ipv6hdr *ip6;
 	const struct iphdr *ip;
+	const struct vlan_hdr *vlan;
 	u8 ip_proto;
 	u32 addr1, addr2;
 	u16 proto;
@@ -2565,6 +2566,13 @@ again:
 		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
 		nhoff += 40;
 		break;
+	case __constant_htons(ETH_P_8021Q):
+		if (!pskb_may_pull(skb, sizeof(*vlan) + nhoff))
+			goto done;
+		vlan = (const struct vlan_hdr *) (skb->data + nhoff);
+		proto = vlan->h_vlan_encapsulated_proto;
+		nhoff += sizeof(*vlan);
+		goto again;
 	default:
 		goto done;
 	}
