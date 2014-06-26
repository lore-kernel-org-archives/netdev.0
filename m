From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/3] bnx2x: Fail probe of VFs using an old incompatible driver
Date: Thu, 26 Jun 2014 14:31:06 +0300
Message-ID: <1403782266-25362-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1403782266-25362-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:43169 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756998AbaFZLbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 07:31:24 -0400
In-Reply-To: <1403782266-25362-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are linux distributions where the inbox bnx2x driver contains SRIOV
support but doesn't contain the changes introduced in b9871bcf
"bnx2x: VF RSS support - PF side".

A VF in a VM running that distribution over a new hypervisor will access
incorrect addresses when trying to transmit packets, causing an attention
in the hypervisor and making that VF inactive until FLRed.

The driver in the VM has to ne upgraded [no real way to overcome this], but
due to the HW attention currently arising upgrading the driver in the VM
would not suffice [since the VF needs also be FLRed if the previous driver
was already loaded].

This patch causes the PF to fail the acquire message from a VF running an
old problematic driver; The VF will then gracefully fail it's probe preventing
the HW attention [and allow clean upgrade of driver in VM].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 48 ++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h |  6 +++
 2 files changed, 54 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index f350773..54e0427 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1235,6 +1235,41 @@ static void bnx2x_vf_mbx_acquire_resp(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	bnx2x_vf_mbx_resp_send_msg(bp, vf, vfop_status);
 }
 
+static bool bnx2x_vf_mbx_is_windows_vm(struct bnx2x *bp,
+				       struct vfpf_acquire_tlv *acquire)
+{
+	/* Windows driver does one of three things:
+	 * 1. Old driver doesn't have bulletin board address set.
+	 * 2. 'Middle' driver sends mc_num == 32.
+	 * 3. New driver sets the OS field.
+	 */
+	if (!acquire->bulletin_addr ||
+	    acquire->resc_request.num_mc_filters == 32 ||
+	    ((acquire->vfdev_info.vf_os & VF_OS_MASK) ==
+	     VF_OS_WINDOWS))
+		return true;
+
+	return false;
+}
+
+static int bnx2x_vf_mbx_acquire_chk_dorq(struct bnx2x *bp,
+					 struct bnx2x_virtf *vf,
+					 struct bnx2x_vf_mbx *mbx)
+{
+	/* Linux drivers which correctly set the doorbell size also
+	 * send a physical port request
+	 */
+	if (bnx2x_search_tlv_list(bp, &mbx->msg->req,
+				  CHANNEL_TLV_PHYS_PORT_ID))
+		return 0;
+
+	/* Issue does not exist in windows VMs */
+	if (bnx2x_vf_mbx_is_windows_vm(bp, &mbx->msg->req.acquire))
+		return 0;
+
+	return -EOPNOTSUPP;
+}
+
 static void bnx2x_vf_mbx_acquire(struct bnx2x *bp, struct bnx2x_virtf *vf,
 				 struct bnx2x_vf_mbx *mbx)
 {
@@ -1250,6 +1285,18 @@ static void bnx2x_vf_mbx_acquire(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	   acquire->resc_request.num_vlan_filters,
 	   acquire->resc_request.num_mc_filters);
 
+	/* Prevent VFs with old drivers from loading, since they calculate
+	 * CIDs incorrectly requiring a VF-flr [VM reboot] in order to recover
+	 * while being upgraded.
+	 */
+	rc = bnx2x_vf_mbx_acquire_chk_dorq(bp, vf, mbx);
+	if (rc) {
+		DP(BNX2X_MSG_IOV,
+		   "VF [%d] - Can't support acquire request due to doorbell mismatch. Please update VM driver\n",
+		   vf->abs_vfid);
+		goto out;
+	}
+
 	/* acquire the resources */
 	rc = bnx2x_vf_acquire(bp, vf, &acquire->resc_request);
 
@@ -1263,6 +1310,7 @@ static void bnx2x_vf_mbx_acquire(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		vf->cfg_flags &= ~VF_CFG_EXT_BULLETIN;
 	}
 
+out:
 	/* response */
 	bnx2x_vf_mbx_acquire_resp(bp, vf, mbx, rc);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index ace4d7b..15670c4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -118,6 +118,12 @@ struct vfpf_acquire_tlv {
 		/* the following fields are for debug purposes */
 		u8  vf_id;		/* ME register value */
 		u8  vf_os;		/* e.g. Linux, W2K8 */
+#define VF_OS_SUBVERSION_MASK	(0x1f)
+#define VF_OS_MASK		(0xe0)
+#define VF_OS_SHIFT		(5)
+#define VF_OS_UNDEFINED		(0 << VF_OS_SHIFT)
+#define VF_OS_WINDOWS		(1 << VF_OS_SHIFT)
+
 		u8 padding;
 		u8 caps;
 #define VF_CAP_SUPPORT_EXT_BULLETIN	(1 << 0)
-- 
1.8.3.1
