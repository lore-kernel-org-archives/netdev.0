From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH net] libcxgb: fix error check for ip6_route_output()
Date: Tue,  3 Jan 2017 21:25:48 +0530
Message-ID: <1483458948-13765-1-git-send-email-varun@chelsio.com>
Cc: netdev@vger.kernel.org, swise@opengridcomputing.com,
        indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:33260 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759732AbdACRDG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 12:03:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_route_output() never returns NULL so
check dst->error instead of !dst.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
index 0f0de5b..d04a6c1 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
@@ -133,17 +133,15 @@ cxgb_find_route6(struct cxgb4_lld_info *lldi,
 		if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
 			fl6.flowi6_oif = sin6_scope_id;
 		dst = ip6_route_output(&init_net, NULL, &fl6);
-		if (!dst)
-			goto out;
-		if (!cxgb_our_interface(lldi, get_real_dev,
-					ip6_dst_idev(dst)->dev) &&
-		    !(ip6_dst_idev(dst)->dev->flags & IFF_LOOPBACK)) {
+		if (dst->error ||
+		    (!cxgb_our_interface(lldi, get_real_dev,
+					 ip6_dst_idev(dst)->dev) &&
+		     !(ip6_dst_idev(dst)->dev->flags & IFF_LOOPBACK))) {
 			dst_release(dst);
-			dst = NULL;
+			return NULL;
 		}
 	}
 
-out:
 	return dst;
 }
 EXPORT_SYMBOL(cxgb_find_route6);
-- 
2.0.2
