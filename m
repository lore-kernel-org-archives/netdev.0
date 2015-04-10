From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH v2 net-next 2/2] sfc: Enable VF's via a write to the sysfs
 file sriov_numvfs
Date: Fri, 10 Apr 2015 10:07:28 +0100
Message-ID: <552792D0.30907@solarflare.com>
References: <5527926E.7030903@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:61734 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754977AbbDJJHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 05:07:37 -0400
In-Reply-To: <5527926E.7030903@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the use of sriov_configure on EF10
to enable Virtual Functions while the driver is loaded.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/Makefile      |  2 +-
 drivers/net/ethernet/sfc/ef10.c        |  1 +
 drivers/net/ethernet/sfc/ef10_sriov.c  | 46 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.h  |  2 ++
 drivers/net/ethernet/sfc/efx.c         | 23 +++++++++++++++++
 drivers/net/ethernet/sfc/net_driver.h  |  1 +
 drivers/net/ethernet/sfc/siena.c       |  1 +
 drivers/net/ethernet/sfc/siena_sriov.c |  5 ++++
 drivers/net/ethernet/sfc/siena_sriov.h |  1 +
 9 files changed, 81 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.c

diff --git a/drivers/net/ethernet/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
index a08a789..ce8470fe7 100644
--- a/drivers/net/ethernet/sfc/Makefile
+++ b/drivers/net/ethernet/sfc/Makefile
@@ -3,6 +3,6 @@ sfc-y			+= efx.o nic.o farch.o falcon.o siena.o ef10.o tx.o \
 			   tenxpress.o txc43128_phy.o falcon_boards.o \
 			   mcdi.o mcdi_port.o mcdi_mon.o ptp.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
-sfc-$(CONFIG_SFC_SRIOV)	+= sriov.o siena_sriov.o
+sfc-$(CONFIG_SFC_SRIOV)	+= sriov.o siena_sriov.o ef10_sriov.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4dab1b9..6890029 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3690,6 +3690,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.ptp_write_host_time = efx_ef10_ptp_write_host_time,
 	.ptp_set_ts_sync_events = efx_ef10_ptp_set_ts_sync_events,
 	.ptp_set_ts_config = efx_ef10_ptp_set_ts_config,
+	.sriov_configure = efx_ef10_sriov_configure,
 	.sriov_init = efx_ef10_sriov_init,
 	.sriov_fini = efx_ef10_sriov_fini,
 	.sriov_mac_address_changed = efx_ef10_sriov_mac_address_changed,
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
new file mode 100644
index 0000000..59e7cd2
--- /dev/null
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -0,0 +1,46 @@
+/****************************************************************************
+ * Driver for Solarflare network controllers and boards
+ * Copyright 2015 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+#include <linux/pci.h>
+#include <linux/module.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "nic.h"
+#include "mcdi_pcol.h"
+
+static int efx_ef10_pci_sriov_enable(struct efx_nic *efx, int num_vfs)
+{
+	int rc = 0;
+	struct pci_dev *dev = efx->pci_dev;
+
+	efx->vf_count = num_vfs;
+	rc = pci_enable_sriov(dev, num_vfs);
+	if (rc) {
+		efx->vf_count = 0;
+		netif_err(efx, probe, efx->net_dev,
+			  "Failed to enable SRIOV VFs\n");
+	}
+	return rc;
+}
+
+static int efx_ef10_pci_sriov_disable(struct efx_nic *efx)
+{
+	struct pci_dev *dev = efx->pci_dev;
+
+	efx->vf_count = 0;
+	pci_disable_sriov(dev);
+	return 0;
+}
+
+int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs)
+{
+	if (num_vfs == 0)
+		return efx_ef10_pci_sriov_disable(efx);
+	else
+		return efx_ef10_pci_sriov_enable(efx, num_vfs);
+}
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 1ba9ecc..5f26d1b 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -17,6 +17,8 @@ static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx)
 	return false;
 }
 
+int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs);
+
 static inline int efx_ef10_sriov_init(struct efx_nic *efx)
 {
 	return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 232c766..fa9ce2a 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3047,6 +3047,26 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	return rc;
 }
 
+/* efx_pci_sriov_configure returns the actual number of Virtual Functions
+ * enabled on success
+ */
+#ifdef CONFIG_SFC_SRIOV
+static int efx_pci_sriov_configure(struct pci_dev *dev, int num_vfs)
+{
+	int rc;
+	struct efx_nic *efx = pci_get_drvdata(dev);
+
+	if (efx->type->sriov_configure) {
+		rc = efx->type->sriov_configure(efx, num_vfs);
+		if (rc)
+			return rc;
+		else
+			return num_vfs;
+	} else
+		return -ENOSYS;
+}
+#endif
+
 static int efx_pm_freeze(struct device *dev)
 {
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
@@ -3269,6 +3289,9 @@ static struct pci_driver efx_pci_driver = {
 	.remove		= efx_pci_remove,
 	.driver.pm	= &efx_pm_ops,
 	.err_handler	= &efx_err_handlers,
+#ifdef CONFIG_SFC_SRIOV
+	.sriov_configure = efx_pci_sriov_configure,
+#endif
 };
 
 /**************************************************************************
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index ae0d145..a6f4d9a 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1330,6 +1330,7 @@ struct efx_nic_type {
 	int (*ptp_set_ts_sync_events)(struct efx_nic *efx, bool en, bool temp);
 	int (*ptp_set_ts_config)(struct efx_nic *efx,
 				 struct hwtstamp_config *init);
+	int (*sriov_configure)(struct efx_nic *efx, int num_vfs);
 	int (*sriov_init)(struct efx_nic *efx);
 	void (*sriov_fini)(struct efx_nic *efx);
 	void (*sriov_mac_address_changed)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 3671e1d..4979228 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -998,6 +998,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 #endif
 	.ptp_write_host_time = siena_ptp_write_host_time,
 	.ptp_set_ts_config = siena_ptp_set_ts_config,
+	.sriov_configure = efx_siena_sriov_configure,
 	.sriov_init = efx_siena_sriov_init,
 	.sriov_fini = efx_siena_sriov_fini,
 	.sriov_mac_address_changed = efx_siena_sriov_mac_address_changed,
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index b7c2816..442b38d 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -1666,3 +1666,8 @@ bool efx_siena_sriov_wanted(struct efx_nic *efx)
 {
 	return efx->vf_count != 0;
 }
+
+int efx_siena_sriov_configure(struct efx_nic *efx, int num_vfs)
+{
+	return 0;
+}
diff --git a/drivers/net/ethernet/sfc/siena_sriov.h b/drivers/net/ethernet/sfc/siena_sriov.h
index b3a08d1..64e3e01 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.h
+++ b/drivers/net/ethernet/sfc/siena_sriov.h
@@ -41,6 +41,7 @@
 	((EFX_MAX_VF_EVQ_SIZE + 2 * EFX_MAX_DMAQ_SIZE) *	\
 	 sizeof(efx_qword_t) / EFX_BUF_SIZE)
 
+int efx_siena_sriov_configure(struct efx_nic *efx, int num_vfs);
 int efx_siena_sriov_init(struct efx_nic *efx);
 void efx_siena_sriov_fini(struct efx_nic *efx);
 void efx_siena_sriov_mac_address_changed(struct efx_nic *efx);
