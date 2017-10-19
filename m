From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v2 6/6] bnxt: Add devlink support for config get/set
Date: Thu, 19 Oct 2017 15:17:10 -0400
Message-ID: <1508440630-25830-7-git-send-email-steven.lin1@broadcom.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:42598 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751836AbdJSTR3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:17:29 -0400
In-Reply-To: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements get and set of configuration parameters using new devlink
config get/set API.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 245 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  17 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 100 +++++++++
 3 files changed, 356 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
index f3f6aa8..88a1f1d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
@@ -14,11 +14,244 @@
 #include "bnxt_vfr.h"
 #include "bnxt_devlink.h"
 
-static const struct devlink_ops bnxt_dl_ops = {
+struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
+	{DEVLINK_PERM_CONFIG_SRIOV_ENABLED, BNXT_DRV_PF,
+		BNXT_DRV_APPL_SHARED, 1, 401},
+	{DEVLINK_PERM_CONFIG_NUM_VF_PER_PF, BNXT_DRV_PF,
+		BNXT_DRV_APPL_FUNCTION, 8, 404},
+	{DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT, BNXT_DRV_PF,
+		BNXT_DRV_APPL_SHARED, 10, 108},
+	{DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF, BNXT_DRV_PF,
+		BNXT_DRV_APPL_FUNCTION, 10, 406},
+};
+
+#define BNXT_NUM_DRV_CFGPARAM ARRAY_SIZE(bnxt_drv_cfgparam_list)
+
+static int bnxt_nvm_read(struct bnxt *bp, int nvm_param, int idx,
+			 void *buf, int size)
+{
+	struct hwrm_nvm_get_variable_input req = {0};
+	void *dest_data_addr = NULL;
+	dma_addr_t dest_data_dma_addr;
+	int rc;
+	int bytesize;
+
+	bytesize = (size + 7) / 8;
+	dest_data_addr = dma_alloc_coherent(&bp->pdev->dev, bytesize,
+					    &dest_data_dma_addr, GFP_KERNEL);
+	if (!dest_data_addr) {
+		netdev_err(bp->dev, "dma_alloc_coherent failure\n");
+		return -ENOMEM;
+	}
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_NVM_GET_VARIABLE, -1, -1);
+	req.dest_data_addr = cpu_to_le64(dest_data_dma_addr);
+	req.data_len = cpu_to_le16(size);
+	req.option_num = cpu_to_le16(nvm_param);
+	req.index_0 = cpu_to_le16(idx);
+	if (idx != 0)
+		req.dimensions = cpu_to_le16(1);
+
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
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
+	void *src_data_addr = NULL;
+	dma_addr_t src_data_dma_addr;
+	int rc;
+	int bytesize;
+
+	bytesize = (size + 7) / 8;
+
+	src_data_addr = dma_alloc_coherent(&bp->pdev->dev, bytesize,
+					   &src_data_dma_addr, GFP_KERNEL);
+	if (!src_data_addr) {
+		netdev_err(bp->dev, "dma_alloc_coherent failure\n");
+		return -ENOMEM;
+	}
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
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+
+	dma_free_coherent(&bp->pdev->dev, bytesize, src_data_addr,
+			  src_data_dma_addr);
+
+	return 0;
+}
+
+static int bnxt_dl_perm_config_set(struct devlink *devlink,
+				   u32 param, u32 value, u8 *restart_reqd)
+{
+	struct bnxt *bp = bnxt_get_bp_from_dl(devlink);
+	int i;
+	int idx = 0;
+	void *data;
+	int ret = 0;
+	u32 bytesize;
+	struct bnxt_drv_cfgparam *entry;
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
+	if (i == BNXT_NUM_DRV_CFGPARAM)
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
+#ifdef CONFIG_BNXT_SRIOV
+		else
+			idx = bp->vf.fw_fid - BNXT_FIRST_VF_FID;
+#endif /* CONFIG_BNXT_SRIOV */
+	}
+
+	bytesize = (entry->bitlength + 7) / 8;
+	data = kmalloc(bytesize, GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	if (bytesize == 1) {
+		u8 val8 = (value & 0xff);
+
+		memcpy(data, &val8, sizeof(u8));
+	} else if (bytesize == 2) {
+		u16 val16 = (value & 0xffff);
+
+		memcpy(data, &val16, sizeof(u16));
+	} else {
+		memcpy(data, &value, sizeof(u32));
+	}
+
+	ret = bnxt_nvm_write(bp, entry->nvm_param, idx, data,
+			     entry->bitlength);
+
+	/* Restart required for all nvm parameter writes */
+	*restart_reqd = 1;
+
+	kfree(data);
+
+	return ret;
+}
+
+static int bnxt_dl_perm_config_get(struct devlink *devlink, u32 param,
+				   u32 *value)
+{
+	struct bnxt *bp = bnxt_get_bp_from_dl(devlink);
+
+	int i;
+	int idx = 0;
+	void *data;
+	int ret = 0;
+	u32 bytesize;
+	struct bnxt_drv_cfgparam *entry;
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
+	if (i == BNXT_NUM_DRV_CFGPARAM)
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
+#ifdef CONFIG_BNXT_SRIOV
+		else
+			idx = bp->vf.fw_fid - BNXT_FIRST_VF_FID;
+#endif /* CONFIG_BNXT_SRIOV */
+	}
+
+	/* Allocate space, retrieve value, and copy to result */
+	bytesize = (entry->bitlength + 7) / 8;
+	data = kmalloc(bytesize, GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+	ret = bnxt_nvm_read(bp, entry->nvm_param, idx, data, entry->bitlength);
+
+	if (ret) {
+		kfree(data);
+		return ret;
+	}
+
+	if (bytesize == 1) {
+		u8 val;
+
+		memcpy(&val, data, sizeof(u8));
+		*value = val;
+	} else if (bytesize == 2) {
+		u16 val;
+
+		memcpy(&val, data, sizeof(u16));
+		*value = val;
+	} else {
+		u32 val;
+
+		memcpy(&val, data, sizeof(u32));
+		*value = val;
+	}
+
+	kfree(data);
+
+	return 0;
+}
+
+static struct devlink_ops bnxt_dl_ops = {
 #ifdef CONFIG_BNXT_SRIOV
 	.eswitch_mode_set = bnxt_dl_eswitch_mode_set,
 	.eswitch_mode_get = bnxt_dl_eswitch_mode_get,
 #endif /* CONFIG_BNXT_SRIOV */
+	.perm_config_get = bnxt_dl_perm_config_get,
+	.perm_config_set = bnxt_dl_perm_config_set,
 };
 
 int bnxt_dl_register(struct bnxt *bp)
@@ -26,12 +259,12 @@ int bnxt_dl_register(struct bnxt *bp)
 	struct devlink *dl;
 	int rc;
 
-	if (!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV))
-		return 0;
-
-	if (bp->hwrm_spec_code < 0x10800) {
+	if ((!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV)) ||
+	    bp->hwrm_spec_code < 0x10800) {
+		/* eswitch switchdev mode not supported */
+		bnxt_dl_ops.eswitch_mode_set = NULL;
+		bnxt_dl_ops.eswitch_mode_get = NULL;
 		netdev_warn(bp->dev, "Firmware does not support SR-IOV E-Switch SWITCHDEV mode.\n");
-		return -ENOTSUPP;
 	}
 
 	dl = devlink_alloc(&bnxt_dl_ops, sizeof(struct bnxt_dl));
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
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
index cb04cc7..8c25731 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h
@@ -5676,6 +5676,106 @@ struct hwrm_nvm_install_update_cmd_err {
 	u8 unused_0[7];
 };
 
+/* hwrm_nvm_get_variable */
+/* Input (40 bytes) */
+struct hwrm_nvm_get_variable_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le64 dest_data_addr;
+	__le16 data_len;
+	__le16 option_num;
+	#define NVM_GET_VARIABLE_REQ_OPTION_NUM_RSVD_0		   0x0UL
+	#define NVM_GET_VARIABLE_REQ_OPTION_NUM_RSVD_FFFF	   0xffffUL
+	__le16 dimensions;
+	__le16 index_0;
+	__le16 index_1;
+	__le16 index_2;
+	__le16 index_3;
+	u8 flags;
+	#define NVM_GET_VARIABLE_REQ_FLAGS_FACTORY_DFLT	    0x1UL
+	u8 unused_0;
+};
+
+/* Output (16 bytes) */
+struct hwrm_nvm_get_variable_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le16 data_len;
+	__le16 option_num;
+	#define NVM_GET_VARIABLE_RESP_OPTION_NUM_RSVD_0	   0x0UL
+	#define NVM_GET_VARIABLE_RESP_OPTION_NUM_RSVD_FFFF	   0xffffUL
+	u8 unused_0;
+	u8 unused_1;
+	u8 unused_2;
+	u8 valid;
+};
+
+/* Command specific Error Codes (8 bytes) */
+struct hwrm_nvm_get_variable_cmd_err {
+	u8 code;
+	#define NVM_GET_VARIABLE_CMD_ERR_CODE_UNKNOWN		   0x0UL
+	#define NVM_GET_VARIABLE_CMD_ERR_CODE_VAR_NOT_EXIST       0x1UL
+	#define NVM_GET_VARIABLE_CMD_ERR_CODE_CORRUPT_VAR	   0x2UL
+	#define NVM_GET_VARIABLE_CMD_ERR_CODE_LEN_TOO_SHORT       0x3UL
+	u8 unused_0[7];
+};
+
+/* hwrm_nvm_set_variable */
+/* Input (40 bytes) */
+struct hwrm_nvm_set_variable_input {
+	__le16 req_type;
+	__le16 cmpl_ring;
+	__le16 seq_id;
+	__le16 target_id;
+	__le64 resp_addr;
+	__le64 src_data_addr;
+	__le16 data_len;
+	__le16 option_num;
+	#define NVM_SET_VARIABLE_REQ_OPTION_NUM_RSVD_0		   0x0UL
+	#define NVM_SET_VARIABLE_REQ_OPTION_NUM_RSVD_FFFF	   0xffffUL
+	__le16 dimensions;
+	__le16 index_0;
+	__le16 index_1;
+	__le16 index_2;
+	__le16 index_3;
+	u8 flags;
+	#define NVM_SET_VARIABLE_REQ_FLAGS_FORCE_FLUSH		    0x1UL
+	#define NVM_SET_VARIABLE_REQ_FLAGS_ENCRYPT_MODE_MASK       0xeUL
+	#define NVM_SET_VARIABLE_REQ_FLAGS_ENCRYPT_MODE_SFT	    1
+	#define NVM_SET_VARIABLE_REQ_FLAGS_ENCRYPT_MODE_NONE      (0x0UL << 1)
+	#define NVM_SET_VARIABLE_REQ_FLAGS_ENCRYPT_MODE_HMAC_SHA1 (0x1UL << 1)
+	#define NVM_SET_VARIABLE_REQ_FLAGS_ENCRYPT_MODE_LAST \
+		NVM_SET_VARIABLE_REQ_FLAGS_ENCRYPT_MODE_HMAC_SHA1
+	u8 unused_0;
+};
+
+/* Output (16 bytes) */
+struct hwrm_nvm_set_variable_output {
+	__le16 error_code;
+	__le16 req_type;
+	__le16 seq_id;
+	__le16 resp_len;
+	__le32 unused_0;
+	u8 unused_1;
+	u8 unused_2;
+	u8 unused_3;
+	u8 valid;
+};
+
+/* Command specific Error Codes (8 bytes) */
+struct hwrm_nvm_set_variable_cmd_err {
+	u8 code;
+	#define NVM_SET_VARIABLE_CMD_ERR_CODE_UNKNOWN		   0x0UL
+	#define NVM_SET_VARIABLE_CMD_ERR_CODE_VAR_NOT_EXIST       0x1UL
+	#define NVM_SET_VARIABLE_CMD_ERR_CODE_CORRUPT_VAR	   0x2UL
+	u8 unused_0[7];
+};
+
 /* hwrm_selftest_qlist */
 /* Input (16 bytes) */
 struct hwrm_selftest_qlist_input {
-- 
2.7.4
