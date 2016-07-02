From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/12] mlxsw: spectrum_router: Add basic ipv4 router initialization
Date: Sat,  2 Jul 2016 11:00:15 +0200
Message-ID: <1467450020-23415-8-git-send-email-jiri@resnulli.us>
References: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35007 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbcGBJAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:00:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id a66so10282176wme.2
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 02:00:33 -0700 (PDT)
In-Reply-To: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Create a skeleton router file and do basic HW initialization of router.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  9 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  5 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 68 ++++++++++++++++++++++
 4 files changed, 83 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index 9b5ebf8..ea05f8a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -7,5 +7,5 @@ obj-$(CONFIG_MLXSW_SWITCHX2)	+= mlxsw_switchx2.o
 mlxsw_switchx2-objs		:= switchx2.o
 obj-$(CONFIG_MLXSW_SPECTRUM)	+= mlxsw_spectrum.o
 mlxsw_spectrum-objs		:= spectrum.o spectrum_buffers.o \
-				   spectrum_switchdev.o
+				   spectrum_switchdev.o spectrum_router.o
 mlxsw_spectrum-$(CONFIG_MLXSW_SPECTRUM_DCB)	+= spectrum_dcb.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b6f4dfb..d011902 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2438,6 +2438,12 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_switchdev_init;
 	}
 
+	err = mlxsw_sp_router_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to initialize router\n");
+		goto err_router_init;
+	}
+
 	err = mlxsw_sp_ports_create(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to create ports\n");
@@ -2447,6 +2453,8 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 	return 0;
 
 err_ports_create:
+	mlxsw_sp_router_fini(mlxsw_sp);
+err_router_init:
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 err_switchdev_init:
 err_lag_init:
@@ -2464,6 +2472,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
 	mlxsw_sp_ports_remove(mlxsw_sp);
+	mlxsw_sp_router_fini(mlxsw_sp);
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 05d5fcc..c2ac037 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -74,6 +74,8 @@
 
 #define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
 
+#define MLXSW_SP_RIF_MAX 800
+
 static inline u16 mlxsw_sp_pfc_delay_get(int mtu, u16 delay)
 {
 	delay = MLXSW_SP_BYTES_TO_CELLS(DIV_ROUND_UP(delay, BITS_PER_BYTE));
@@ -411,4 +413,7 @@ static inline void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 
 #endif
 
+int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp);
+void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp);
+
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
new file mode 100644
index 0000000..8d70496
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -0,0 +1,68 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2016 Ido Schimmel <idosch@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+
+#include "spectrum.h"
+#include "core.h"
+#include "reg.h"
+
+static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
+{
+	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+
+	mlxsw_reg_rgcr_pack(rgcr_pl, true);
+	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, MLXSW_SP_RIF_MAX);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+}
+
+static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+
+	mlxsw_reg_rgcr_pack(rgcr_pl, false);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+}
+
+int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
+{
+	return __mlxsw_sp_router_init(mlxsw_sp);
+}
+
+void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	__mlxsw_sp_router_fini(mlxsw_sp);
+}
-- 
2.5.5
