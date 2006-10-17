From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 3/13] [IPV6] Make sure error handling is done when calling
 ip6_route_output().
Date: Tue, 17 Oct 2006 03:04:08 +0300
Message-ID: <45341DF8.90104@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:58897 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422949AbWJQAEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:04:10 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As ip6_route_output() never returns NULL, error checking must be done by
looking at dst->error in stead of comparing dst against NULL.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/xfrm6_policy.c |   12 +++++++-----
 net/sctp/ipv6.c         |   10 +++++-----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 6a252e2..db2d55c 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -25,12 +25,14 @@ #endif
 static struct dst_ops xfrm6_dst_ops;
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;

-static int xfrm6_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
+static int xfrm6_dst_lookup(struct xfrm_dst **xdst, struct flowi *fl)
 {
-	int err = 0;
-	*dst = (struct xfrm_dst*)ip6_route_output(NULL, fl);
-	if (!*dst)
-		err = -ENETUNREACH;
+	struct dst_entry *dst = ip6_route_output(NULL, fl);
+	int err = dst->error;
+	if (!err)
+		*xdst = (struct xfrm_dst *) dst;
+	else
+		dst_release(dst);
 	return err;
 }

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 249e503..78071c6 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -215,17 +215,17 @@ static struct dst_entry *sctp_v6_get_dst
 	}

 	dst = ip6_route_output(NULL, &fl);
-	if (dst) {
+	if (!dst->error) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
 		SCTP_DEBUG_PRINTK(
 			"rt6_dst:" NIP6_FMT " rt6_src:" NIP6_FMT "\n",
 			NIP6(rt->rt6i_dst.addr), NIP6(rt->rt6i_src.addr));
-	} else {
-		SCTP_DEBUG_PRINTK("NO ROUTE\n");
+		return dst;
 	}
-
-	return dst;
+	SCTP_DEBUG_PRINTK("NO ROUTE\n");
+	dst_release(dst);
+	return NULL;
 }

 /* Returns the number of consecutive initial bits that match in the 2 ipv6
-- 
1.4.2.3
