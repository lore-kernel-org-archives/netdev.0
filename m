From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/9] mlxsw: spectrum: Add support for counter allocator
Date: Sat, 11 Mar 2017 09:42:51 +0100
Message-ID: <1489221779-3807-2-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36197 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751788AbdCKInE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:04 -0500
Received: by mail-wr0-f194.google.com with SMTP id l37so14006650wrc.3
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:02 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add implementation for counter allocator. The ASIC has special memory
pool for various counting purposes. Counter memory is distributed between
equal size banks.

The static sub-pool configuration should specify the following parameters
for each sub-pool:
- Number of required banks.
- Maximum entry size.

Each module can add dedicated sub-pool or use existing one.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   3 +-
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  10 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c | 177 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h |  54 +++++++
 6 files changed, 247 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index 6b6c30d..95fcacf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -15,7 +15,8 @@ obj-$(CONFIG_MLXSW_SPECTRUM)	+= mlxsw_spectrum.o
 mlxsw_spectrum-objs		:= spectrum.o spectrum_buffers.o \
 				   spectrum_switchdev.o spectrum_router.o \
 				   spectrum_kvdl.o spectrum_acl_tcam.o \
-				   spectrum_acl.o spectrum_flower.o
+				   spectrum_acl.o spectrum_flower.o \
+				   spectrum_cnt.o
 mlxsw_spectrum-$(CONFIG_MLXSW_SPECTRUM_DCB)	+= spectrum_dcb.o
 obj-$(CONFIG_MLXSW_MINIMAL)	+= mlxsw_minimal.o
 mlxsw_minimal-objs		:= minimal.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index bce8c2e..15b8086 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -43,6 +43,7 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_KVD_SINGLE_MIN_SIZE,
 	MLXSW_RES_ID_KVD_DOUBLE_MIN_SIZE,
 	MLXSW_RES_ID_MAX_TRAP_GROUPS,
+	MLXSW_RES_ID_COUNTER_POOL_SIZE,
 	MLXSW_RES_ID_MAX_SPAN,
 	MLXSW_RES_ID_MAX_SYSTEM_PORT,
 	MLXSW_RES_ID_MAX_LAG,
@@ -75,6 +76,7 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_KVD_SINGLE_MIN_SIZE] = 0x1002,
 	[MLXSW_RES_ID_KVD_DOUBLE_MIN_SIZE] = 0x1003,
 	[MLXSW_RES_ID_MAX_TRAP_GROUPS] = 0x2201,
+	[MLXSW_RES_ID_COUNTER_POOL_SIZE] = 0x2410,
 	[MLXSW_RES_ID_MAX_SPAN] = 0x2420,
 	[MLXSW_RES_ID_MAX_SYSTEM_PORT] = 0x2502,
 	[MLXSW_RES_ID_MAX_LAG] = 0x2520,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 2104ee4..b8237f9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -66,6 +66,7 @@
 #include "port.h"
 #include "trap.h"
 #include "txheader.h"
+#include "spectrum_cnt.h"
 
 static const char mlxsw_sp_driver_name[] = "mlxsw_spectrum";
 static const char mlxsw_sp_driver_version[] = "1.0";
@@ -3224,6 +3225,12 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_acl_init;
 	}
 
+	err = mlxsw_sp_counter_pool_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to init counter pool\n");
+		goto err_counter_pool_init;
+	}
+
 	err = mlxsw_sp_ports_create(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to create ports\n");
@@ -3233,6 +3240,8 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 	return 0;
 
 err_ports_create:
+	mlxsw_sp_counter_pool_fini(mlxsw_sp);
+err_counter_pool_init:
 	mlxsw_sp_acl_fini(mlxsw_sp);
 err_acl_init:
 	mlxsw_sp_span_fini(mlxsw_sp);
@@ -3255,6 +3264,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
 	mlxsw_sp_ports_remove(mlxsw_sp);
+	mlxsw_sp_counter_pool_fini(mlxsw_sp);
 	mlxsw_sp_acl_fini(mlxsw_sp);
 	mlxsw_sp_span_fini(mlxsw_sp);
 	mlxsw_sp_router_fini(mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 3bc1b09..dd59a9b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -246,6 +246,7 @@ struct mlxsw_sp_router {
 };
 
 struct mlxsw_sp_acl;
+struct mlxsw_sp_counter_pool;
 
 struct mlxsw_sp {
 	struct {
@@ -281,6 +282,7 @@ struct mlxsw_sp {
 		DECLARE_BITMAP(usage, MLXSW_SP_KVD_LINEAR_SIZE);
 	} kvdl;
 
+	struct mlxsw_sp_counter_pool *counter_pool;
 	struct {
 		struct mlxsw_sp_span_entry *entries;
 		int entries_count;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
new file mode 100644
index 0000000..0cae75c
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
@@ -0,0 +1,177 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
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
+#include <linux/kernel.h>
+#include <linux/bitops.h>
+
+#include "spectrum_cnt.h"
+
+#define MLXSW_SP_COUNTER_POOL_BANK_SIZE 4096
+
+struct mlxsw_sp_counter_sub_pool {
+	unsigned int base_index;
+	unsigned int size;
+	unsigned int entry_size;
+	unsigned int bank_count;
+};
+
+struct mlxsw_sp_counter_pool {
+	unsigned int pool_size;
+	unsigned long *usage; /* Usage bitmap */
+	struct mlxsw_sp_counter_sub_pool *sub_pools;
+};
+
+static struct mlxsw_sp_counter_sub_pool mlxsw_sp_counter_sub_pools[] = {};
+
+static int mlxsw_sp_counter_pool_validate(struct mlxsw_sp *mlxsw_sp)
+{
+	unsigned int total_bank_config = 0;
+	unsigned int pool_size;
+	int i;
+
+	pool_size = MLXSW_CORE_RES_GET(mlxsw_sp->core, COUNTER_POOL_SIZE);
+	/* Check config is valid, no bank over subscription */
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_counter_sub_pools); i++)
+		total_bank_config += mlxsw_sp_counter_sub_pools[i].bank_count;
+	if (total_bank_config > pool_size / MLXSW_SP_COUNTER_POOL_BANK_SIZE + 1)
+		return -EINVAL;
+	return 0;
+}
+
+int mlxsw_sp_counter_pool_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_counter_sub_pool *sub_pool;
+	struct mlxsw_sp_counter_pool *pool;
+	unsigned int base_index;
+	unsigned int map_size;
+	int i;
+	int err;
+
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, COUNTER_POOL_SIZE))
+		return -EIO;
+
+	err = mlxsw_sp_counter_pool_validate(mlxsw_sp);
+	if (err)
+		return err;
+
+	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
+	if (!pool)
+		return -ENOMEM;
+
+	pool->pool_size = MLXSW_CORE_RES_GET(mlxsw_sp->core, COUNTER_POOL_SIZE);
+	map_size = BITS_TO_LONGS(pool->pool_size) * sizeof(unsigned long);
+
+	pool->usage = kzalloc(map_size, GFP_KERNEL);
+	if (!pool->usage) {
+		err = -ENOMEM;
+		goto err_usage_alloc;
+	}
+
+	pool->sub_pools = mlxsw_sp_counter_sub_pools;
+	/* Allocation is based on bank count which should be
+	 * specified for each sub pool statically.
+	 */
+	base_index = 0;
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_counter_sub_pools); i++) {
+		sub_pool = &pool->sub_pools[i];
+		sub_pool->size = sub_pool->bank_count *
+				 MLXSW_SP_COUNTER_POOL_BANK_SIZE;
+		sub_pool->base_index = base_index;
+		base_index += sub_pool->size;
+		/* The last bank can't be fully used */
+		if (sub_pool->base_index + sub_pool->size > pool->pool_size)
+			sub_pool->size = pool->pool_size - sub_pool->base_index;
+	}
+
+	mlxsw_sp->counter_pool = pool;
+	return 0;
+
+err_usage_alloc:
+	kfree(pool);
+	return err;
+}
+
+void mlxsw_sp_counter_pool_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_counter_pool *pool = mlxsw_sp->counter_pool;
+
+	WARN_ON(find_first_bit(pool->usage, pool->pool_size) !=
+			       pool->pool_size);
+	kfree(pool->usage);
+	kfree(pool);
+}
+
+int mlxsw_sp_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+			   enum mlxsw_sp_counter_sub_pool_id sub_pool_id,
+			   unsigned int *p_counter_index)
+{
+	struct mlxsw_sp_counter_pool *pool = mlxsw_sp->counter_pool;
+	struct mlxsw_sp_counter_sub_pool *sub_pool;
+	unsigned int entry_index;
+	unsigned int stop_index;
+	int i;
+
+	sub_pool = &mlxsw_sp_counter_sub_pools[sub_pool_id];
+	stop_index = sub_pool->base_index + sub_pool->size;
+	entry_index = sub_pool->base_index;
+
+	entry_index = find_next_zero_bit(pool->usage, stop_index, entry_index);
+	if (entry_index == stop_index)
+		return -ENOBUFS;
+	/* The sub-pools can contain non-integer number of entries
+	 * so we must check for overflow
+	 */
+	if (entry_index + sub_pool->entry_size > stop_index)
+		return -ENOBUFS;
+	for (i = 0; i < sub_pool->entry_size; i++)
+		__set_bit(entry_index + i, pool->usage);
+
+	*p_counter_index = entry_index;
+	return 0;
+}
+
+void mlxsw_sp_counter_free(struct mlxsw_sp *mlxsw_sp,
+			   enum mlxsw_sp_counter_sub_pool_id sub_pool_id,
+			   unsigned int counter_index)
+{
+	struct mlxsw_sp_counter_pool *pool = mlxsw_sp->counter_pool;
+	struct mlxsw_sp_counter_sub_pool *sub_pool;
+	int i;
+
+	if (WARN_ON(counter_index >= pool->pool_size))
+		return;
+	sub_pool = &mlxsw_sp_counter_sub_pools[sub_pool_id];
+	for (i = 0; i < sub_pool->entry_size; i++)
+		__clear_bit(counter_index + i, pool->usage);
+}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
new file mode 100644
index 0000000..5bf42d9
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
@@ -0,0 +1,54 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2017 Arkadi Sharshevsky <arkdis@mellanox.com>
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
+#ifndef _MLXSW_SPECTRUM_CNT_H
+#define _MLXSW_SPECTRUM_CNT_H
+
+#include "spectrum.h"
+
+enum mlxsw_sp_counter_sub_pool_id {
+	/* Placeholder before first pool registered */
+	MLXSW_SP_COUNTER_SUB_POOL_PLACEHOLDER,
+};
+
+int mlxsw_sp_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+			   enum mlxsw_sp_counter_sub_pool_id sub_pool_id,
+			   unsigned int *p_counter_index);
+void mlxsw_sp_counter_free(struct mlxsw_sp *mlxsw_sp,
+			   enum mlxsw_sp_counter_sub_pool_id sub_pool_id,
+			   unsigned int counter_index);
+int mlxsw_sp_counter_pool_init(struct mlxsw_sp *mlxsw_sp);
+void mlxsw_sp_counter_pool_fini(struct mlxsw_sp *mlxsw_sp);
+
+#endif
-- 
2.7.4
