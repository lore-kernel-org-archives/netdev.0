From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/10] mlxsw: spectrum: Extend port_orig_get for bridge devices
Date: Thu,  9 Feb 2017 14:54:48 +0100
Message-ID: <1486648489-16455-10-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35223 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdBIOY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:24:58 -0500
Received: by mail-wr0-f193.google.com with SMTP id o16so12115231wra.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:24:04 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

The function mlxsw_sp_port_orig_get returns the vport from the physical
port if needed, based on the original device.
This patch addresses the case where the original device is a bridge.
If it is vlan unaware bridge, it returns the matching vport. If it is vlan
aware bridge, there is no matching vport, and it returns the original port.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 5370246..9540f20 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -71,8 +71,21 @@ mlxsw_sp_port_orig_get(struct net_device *dev,
 		       struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_vport;
+	struct mlxsw_sp_fid *fid;
 	u16 vid;
 
+	if (netif_is_bridge_master(dev)) {
+		fid = mlxsw_sp_vfid_find(mlxsw_sp_port->mlxsw_sp,
+					 dev);
+		if (fid) {
+			mlxsw_sp_vport =
+				mlxsw_sp_port_vport_find_by_fid(mlxsw_sp_port,
+								fid->fid);
+			WARN_ON(!mlxsw_sp_vport);
+			return mlxsw_sp_vport;
+		}
+	}
+
 	if (!is_vlan_dev(dev))
 		return mlxsw_sp_port;
 
-- 
2.7.4
