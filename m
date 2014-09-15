From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [BUG REPORT]  Unencrypted packets after SNAT, allthough
 IPSEC-Policies are present
Date: Mon, 15 Sep 2014 10:09:41 +0200
Message-ID: <20140915080941.GP6390@secunet.com>
References: <541089DD.6060307@sirrix.com>
 <20140911115401.GL6390@secunet.com>
 <54119F75.8090305@sirrix.com>
 <20140912093143.GN6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<herbert@gondor.apana.org.au>
To: Konstantinos Kolelis <k.kolelis@sirrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50553 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575AbaIOIJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 04:09:48 -0400
Content-Disposition: inline
In-Reply-To: <20140912093143.GN6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 11:31:43AM +0200, Steffen Klassert wrote:
> On Thu, Sep 11, 2014 at 03:11:17PM +0200, Konstantinos Kolelis wrote:
> > Am 11.09.2014 13:54, schrieb Steffen Klassert:
> > > On Wed, Sep 10, 2014 at 07:26:53PM +0200, Konstantinos Kolelis wrote:
> > >> Hi all,
> > >>
> > >> i' ve observed a problem with xfrm lookups, SNAT, blackhole route and
> > >> missing SAs.
> > >> The problem occures with all Kernels above 3.6.x and might has to do
> > >> with the changes in
> > >> ip4_blackhole_route() function in net/route.c.
> > > 
> > > Thanks for the report!
> > > 
> > > Is kernel v3.6 the first kernel with this issue? It seems that
> > > we have this problem already longer, at least if my analysis
> > > is correct.
> > > 
> > 
> > It worked until Kernel 3.4.103, i did not check with v3.5 though.
> 
> Hm. I thought the problem exists already for longer, so I did
> a bisect. To my surprise, the following commit introduced the bug:
> 
> commit a263b3093641fb1ec377582c90986a7fd0625184
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Jul 2 02:02:15 2012 -0700
> 
>     ipv4: Make neigh lookups directly in output packet path.
>     
>     Do not use the dst cached neigh, we'll be getting rid of that.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> But this is not really the offending commit. As I said, the problem
> was introduced by git commit 2774c131 ("xfrm: Handle blackhole route
> creation via afinfo.") because the assumption that dst_output() is
> called always after a  xfrm_lookup() is wrong. On postrouting nat,
> dst_output() is not called for blackholed packets. But we were in luck
> because ip_finish_output2() tried to use a dst cached neigh entry.
> On blackhole routes we did not cache neigh entries, so the packets
> were dropped in the last moment. The above commit finally opened the
> door by replacing the usage of a dst cached neigh entry by a direct
> lookup.
> 
> So we need to ensure that a blackhole route is generated only by the
> route lookup functions.

Can you please try the patch below? This should fix the default case
where xfrm_larval_drop is true. The xfrm_larval_drop false case needs
a separate fix.

Subject: [PATCH] xfrm: Generate blackhole routes only from route lookup
 functions

Currently we genarate a blackhole route route whenever we have
matching policies but can not resolve the states. Here we assume
that dst_output() is called to kill the balckholed packets.
Unfortunately this assumption is not true in all cases, so
it is possible that these packets leave the system unwanted.

We fix this by generating blackhole routes only from the
route lookup functions, here we can guarantee a call to
dst_output() afterwards.

Fixes: 2774c131b1d ("xfrm: Handle blackhole route creation via afinfo.")
Reported-by: Konstantinos Kolelis <k.kolelis@sirrix.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      | 15 ++++++++++++++-
 net/ipv4/route.c       |  6 +++---
 net/ipv6/ip6_output.c  |  4 ++--
 net/xfrm/xfrm_policy.c | 16 +++++++++++++++-
 4 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 71c60f4..fa11c90 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -490,7 +490,16 @@ static inline struct dst_entry *xfrm_lookup(struct net *net,
 					    int flags)
 {
 	return dst_orig;
-} 
+}
+
+static inline struct dst_entry *xfrm_lookup_route(struct net *net,
+						  struct dst_entry *dst_orig,
+						  const struct flowi *fl,
+						  struct sock *sk,
+						  int flags)
+{
+	return dst_orig;
+}
 
 static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
 {
@@ -502,6 +511,10 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			      const struct flowi *fl, struct sock *sk,
 			      int flags);
 
+struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
+				    const struct flowi *fl, struct sock *sk,
+				    int flags);
+
 /* skb attached with this dst needs transformation if dst->xfrm is valid */
 static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
 {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eaa4b00..173e7ea 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2265,9 +2265,9 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 		return rt;
 
 	if (flp4->flowi4_proto)
-		rt = (struct rtable *) xfrm_lookup(net, &rt->dst,
-						   flowi4_to_flowi(flp4),
-						   sk, 0);
+		rt = (struct rtable *)xfrm_lookup_route(net, &rt->dst,
+							flowi4_to_flowi(flp4),
+							sk, 0);
 
 	return rt;
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 315a55d..0a3448b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1009,7 +1009,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 	if (final_dst)
 		fl6->daddr = *final_dst;
 
-	return xfrm_lookup(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
+	return xfrm_lookup_route(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
 
@@ -1041,7 +1041,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 	if (final_dst)
 		fl6->daddr = *final_dst;
 
-	return xfrm_lookup(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
+	return xfrm_lookup_route(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index beeed60..e041822 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2138,7 +2138,8 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			xfrm_pols_put(pols, drop_pols);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 
-			return make_blackhole(net, family, dst_orig);
+			err = -EREMOTE;
+			goto error;
 		}
 
 		err = -EAGAIN;
@@ -2195,6 +2196,19 @@ dropdst:
 }
 EXPORT_SYMBOL(xfrm_lookup);
 
+struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
+				    const struct flowi *fl,
+				    struct sock *sk, int flags)
+{
+	struct dst_entry *dst = xfrm_lookup(net, dst_orig, fl, sk, flags);
+
+	if (IS_ERR(dst) && PTR_ERR(dst) == -EREMOTE)
+		return make_blackhole(net, dst_orig->ops->family, dst_orig);
+
+	return dst;
+}
+EXPORT_SYMBOL(xfrm_lookup_route);
+
 static inline int
 xfrm_secpath_reject(int idx, struct sk_buff *skb, const struct flowi *fl)
 {
-- 
1.9.1
