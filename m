From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 5/5] bnx2x: track vxlan port count
Date: Thu, 17 Sep 2015 16:11:14 +0200
Message-ID: <b4b940529e405e005b3419341ab007f15f5ad8b3.1442498316.git.jbenc@redhat.com>
References: <cover.1442498316.git.jbenc@redhat.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21625 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751737AbbIQOL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 10:11:29 -0400
In-Reply-To: <cover.1442498316.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The callback for adding vxlan port can be called with the same port for
both IPv4 and IPv6. Do not disable the offloading when the same port for
both protocols is added and later one of them removed.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index ba936635322a..b5e64b02200c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1946,6 +1946,7 @@ struct bnx2x {
 	u16 vlan_cnt;
 	u16 vlan_credit;
 	u16 vxlan_dst_port;
+	u8 vxlan_dst_port_count;
 	bool accept_any_vlan;
 };
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 89a174fa1300..f1d62d5dbaff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10108,12 +10108,18 @@ static void __bnx2x_add_vxlan_port(struct bnx2x *bp, u16 port)
 	if (!netif_running(bp->dev))
 		return;
 
-	if (bp->vxlan_dst_port || !IS_PF(bp)) {
+	if (bp->vxlan_dst_port_count && bp->vxlan_dst_port == port) {
+		bp->vxlan_dst_port_count++;
+		return;
+	}
+
+	if (bp->vxlan_dst_port_count || !IS_PF(bp)) {
 		DP(BNX2X_MSG_SP, "Vxlan destination port limit reached\n");
 		return;
 	}
 
 	bp->vxlan_dst_port = port;
+	bp->vxlan_dst_port_count = 1;
 	bnx2x_schedule_sp_rtnl(bp, BNX2X_SP_RTNL_ADD_VXLAN_PORT, 0);
 }
 
@@ -10128,10 +10134,14 @@ static void bnx2x_add_vxlan_port(struct net_device *netdev,
 
 static void __bnx2x_del_vxlan_port(struct bnx2x *bp, u16 port)
 {
-	if (!bp->vxlan_dst_port || bp->vxlan_dst_port != port || !IS_PF(bp)) {
+	if (!bp->vxlan_dst_port_count || bp->vxlan_dst_port != port ||
+	    !IS_PF(bp)) {
 		DP(BNX2X_MSG_SP, "Invalid vxlan port\n");
 		return;
 	}
+	bp->vxlan_dst_port--;
+	if (bp->vxlan_dst_port)
+		return;
 
 	if (netif_running(bp->dev)) {
 		bnx2x_schedule_sp_rtnl(bp, BNX2X_SP_RTNL_DEL_VXLAN_PORT, 0);
-- 
1.8.3.1
