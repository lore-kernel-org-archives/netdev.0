From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2] ipv4: Restart rt_intern_hash after emergency rebuild
Date: Wed, 24 Mar 2010 20:43:27 +0300
Message-ID: <4BAA4F3F.70703@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43827 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932375Ab0CXRnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 13:43:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The the rebuild changes the genid which in turn is used at the
hash calculation. Thus if we don't restart and go on with the
inserting the rt will happen in wrong chain.

This doesn't seem critical to me, since the proper rt entry will 
be hashed at next skb.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/route.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 28c1c2f..bbce53e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1097,7 +1097,7 @@ static int slow_chain_length(const struct rtable *head)
 }
 
 static int rt_intern_hash(unsigned hash, struct rtable *rt,
-			  struct rtable **rp, struct sk_buff *skb)
+			  struct rtable **rp, struct sk_buff *skb, int in)
 {
 	struct rtable	*rth, **rthp;
 	unsigned long	now;
@@ -1217,6 +1217,12 @@ restart:
 					rt->u.dst.dev->name, num);
 			}
 			rt_emergency_hash_rebuild(net);
+			spin_unlock_bh(rt_hash_lock_addr(hash));
+
+			hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
+					in ? rt->fl.iif : rt->fl.oif,
+					rt_genid(net));
+			goto restart;
 		}
 	}
 
@@ -1477,7 +1483,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 							&netevent);
 
 				rt_del(hash, rth);
-				if (!rt_intern_hash(hash, rt, &rt, NULL))
+				if (!rt_intern_hash(hash, rt, &rt, NULL, 0))
 					ip_rt_put(rt);
 				goto do_next;
 			}
@@ -1930,7 +1936,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	in_dev_put(in_dev);
 	hash = rt_hash(daddr, saddr, dev->ifindex, rt_genid(dev_net(dev)));
-	return rt_intern_hash(hash, rth, NULL, skb);
+	return rt_intern_hash(hash, rth, NULL, skb, 1);
 
 e_nobufs:
 	in_dev_put(in_dev);
@@ -2097,7 +2103,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	/* put it into the cache */
 	hash = rt_hash(daddr, saddr, fl->iif,
 		       rt_genid(dev_net(rth->u.dst.dev)));
-	return rt_intern_hash(hash, rth, NULL, skb);
+	return rt_intern_hash(hash, rth, NULL, skb, 1);
 }
 
 /*
@@ -2254,7 +2260,7 @@ local_input:
 	}
 	rth->rt_type	= res.type;
 	hash = rt_hash(daddr, saddr, fl.iif, rt_genid(net));
-	err = rt_intern_hash(hash, rth, NULL, skb);
+	err = rt_intern_hash(hash, rth, NULL, skb, 1);
 	goto done;
 
 no_route:
@@ -2501,7 +2507,7 @@ static int ip_mkroute_output(struct rtable **rp,
 	if (err == 0) {
 		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->oif,
 			       rt_genid(dev_net(dev_out)));
-		err = rt_intern_hash(hash, rth, rp, NULL);
+		err = rt_intern_hash(hash, rth, rp, NULL, 0);
 	}
 
 	return err;
