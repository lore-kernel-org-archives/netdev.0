From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 26/29] fm10k: Add support for IEEE DCBx
Date: Thu, 18 Sep 2014 18:40:08 -0400
Message-ID: <20140918224004.10373.65972.stgit@ahduyck-bv4.jf.intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33604 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757600AbaIRWsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 18:48:51 -0400
In-Reply-To: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for management of the limited QOS features of the
FM10000 interface.  Specifically we can support up to 8 traffic classes,
however the part only provides 1 Rx and 1 Tx FIFO in the host interface and
as a result this can lead to head-of-line blocking on Rx.  This can be
avoided by setting PFC only for priorities that cannot afford to drop
frames.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile      |    3 
 drivers/net/ethernet/intel/fm10k/fm10k.h       |    3 
 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c |  174 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c   |    3 
 4 files changed, 182 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index 70565ab..5023625 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -29,4 +29,5 @@ obj-$(CONFIG_FM10K) += fm10k.o
 
 fm10k-objs := fm10k_main.o fm10k_common.o fm10k_pci.o \
 	      fm10k_netdev.o fm10k_ethtool.o fm10k_pf.o fm10k_vf.o \
-	      fm10k_mbx.o fm10k_iov.o fm10k_tlv.o
+	      fm10k_mbx.o fm10k_iov.o fm10k_tlv.o \
+	      fm10k_dcbnl.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index e529bfe..fe1c033 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -467,4 +467,7 @@ int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx, int rate,
 			int unused);
 int fm10k_ndo_get_vf_config(struct net_device *netdev,
 			    int vf_idx, struct ifla_vf_info *ivi);
+
+/* DCB */
+void fm10k_dcbnl_set_ops(struct net_device *dev);
 #endif /* _FM10K_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c b/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
new file mode 100644
index 0000000..8d74edb
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
@@ -0,0 +1,174 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include "fm10k.h"
+
+#if defined(HAVE_DCBNL_IEEE) && defined(CONFIG_DCB)
+/**
+ * fm10k_dcbnl_ieee_getets - get the ETS configuration for the device
+ * @dev: netdev interface for the device
+ * @ets: ETS structure to push configuration to
+ **/
+static int fm10k_dcbnl_ieee_getets(struct net_device *dev, struct ieee_ets *ets)
+{
+	int i;
+
+	/* we support 8 TCs in all modes */
+	ets->ets_cap = IEEE_8021QAZ_MAX_TCS;
+	ets->cbs = 0;
+
+	/* we only support strict priority and cannot do traffic shaping */
+	memset(ets->tc_tx_bw, 0, sizeof(ets->tc_tx_bw));
+	memset(ets->tc_rx_bw, 0, sizeof(ets->tc_rx_bw));
+	memset(ets->tc_tsa, IEEE_8021QAZ_TSA_STRICT, sizeof(ets->tc_tsa));
+
+	/* populate the prio map based on the netdev */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		ets->prio_tc[i] = netdev_get_prio_tc_map(dev, i);
+
+	return 0;
+}
+
+/**
+ * fm10k_dcbnl_ieee_setets - set the ETS configuration for the device
+ * @dev: netdev interface for the device
+ * @ets: ETS structure to pull configuration from
+ **/
+static int fm10k_dcbnl_ieee_setets(struct net_device *dev, struct ieee_ets *ets)
+{
+	u8 num_tc = 0;
+	int i, err;
+
+	/* verify type and determine num_tcs needed */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		if (ets->tc_tx_bw[i] || ets->tc_rx_bw[i])
+			return -EINVAL;
+		if (ets->tc_tsa[i] != IEEE_8021QAZ_TSA_STRICT)
+			return -EINVAL;
+		if (ets->prio_tc[i] > num_tc)
+			num_tc = ets->prio_tc[i];
+	}
+
+	/* if requested TC is greater than 0 then num_tcs is max + 1 */
+	if (num_tc)
+		num_tc++;
+
+	if (num_tc > IEEE_8021QAZ_MAX_TCS)
+		return -EINVAL;
+
+	/* update TC hardware mapping if necessary */
+	if (num_tc != netdev_get_num_tc(dev)) {
+		err = fm10k_setup_tc(dev, num_tc);
+		if (err)
+			return err;
+	}
+
+	/* update priority mapping */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		netdev_set_prio_tc_map(dev, i, ets->prio_tc[i]);
+
+	return 0;
+}
+
+/**
+ * fm10k_dcbnl_ieee_getpfc - get the PFC configuration for the device
+ * @dev: netdev interface for the device
+ * @pfc: PFC structure to push configuration to
+ **/
+static int fm10k_dcbnl_ieee_getpfc(struct net_device *dev, struct ieee_pfc *pfc)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+
+	/* record flow control max count and state of TCs */
+	pfc->pfc_cap = IEEE_8021QAZ_MAX_TCS;
+	pfc->pfc_en = interface->pfc_en;
+
+	return 0;
+}
+
+/**
+ * fm10k_dcbnl_ieee_setpfc - set the PFC configuration for the device
+ * @dev: netdev interface for the device
+ * @pfc: PFC structure to pull configuration from
+ **/
+static int fm10k_dcbnl_ieee_setpfc(struct net_device *dev, struct ieee_pfc *pfc)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+
+	/* record PFC configuration to interface */
+	interface->pfc_en = pfc->pfc_en;
+
+	/* if we are running update the drop_en state for all queues */
+	if (netif_running(dev))
+		fm10k_update_rx_drop_en(interface);
+
+	return 0;
+}
+
+/**
+ * fm10k_dcbnl_ieee_getdcbx - get the DCBX configuration for the device
+ * @dev: netdev interface for the device
+ *
+ * Returns that we support only IEEE DCB for this interface
+ **/
+static u8 fm10k_dcbnl_getdcbx(struct net_device *dev)
+{
+	return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
+}
+
+/**
+ * fm10k_dcbnl_ieee_setdcbx - get the DCBX configuration for the device
+ * @dev: netdev interface for the device
+ * @mode: new mode for this device
+ *
+ * Returns error on attempt to enable anything but IEEE DCB for this interface
+ **/
+static u8 fm10k_dcbnl_setdcbx(struct net_device *dev, u8 mode)
+{
+	return (mode != (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE)) ? 1 : 0;
+}
+
+static const struct dcbnl_rtnl_ops fm10k_dcbnl_ops = {
+	.ieee_getets	= fm10k_dcbnl_ieee_getets,
+	.ieee_setets	= fm10k_dcbnl_ieee_setets,
+	.ieee_getpfc	= fm10k_dcbnl_ieee_getpfc,
+	.ieee_setpfc	= fm10k_dcbnl_ieee_setpfc,
+
+	.getdcbx	= fm10k_dcbnl_getdcbx,
+	.setdcbx	= fm10k_dcbnl_setdcbx,
+};
+
+#endif /* HAVE_DCBNL_IEEE && CONFIG_DCB */
+/**
+ * fm10k_dcbnl_set_ops - Configures dcbnl ops pointer for netdev
+ * @dev: netdev interface for the device
+ *
+ * Enables PF for DCB by assigning DCBNL ops pointer.
+ **/
+void fm10k_dcbnl_set_ops(struct net_device *dev)
+{
+#if defined(HAVE_DCBNL_IEEE) && defined(CONFIG_DCB)
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_hw *hw = &interface->hw;
+
+	if (hw->mac.type == fm10k_mac_pf)
+		dev->dcbnl_ops = &fm10k_dcbnl_ops;
+#endif /* HAVE_DCBNL_IEEE && CONFIG_DCB */
+}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index a2eb889..b3ebedb 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1555,6 +1555,9 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		netdev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
 	}
 
+	/* initialize DCBNL interface */
+	fm10k_dcbnl_set_ops(netdev);
+
 	/* Initialize service timer and service task */
 	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
 	setup_timer(&interface->service_timer, &fm10k_service_timer,
