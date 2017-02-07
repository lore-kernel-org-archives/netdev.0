From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 5/6] xfrm: policy: remove xfrm_policy_put_afinfo
Date: Tue,  7 Feb 2017 15:00:18 +0100
Message-ID: <20170207140019.20269-6-fw@strlen.de>
References: <20170207140019.20269-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56652 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754499AbdBGOCY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:02:24 -0500
In-Reply-To: <20170207140019.20269-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alternative is to keep it an make the (unused) afinfo arg const to avoid
the compiler warnings once the afinfo structs get constified.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7698785876d7..80ef0dcf0e29 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -116,11 +116,6 @@ static const struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short fa
 	return afinfo;
 }
 
-static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
-{
-	rcu_read_unlock();
-}
-
 static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
 						  int tos, int oif,
 						  const xfrm_address_t *saddr,
@@ -136,7 +131,7 @@ static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
 
 	dst = afinfo->dst_lookup(net, tos, oif, saddr, daddr);
 
-	xfrm_policy_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	return dst;
 }
@@ -1436,7 +1431,7 @@ xfrm_get_saddr(struct net *net, int oif, xfrm_address_t *local,
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
 	err = afinfo->get_saddr(net, oif, local, remote);
-	xfrm_policy_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -1546,7 +1541,7 @@ static int xfrm_get_tos(const struct flowi *fl, int family)
 	afinfo = xfrm_policy_get_afinfo(family);
 	tos = afinfo ? afinfo->get_tos(fl) : 0;
 
-	xfrm_policy_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	return tos;
 }
@@ -1632,7 +1627,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	} else
 		xdst = ERR_PTR(-ENOBUFS);
 
-	xfrm_policy_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	return xdst;
 }
@@ -1649,7 +1644,7 @@ static inline int xfrm_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 
 	err = afinfo->init_path(path, dst, nfheader_len);
 
-	xfrm_policy_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	return err;
 }
@@ -1666,7 +1661,7 @@ static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 
 	err = afinfo->fill_dst(xdst, dev, fl);
 
-	xfrm_policy_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	return err;
 }
@@ -2215,7 +2210,7 @@ static struct dst_entry *make_blackhole(struct net *net, u16 family,
 	} else {
 		ret = afinfo->blackhole_route(net, dst_orig);
 	}
-	xfrm_policy_put_afinfo(afinfo);
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -2465,7 +2460,7 @@ int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
 
 	afinfo->decode_session(skb, fl, reverse);
 	err = security_xfrm_decode_session(skb, &fl->flowi_secid);
-	xfrm_policy_put_afinfo(afinfo);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(__xfrm_decode_session);
-- 
2.10.2
