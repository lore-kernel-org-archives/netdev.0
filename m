From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net-2.6] xfrm: avoid possible oopse in xfrm_alloc_dst
Date: Fri, 11 Feb 2011 15:41:35 +0900
Message-ID: <1297406495.18018.76.camel@vega>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timo.teras@iki.fi,
	herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42767 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430Ab1BKGlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 01:41:36 -0500
Received: by gwj20 with SMTP id 20so943592gwj.19
        for <netdev@vger.kernel.org>; Thu, 10 Feb 2011 22:41:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 80c802f3073e84 (xfrm: cache bundles instead of policies for
outgoing flows) introduced possible oopse when dst_alloc returns NULL.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 net/xfrm/xfrm_policy.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 8b3ef40..6459588 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1340,10 +1340,13 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	default:
 		BUG();
 	}
-	xdst = dst_alloc(dst_ops) ?: ERR_PTR(-ENOBUFS);
+	xdst = dst_alloc(dst_ops);
 	xfrm_policy_put_afinfo(afinfo);
 
-	xdst->flo.ops = &xfrm_bundle_fc_ops;
+	if (likely(xdst))
+		xdst->flo.ops = &xfrm_bundle_fc_ops;
+	else
+		xdst = ERR_PTR(-ENOBUFS);
 
 	return xdst;
 }

