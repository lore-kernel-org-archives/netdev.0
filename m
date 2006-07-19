From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ip multicast route bug fix
Date: Wed, 19 Jul 2006 14:57:16 -0700
Message-ID: <20060719145716.4cb9e7e2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43188 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932185AbWGXWiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 18:38:07 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should fix the problem reported in http://bugzilla.kernel.org/show_bug.cgi?id=6186
where the skb is used after freed. The code in IP multicast route.

Code was reusing an skb which could lead to use after free or double free.

Signed-off-by: Stephen Hemminger <shemminger@dxpl.pdx.osdl.net>
---
 net/ipv4/ipmr.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ba33f86..d336104 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1580,6 +1580,7 @@ int ipmr_get_route(struct sk_buff *skb, 
 	cache = ipmr_cache_find(rt->rt_src, rt->rt_dst);
 
 	if (cache==NULL) {
+		struct sk_buff *iskb;
 		struct net_device *dev;
 		int vif;
 
@@ -1593,12 +1594,19 @@ int ipmr_get_route(struct sk_buff *skb, 
 			read_unlock(&mrt_lock);
 			return -ENODEV;
 		}
-		skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
-		skb->nh.iph->ihl = sizeof(struct iphdr)>>2;
-		skb->nh.iph->saddr = rt->rt_src;
-		skb->nh.iph->daddr = rt->rt_dst;
-		skb->nh.iph->version = 0;
-		err = ipmr_cache_unresolved(vif, skb);
+		
+		iskb = alloc_skb(sizeof(struct iphdr), GFP_KERNEL);
+		if (!iskb) {
+			read_unlock(&mrt_lock);
+			return -ENOMEM;
+		}
+		memset(iskb->data, 0, sizeof(struct iphdr));
+		iskb->nh.raw = iskb->data;
+		iskb->nh.iph->ihl = sizeof(struct iphdr)>>2;
+		iskb->nh.iph->saddr = rt->rt_src;
+		iskb->nh.iph->daddr = rt->rt_dst;
+
+		err = ipmr_cache_unresolved(vif, iskb);
 		read_unlock(&mrt_lock);
 		return err;
 	}
-- 
1.4.0

