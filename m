From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/16] mlxsw: Introduce simplistic KVD linear area manager
Date: Tue,  5 Jul 2016 11:27:47 +0200
Message-ID: <1467710872-20056-12-git-send-email-jiri@resnulli.us>
References: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36060 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbcGEJ2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 05:28:08 -0400
Received: by mail-wm0-f68.google.com with SMTP id c82so27228450wme.3
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 02:28:08 -0700 (PDT)
In-Reply-To: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is a very simple manager for KVD linear area. Currently, the
allocator will either allocate a single entry from pre-defined sub-area,
or in case more than one entry is needed, it will allocate 32-entry chunk
in other pre-defined sub-area.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |  3 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  6 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_kvdl.c    | 91 ++++++++++++++++++++++
 3 files changed, 99 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index ea05f8a..d20ae18 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -7,5 +7,6 @@ obj-$(CONFIG_MLXSW_SWITCHX2)	+= mlxsw_switchx2.o
 mlxsw_switchx2-objs		:= switchx2.o
 obj-$(CONFIG_MLXSW_SPECTRUM)	+= mlxsw_spectrum.o
 mlxsw_spectrum-objs		:= spectrum.o spectrum_buffers.o \
-				   spectrum_switchdev.o spectrum_router.o
+				   spectrum_switchdev.o spectrum_router.o \
+				   spectrum_kvdl.o
 mlxsw_spectrum-$(CONFIG_MLXSW_SPECTRUM_DCB)	+= spectrum_dcb.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index f7d34d8..e781128 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -253,6 +253,9 @@ struct mlxsw_sp {
 	u8 port_to_module[MLXSW_PORT_MAX_PORTS];
 	struct mlxsw_sp_sb sb;
 	struct mlxsw_sp_router router;
+	struct {
+		DECLARE_BITMAP(usage, MLXSW_SP_KVD_LINEAR_SIZE);
+	} kvdl;
 };
 
 static inline struct mlxsw_sp_upper *
@@ -539,4 +542,7 @@ int mlxsw_sp_router_neigh_construct(struct net_device *dev,
 void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
 				   struct neighbour *n);
 
+int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count);
+void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
+
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
new file mode 100644
index 0000000..ac321e8
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
@@ -0,0 +1,91 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
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
+#include "spectrum.h"
+
+#define MLXSW_SP_KVDL_SINGLE_BASE 0
+#define MLXSW_SP_KVDL_SINGLE_SIZE 16384
+#define MLXSW_SP_KVDL_CHUNKS_BASE \
+	(MLXSW_SP_KVDL_SINGLE_BASE + MLXSW_SP_KVDL_SINGLE_SIZE)
+#define MLXSW_SP_KVDL_CHUNKS_SIZE \
+	(MLXSW_SP_KVD_LINEAR_SIZE - MLXSW_SP_KVDL_CHUNKS_BASE)
+#define MLXSW_SP_CHUNK_MAX 32
+
+int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count)
+{
+	int entry_index;
+	int size;
+	int type_base;
+	int type_size;
+	int type_entries;
+
+	if (entry_count == 0 || entry_count > MLXSW_SP_CHUNK_MAX) {
+		return -EINVAL;
+	} else if (entry_count == 1) {
+		type_base = MLXSW_SP_KVDL_SINGLE_BASE;
+		type_size = MLXSW_SP_KVDL_SINGLE_SIZE;
+		type_entries = 1;
+	} else {
+		type_base = MLXSW_SP_KVDL_CHUNKS_BASE;
+		type_size = MLXSW_SP_KVDL_CHUNKS_SIZE;
+		type_entries = MLXSW_SP_CHUNK_MAX;
+	}
+
+	entry_index = type_base;
+	size = type_base + type_size;
+	for_each_clear_bit_from(entry_index, mlxsw_sp->kvdl.usage, size) {
+		int i;
+
+		for (i = 0; i < type_entries; i++)
+			set_bit(entry_index + i, mlxsw_sp->kvdl.usage);
+		return entry_index;
+	}
+	return -ENOBUFS;
+}
+
+void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index)
+{
+	int type_entries;
+	int i;
+
+	if (entry_index < MLXSW_SP_KVDL_CHUNKS_BASE)
+		type_entries = 1;
+	else
+		type_entries = MLXSW_SP_CHUNK_MAX;
+	for (i = 0; i < type_entries; i++)
+		clear_bit(entry_index + i, mlxsw_sp->kvdl.usage);
+}
-- 
2.5.5
