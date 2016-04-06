From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/17] mlxsw: spectrum: Correctly configure headroom size
Date: Wed,  6 Apr 2016 17:10:03 +0200
Message-ID: <1459955416-23786-5-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36776 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396AbcDFPKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:41 -0400
Received: by mail-wm0-f66.google.com with SMTP id o129so4681646wmo.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:35 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When packets ingress the switch they are assigned a switch priority and
directed to the corresponding priority group (PG) buffer in the port's
headroom buffer.

Since we now map all switch priorities to priority group 0 (PG0) by
default, there is no need to allocate the other priority groups during
initialization. The only exception is PG9, which is used for control
traffic.

At minimum, the PG should be able to store the currently classified
packet (pipeline latency isn't 0) and also the packets arriving during
the classification time. However, an incoming packet will not be
buffered if there is no available MTU-sized buffer space for storing it.

The buffer needed to accommodate for pipeline latency is variable and
needs to take into account both the current link speed and current
latency of the pipeline, which is time-dependent. Testing showed that
setting the PG's size to twice the current MTU is optimal.

Since PG9 is used strictly for control packets and not subject to flow
control, we are not going to resize it according to user configuration,
so we simply set it according to worst case scenario, which is twice the
maximum MTU.

In any case, later patches in the series will allow a user to direct
lossless flows to other PGs than PG0 and set their size to accommodate
for round-trip propagation delay.

The above change also requires us to resize the PG buffer whenever the
port's MTU is changed.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 25 +++++++++++++++++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 19 ++++++++--------
 2 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index cb5f36e..4576d59 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -449,16 +449,39 @@ static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
+static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				      int mtu)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u16 pg_size = 2 * MLXSW_SP_BYTES_TO_CELLS(mtu);
+	char pbmc_pl[MLXSW_REG_PBMC_LEN];
+	int err;
+
+	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port, 0, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
+	if (err)
+		return err;
+	mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, 0, pg_size);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
+}
+
 static int mlxsw_sp_port_change_mtu(struct net_device *dev, int mtu)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	int err;
 
-	err = mlxsw_sp_port_mtu_set(mlxsw_sp_port, mtu);
+	err = mlxsw_sp_port_headroom_set(mlxsw_sp_port, mtu);
 	if (err)
 		return err;
+	err = mlxsw_sp_port_mtu_set(mlxsw_sp_port, mtu);
+	if (err)
+		goto err_port_mtu_set;
 	dev->mtu = mtu;
 	return 0;
+
+err_port_mtu_set:
+	mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu);
+	return err;
 }
 
 static struct rtnl_link_stats64 *
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index dadb6e1..e7a5b73 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -35,6 +35,7 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/dcbnl.h>
+#include <linux/if_ether.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -53,15 +54,15 @@ struct mlxsw_sp_pb {
 	}
 
 static const struct mlxsw_sp_pb mlxsw_sp_pbs[] = {
-	MLXSW_SP_PB(0, 208),
-	MLXSW_SP_PB(1, 208),
-	MLXSW_SP_PB(2, 208),
-	MLXSW_SP_PB(3, 208),
-	MLXSW_SP_PB(4, 208),
-	MLXSW_SP_PB(5, 208),
-	MLXSW_SP_PB(6, 208),
-	MLXSW_SP_PB(7, 208),
-	MLXSW_SP_PB(9, 208),
+	MLXSW_SP_PB(0, 2 * MLXSW_SP_BYTES_TO_CELLS(ETH_FRAME_LEN)),
+	MLXSW_SP_PB(1, 0),
+	MLXSW_SP_PB(2, 0),
+	MLXSW_SP_PB(3, 0),
+	MLXSW_SP_PB(4, 0),
+	MLXSW_SP_PB(5, 0),
+	MLXSW_SP_PB(6, 0),
+	MLXSW_SP_PB(7, 0),
+	MLXSW_SP_PB(9, 2 * MLXSW_SP_BYTES_TO_CELLS(MLXSW_PORT_MAX_MTU)),
 };
 
 #define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)
-- 
2.5.5
