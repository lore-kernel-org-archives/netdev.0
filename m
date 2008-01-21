From: Jim Paris <jim@jtan.com>
Subject: [PATCH] ipv6: update MSS even if MTU is unchanged
Date: Mon, 21 Jan 2008 17:02:48 -0500
Message-ID: <20080121220248.GA25284@jim.sh>
References: <20080121105227.GA8306@jim.sh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from NEUROSIS.MIT.EDU ([18.95.3.133]:35796 "EHLO neurosis.jim.sh"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475AbYAUWCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 17:02:50 -0500
Received: from neurosis.jim.sh (localhost [127.0.0.1])
	by neurosis.jim.sh (8.14.1/8.14.1/Debian-9) with ESMTP id m0LM2nIa025420
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 17:02:49 -0500
Received: (from jim@localhost)
	by neurosis.jim.sh (8.14.1/8.14.1/Submit) id m0LM2mFf025419
	for netdev@vger.kernel.org; Mon, 21 Jan 2008 17:02:48 -0500
Content-Disposition: inline
In-Reply-To: <20080121105227.GA8306@jim.sh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed because in ndisc.c, we have:

  static void ndisc_router_discovery(struct sk_buff *skb)
  {
  // ...
  	if (ndopts.nd_opts_mtu) {
  // ...
  			if (rt)
  				rt->u.dst.metrics[RTAX_MTU-1] = mtu;

  			rt6_mtu_change(skb->dev, mtu);
  // ...
  }

Since the mtu is set directly here, rt6_mtu_change_route thinks that
it is unchanged, and so it fails to update the MSS accordingly.  This
patch lets rt6_mtu_change_route still update MSS if old_mtu == new_mtu.

Signed-off-by: Jim Paris <jim@jtan.com>
---
This fixes the problem I reported earlier where IPv6 autoconfiguration
ends up with mtu < advmss on the default route.

I don't know if this is the best way to fix the problem, but it works
for me.  Other options: set rt->u.dst.metrics[RTAX_ADVMSS-1] directly
in ndisc_router_discovery (but ipv6_advmss function isn't available);
don't set MTU at all in ndisc_router_discovery and let rt6_mtu_change
handle it; etc.

 net/ipv6/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6ecb5e6..0965fb3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1912,7 +1912,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	 */
 	if (rt->rt6i_dev == arg->dev &&
 	    !dst_metric_locked(&rt->u.dst, RTAX_MTU) &&
-	    (dst_mtu(&rt->u.dst) > arg->mtu ||
+	    (dst_mtu(&rt->u.dst) >= arg->mtu ||
 	     (dst_mtu(&rt->u.dst) < arg->mtu &&
 	      dst_mtu(&rt->u.dst) == idev->cnf.mtu6))) {
 		rt->u.dst.metrics[RTAX_MTU-1] = arg->mtu;
-- 
1.5.3.8

