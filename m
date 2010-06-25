From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 4/9] cxgb4vf: Add code to provision T4 PCI-E SR-IOV Virtual Functions with hardware resources
Date: Fri, 25 Jun 2010 15:11:46 -0700
Message-ID: <201006251511.46660.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23430 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756403Ab0FYWLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:11:47 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5PMBmnh019400
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 15:11:48 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add code to provision T4 PCI-E SR-IOV Virtual Functions with hardware
resources.

Signed-off-by: Casey Leedom
---
 drivers/net/cxgb4/cxgb4_main.c |  106 
++++++++++++++++++++++++++++++++++++++++
 1 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 27f65b5..6528167 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -77,6 +77,76 @@
  */
 #define MAX_SGE_TIMERVAL 200U
 
+#ifdef CONFIG_PCI_IOV
+/*
+ * Virtual Function provisioning constants.  We need two extra Ingress Queues
+ * with Interrupt capability to serve as the VF's Firmware Event Queue and
+ * Forwarded Interrupt Queue (when using MSI mode) -- neither will have Free
+ * Lists associated with them).  For each Ethernet/Control Egress Queue and
+ * for each Free List, we need an Egress Context.
+ */
+enum {
+	VFRES_NPORTS = 1,		/* # of "ports" per VF */
+	VFRES_NQSETS = 2,		/* # of "Queue Sets" per VF */
+
+	VFRES_NVI = VFRES_NPORTS,	/* # of Virtual Interfaces */
+	VFRES_NETHCTRL = VFRES_NQSETS,	/* # of EQs used for ETH or CTRL Qs */
+	VFRES_NIQFLINT = VFRES_NQSETS+2,/* # of ingress Qs/w Free List(s)/intr */
+	VFRES_NIQ = 0,			/* # of non-fl/int ingress queues */
+	VFRES_NEQ = VFRES_NQSETS*2,	/* # of egress queues */
+	VFRES_TC = 0,			/* PCI-E traffic class */
+	VFRES_NEXACTF = 16,		/* # of exact MPS filters */
+
+	VFRES_R_CAPS = FW_CMD_CAP_DMAQ|FW_CMD_CAP_VF|FW_CMD_CAP_PORT,
+	VFRES_WX_CAPS = FW_CMD_CAP_DMAQ|FW_CMD_CAP_VF,
+};
+
+/*
+ * Provide a Port Access Rights Mask for the specified PF/VF.  This is very
+ * static and likely not to be useful in the long run.  We really need to
+ * implement some form of persistent configuration which the firmware
+ * controls.
+ */
+static unsigned int pfvfres_pmask(struct adapter *adapter,
+				  unsigned int pf, unsigned int vf)
+{
+	unsigned int portn, portvec;
+
+	/*
+	 * Give PF's access to all of the ports.
+	 */
+	if (vf == 0)
+		return FW_PFVF_CMD_PMASK_MASK;
+
+	/*
+	 * For VFs, we'll assign them access to the ports based purely on the
+	 * PF.  We assign active ports in order, wrapping around if there are
+	 * fewer active ports than PFs: e.g. active port[pf % nports].
+	 * Unfortunately the adapter's port_info structs haven't been
+	 * initialized yet so we have to compute this.
+	 */
+	if (adapter->params.nports == 0)
+		return 0;
+
+	portn = pf % adapter->params.nports;
+	portvec = adapter->params.portvec;
+	for (;;) {
+		/*
+		 * Isolate the lowest set bit in the port vector.  If we're at
+		 * the port number that we want, return that as the pmask.
+		 * otherwise mask that bit out of the port vector and
+		 * decrement our port number ...
+		 */
+		unsigned int pmask = portvec ^ (portvec & (portvec-1));
+		if (portn == 0)
+			return pmask;
+		portn--;
+		portvec &= ~pmask;
+	}
+	/*NOTREACHED*/
+}
+#endif
+
 enum {
 	MEMWIN0_APERTURE = 65536,
 	MEMWIN0_BASE     = 0x30000,
@@ -2925,6 +2995,42 @@ static int adap_init0(struct adapter *adap)
 	t4_read_mtu_tbl(adap, adap->params.mtus, NULL);
 	t4_load_mtus(adap, adap->params.mtus, adap->params.a_wnd,
 		     adap->params.b_wnd);
+
+#ifdef CONFIG_PCI_IOV
+	/*
+	 * Provision resource limits for Virtual Functions.  We currently
+	 * grant them all the same static resource limits except for the Port
+	 * Access Rights Mask which we're assigning based on the PF.  All of
+	 * the static provisioning stuff for both the PF and VF really needs
+	 * to be managed in a persistent manner for each device which the
+	 * firmware controls.
+	 */
+	{
+		int pf, vf;
+
+		for (pf = 0; pf < ARRAY_SIZE(num_vf); pf++) {
+			if (num_vf[pf] <= 0)
+				continue;
+
+			/* VF numbering starts at 1! */
+			for (vf = 1; vf <= num_vf[pf]; vf++) {
+				ret = t4_cfg_pfvf(adap, 0, pf, vf,
+						  VFRES_NEQ, VFRES_NETHCTRL,
+						  VFRES_NIQFLINT, VFRES_NIQ,
+						  VFRES_TC, VFRES_NVI,
+						  FW_PFVF_CMD_CMASK_MASK,
+						  pfvfres_pmask(adap, pf, vf),
+						  VFRES_NEXACTF,
+						  VFRES_R_CAPS, VFRES_WX_CAPS);
+				if (ret < 0)
+					dev_warn(adap->pdev_dev, "failed to "
+						 "provision pf/vf=%d/%d; "
+						 "err=%d\n", pf, vf, ret);
+			}
+		}
+	}
+#endif
+
 	return 0;
 
 	/*
