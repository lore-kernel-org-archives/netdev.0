From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH 6/7] bnxt: Move generic devlink code to new file
Date: Tue, 17 Oct 2017 16:44:28 -0400
Message-ID: <1508273069-40461-7-git-send-email-steven.lin1@broadcom.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:49952 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760640AbdJQUos (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:44:48 -0400
In-Reply-To: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving generic devlink code (registration) out of VR-R code
into new bnxt_devlink file.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/Makefile       |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 65 +++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h | 39 ++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c     | 53 ++----------------
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h     | 37 ++-----------
 6 files changed, 112 insertions(+), 85 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h

diff --git a/drivers/net/ethernet/broadcom/bnxt/Makefile b/drivers/net/ethernet/broadcom/bnxt/Makefile
index 457201f..59c8ec9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/Makefile
+++ b/drivers/net/ethernet/broadcom/bnxt/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_BNXT) += bnxt_en.o
 
-bnxt_en-y := bnxt.o bnxt_sriov.o bnxt_ethtool.o bnxt_dcb.o bnxt_ulp.o bnxt_xdp.o bnxt_vfr.o
+bnxt_en-y := bnxt.o bnxt_sriov.o bnxt_ethtool.o bnxt_dcb.o bnxt_ulp.o bnxt_xdp.o bnxt_vfr.o bnxt_devlink.o
 bnxt_en-$(CONFIG_BNXT_FLOWER_OFFLOAD) += bnxt_tc.o
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5ba4993..52cc38d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -61,6 +61,7 @@
 #include "bnxt_xdp.h"
 #include "bnxt_vfr.h"
 #include "bnxt_tc.h"
+#include "bnxt_devlink.h"
 
 #define BNXT_TX_TIMEOUT		(5 * HZ)
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
new file mode 100644
index 0000000..f3f6aa8
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
@@ -0,0 +1,65 @@
+/* Broadcom NetXtreme-C/E network driver.
+ *
+ * Copyright (c) 2017 Broadcom Limited
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include "bnxt_hsi.h"
+#include "bnxt.h"
+#include "bnxt_vfr.h"
+#include "bnxt_devlink.h"
+
+static const struct devlink_ops bnxt_dl_ops = {
+#ifdef CONFIG_BNXT_SRIOV
+	.eswitch_mode_set = bnxt_dl_eswitch_mode_set,
+	.eswitch_mode_get = bnxt_dl_eswitch_mode_get,
+#endif /* CONFIG_BNXT_SRIOV */
+};
+
+int bnxt_dl_register(struct bnxt *bp)
+{
+	struct devlink *dl;
+	int rc;
+
+	if (!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV))
+		return 0;
+
+	if (bp->hwrm_spec_code < 0x10800) {
+		netdev_warn(bp->dev, "Firmware does not support SR-IOV E-Switch SWITCHDEV mode.\n");
+		return -ENOTSUPP;
+	}
+
+	dl = devlink_alloc(&bnxt_dl_ops, sizeof(struct bnxt_dl));
+	if (!dl) {
+		netdev_warn(bp->dev, "devlink_alloc failed");
+		return -ENOMEM;
+	}
+
+	bnxt_link_bp_to_dl(bp, dl);
+	bp->eswitch_mode = DEVLINK_ESWITCH_MODE_LEGACY;
+	rc = devlink_register(dl, &bp->pdev->dev);
+	if (rc) {
+		bnxt_link_bp_to_dl(bp, NULL);
+		devlink_free(dl);
+		netdev_warn(bp->dev, "devlink_register failed. rc=%d", rc);
+		return rc;
+	}
+
+	return 0;
+}
+
+void bnxt_dl_unregister(struct bnxt *bp)
+{
+	struct devlink *dl = bp->dl;
+
+	if (!dl)
+		return;
+
+	devlink_unregister(dl);
+	devlink_free(dl);
+}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h
new file mode 100644
index 0000000..e92a35d
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h
@@ -0,0 +1,39 @@
+/* Broadcom NetXtreme-C/E network driver.
+ *
+ * Copyright (c) 2017 Broadcom Limited
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#ifndef BNXT_DEVLINK_H
+#define BNXT_DEVLINK_H
+
+/* Struct to hold housekeeping info needed by devlink interface */
+struct bnxt_dl {
+	struct bnxt *bp;	/* back ptr to the controlling dev */
+};
+
+static inline struct bnxt *bnxt_get_bp_from_dl(struct devlink *dl)
+{
+	return ((struct bnxt_dl *)devlink_priv(dl))->bp;
+}
+
+/* To clear devlink pointer from bp, pass NULL dl */
+static inline void bnxt_link_bp_to_dl(struct bnxt *bp, struct devlink *dl)
+{
+	bp->dl = dl;
+
+	/* add a back pointer in dl to bp */
+	if (dl) {
+		struct bnxt_dl *bp_dl = devlink_priv(dl);
+
+		bp_dl->bp = bp;
+	}
+}
+
+int bnxt_dl_register(struct bnxt *bp);
+void bnxt_dl_unregister(struct bnxt *bp);
+
+#endif /* BNXT_DEVLINK_H */
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index e75db04..b76849f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -16,6 +16,7 @@
 #include "bnxt_hsi.h"
 #include "bnxt.h"
 #include "bnxt_vfr.h"
+#include "bnxt_devlink.h"
 #include "bnxt_tc.h"
 
 #ifdef CONFIG_BNXT_SRIOV
@@ -416,7 +417,7 @@ static int bnxt_vf_reps_create(struct bnxt *bp)
 }
 
 /* Devlink related routines */
-static int bnxt_dl_eswitch_mode_get(struct devlink *devlink, u16 *mode)
+int bnxt_dl_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 {
 	struct bnxt *bp = bnxt_get_bp_from_dl(devlink);
 
@@ -424,7 +425,7 @@ static int bnxt_dl_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 	return 0;
 }
 
-static int bnxt_dl_eswitch_mode_set(struct devlink *devlink, u16 mode)
+int bnxt_dl_eswitch_mode_set(struct devlink *devlink, u16 mode)
 {
 	struct bnxt *bp = bnxt_get_bp_from_dl(devlink);
 	int rc = 0;
@@ -462,52 +463,4 @@ static int bnxt_dl_eswitch_mode_set(struct devlink *devlink, u16 mode)
 	return rc;
 }
 
-static const struct devlink_ops bnxt_dl_ops = {
-	.eswitch_mode_set = bnxt_dl_eswitch_mode_set,
-	.eswitch_mode_get = bnxt_dl_eswitch_mode_get
-};
-
-int bnxt_dl_register(struct bnxt *bp)
-{
-	struct devlink *dl;
-	int rc;
-
-	if (!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV))
-		return 0;
-
-	if (bp->hwrm_spec_code < 0x10800) {
-		netdev_warn(bp->dev, "Firmware does not support SR-IOV E-Switch SWITCHDEV mode.\n");
-		return -ENOTSUPP;
-	}
-
-	dl = devlink_alloc(&bnxt_dl_ops, sizeof(struct bnxt_dl));
-	if (!dl) {
-		netdev_warn(bp->dev, "devlink_alloc failed");
-		return -ENOMEM;
-	}
-
-	bnxt_link_bp_to_dl(bp, dl);
-	bp->eswitch_mode = DEVLINK_ESWITCH_MODE_LEGACY;
-	rc = devlink_register(dl, &bp->pdev->dev);
-	if (rc) {
-		bnxt_link_bp_to_dl(bp, NULL);
-		devlink_free(dl);
-		netdev_warn(bp->dev, "devlink_register failed. rc=%d", rc);
-		return rc;
-	}
-
-	return 0;
-}
-
-void bnxt_dl_unregister(struct bnxt *bp)
-{
-	struct devlink *dl = bp->dl;
-
-	if (!dl)
-		return;
-
-	devlink_unregister(dl);
-	devlink_free(dl);
-}
-
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
index 7787cd24..fb06bbe 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
@@ -14,31 +14,6 @@
 
 #define	MAX_CFA_CODE			65536
 
-/* Struct to hold housekeeping info needed by devlink interface */
-struct bnxt_dl {
-	struct bnxt *bp;	/* back ptr to the controlling dev */
-};
-
-static inline struct bnxt *bnxt_get_bp_from_dl(struct devlink *dl)
-{
-	return ((struct bnxt_dl *)devlink_priv(dl))->bp;
-}
-
-/* To clear devlink pointer from bp, pass NULL dl */
-static inline void bnxt_link_bp_to_dl(struct bnxt *bp, struct devlink *dl)
-{
-	bp->dl = dl;
-
-	/* add a back pointer in dl to bp */
-	if (dl) {
-		struct bnxt_dl *bp_dl = devlink_priv(dl);
-
-		bp_dl->bp = bp;
-	}
-}
-
-int bnxt_dl_register(struct bnxt *bp);
-void bnxt_dl_unregister(struct bnxt *bp);
 void bnxt_vf_reps_destroy(struct bnxt *bp);
 void bnxt_vf_reps_close(struct bnxt *bp);
 void bnxt_vf_reps_open(struct bnxt *bp);
@@ -53,16 +28,10 @@ static inline u16 bnxt_vf_rep_get_fid(struct net_device *dev)
 	return bp->pf.vf[vf_rep->vf_idx].fw_fid;
 }
 
-#else
-
-static inline int bnxt_dl_register(struct bnxt *bp)
-{
-	return 0;
-}
+int bnxt_dl_eswitch_mode_get(struct devlink *devlink, u16 *mode);
+int bnxt_dl_eswitch_mode_set(struct devlink *devlink, u16 mode);
 
-static inline void bnxt_dl_unregister(struct bnxt *bp)
-{
-}
+#else
 
 static inline void bnxt_vf_reps_close(struct bnxt *bp)
 {
-- 
2.7.4
