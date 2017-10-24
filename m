From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] ipsec: Fix dst leak in xfrm_bundle_create().
Date: Tue, 24 Oct 2017 12:37:39 +0200
Message-ID: <1508841460-26369-2-git-send-email-steffen.klassert@secunet.com>
References: <1508841460-26369-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39116 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751912AbdJXKht (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 06:37:49 -0400
In-Reply-To: <1508841460-26369-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>

If we cannot find a suitable inner_mode value, we will leak
the currently allocated 'xdst'.

The fix is to make sure it is linked into the chain before
erroring out.

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f062539..2746b62 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1573,6 +1573,14 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 			goto put_states;
 		}
 
+		if (!dst_prev)
+			dst0 = dst1;
+		else
+			/* Ref count is taken during xfrm_alloc_dst()
+			 * No need to do dst_clone() on dst1
+			 */
+			dst_prev->child = dst1;
+
 		if (xfrm[i]->sel.family == AF_UNSPEC) {
 			inner_mode = xfrm_ip2inner_mode(xfrm[i],
 							xfrm_af2proto(family));
@@ -1584,14 +1592,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		} else
 			inner_mode = xfrm[i]->inner_mode;
 
-		if (!dst_prev)
-			dst0 = dst1;
-		else
-			/* Ref count is taken during xfrm_alloc_dst()
-			 * No need to do dst_clone() on dst1
-			 */
-			dst_prev->child = dst1;
-
 		xdst->route = dst;
 		dst_copy_metrics(dst1, dst);
 
-- 
2.7.4
