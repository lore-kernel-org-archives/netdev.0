From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Wed, 26 Jul 2006 01:17:25 +0400
Message-ID: <20060725211725.GA24366@ms2.inr.ac.ru>
References: <20060719145716.4cb9e7e2@localhost.localdomain> <20060725162001.GA15058@ms2.inr.ac.ru> <20060725085528.38b86319@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:16552 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751483AbWGYVSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 17:18:14 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060725085528.38b86319@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Wouldn't it be better to have a consistent interface (skb always freed),
> and clone the skb if needed for deferred processing?

I think you mean this.

Note, it is real skb_clone(), not alloc_skb(). Equeued skb contains
the whole half-prepared netlink message plus room for the rest.
It could be also skb_copy(), if we want to be puristic about mangling
cloned data, but original copy is really not going to be used.  

Alexey


diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9ccacf5..85893ee 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1578,6 +1578,7 @@ int ipmr_get_route(struct sk_buff *skb, 
 	cache = ipmr_cache_find(rt->rt_src, rt->rt_dst);
 
 	if (cache==NULL) {
+		struct sk_buff *skb2;
 		struct net_device *dev;
 		int vif;
 
@@ -1591,12 +1592,18 @@ int ipmr_get_route(struct sk_buff *skb, 
 			read_unlock(&mrt_lock);
 			return -ENODEV;
 		}
-		skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
-		skb->nh.iph->ihl = sizeof(struct iphdr)>>2;
-		skb->nh.iph->saddr = rt->rt_src;
-		skb->nh.iph->daddr = rt->rt_dst;
-		skb->nh.iph->version = 0;
-		err = ipmr_cache_unresolved(vif, skb);
+		skb2 = skb_clone(skb, GFP_ATOMIC);
+		if (!skb2) {
+			read_unlock(&mrt_lock);
+			return -ENOMEM;
+		}
+
+		skb2->nh.raw = skb_push(skb2, sizeof(struct iphdr));
+		skb2->nh.iph->ihl = sizeof(struct iphdr)>>2;
+		skb2->nh.iph->saddr = rt->rt_src;
+		skb2->nh.iph->daddr = rt->rt_dst;
+		skb2->nh.iph->version = 0;
+		err = ipmr_cache_unresolved(vif, skb2);
 		read_unlock(&mrt_lock);
 		return err;
 	}
