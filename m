From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] mlxsw: spectrum: Add placeholder for dpipe
Date: Sat, 25 Mar 2017 08:35:37 +0100
Message-ID: <1490427342-2061-4-git-send-email-jiri@resnulli.us>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36271 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750867AbdCYHfv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 03:35:51 -0400
Received: by mail-wm0-f66.google.com with SMTP id x124so1838617wmf.3
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 00:35:49 -0700 (PDT)
In-Reply-To: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add placeholder for dpipe. Support for specific tables and headers will
be introduced in following patches. The headers are shared between all
mlxsw_sp instances.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 10 ++++
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 57 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   | 41 ++++++++++++++++
 4 files changed, 109 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index 95fcacf..2fb8c65 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -16,7 +16,7 @@ mlxsw_spectrum-objs		:= spectrum.o spectrum_buffers.o \
 				   spectrum_switchdev.o spectrum_router.o \
 				   spectrum_kvdl.o spectrum_acl_tcam.o \
 				   spectrum_acl.o spectrum_flower.o \
-				   spectrum_cnt.o
+				   spectrum_cnt.o spectrum_dpipe.o
 mlxsw_spectrum-$(CONFIG_MLXSW_SPECTRUM_DCB)	+= spectrum_dcb.o
 obj-$(CONFIG_MLXSW_MINIMAL)	+= mlxsw_minimal.o
 mlxsw_minimal-objs		:= minimal.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index eabfe5c..b031f09 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -67,6 +67,7 @@
 #include "trap.h"
 #include "txheader.h"
 #include "spectrum_cnt.h"
+#include "spectrum_dpipe.h"
 
 static const char mlxsw_sp_driver_name[] = "mlxsw_spectrum";
 static const char mlxsw_sp_driver_version[] = "1.0";
@@ -3339,6 +3340,12 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_counter_pool_init;
 	}
 
+	err = mlxsw_sp_dpipe_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to init pipeline debug\n");
+		goto err_dpipe_init;
+	}
+
 	err = mlxsw_sp_ports_create(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to create ports\n");
@@ -3348,6 +3355,8 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 	return 0;
 
 err_ports_create:
+	mlxsw_sp_dpipe_fini(mlxsw_sp);
+err_dpipe_init:
 	mlxsw_sp_counter_pool_fini(mlxsw_sp);
 err_counter_pool_init:
 	mlxsw_sp_acl_fini(mlxsw_sp);
@@ -3372,6 +3381,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
 	mlxsw_sp_ports_remove(mlxsw_sp);
+	mlxsw_sp_dpipe_fini(mlxsw_sp);
 	mlxsw_sp_counter_pool_fini(mlxsw_sp);
 	mlxsw_sp_acl_fini(mlxsw_sp);
 	mlxsw_sp_span_fini(mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
new file mode 100644
index 0000000..7c87bc8
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -0,0 +1,57 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2017 Arkadi Sharshevsky <arakdis@mellanox.com>
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
+#include <net/devlink.h>
+
+#include "spectrum.h"
+#include "spectrum_dpipe.h"
+
+static struct devlink_dpipe_header *mlxsw_dpipe_headers[] = {};
+
+static struct devlink_dpipe_headers mlxsw_sp_dpipe_headers = {
+	.headers = mlxsw_dpipe_headers,
+	.headers_count = ARRAY_SIZE(mlxsw_dpipe_headers),
+};
+
+int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
+{
+	return devlink_dpipe_headers_register(priv_to_devlink(mlxsw_sp->core),
+					      &mlxsw_sp_dpipe_headers);
+}
+
+void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	devlink_dpipe_headers_unregister(priv_to_devlink(mlxsw_sp->core));
+}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
new file mode 100644
index 0000000..ad16259
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
@@ -0,0 +1,41 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2017 Arkadi Sharshevsky <arkadis@mellanox.com>
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
+#ifndef _MLXSW_PIPELINE_H_
+#define _MLXSW_PIPELINE_H_
+
+int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp);
+void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp);
+
+#endif /* _MLXSW_PIPELINE_H_*/
-- 
2.7.4
