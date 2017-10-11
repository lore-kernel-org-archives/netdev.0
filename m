From: David Miller <davem@davemloft.net>
Subject: ipsec: Fix dst leak in xfrm_bundle_create().
Date: Tue, 10 Oct 2017 20:59:38 -0700 (PDT)
Message-ID: <20171010.205938.2305003344238226004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756502AbdJKD7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 23:59:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If we cannot find a suitable inner_mode value, we will leak
the currently allocated 'xdst'.

The fix is to make sure it is linked into the chain before
erroring out.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Steffen, I found this via visual inspection.  Please double check my
work before applying this :-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f06253969972..2746b62a8944 100644
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
 
