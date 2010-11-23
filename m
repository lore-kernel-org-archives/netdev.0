From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT] qlcnic: avoid using reset_devices as it may become obsolete.
Date: Tue, 23 Nov 2010 03:25:21 -0800
Message-ID: <1290511521-5773-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21842 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752033Ab0KWLZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 06:25:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

In kdump environment do not depend upon reset_devices parameter
to reset the pci function as this parameter may become obsolete.
Instead use an adapter specific mechanism to determine if the pci
function needs to be reset.

Per function refcount is maintained in driver, which is set in probe
and reset in remove handler of adapter. If the probe detects the count
as non zero then reset the function.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_ctx.c  |    4 +++-
 drivers/net/qlcnic/qlcnic_hdr.h  |    2 +-
 drivers/net/qlcnic/qlcnic_main.c |    5 +++++
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 56f54ff..9513a83 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -923,6 +923,7 @@ struct qlcnic_ipaddr {
 #define QLCNIC_MACSPOOF			0x200
 #define QLCNIC_MAC_OVERRIDE_DISABLED	0x400
 #define QLCNIC_PROMISC_DISABLED		0x800
+#define QLCNIC_NEED_FLR			0x1000
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 3ad1f3e..29cbc2a 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -480,8 +480,10 @@ int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
 {
 	int err;
 
-	if (reset_devices)
+	if (adapter->flags & QLCNIC_NEED_FLR) {
 		pci_reset_function(adapter->pdev);
+		adapter->flags &= ~QLCNIC_NEED_FLR;
+	}
 
 	err = qlcnic_fw_cmd_create_rx_ctx(adapter);
 	if (err)
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 4290b80..566e0e8 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -722,7 +722,7 @@ enum {
 #define QLCNIC_DEV_NPAR_OPER		1 /* NPAR Operational */
 #define QLCNIC_DEV_NPAR_OPER_TIMEO	30 /* Operational time out */
 
-#define QLC_DEV_CHECK_ACTIVE(VAL, FN)		((VAL) &= (1 << (FN * 4)))
+#define QLC_DEV_CHECK_ACTIVE(VAL, FN)		((VAL) & (1 << (FN * 4)))
 #define QLC_DEV_SET_REF_CNT(VAL, FN)		((VAL) |= (1 << (FN * 4)))
 #define QLC_DEV_CLR_REF_CNT(VAL, FN)		((VAL) &= ~(1 << (FN * 4)))
 #define QLC_DEV_SET_RST_RDY(VAL, FN)		((VAL) |= (1 << (FN * 4)))
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index a3dcd04..899df5a 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1485,6 +1485,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	uint8_t revision_id;
 	uint8_t pci_using_dac;
 	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
+	u32 val;
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1546,6 +1547,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_out_iounmap;
 
+	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	if (QLC_DEV_CHECK_ACTIVE(val, adapter->portnum))
+		adapter->flags |= QLCNIC_NEED_FLR;
+
 	err = adapter->nic_ops->start_firmware(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n");
-- 
1.7.3.2

