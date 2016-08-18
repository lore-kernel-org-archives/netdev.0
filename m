From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 10/10] net/mlx5: E-Switch, Avoid ACLs in the offloads mode
Date: Thu, 18 Aug 2016 21:09:11 +0300
Message-ID: <1471543751-24164-11-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41787 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754689AbcHSBnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:06 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

When we are in the switchdev/offloads mode, HW matching is done as
dictated by the offloaded rules and hence we don't need to enable
the ACLs mechanism used by the legacy mode.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index f6d6677..8b78f15 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1451,7 +1451,8 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 
 	esw_debug(esw->dev, "Enabling VPORT(%d)\n", vport_num);
 
-	if (vport_num) { /* Only VFs need ACLs for VST and spoofchk filtering */
+	/* Only VFs need ACLs for VST and spoofchk filtering */
+	if (vport_num && esw->mode == SRIOV_LEGACY) {
 		esw_vport_ingress_config(esw, vport);
 		esw_vport_egress_config(esw, vport);
 	}
@@ -1502,7 +1503,7 @@ static void esw_disable_vport(struct mlx5_eswitch *esw, int vport_num)
 	 */
 	esw_vport_change_handle_locked(vport);
 	vport->enabled_events = 0;
-	if (vport_num) {
+	if (vport_num && esw->mode == SRIOV_LEGACY) {
 		esw_vport_disable_egress_acl(esw, vport);
 		esw_vport_disable_ingress_acl(esw, vport);
 	}
@@ -1767,7 +1768,7 @@ int mlx5_eswitch_set_vport_mac(struct mlx5_eswitch *esw,
 			       vport, err);
 
 	mutex_lock(&esw->state_lock);
-	if (evport->enabled)
+	if (evport->enabled && esw->mode == SRIOV_LEGACY)
 		err = esw_vport_ingress_config(esw, evport);
 	mutex_unlock(&esw->state_lock);
 	return err;
@@ -1839,7 +1840,7 @@ int mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
 	mutex_lock(&esw->state_lock);
 	evport->vlan = vlan;
 	evport->qos = qos;
-	if (evport->enabled) {
+	if (evport->enabled && esw->mode == SRIOV_LEGACY) {
 		err = esw_vport_ingress_config(esw, evport);
 		if (err)
 			goto out;
@@ -1868,10 +1869,11 @@ int mlx5_eswitch_set_vport_spoofchk(struct mlx5_eswitch *esw,
 	mutex_lock(&esw->state_lock);
 	pschk = evport->spoofchk;
 	evport->spoofchk = spoofchk;
-	if (evport->enabled)
+	if (evport->enabled && esw->mode == SRIOV_LEGACY) {
 		err = esw_vport_ingress_config(esw, evport);
-	if (err)
-		evport->spoofchk = pschk;
+		if (err)
+			evport->spoofchk = pschk;
+	}
 	mutex_unlock(&esw->state_lock);
 
 	return err;
-- 
2.7.4
