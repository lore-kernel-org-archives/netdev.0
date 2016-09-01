From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 5/6] mlxsw: spectrum: Don't take multiple references on a FID
Date: Thu,  1 Sep 2016 10:37:44 +0200
Message-ID: <1472719065-3247-6-git-send-email-jiri@resnulli.us>
References: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33508 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752895AbcIAIh5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 04:37:57 -0400
Received: by mail-wm0-f65.google.com with SMTP id w207so7295706wmw.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 01:37:56 -0700 (PDT)
In-Reply-To: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In commit 14d39461b3f4 ("mlxsw: spectrum: Use per-FID struct for the
VLAN-aware bridge") I added a per-FID struct, which member ports can
take a reference on upon VLAN membership configuration.

However, sometimes only the VLAN flags (e.g. egress untagged) are
toggled without changing the VLAN membership. In these cases we
shouldn't take another reference on the FID.

Fixes: 14d39461b3f4 ("mlxsw: spectrum: Use per-FID struct for the VLAN-aware bridge")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index d1b59cd..e0d95c4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -460,6 +460,9 @@ static int __mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	struct mlxsw_sp_fid *f;
 
+	if (test_bit(fid, mlxsw_sp_port->active_vlans))
+		return 0;
+
 	f = mlxsw_sp_fid_find(mlxsw_sp_port->mlxsw_sp, fid);
 	if (!f) {
 		f = mlxsw_sp_fid_create(mlxsw_sp_port->mlxsw_sp, fid);
-- 
2.5.5
