From: Neel Patel <neepatel@cisco.com>
Subject: [PATCH v3 2/3] drivers/net: enic: Add an interface for USNIC to interact with firmware
Date: Fri, 16 Aug 2013 15:47:40 -0700
Message-ID: <1376693261-1949-3-git-send-email-neepatel@cisco.com>
References: <1376693261-1949-1-git-send-email-neepatel@cisco.com>
Cc: umalhi@cisco.com, Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>,
	Christian Benvenuti <benve@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:39998 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757840Ab3HPWrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:47:45 -0400
In-Reply-To: <1376693261-1949-1-git-send-email-neepatel@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an interface for USNIC to proxy firmware commands
through ENIC.

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/ethernet/cisco/enic/Makefile    |  2 +-
 drivers/net/ethernet/cisco/enic/enic.h      |  1 +
 drivers/net/ethernet/cisco/enic/enic_api.c  | 48 +++++++++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_api.h  | 30 ++++++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c |  3 ++
 5 files changed, 83 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_api.c
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_api.h

diff --git a/drivers/net/ethernet/cisco/enic/Makefile b/drivers/net/ethernet/cisco/enic/Makefile
index e52296d..239e1e4 100644
--- a/drivers/net/ethernet/cisco/enic/Makefile
+++ b/drivers/net/ethernet/cisco/enic/Makefile
@@ -2,5 +2,5 @@ obj-$(CONFIG_ENIC) := enic.o
 
 enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
 	enic_res.o enic_dev.o enic_pp.o vnic_dev.o vnic_rq.o vnic_vic.o \
-	enic_ethtool.o
+	enic_ethtool.o enic_api.o
 
diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 75e842d..cacca29 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -96,6 +96,7 @@ struct enic {
 #ifdef CONFIG_PCI_IOV
 	u16 num_vfs;
 #endif
+	spinlock_t enic_api_lock;
 	struct enic_port_profile *pp;
 
 	/* work queue cache line section */
diff --git a/drivers/net/ethernet/cisco/enic/enic_api.c b/drivers/net/ethernet/cisco/enic/enic_api.c
new file mode 100644
index 0000000..e13efbd
--- /dev/null
+++ b/drivers/net/ethernet/cisco/enic/enic_api.c
@@ -0,0 +1,48 @@
+/**
+ * Copyright 2013 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
+
+#include "vnic_dev.h"
+#include "vnic_devcmd.h"
+
+#include "enic_res.h"
+#include "enic.h"
+#include "enic_api.h"
+
+int enic_api_devcmd_proxy_by_index(struct net_device *netdev, int vf,
+	enum vnic_devcmd_cmd cmd, u64 *a0, u64 *a1, int wait)
+{
+	int err;
+	struct enic *enic = netdev_priv(netdev);
+	struct vnic_dev *vdev = enic->vdev;
+
+	spin_lock(&enic->enic_api_lock);
+	spin_lock(&enic->devcmd_lock);
+
+	vnic_dev_cmd_proxy_by_index_start(vdev, vf);
+	err = vnic_dev_cmd(vdev, cmd, a0, a1, wait);
+	vnic_dev_cmd_proxy_end(vdev);
+
+	spin_unlock(&enic->devcmd_lock);
+	spin_unlock(&enic->enic_api_lock);
+
+	return err;
+}
+EXPORT_SYMBOL(enic_api_devcmd_proxy_by_index);
diff --git a/drivers/net/ethernet/cisco/enic/enic_api.h b/drivers/net/ethernet/cisco/enic/enic_api.h
new file mode 100644
index 0000000..6b9f925
--- /dev/null
+++ b/drivers/net/ethernet/cisco/enic/enic_api.h
@@ -0,0 +1,30 @@
+/**
+ * Copyright 2013 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef __ENIC_API_H__
+#define __ENIC_API_H__
+
+#include <linux/netdevice.h>
+
+#include "vnic_dev.h"
+#include "vnic_devcmd.h"
+
+int enic_api_devcmd_proxy_by_index(struct net_device *netdev, int vf,
+	enum vnic_devcmd_cmd cmd, u64 *a0, u64 *a1, int wait);
+
+#endif
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index b12b32b..7f8891b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1733,6 +1733,7 @@ static void enic_reset(struct work_struct *work)
 
 	rtnl_lock();
 
+	spin_lock(&enic->enic_api_lock);
 	enic_dev_hang_notify(enic);
 	enic_stop(enic->netdev);
 	enic_dev_hang_reset(enic);
@@ -1741,6 +1742,7 @@ static void enic_reset(struct work_struct *work)
 	enic_set_rss_nic_cfg(enic);
 	enic_dev_set_ig_vlan_rewrite_mode(enic);
 	enic_open(enic->netdev);
+	spin_unlock(&enic->enic_api_lock);
 
 	rtnl_unlock();
 }
@@ -2153,6 +2155,7 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 
 	spin_lock_init(&enic->devcmd_lock);
+	spin_lock_init(&enic->enic_api_lock);
 
 	/*
 	 * Set ingress vlan rewrite mode before vnic initialization
-- 
1.8.4-rc0
