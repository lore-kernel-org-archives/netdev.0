From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/17] mlxsw: spectrum: Introduce support for Data Center Bridging (DCB)
Date: Wed,  6 Apr 2016 17:10:09 +0200
Message-ID: <1459955416-23786-11-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33812 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbcDFPKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:32 -0400
Received: by mail-wm0-f65.google.com with SMTP id n3so14166714wmn.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:32 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Introduce basic infrastructure for DCB and add the missing ops in
following patches.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |  8 +++
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 10 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 17 ++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 65 ++++++++++++++++++++++
 5 files changed, 101 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index 2ad7f67..5989f7c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -50,3 +50,11 @@ config MLXSW_SPECTRUM
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called mlxsw_spectrum.
+
+config MLXSW_SPECTRUM_DCB
+	bool "Data Center Bridging (DCB) support"
+	depends on MLXSW_SPECTRUM && DCB
+	default y
+	---help---
+	  Say Y here if you want to use Data Center Bridging (DCB) in the
+	  driver.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index 584cac4..9b5ebf8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -8,3 +8,4 @@ mlxsw_switchx2-objs		:= switchx2.o
 obj-$(CONFIG_MLXSW_SPECTRUM)	+= mlxsw_spectrum.o
 mlxsw_spectrum-objs		:= spectrum.o spectrum_buffers.o \
 				   spectrum_switchdev.o
+mlxsw_spectrum-$(CONFIG_MLXSW_SPECTRUM_DCB)	+= spectrum_dcb.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1243c74..baaa9ea 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1681,6 +1681,14 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_port_ets_init;
 	}
 
+	/* ETS and buffers must be initialized before DCB. */
+	err = mlxsw_sp_port_dcb_init(mlxsw_sp_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to initialize DCB\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_dcb_init;
+	}
+
 	mlxsw_sp_port_switchdev_init(mlxsw_sp_port);
 	err = register_netdev(dev);
 	if (err) {
@@ -1701,6 +1709,7 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 err_port_vlan_init:
 	unregister_netdev(dev);
 err_register_netdev:
+err_port_dcb_init:
 err_port_ets_init:
 err_port_buffers_init:
 err_port_admin_status_set:
@@ -1771,6 +1780,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	devlink_port = &mlxsw_sp_port->devlink_port;
 	devlink_port_type_clear(devlink_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
+	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
 	devlink_port_unregister(devlink_port);
 	mlxsw_sp_port_vports_fini(mlxsw_sp_port);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 84dddd4..1f50af8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -270,4 +270,21 @@ int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
 int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 
+#ifdef CONFIG_MLXSW_SPECTRUM_DCB
+
+int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port);
+void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port);
+
+#else
+
+static inline int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	return 0;
+}
+
+static inline void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
+{}
+
+#endif
+
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
new file mode 100644
index 0000000..631e980
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -0,0 +1,65 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
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
+#include <linux/netdevice.h>
+#include <net/dcbnl.h>
+
+#include "spectrum.h"
+
+static u8 mlxsw_sp_dcbnl_getdcbx(struct net_device __always_unused *dev)
+{
+	return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
+}
+
+static u8 mlxsw_sp_dcbnl_setdcbx(struct net_device __always_unused *dev,
+				 u8 mode)
+{
+	return (mode != (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE)) ? 1 : 0;
+}
+
+static const struct dcbnl_rtnl_ops mlxsw_sp_dcbnl_ops = {
+	.getdcbx		= mlxsw_sp_dcbnl_getdcbx,
+	.setdcbx		= mlxsw_sp_dcbnl_setdcbx,
+};
+
+int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	mlxsw_sp_port->dev->dcbnl_ops = &mlxsw_sp_dcbnl_ops;
+
+	return 0;
+}
+
+void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+}
-- 
2.5.5
