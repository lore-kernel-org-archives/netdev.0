From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/18] mlxsw: spectrum: Remove RIF from PVID vPort when joining / leaving LAG
Date: Sat,  2 Jul 2016 09:26:26 +0200
Message-ID: <1467444400-9480-5-git-send-email-jiri@resnulli.us>
References: <1467444400-9480-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35759 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbcGBH1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 03:27:23 -0400
Received: by mail-wm0-f65.google.com with SMTP id a66so9892277wme.2
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 00:26:49 -0700 (PDT)
In-Reply-To: <1467444400-9480-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We are going to assign router interfaces (RIFs) to netdevs if an IPv4
address was assigned to them. If one was assigned to a port netdev, this
will translate to the PVID vPort being member in a RIF.

While it's possible for a LAG slave to have an IP address, we can't have
a vPort being member in two FIDs (assuming the LAG device will be
put in bridge / assigned an IP address).

Solve that by making the PVID vPort leave any FID it might be a member
in when joining / leaving LAG.

Note that the PVID vPort is the only vPort that can be present on the
port when it's put under LAG.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f276c45..30fe0d2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2800,11 +2800,19 @@ mlxsw_sp_port_pvid_vport_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 				  u16 lag_id)
 {
 	struct mlxsw_sp_port *mlxsw_sp_vport;
+	struct mlxsw_sp_fid *f;
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, 1);
 	if (WARN_ON(!mlxsw_sp_vport))
 		return;
 
+	/* If vPort is assigned a RIF, then leave it since it's no
+	 * longer valid.
+	 */
+	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+	if (f)
+		f->leave(mlxsw_sp_vport);
+
 	mlxsw_sp_vport->lag_id = lag_id;
 	mlxsw_sp_vport->lagged = 1;
 }
@@ -2813,11 +2821,16 @@ static void
 mlxsw_sp_port_pvid_vport_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_vport;
+	struct mlxsw_sp_fid *f;
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, 1);
 	if (WARN_ON(!mlxsw_sp_vport))
 		return;
 
+	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+	if (f)
+		f->leave(mlxsw_sp_vport);
+
 	mlxsw_sp_vport->lagged = 0;
 }
 
-- 
2.5.5
