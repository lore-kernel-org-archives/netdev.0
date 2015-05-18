From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 14/16] sfc: add ndo_set_vf_link_state() function
 for EF10
Date: Mon, 18 May 2015 16:31:24 +0100
Message-ID: <555A05CC.90909@solarflare.com>
References: <555A044A.4060202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:25186 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752704AbbERPbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:31:39 -0400
In-Reply-To: <555A044A.4060202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

Exercised with
"ip link set <PF intf> vf <vf_i> state {auto|enable|disable}"
Sets the reporting policy for VF link state to either
 - mirror physical link state
 - always up
 - always down

get VF link state mode in efx_ef10_sriov_get_vf_config

Exercised by
"ip link show <PF intf>";
output will include a line like
vf 0 MAC 12:34:56:78:9a:bc, link-state auto

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  1 +
 drivers/net/ethernet/sfc/ef10_sriov.c | 40 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.h |  3 +++
 drivers/net/ethernet/sfc/efx.c        |  1 +
 drivers/net/ethernet/sfc/mcdi_pcol.h  | 33 +++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 drivers/net/ethernet/sfc/sriov.c      | 12 +++++++++++
 drivers/net/ethernet/sfc/sriov.h      |  2 ++
 8 files changed, 94 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 525808f..e624ddd 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -4135,6 +4135,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.sriov_set_vf_vlan = efx_ef10_sriov_set_vf_vlan,
 	.sriov_set_vf_spoofchk = efx_ef10_sriov_set_vf_spoofchk,
 	.sriov_get_vf_config = efx_ef10_sriov_get_vf_config,
+	.sriov_set_vf_link_state = efx_ef10_sriov_set_vf_link_state,
 	.vswitching_probe = efx_ef10_vswitching_probe_pf,
 	.vswitching_restore = efx_ef10_vswitching_restore_pf,
 	.vswitching_remove = efx_ef10_vswitching_remove_pf,
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 49238fc..edc34f3 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -667,11 +667,37 @@ reset_nic:
 	return rc ? rc : rc2;
 }
 
+int efx_ef10_sriov_set_vf_link_state(struct efx_nic *efx, int vf_i,
+				     int link_state)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_LINK_STATE_MODE_IN_LEN);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	BUILD_BUG_ON(IFLA_VF_LINK_STATE_AUTO !=
+		     MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_AUTO);
+	BUILD_BUG_ON(IFLA_VF_LINK_STATE_ENABLE !=
+		     MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_UP);
+	BUILD_BUG_ON(IFLA_VF_LINK_STATE_DISABLE !=
+		     MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_DOWN);
+	MCDI_POPULATE_DWORD_2(inbuf, LINK_STATE_MODE_IN_FUNCTION,
+			      LINK_STATE_MODE_IN_FUNCTION_PF,
+			      nic_data->pf_index,
+			      LINK_STATE_MODE_IN_FUNCTION_VF, vf_i);
+	MCDI_SET_DWORD(inbuf, LINK_STATE_MODE_IN_NEW_MODE, link_state);
+	return efx_mcdi_rpc(efx, MC_CMD_LINK_STATE_MODE, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL); /* don't care what old mode was */
+}
+
 int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 				 struct ifla_vf_info *ivf)
 {
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_LINK_STATE_MODE_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_LINK_STATE_MODE_OUT_LEN);
+
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	struct ef10_vf *vf;
+	size_t outlen;
+	int rc;
 
 	if (vf_i >= efx->vf_count)
 		return -EINVAL;
@@ -688,5 +714,19 @@ int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 	ivf->vlan = (vf->vlan == EFX_EF10_NO_VLAN) ? 0 : vf->vlan;
 	ivf->qos = 0;
 
+	MCDI_POPULATE_DWORD_2(inbuf, LINK_STATE_MODE_IN_FUNCTION,
+			      LINK_STATE_MODE_IN_FUNCTION_PF,
+			      nic_data->pf_index,
+			      LINK_STATE_MODE_IN_FUNCTION_VF, vf_i);
+	MCDI_SET_DWORD(inbuf, LINK_STATE_MODE_IN_NEW_MODE,
+		       MC_CMD_LINK_STATE_MODE_IN_DO_NOT_CHANGE);
+	rc = efx_mcdi_rpc(efx, MC_CMD_LINK_STATE_MODE, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		return rc;
+	if (outlen < MC_CMD_LINK_STATE_MODE_OUT_LEN)
+		return -EIO;
+	ivf->linkstate = MCDI_DWORD(outbuf, LINK_STATE_MODE_OUT_OLD_MODE);
+
 	return 0;
 }
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 0428265..91393a6 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -58,6 +58,9 @@ static inline int efx_ef10_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf,
 int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 				 struct ifla_vf_info *ivf);
 
+int efx_ef10_sriov_set_vf_link_state(struct efx_nic *efx, int vf_i,
+				     int link_state);
+
 int efx_ef10_vswitching_probe_pf(struct efx_nic *efx);
 int efx_ef10_vswitching_probe_vf(struct efx_nic *efx);
 int efx_ef10_vswitching_restore_pf(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0ca6e77..8cacb96 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2281,6 +2281,7 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_set_vf_vlan	= efx_sriov_set_vf_vlan,
 	.ndo_set_vf_spoofchk	= efx_sriov_set_vf_spoofchk,
 	.ndo_get_vf_config	= efx_sriov_get_vf_config,
+	.ndo_set_vf_link_state  = efx_sriov_set_vf_link_state,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 30c7170..ada610a 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -4285,6 +4285,39 @@
 
 
 /***********************************/
+/* MC_CMD_LINK_STATE_MODE
+ * Read/set link state mode of a VF
+ */
+#define MC_CMD_LINK_STATE_MODE 0x5c
+#undef MC_CMD_0x5c_PRIVILEGE_CTG
+
+#define MC_CMD_0x5c_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_LINK_STATE_MODE_IN msgrequest */
+#define    MC_CMD_LINK_STATE_MODE_IN_LEN 8
+/* The target function to have its link state mode read or set, must be a VF
+ * e.g. VF 1,3 = 0x00030001
+ */
+#define       MC_CMD_LINK_STATE_MODE_IN_FUNCTION_OFST 0
+#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_PF_LBN 0
+#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_PF_WIDTH 16
+#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_VF_LBN 16
+#define        MC_CMD_LINK_STATE_MODE_IN_FUNCTION_VF_WIDTH 16
+/* New link state mode to be set */
+#define       MC_CMD_LINK_STATE_MODE_IN_NEW_MODE_OFST 4
+#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_AUTO       0x0 /* enum */
+#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_UP         0x1 /* enum */
+#define          MC_CMD_LINK_STATE_MODE_IN_LINK_STATE_DOWN       0x2 /* enum */
+/* enum: Use this value to just read the existing setting without modifying it.
+ */
+#define          MC_CMD_LINK_STATE_MODE_IN_DO_NOT_CHANGE         0xffffffff
+
+/* MC_CMD_LINK_STATE_MODE_OUT msgresponse */
+#define    MC_CMD_LINK_STATE_MODE_OUT_LEN 4
+#define       MC_CMD_LINK_STATE_MODE_OUT_OLD_MODE_OFST 0
+
+
+/***********************************/
 /* MC_CMD_READ_REGS
  * Get a dump of the MCPU registers
  */
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 364217b..c2eabd9 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1348,6 +1348,8 @@ struct efx_nic_type {
 				     bool spoofchk);
 	int (*sriov_get_vf_config)(struct efx_nic *efx, int vf_i,
 				   struct ifla_vf_info *ivi);
+	int (*sriov_set_vf_link_state)(struct efx_nic *efx, int vf_i,
+				       int link_state);
 	int (*vswitching_probe)(struct efx_nic *efx);
 	int (*vswitching_restore)(struct efx_nic *efx);
 	void (*vswitching_remove)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/sriov.c b/drivers/net/ethernet/sfc/sriov.c
index d4b7445..6c5edbd 100644
--- a/drivers/net/ethernet/sfc/sriov.c
+++ b/drivers/net/ethernet/sfc/sriov.c
@@ -58,3 +58,15 @@ int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
 	else
 		return -EOPNOTSUPP;
 }
+
+int efx_sriov_set_vf_link_state(struct net_device *net_dev, int vf_i,
+				int link_state)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->sriov_set_vf_link_state)
+		return efx->type->sriov_set_vf_link_state(efx, vf_i,
+							  link_state);
+	else
+		return -EOPNOTSUPP;
+}
diff --git a/drivers/net/ethernet/sfc/sriov.h b/drivers/net/ethernet/sfc/sriov.h
index 0b9f0f6..3be15a5 100644
--- a/drivers/net/ethernet/sfc/sriov.h
+++ b/drivers/net/ethernet/sfc/sriov.h
@@ -21,6 +21,8 @@ int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf_i,
 			      bool spoofchk);
 int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
 			    struct ifla_vf_info *ivi);
+int efx_sriov_set_vf_link_state(struct net_device *net_dev, int vf_i,
+				int link_state);
 
 #endif /* CONFIG_SFC_SRIOV */
 
