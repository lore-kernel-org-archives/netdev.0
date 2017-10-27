From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v4 06/10] bnxt: Add devlink support for config get/set
Date: Fri, 27 Oct 2017 16:54:10 -0400
Message-ID: <1509137654-1580-7-git-send-email-steven.lin1@broadcom.com>
References: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:38557 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932576AbdJ0Uyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:54:35 -0400
In-Reply-To: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements get and set of configuration parameters using new devlink
config get/set API.  Parameters themselves defined in later patches.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 258 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  17 ++
 2 files changed, 263 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
index 402fa32..8a6037f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
@@ -14,26 +14,260 @@
 #include "bnxt_vfr.h"
 #include "bnxt_devlink.h"
 
-static const struct devlink_ops bnxt_dl_ops = {
-#ifdef CONFIG_BNXT_SRIOV
-	.eswitch_mode_set = bnxt_dl_eswitch_mode_set,
-	.eswitch_mode_get = bnxt_dl_eswitch_mode_get,
-#endif /* CONFIG_BNXT_SRIOV */
+struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
 };
 
-int bnxt_dl_register(struct bnxt *bp)
+#define BNXT_NUM_DRV_CFGPARAM ARRAY_SIZE(bnxt_drv_cfgparam_list)
+
+static int bnxt_nvm_read(struct bnxt *bp, int nvm_param, int idx,
+			 void *buf, int size)
 {
-	struct devlink *dl;
+	struct hwrm_nvm_get_variable_input req = {0};
+	dma_addr_t dest_data_dma_addr;
+	void *dest_data_addr = NULL;
+	int bytesize;
 	int rc;
 
-	if (!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV))
-		return 0;
+	bytesize = roundup(size, BITS_PER_BYTE) / BITS_PER_BYTE;
+	dest_data_addr = dma_alloc_coherent(&bp->pdev->dev, bytesize,
+					    &dest_data_dma_addr, GFP_KERNEL);
+	if (!dest_data_addr)
+		return -ENOMEM;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_NVM_GET_VARIABLE, -1, -1);
+	req.dest_data_addr = cpu_to_le64(dest_data_dma_addr);
+	req.data_len = cpu_to_le16(size);
+	req.option_num = cpu_to_le16(nvm_param);
+	req.index_0 = cpu_to_le16(idx);
+	if (idx != 0)
+		req.dimensions = cpu_to_le16(1);
+
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+
+	memcpy(buf, dest_data_addr, bytesize);
+
+	dma_free_coherent(&bp->pdev->dev, bytesize, dest_data_addr,
+			  dest_data_dma_addr);
+
+	return rc;
+}
+
+static int bnxt_nvm_write(struct bnxt *bp, int nvm_param, int idx,
+			  const void *buf, int size)
+{
+	struct hwrm_nvm_set_variable_input req = {0};
+	dma_addr_t src_data_dma_addr;
+	void *src_data_addr = NULL;
+	int bytesize;
+	int rc;
+
+	bytesize = roundup(size, BITS_PER_BYTE) / BITS_PER_BYTE;
+
+	src_data_addr = dma_alloc_coherent(&bp->pdev->dev, bytesize,
+					   &src_data_dma_addr, GFP_KERNEL);
+	if (!src_data_addr)
+		return -ENOMEM;
+
+	memcpy(src_data_addr, buf, bytesize);
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_NVM_SET_VARIABLE, -1, -1);
+	req.src_data_addr = cpu_to_le64(src_data_dma_addr);
+	req.data_len = cpu_to_le16(size);
+	req.option_num = cpu_to_le16(nvm_param);
+	req.index_0 = cpu_to_le16(idx);
+	if (idx != 0)
+		req.dimensions = cpu_to_le16(1);
+
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+
+	dma_free_coherent(&bp->pdev->dev, bytesize, src_data_addr,
+			  src_data_dma_addr);
 
-	if (bp->hwrm_spec_code < 0x10803) {
-		netdev_warn(bp->dev, "Firmware does not support SR-IOV E-Switch SWITCHDEV mode.\n");
-		return -ENOTSUPP;
+	return 0;
+}
+
+static int bnxt_dl_perm_config_set(struct devlink *devlink,
+				   enum devlink_perm_config_param param,
+				   u8 type,
+				   union devlink_perm_config_value *value,
+				   u8 *restart_reqd)
+{
+	struct bnxt *bp = bnxt_get_bp_from_dl(devlink);
+	struct bnxt_drv_cfgparam *entry = NULL;
+	u32 value_int;
+	u32 bytesize;
+	int idx = 0;
+	int ret = 0;
+	u16 val16;
+	u8 val8;
+	int i;
+
+	*restart_reqd = 0;
+
+	/* Find parameter in table */
+	for (i = 0; i < BNXT_NUM_DRV_CFGPARAM; i++) {
+		if (param == bnxt_drv_cfgparam_list[i].param) {
+			entry = &bnxt_drv_cfgparam_list[i];
+			break;
+		}
+	}
+
+	/* Not found */
+	if (!entry)
+		return -EINVAL;
+
+	/* Check to see if this func type can access variable */
+	if (BNXT_PF(bp) && !(entry->func & BNXT_DRV_PF))
+		return -EOPNOTSUPP;
+	if (BNXT_VF(bp) && !(entry->func & BNXT_DRV_VF))
+		return -EOPNOTSUPP;
+
+	/* If parameter is per port or function, compute index */
+	if (entry->appl == BNXT_DRV_APPL_PORT) {
+		idx = bp->pf.port_id;
+	} else if (entry->appl == BNXT_DRV_APPL_FUNCTION) {
+		if (BNXT_PF(bp))
+			idx = bp->pf.fw_fid - BNXT_FIRST_PF_FID;
 	}
 
+	bytesize = roundup(entry->bitlength, BITS_PER_BYTE) / BITS_PER_BYTE;
+
+	/* Type expected by device may or may not be the same as type passed
+	 * in from devlink API.  So first convert to an interval u32 value,
+	 * then to type needed by device.
+	 */
+	if (type == NLA_U8) {
+		value_int = value->value8;
+	} else if (type == NLA_U16) {
+		value_int = value->value16;
+	} else if (type == NLA_U32) {
+		value_int = value->value32;
+	} else {
+		/* Unsupported type */
+		return -EINVAL;
+	}
+
+	if (bytesize == 1) {
+		val8 = value_int;
+		ret = bnxt_nvm_write(bp, entry->nvm_param, idx, &val8,
+				     entry->bitlength);
+	} else if (bytesize == 2) {
+		val16 = value_int;
+		ret = bnxt_nvm_write(bp, entry->nvm_param, idx, &val16,
+				     entry->bitlength);
+	} else {
+		ret = bnxt_nvm_write(bp, entry->nvm_param, idx, &value_int,
+				     entry->bitlength);
+	}
+
+	/* Restart required for all nvm parameter writes */
+	*restart_reqd = 1;
+
+	return ret;
+}
+
+static int bnxt_dl_perm_config_get(struct devlink *devlink,
+				   enum devlink_perm_config_param param,
+				   u8 type,
+				   union devlink_perm_config_value *value)
+{
+	struct bnxt *bp = bnxt_get_bp_from_dl(devlink);
+	struct bnxt_drv_cfgparam *entry = NULL;
+	u32 value_int;
+	u32 bytesize;
+	int idx = 0;
+	int err = 0;
+	void *data;
+	u16 val16;
+	u8 val8;
+	int i;
+
+	/* Find parameter in table */
+	for (i = 0; i < BNXT_NUM_DRV_CFGPARAM; i++) {
+		if (param == bnxt_drv_cfgparam_list[i].param) {
+			entry = &bnxt_drv_cfgparam_list[i];
+			break;
+		}
+	}
+
+	/* Not found */
+	if (!entry)
+		return -EINVAL;
+
+	/* Check to see if this func type can access variable */
+	if (BNXT_PF(bp) && !(entry->func & BNXT_DRV_PF))
+		return -EOPNOTSUPP;
+	if (BNXT_VF(bp) && !(entry->func & BNXT_DRV_VF))
+		return -EOPNOTSUPP;
+
+	/* If parameter is per port or function, compute index */
+	if (entry->appl == BNXT_DRV_APPL_PORT) {
+		idx = bp->pf.port_id;
+	} else if (entry->appl == BNXT_DRV_APPL_FUNCTION) {
+		if (BNXT_PF(bp))
+			idx = bp->pf.fw_fid - BNXT_FIRST_PF_FID;
+	}
+
+	/* Allocate space, retrieve value, and copy to result */
+	bytesize = roundup(entry->bitlength, BITS_PER_BYTE) / BITS_PER_BYTE;
+	data = kmalloc(bytesize, GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+	err = bnxt_nvm_read(bp, entry->nvm_param, idx, data, entry->bitlength);
+	if (err)
+		goto err_data;
+
+	/* Type returned by device may or may not be the same as type expected
+	 * by devlink API.  So first convert to an interval u32 value, then to
+	 * type expected by devlink.
+	 */
+	if (bytesize == 1) {
+		memcpy(&val8, data, sizeof(val8));
+		value_int = val8;
+	} else if (bytesize == 2) {
+		memcpy(&val16, data, sizeof(val16));
+		value_int = val16;
+	} else {
+		memcpy(&value_int, data, sizeof(value_int));
+	}
+
+	if (type == NLA_U8) {
+		value->value8 = value_int;
+	} else if (type == NLA_U16) {
+		value->value16 = value_int;
+	} else if (type == NLA_U32) {
+		value->value32 = value_int;
+	} else {
+		/* Unsupported type */
+		err = -EINVAL;
+	}
+
+err_data:
+	kfree(data);
+
+	return err;
+}
+
+static struct devlink_ops bnxt_dl_ops = {
+	.perm_config_get = bnxt_dl_perm_config_get,
+	.perm_config_set = bnxt_dl_perm_config_set,
+};
+
+int bnxt_dl_register(struct bnxt *bp)
+{
+	struct devlink *dl;
+	int rc;
+
+#ifdef CONFIG_BNXT_SRIOV
+	/* Add switchdev eswitch mode setting if SRIOV supported */
+	if (pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV) &&
+	    bp->hwrm_spec_code >= 0x10800) {
+		bnxt_dl_ops.eswitch_mode_set = bnxt_dl_eswitch_mode_set;
+		bnxt_dl_ops.eswitch_mode_get = bnxt_dl_eswitch_mode_get;
+	} else
+#endif /* CONFIG_BNXT_SRIOV */
+		netdev_warn(bp->dev, "SR-IOV E-Switch SWITCHDEV mode not supported.\n");
+
 	dl = devlink_alloc(&bnxt_dl_ops, sizeof(struct bnxt_dl));
 	if (!dl) {
 		netdev_warn(bp->dev, "devlink_alloc failed");
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h
index e92a35d..d843a81 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h
@@ -10,6 +10,23 @@
 #ifndef BNXT_DEVLINK_H
 #define BNXT_DEVLINK_H
 
+#define BNXT_DRV_PF 1
+#define BNXT_DRV_VF 2
+
+enum bnxt_drv_appl {
+	BNXT_DRV_APPL_SHARED,
+	BNXT_DRV_APPL_PORT,
+	BNXT_DRV_APPL_FUNCTION
+};
+
+struct bnxt_drv_cfgparam {
+	enum devlink_perm_config_param	param;
+	u8			func; /* BNXT_DRV_PF | BNXT_DRV_VF */
+	enum bnxt_drv_appl	appl; /* applicability (shared, func, port) */
+	u32			bitlength; /* length, in bits */
+	u32			nvm_param;
+};
+
 /* Struct to hold housekeeping info needed by devlink interface */
 struct bnxt_dl {
 	struct bnxt *bp;	/* back ptr to the controlling dev */
-- 
2.7.4
