From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next V2 14/27] RDMA/netlink: Add nldev initialization flows
Date: Mon,  3 Jul 2017 09:28:17 +0300
Message-ID: <20170703062830.30361-15-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170703062830.30361-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add nldev init and exit flows to the RDMA/core.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/core/Makefile |  4 +++-
 drivers/infiniband/core/device.c |  2 ++
 drivers/infiniband/core/nldev.c  | 45 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 1 deletion(-)
 create mode 100644 drivers/infiniband/core/nldev.c

diff --git a/drivers/infiniband/core/Makefile b/drivers/infiniband/core/Makefile
index 6ebd9ad95010..d260c5ecf656 100644
--- a/drivers/infiniband/core/Makefile
+++ b/drivers/infiniband/core/Makefile
@@ -10,7 +10,9 @@ obj-$(CONFIG_INFINIBAND_USER_ACCESS) +=	ib_uverbs.o ib_ucm.o \
 ib_core-y :=			packer.o ud_header.o verbs.o cq.o rw.o sysfs.o \
 				device.o fmr_pool.o cache.o netlink.o \
 				roce_gid_mgmt.o mr_pool.o addr.o sa_query.o \
-				multicast.o mad.o smi.o agent.o mad_rmpp.o
+				multicast.o mad.o smi.o agent.o mad_rmpp.o \
+				nldev.o
+
 ib_core-$(CONFIG_INFINIBAND_USER_MEM) += umem.o
 ib_core-$(CONFIG_INFINIBAND_ON_DEMAND_PAGING) += umem_odp.o umem_rbtree.o
 ib_core-$(CONFIG_CGROUP_RDMA) += cgroup.o
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 4aaf51db528a..646c98acc43b 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -1128,6 +1128,7 @@ static int __init ib_core_init(void)
 		goto err_mad;
 	}
 
+	nldev_init();
 	rdma_nl_register(RDMA_NL_LS, ibnl_ls_cb_table);
 	ib_cache_setup();
 
@@ -1151,6 +1152,7 @@ static int __init ib_core_init(void)
 static void __exit ib_core_cleanup(void)
 {
 	ib_cache_cleanup();
+	nldev_exit();
 	rdma_nl_unregister(RDMA_NL_LS);
 	ib_sa_cleanup();
 	ib_mad_cleanup();
diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
new file mode 100644
index 000000000000..1d1e4f214874
--- /dev/null
+++ b/drivers/infiniband/core/nldev.c
@@ -0,0 +1,45 @@
+/*
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
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
+#include <rdma/rdma_netlink.h>
+
+#include "core_priv.h"
+
+void __init nldev_init(void)
+{
+	rdma_nl_register(RDMA_NL_NLDEV, NULL);
+}
+
+void __exit nldev_exit(void)
+{
+	rdma_nl_unregister(RDMA_NL_NLDEV);
+}
-- 
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
