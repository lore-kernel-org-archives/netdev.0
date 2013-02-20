From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] ipv6: Split from and expires field in dst_entry out
 of union [net-next]
Date: Tue, 19 Feb 2013 23:00:10 -0800
Message-ID: <1361343610.19353.177.camel@edumazet-glaptop>
References: <1361231718.19353.117.camel@edumazet-glaptop>
	  <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>
	  <1361308665.19353.161.camel@edumazet-glaptop>
	  <20130219214934.GD31871@hmsreliant.think-freely.org>
	 <1361310958.19353.164.camel@edumazet-glaptop>
	 <51246E43.5010202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, Jiri Bohac <jbohac@suse.cz>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:47700 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756456Ab3BTHAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 02:00:14 -0500
Received: by mail-da0-f49.google.com with SMTP id t11so3363265daj.22
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 23:00:13 -0800 (PST)
In-Reply-To: <51246E43.5010202@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-20 at 14:33 +0800, Gao feng wrote:

> How can we?
> one usage of rt6_update_expires and rt6_set_expires
> is changing rt6->dst.from to rt6->dst.expires, we should release the
> already holded reference of rt6->dst.from.
> 

Just don't union the two fields, as Neil did.

Setting the dst.expires value should not change dst.from at all.

Something like the (untested, because its too late here) patch ?

 include/net/dst.h     |   11 +++++------
 include/net/ip6_fib.h |   21 +++------------------
 net/ipv6/route.c      |    3 +--
 3 files changed, 9 insertions(+), 26 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 3da47e0..3f31a48 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -36,13 +36,12 @@ struct dst_entry {
 	struct net_device       *dev;
 	struct  dst_ops	        *ops;
 	unsigned long		_metrics;
-	union {
-		unsigned long           expires;
-		/* point to where the dst_entry copied from */
-		struct dst_entry        *from;
-	};
+	unsigned long           expires;
+
+	/* point to where the dst_entry copied from */
+	struct dst_entry        *from;
+
 	struct dst_entry	*path;
-	void			*__pad0;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 6919a50..731b35c 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -164,33 +164,19 @@ static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 
 static inline void rt6_clean_expires(struct rt6_info *rt)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
-		dst_release(rt->dst.from);
-
 	rt->rt6i_flags &= ~RTF_EXPIRES;
-	rt->dst.from = NULL;
+	rt->dst.expires = 0;
 }
 
 static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
-		dst_release(rt->dst.from);
-
 	rt->rt6i_flags |= RTF_EXPIRES;
 	rt->dst.expires = expires;
 }
 
 static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
-		if (rt->dst.from)
-			dst_release(rt->dst.from);
-		/* dst_set_expires relies on expires == 0 
-		 * if it has not been set previously.
-		 */
-		rt->dst.expires = 0;
-	}
-
+	rt->dst.expires = 0;
 	dst_set_expires(&rt->dst, timeout);
 	rt->rt6i_flags |= RTF_EXPIRES;
 }
@@ -199,13 +185,12 @@ static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 {
 	struct dst_entry *new = (struct dst_entry *) from;
 
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from) {
+	if (rt->dst.from) {
 		if (new == rt->dst.from)
 			return;
 		dst_release(rt->dst.from);
 	}
 
-	rt->rt6i_flags &= ~RTF_EXPIRES;
 	rt->dst.from = new;
 	dst_hold(new);
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 515bb51..6874b6e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -296,8 +296,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 		in6_dev_put(idev);
 	}
 
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && dst->from)
-		dst_release(dst->from);
+	dst_release(dst->from);
 
 	if (rt6_has_peer(rt)) {
 		struct inet_peer *peer = rt6_peer_ptr(rt);
