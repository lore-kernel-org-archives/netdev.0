From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next] xfrm: check that cached bundle is still valid
Date: Sun,  6 Aug 2017 10:19:07 +0200
Message-ID: <20170806081907.5267-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51602 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751179AbdHFITS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 04:19:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Ilan Tayari:
  1. Set up a host-to-host IPSec tunnel (or transport, doesn't matter)
  2. Ping over IPSec, or do something to populate the pcpu cache
  3. Join a MC group, then leave MC group
  4. Try to ping again using same CPU as before -> traffic
     doesn't egress the machine at all

Ilan debugged the problem down to the fact that one of the path dsts
devices point to lo due to earlier dst_dev_put().
In this case, dst is marked as DEAD and we cannot reuse the bundle.

The cache only asserted that the requested policy and that of the cached
bundle match, but its not enough - also verify the path is still valid.

Fixes: ec30d78c14a813 ("xfrm: add xdst pcpu cache")
Reported-by: Ayham Masood <ayhamm@mellanox.com>
Tested-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 06c3bf7ab86b..8da428f56aec 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1818,7 +1818,8 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	    xdst->num_pols == num_pols &&
 	    !xfrm_pol_dead(xdst) &&
 	    memcmp(xdst->pols, pols,
-		   sizeof(struct xfrm_policy *) * num_pols) == 0) {
+		   sizeof(struct xfrm_policy *) * num_pols) == 0 &&
+	    xfrm_bundle_ok(xdst)) {
 		dst_hold(&xdst->u.dst);
 		return xdst;
 	}
-- 
2.13.3
