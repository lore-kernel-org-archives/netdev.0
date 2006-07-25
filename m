From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ip multicast route bug fix (rev2)
Date: Tue, 25 Jul 2006 08:42:38 -0700
Message-ID: <20060725084238.32bcc50f@localhost.localdomain>
References: <20060719145716.4cb9e7e2@localhost.localdomain>
	<E1G5Ht7-00060p-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62170 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932451AbWGYQXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 12:23:40 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
In-Reply-To: <E1G5Ht7-00060p-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IP multicast route code was reusing an skb which causes
use after free and double free.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/ipv4/ipmr.c |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ba33f86..f5d3d96 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1580,6 +1580,7 @@ int ipmr_get_route(struct sk_buff *skb, 
 	cache = ipmr_cache_find(rt->rt_src, rt->rt_dst);
 
 	if (cache==NULL) {
+		struct sk_buff *skb2;
 		struct net_device *dev;
 		int vif;
 
@@ -1593,12 +1594,21 @@ int ipmr_get_route(struct sk_buff *skb, 
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
+		skb2 = alloc_skb(sizeof(struct iphdr) + sizeof(struct nlmsghdr),
+				 GFP_ATOMIC);
+		if (!skb2) {
+			read_unlock(&mrt_lock);
+			return -ENOMEM;
+		}
+
+		memset(skb2->data, 0, sizeof(struct iphdr));
+		skb2->nh.raw = skb2->data;
+		skb2->nh.iph->ihl = sizeof(struct iphdr)>>2;
+		skb2->nh.iph->saddr = rt->rt_src;
+		skb2->nh.iph->daddr = rt->rt_dst;
+
+		err = ipmr_cache_unresolved(vif, skb2);
 		read_unlock(&mrt_lock);
 		return err;
 	}
-- 
1.4.0

