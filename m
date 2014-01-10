From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 1/8] qlcnic: Restrict VF from configuring any VLAN mode.
Date: Fri, 10 Jan 2014 11:48:52 -0500
Message-ID: <1389372539-13753-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41562 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691AbaAJRWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:22:50 -0500
In-Reply-To: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Adapter should allow vlan traffic only for vlans configured on a VF.
  On configuring any vlan mode from VF, adapter will allow any vlan
  traffic to pass for that VF. Do not allow VF to configure this mode.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index d14d9a1..c588286 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -9,9 +9,12 @@
 #include "qlcnic.h"
 #include <linux/types.h>
 
-#define QLCNIC_SRIOV_VF_MAX_MAC 8
+#define QLCNIC_SRIOV_VF_MAX_MAC 7
 #define QLC_VF_MIN_TX_RATE	100
 #define QLC_VF_MAX_TX_RATE	9999
+#define QLC_MAC_OPCODE_MASK	0x7
+#define QLC_MAC_STAR_ADD	6
+#define QLC_MAC_STAR_DEL	7
 
 static int qlcnic_sriov_pf_get_vport_handle(struct qlcnic_adapter *, u8);
 
@@ -1173,6 +1176,13 @@ static int qlcnic_sriov_validate_cfg_macvlan(struct qlcnic_adapter *adapter,
 	struct qlcnic_vport *vp = vf->vp;
 	u8 op, new_op;
 
+	if (((cmd->req.arg[1] & QLC_MAC_OPCODE_MASK) == QLC_MAC_STAR_ADD) ||
+	    ((cmd->req.arg[1] & QLC_MAC_OPCODE_MASK) == QLC_MAC_STAR_DEL)) {
+		netdev_err(adapter->netdev, "MAC + any VLAN filter not allowed from VF %d\n",
+			   vf->pci_func);
+		return -EINVAL;
+	}
+
 	if (!(cmd->req.arg[1] & BIT_8))
 		return -EINVAL;
 
-- 
1.8.3.1
