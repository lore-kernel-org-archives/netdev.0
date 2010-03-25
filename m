From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2] ipv4: Restart rt_intern_hash after emergency rebuild
 (v2)
Date: Thu, 25 Mar 2010 10:51:22 +0300
Message-ID: <4BAB15FA.20108@openvz.org>
References: <4BAA4F3F.70703@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31609 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab0CYHvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Mar 2010 03:51:39 -0400
In-Reply-To: <4BAA4F3F.70703@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The the rebuild changes the genid which in turn is used at
the hash calculation. Thus if we don't restart and go on with
inserting the rt will happen in wrong chain.

(Fixed Neil's comment about the index passed into the rt_intern_hash)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/route.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 28c1c2f..54ddc84 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1097,7 +1097,7 @@ static int slow_chain_length(const struct rtable *head)
 }
 
 static int rt_intern_hash(unsigned hash, struct rtable *rt,
-			  struct rtable **rp, struct sk_buff *skb)
+			  struct rtable **rp, struct sk_buff *skb, int ifindex)
 {
 	struct rtable	*rth, **rthp;
 	unsigned long	now;
@@ -1217,6 +1217,11 @@ restart:
 					rt->u.dst.dev->name, num);
 			}
 			rt_emergency_hash_rebuild(net);
+			spin_unlock_bh(rt_hash_lock_addr(hash));
+
+			hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
+					ifindex, rt_genid(net));
+			goto restart;
 		}
 	}
 
@@ -1477,7 +1482,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 							&netevent);
 
 				rt_del(hash, rth);
-				if (!rt_intern_hash(hash, rt, &rt, NULL))
+				if (!rt_intern_hash(hash, rt, &rt, NULL, rt->fl.oif))
 					ip_rt_put(rt);
 				goto do_next;
 			}
@@ -1930,7 +1935,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	in_dev_put(in_dev);
 	hash = rt_hash(daddr, saddr, dev->ifindex, rt_genid(dev_net(dev)));
-	return rt_intern_hash(hash, rth, NULL, skb);
+	return rt_intern_hash(hash, rth, NULL, skb, dev->ifindex);
 
 e_nobufs:
 	in_dev_put(in_dev);
@@ -2097,7 +2102,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	/* put it into the cache */
 	hash = rt_hash(daddr, saddr, fl->iif,
 		       rt_genid(dev_net(rth->u.dst.dev)));
-	return rt_intern_hash(hash, rth, NULL, skb);
+	return rt_intern_hash(hash, rth, NULL, skb, fl->iif);
 }
 
 /*
@@ -2254,7 +2259,7 @@ local_input:
 	}
 	rth->rt_type	= res.type;
 	hash = rt_hash(daddr, saddr, fl.iif, rt_genid(net));
-	err = rt_intern_hash(hash, rth, NULL, skb);
+	err = rt_intern_hash(hash, rth, NULL, skb, fl.iif);
 	goto done;
 
 no_route:
@@ -2501,7 +2506,7 @@ static int ip_mkroute_output(struct rtable **rp,
 	if (err == 0) {
 		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif,
 			       rt_genid(dev_net(dev_out)));
-		err = rt_intern_hash(hash, rth, rp, NULL);
+		err = rt_intern_hash(hash, rth, rp, NULL, oldflp->oif);
 	}
 
 	return err;
-- 
1.5.5.6

