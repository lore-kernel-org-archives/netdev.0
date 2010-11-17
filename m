From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] igmp: refine skb allocations
Date: Wed, 17 Nov 2010 07:36:42 +0100
Message-ID: <1289975802.2732.195.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:55047 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933259Ab0KQGgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 01:36:48 -0500
Received: by wwb13 with SMTP id 13so201wwb.1
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 22:36:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IGMP allocates MTU sized skbs. This may fail for large MTU (order-2
allocations), so add a fallback to try lower sizes.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/igmp.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a1bf2f4..caff2fc 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -300,6 +300,8 @@ igmp_scount(struct ip_mc_list *pmc, int type, int gdeleted, int sdeleted)
 	return scount;
 }
 
+#define igmp_skb_size(skb) (*(unsigned int *)((skb)->cb))
+
 static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 {
 	struct sk_buff *skb;
@@ -308,9 +310,16 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	struct igmpv3_report *pig;
 	struct net *net = dev_net(dev);
 
-	skb = alloc_skb(size + LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
-	if (skb == NULL)
-		return NULL;
+	while (1) {
+		skb = alloc_skb(size + LL_ALLOCATED_SPACE(dev),
+				GFP_ATOMIC | __GFP_NOWARN);
+		if (skb)
+			break;
+		size >>= 1;
+		if (size < 256)
+			return NULL;
+	}
+	igmp_skb_size(skb) = size;
 
 	{
 		struct flowi fl = { .oif = dev->ifindex,
@@ -400,7 +409,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ip_mc_list *pmc,
 	return skb;
 }
 
-#define AVAILABLE(skb) ((skb) ? ((skb)->dev ? (skb)->dev->mtu - (skb)->len : \
+#define AVAILABLE(skb) ((skb) ? ((skb)->dev ? igmp_skb_size(skb) - (skb)->len : \
 	skb_tailroom(skb)) : 0)
 
 static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,


