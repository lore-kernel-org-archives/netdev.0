From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] RPS: support 802.1q and pppoe session
Date: Thu, 25 Mar 2010 12:30:33 +0800
Message-ID: <4BAAE6E9.6030103@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, xiaosuo <xiaosuo@gmail.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40344 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842Ab0CYEaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 00:30:52 -0400
Received: by gyg8 with SMTP id 8so3993923gyg.19
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 21:30:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

support 802.1q and pppoe session

Support 802.1q and pppoe session, and these two protocols can get the
benefit from RPS.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/core/dev.c | 38 ++++++++++++++++++++++++++++++--------
1 file changed, 30 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a03aab4..647ecc4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -130,6 +130,10 @@
 #include <linux/random.h>
 #include <trace/events/napi.h>
 
+#ifdef CONFIG_SMP
+#include <linux/if_pppox.h>
+#endif
+
 #include "net-sysfs.h"
 
 /* Instead of increasing this, you should create a hash table. */
@@ -2190,7 +2194,8 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 	struct rps_map *map;
 	int cpu = -1;
 	u8 ip_proto;
-	u32 addr1, addr2, ports, ihl;
+	__be16 protocol;
+	u32 addr1, addr2, ports, offset;
 
 	rcu_read_lock();
 
@@ -2214,26 +2219,43 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 	if (skb->rxhash)
 		goto got_hash; /* Skip hash computation on packet header */
 
-	switch (skb->protocol) {
+	offset = 0;
+	protocol = skb->protocol;
+nest:
+	switch (protocol) {
+	case __constant_htons(ETH_P_8021Q):
+		if (!pskb_may_pull(skb, offset + VLAN_HLEN))
+			goto done;
+		protocol = ((struct vlan_hdr*)(skb->data +
+				offset))->h_vlan_encapsulated_proto;
+		offset += VLAN_HLEN;
+		goto nest;
+	case __constant_htons(ETH_P_PPP_SES):
+		if (!pskb_may_pull(skb, offset + PPPOE_SES_HLEN))
+			goto done;
+		protocol = *((__be16 *)(skb->data + offset +
+				sizeof(struct pppoe_hdr)));
+		offset += PPPOE_SES_HLEN;
+		goto nest;
 	case __constant_htons(ETH_P_IP):
-		if (!pskb_may_pull(skb, sizeof(*ip)))
+		if (!pskb_may_pull(skb, offset + sizeof(*ip)))
 			goto done;
 
 		ip = (struct iphdr *) skb->data;
 		ip_proto = ip->protocol;
 		addr1 = ip->saddr;
 		addr2 = ip->daddr;
-		ihl = ip->ihl;
+		offset += ip->ihl << 2;
 		break;
 	case __constant_htons(ETH_P_IPV6):
-		if (!pskb_may_pull(skb, sizeof(*ip6)))
+		if (!pskb_may_pull(skb, offset + sizeof(*ip6)))
 			goto done;
 
 		ip6 = (struct ipv6hdr *) skb->data;
 		ip_proto = ip6->nexthdr;
 		addr1 = ip6->saddr.s6_addr32[3];
 		addr2 = ip6->daddr.s6_addr32[3];
-		ihl = (40 >> 2);
+		offset += 40;
 		break;
 	default:
 		goto done;
@@ -2247,8 +2269,8 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 	case IPPROTO_AH:
 	case IPPROTO_SCTP:
 	case IPPROTO_UDPLITE:
-		if (pskb_may_pull(skb, (ihl * 4) + 4))
-			ports = *((u32 *) (skb->data + (ihl * 4)));
+		if (pskb_may_pull(skb, offset + 4))
+			ports = *((u32 *) (skb->data + offset));
 		break;
 
 	default:


