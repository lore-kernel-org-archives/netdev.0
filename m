From: Markus Stenberg <markus.stenberg@iki.fi>
Subject: [PATCH] ipv6: Fixed source specific default route handling.
Date: Tue, 5 May 2015 13:36:59 +0300
Message-ID: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Markus Stenberg <markus.stenberg@iki.fi>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out1.inet.fi ([62.71.2.195]:56373 "EHLO kirsi1.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579AbbEEKhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 06:37:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there are only IPv6 source specific default routes present, the
host gets -ENETUNREACH on e.g. connect() because ip6_dst_lookup_tail
calls ip6_route_output first, and given source address any, it fails,
and ip6_route_get_saddr is never called.

The change is to use the ip6_route_get_saddr, even if the initial
ip6_route_output fails, and then doing ip6_route_output _again_ after
we have appropriate source address available.

Note that this is '99% fix' to the problem; a correct fix would be to
do route lookups only within addrconf.c when picking a source address,
and never call ip6_route_output before source address has been
populated.

Signed-off-by: Markus Stenberg <markus.stenberg@iki.fi>
---
 net/ipv6/ip6_output.c | 39 +++++++++++++++++++++++++++++++--------
 net/ipv6/route.c      |  5 +++--
 2 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7fde1f2..c217775 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -886,22 +886,45 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 #endif
 	int err;
 
-	if (!*dst)
-		*dst = ip6_route_output(net, sk, fl6);
-
-	err = (*dst)->error;
-	if (err)
-		goto out_err_release;
+	/* The correct way to handle this would be to do
+	 * ip6_route_get_saddr, and then ip6_route_output; however,
+	 * the route-specific preferred source forces the
+	 * ip6_route_output call _before_ ip6_route_get_saddr.
+	 *
+	 * In source specific routing (no src=any default route),
+	 * ip6_route_output will fail given src=any saddr, though, so
+	 * that's why we try it again later.
+	 */
+	if (ipv6_addr_any(&fl6->saddr) && (!*dst || !(*dst)->error)) {
+		struct rt6_info *rt;
+		bool had_dst = *dst != NULL;
 
-	if (ipv6_addr_any(&fl6->saddr)) {
-		struct rt6_info *rt = (struct rt6_info *) *dst;
+		if (!had_dst)
+			*dst = ip6_route_output(net, sk, fl6);
+		rt = (*dst)->error ? NULL : (struct rt6_info *)*dst;
 		err = ip6_route_get_saddr(net, rt, &fl6->daddr,
 					  sk ? inet6_sk(sk)->srcprefs : 0,
 					  &fl6->saddr);
 		if (err)
 			goto out_err_release;
+
+		/* If we had an erroneous initial result, pretend it
+		 * never existed and let the SA-enabled version take
+		 * over.
+		 */
+		if (!had_dst && (*dst)->error) {
+			dst_release(*dst);
+			*dst = NULL;
+		}
 	}
 
+	if (!*dst)
+		*dst = ip6_route_output(net, sk, fl6);
+
+	err = (*dst)->error;
+	if (err)
+		goto out_err_release;
+
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	/*
 	 * Here if the dst entry we've looked up
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5c48293..d358888 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2245,9 +2245,10 @@ int ip6_route_get_saddr(struct net *net,
 			unsigned int prefs,
 			struct in6_addr *saddr)
 {
-	struct inet6_dev *idev = ip6_dst_idev((struct dst_entry *)rt);
+	struct inet6_dev *idev =
+		rt ? ip6_dst_idev((struct dst_entry *)rt) : NULL;
 	int err = 0;
-	if (rt->rt6i_prefsrc.plen)
+	if (rt && rt->rt6i_prefsrc.plen)
 		*saddr = rt->rt6i_prefsrc.addr;
 	else
 		err = ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
-- 
2.3.2 (Apple Git-55)
