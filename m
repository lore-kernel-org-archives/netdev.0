From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Add vxlan RSS support
Date: Tue, 18 Aug 2015 10:22:59 +0300
Message-ID: <1439882579-16136-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>,
	Rajesh Borundia <Rajesh.Borundia@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:16439 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbbHRHXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 03:23:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <Rajesh.Borundia@qlogic.com>

Latest FW submission added some vxlan offload capabilities to our device.
This patch adds the ability to connect to the vxlan NDOs and configure
the UDP port associated with it in the HW.

The device would now be capable of performing RSS according to the
inner headers of the vxlan packets.

Signed-off-by: Rajesh Borundia <Rajesh.Borundia@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/Kconfig            |  10 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 109 +++++++++++++++++++++++
 4 files changed, 123 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 8be9eab..e930aa9 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -139,6 +139,16 @@ config BNX2X_SRIOV
 	  Virtualization support in the 578xx and 57712 products. This
 	  allows for virtual function acceleration in virtual environments.
 
+config BNX2X_VXLAN
+	bool "Virtual eXtensible Local Area Network support"
+	default n
+	depends on BNX2X && VXLAN && !(BNX2X=y && VXLAN=m)
+	---help---
+	  This enables hardward offload support for VXLAN protocol over the
+	  NetXtremeII series adapters.
+	  Say Y here if you want to enable hardware offload support for
+	  Virtual eXtensible Local Area Network (VXLAN) in the driver.
+
 config BGMAC
 	tristate "BCMA bus GBit core support"
 	depends on BCMA_HOST_SOC && HAS_DMA && (BCM47XX || ARCH_BCM_5301X)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 5762c48..cbd6e25 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1392,6 +1392,8 @@ enum sp_rtnl_flag {
 	BNX2X_SP_RTNL_HYPERVISOR_VLAN,
 	BNX2X_SP_RTNL_TX_STOP,
 	BNX2X_SP_RTNL_GET_DRV_VERSION,
+	BNX2X_SP_RTNL_ADD_VXLAN_PORT,
+	BNX2X_SP_RTNL_DEL_VXLAN_PORT,
 };
 
 enum bnx2x_iov_flag {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index e18a0e4..d276de3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -967,6 +967,8 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 	else /* CHIP_IS_E1X */
 		start_params->network_cos_mode = FW_WRR;
 
+	start_params->vxlan_dst_port = cpu_to_le16(bp->vxlan_dst_port);
+
 	start_params->inner_rss = 1;
 
 	if (IS_MF_UFP(bp) && BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ad73a60..5c00350 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10075,6 +10075,81 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 	}
 }
 
+#ifdef CONFIG_BNX2X_VXLAN
+static int bnx2x_vxlan_port_update(struct bnx2x *bp, u16 port)
+{
+	struct bnx2x_func_switch_update_params *switch_update_params;
+	struct bnx2x_func_state_params func_params = {NULL};
+	int rc;
+
+	switch_update_params = &func_params.params.switch_update;
+
+	/* Prepare parameters for function state transitions */
+	__set_bit(RAMROD_COMP_WAIT, &func_params.ramrod_flags);
+	__set_bit(RAMROD_RETRY, &func_params.ramrod_flags);
+
+	func_params.f_obj = &bp->func_obj;
+	func_params.cmd = BNX2X_F_CMD_SWITCH_UPDATE;
+
+	/* Function parameters */
+	__set_bit(BNX2X_F_UPDATE_TUNNEL_CFG_CHNG,
+		  &switch_update_params->changes);
+	switch_update_params->vxlan_dst_port = port;
+	rc = bnx2x_func_state_change(bp, &func_params);
+	if (rc)
+		BNX2X_ERR("failed to change vxlan dst port to %d (rc = 0x%x)\n",
+			  port, rc);
+	return rc;
+}
+
+static void __bnx2x_add_vxlan_port(struct bnx2x *bp, u16 port)
+{
+	if (!netif_running(bp->dev))
+		return;
+
+	if (bp->vxlan_dst_port || !IS_PF(bp)) {
+		DP(BNX2X_MSG_SP, "Vxlan destination port limit reached\n");
+		return;
+	}
+
+	bp->vxlan_dst_port = port;
+	bnx2x_schedule_sp_rtnl(bp, BNX2X_SP_RTNL_ADD_VXLAN_PORT, 0);
+}
+
+static void bnx2x_add_vxlan_port(struct net_device *netdev,
+				 sa_family_t sa_family, __be16 port)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u16 t_port = ntohs(port);
+
+	__bnx2x_add_vxlan_port(bp, t_port);
+}
+
+static void __bnx2x_del_vxlan_port(struct bnx2x *bp, u16 port)
+{
+	if (!bp->vxlan_dst_port || bp->vxlan_dst_port != port || !IS_PF(bp)) {
+		DP(BNX2X_MSG_SP, "Invalid vxlan port\n");
+		return;
+	}
+
+	if (netif_running(bp->dev)) {
+		bnx2x_schedule_sp_rtnl(bp, BNX2X_SP_RTNL_DEL_VXLAN_PORT, 0);
+	} else {
+		bp->vxlan_dst_port = 0;
+		netdev_info(bp->dev, "Deleted vxlan dest port %d", port);
+	}
+}
+
+static void bnx2x_del_vxlan_port(struct net_device *netdev,
+				 sa_family_t sa_family, __be16 port)
+{
+	struct bnx2x *bp = netdev_priv(netdev);
+	u16 t_port = ntohs(port);
+
+	__bnx2x_del_vxlan_port(bp, t_port);
+}
+#endif
+
 static int bnx2x_close(struct net_device *dev);
 
 /* bnx2x_nic_unload() flushes the bnx2x_wq, thus reset task is
@@ -10083,6 +10158,9 @@ static int bnx2x_close(struct net_device *dev);
 static void bnx2x_sp_rtnl_task(struct work_struct *work)
 {
 	struct bnx2x *bp = container_of(work, struct bnx2x, sp_rtnl_task.work);
+#ifdef CONFIG_BNX2X_VXLAN
+	u16 port;
+#endif
 
 	rtnl_lock();
 
@@ -10181,6 +10259,27 @@ sp_rtnl_not_reset:
 			       &bp->sp_rtnl_state))
 		bnx2x_update_mng_version(bp);
 
+#ifdef CONFIG_BNX2X_VXLAN
+	port = bp->vxlan_dst_port;
+	if (test_and_clear_bit(BNX2X_SP_RTNL_ADD_VXLAN_PORT,
+			       &bp->sp_rtnl_state)) {
+		if (!bnx2x_vxlan_port_update(bp, port))
+			netdev_info(bp->dev, "Added vxlan dest port %d", port);
+		else
+			bp->vxlan_dst_port = 0;
+	}
+
+	if (test_and_clear_bit(BNX2X_SP_RTNL_DEL_VXLAN_PORT,
+			       &bp->sp_rtnl_state)) {
+		if (!bnx2x_vxlan_port_update(bp, 0)) {
+			netdev_info(bp->dev,
+				    "Deleted vxlan dest port %d", port);
+			bp->vxlan_dst_port = 0;
+			vxlan_get_rx_port(bp->dev);
+		}
+	}
+#endif
+
 	/* work which needs rtnl lock not-taken (as it takes the lock itself and
 	 * can be called from other contexts as well)
 	 */
@@ -12379,6 +12478,12 @@ static int bnx2x_open(struct net_device *dev)
 	rc = bnx2x_nic_load(bp, LOAD_OPEN);
 	if (rc)
 		return rc;
+
+#ifdef CONFIG_BNX2X_VXLAN
+	if (IS_PF(bp))
+		vxlan_get_rx_port(dev);
+#endif
+
 	return 0;
 }
 
@@ -12894,6 +12999,10 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_get_phys_port_id	= bnx2x_get_phys_port_id,
 	.ndo_set_vf_link_state	= bnx2x_set_vf_link_state,
 	.ndo_features_check	= bnx2x_features_check,
+#ifdef CONFIG_BNX2X_VXLAN
+	.ndo_add_vxlan_port	= bnx2x_add_vxlan_port,
+	.ndo_del_vxlan_port	= bnx2x_del_vxlan_port,
+#endif
 };
 
 static int bnx2x_set_coherency_mask(struct bnx2x *bp)
-- 
1.9.3
