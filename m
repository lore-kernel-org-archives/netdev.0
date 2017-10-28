From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next] bnxt_en: Fix randconfig build errors.
Date: Sat, 28 Oct 2017 01:56:10 -0400
Message-ID: <1509170170-14847-1-git-send-email-michael.chan@broadcom.com>
Cc: kubakici@wp.pl, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:54186 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdJ1F4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 01:56:31 -0400
Received: by mail-qt0-f193.google.com with SMTP id n61so10848702qte.10
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 22:56:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix undefined symbols when CONFIG_VLAN_8021Q or CONFIG_INET is not set.

Fixes: 8c95f773b4a3 ("bnxt_en: add support for Flower based vxlan encap/decap offload")
Reported-by: Jakub Kicinski <kubakici@wp.pl>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
index 798d139..d5031f4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
@@ -904,6 +904,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
 				       struct bnxt_tc_l2_key *l2_info,
 				       struct net_device *real_dst_dev)
 {
+#ifdef CONFIG_INET
 	struct flowi4 flow = { {0} };
 	struct net_device *dst_dev;
 	struct neighbour *nbr;
@@ -925,6 +926,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
 	 */
 	dst_dev = rt->dst.dev;
 	if (is_vlan_dev(dst_dev)) {
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 		struct vlan_dev_priv *vlan = vlan_dev_priv(dst_dev);
 
 		if (vlan->real_dev != real_dst_dev) {
@@ -938,6 +940,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
 		l2_info->inner_vlan_tci = htons(vlan->vlan_id);
 		l2_info->inner_vlan_tpid = vlan->vlan_proto;
 		l2_info->num_vlans = 1;
+#endif
 	} else if (dst_dev != real_dst_dev) {
 		netdev_info(bp->dev,
 			    "dst_dev(%s) for %pI4b is not PF-if(%s)",
@@ -966,6 +969,9 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
 put_rt:
 	ip_rt_put(rt);
 	return rc;
+#else
+	return -EOPNOTSUPP;
+#endif
 }
 
 static int bnxt_tc_get_decap_handle(struct bnxt *bp, struct bnxt_tc_flow *flow,
-- 
1.8.3.1
