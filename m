From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 06/13] xfrm: policy: remove xfrm_policy_put_afinfo
Date: Thu, 16 Feb 2017 13:18:40 +0100
Message-ID: <1487247527-17925-7-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49306 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754601AbdBPMS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:57 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Alternative is to keep it an make the (unused) afinfo arg const to avoid
the compiler warnings once the afinfo structs get constified.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7698785..80ef0dc 100644
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
@@ -1436,7 +1431,7 @@ int __xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk)
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
1.9.1
