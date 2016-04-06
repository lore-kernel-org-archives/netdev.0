From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/17] mlxsw: spectrum: Map all switch priorities to priority group 0
Date: Wed,  6 Apr 2016 17:10:01 +0200
Message-ID: <1459955416-23786-3-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34655 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbcDFPK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:28 -0400
Received: by mail-wm0-f68.google.com with SMTP id n3so14165355wmn.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:28 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

During transmission, the skb's priority is used to map the skb to a
traffic class, where the idea is to group priorities with similar
characteristics (e.g. lossy, lossless) to the same traffic class. By
default, all priorities are mapped to traffic class 0.

In the device, we model the skb's priority as the switch priority, which
is assigned to a packet according to its PCP value and ingress port
(untagged packets are assigned the port's default switch priority - 0).

At ingress, the packet is directed to a priority group (PG) buffer in
the port's headroom buffer according to the packet's switch priority and
switch priority to buffer mapping.

While it's possible to configure the egress mapping between skb's
priority (switch priority) and traffic class, there is no mechanism to
configure the ingress mapping to a PG.

In order to keep things simple and since grouping certain priorities into
a traffic class at egress also implies they should be grouped the same
at ingress, treat a PG as the ingress counterpart of an egress traffic
class.

Having established the above, during initialization map all the switch
priorities to PG0 in accordance with the Linux defaults for traffic
class mapping.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 25 +++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index d59195e..c3a275b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -34,6 +34,7 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
+#include <linux/dcbnl.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -82,6 +83,28 @@ static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 			       MLXSW_REG(pbmc), pbmc_pl);
 }
 
+static int mlxsw_sp_port_pb_prio_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	char pptb_pl[MLXSW_REG_PPTB_LEN];
+	int i;
+
+	mlxsw_reg_pptb_pack(pptb_pl, mlxsw_sp_port->local_port);
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		mlxsw_reg_pptb_prio_to_buff_set(pptb_pl, i, 0);
+	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(pptb),
+			       pptb_pl);
+}
+
+static int mlxsw_sp_port_headroom_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	int err;
+
+	err = mlxsw_sp_port_pb_init(mlxsw_sp_port);
+	if (err)
+		return err;
+	return mlxsw_sp_port_pb_prio_init(mlxsw_sp_port);
+}
+
 #define MLXSW_SP_SB_BYTES_PER_CELL 96
 
 struct mlxsw_sp_sb_pool {
@@ -410,7 +433,7 @@ int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	int err;
 
-	err = mlxsw_sp_port_pb_init(mlxsw_sp_port);
+	err = mlxsw_sp_port_headroom_init(mlxsw_sp_port);
 	if (err)
 		return err;
 	err = mlxsw_sp_port_sb_cms_init(mlxsw_sp_port);
-- 
2.5.5
