From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH] cxgb4: implement ndo_set_vf_rate()
Date: Mon,  5 Jun 2017 18:34:20 +0530
Message-ID: <1496667860-11703-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, kumaras@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:8980 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdFENEO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 09:04:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement ndo_set_vf_rate() for mgmt interface to support rate-limiting
of VF traffic using 'ip' command.

Based on the original work of Kumar Sanghvi <kumaras@chelsio.com>

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 106 ++++++++++++++++++++++++
 2 files changed, 107 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 1cf3e2f..b7a92eb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -777,6 +777,7 @@ struct uld_msix_info {
 
 struct vf_info {
 	unsigned char vf_mac_addr[ETH_ALEN];
+	unsigned int tx_rate;
 	bool pf_set_mac;
 };
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8c69046..64af406 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2563,6 +2563,8 @@ static int cxgb_get_vf_config(struct net_device *dev,
 	if (vf >= adap->num_vfs)
 		return -EINVAL;
 	ivi->vf = vf;
+	ivi->max_tx_rate = adap->vfinfo[vf].tx_rate;
+	ivi->min_tx_rate = 0;
 	ether_addr_copy(ivi->mac, adap->vfinfo[vf].vf_mac_addr);
 	return 0;
 }
@@ -2579,6 +2581,109 @@ static int cxgb_get_phys_port_id(struct net_device *dev,
 	return 0;
 }
 
+static int cxgb_set_vf_rate(struct net_device *dev, int vf, int min_tx_rate,
+			    int max_tx_rate)
+{
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
+	struct fw_port_cmd port_cmd, port_rpl;
+	u32 link_status, speed = 0;
+	u32 fw_pfvf, fw_class;
+	int class_id = vf;
+	int link_ok, ret;
+	u16 pktsize;
+
+	if (vf >= adap->num_vfs)
+		return -EINVAL;
+
+	if (min_tx_rate) {
+		dev_err(adap->pdev_dev,
+			"Min tx rate (%d) (> 0) for VF %d is Invalid.\n",
+			min_tx_rate, vf);
+		return -EINVAL;
+	}
+	/* Retrieve link details for VF port */
+	memset(&port_cmd, 0, sizeof(port_cmd));
+	port_cmd.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
+					    FW_CMD_REQUEST_F |
+					    FW_CMD_READ_F |
+					    FW_PORT_CMD_PORTID_V(pi->port_id));
+	port_cmd.action_to_len16 =
+		cpu_to_be32(FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_GET_PORT_INFO) |
+			    FW_LEN16(port_cmd));
+	ret = t4_wr_mbox(adap, adap->mbox, &port_cmd, sizeof(port_cmd),
+			 &port_rpl);
+	if (ret != FW_SUCCESS) {
+		dev_err(adap->pdev_dev,
+			"Failed to get link status for VF %d\n", vf);
+		return -EINVAL;
+	}
+	link_status = be32_to_cpu(port_rpl.u.info.lstatus_to_modtype);
+	link_ok = (link_status & FW_PORT_CMD_LSTATUS_F) != 0;
+	if (!link_ok) {
+		dev_err(adap->pdev_dev, "Link down for VF %d\n", vf);
+		return -EINVAL;
+	}
+	/* Determine link speed */
+	if (link_status & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_100M))
+		speed = 100;
+	else if (link_status & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_1G))
+		speed = 1000;
+	else if (link_status & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_10G))
+		speed = 10000;
+	else if (link_status & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_25G))
+		speed = 25000;
+	else if (link_status & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_40G))
+		speed = 40000;
+	else if (link_status & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_100G))
+		speed = 100000;
+
+	if (max_tx_rate > speed) {
+		dev_err(adap->pdev_dev,
+			"Max tx rate %d for VF %d can't be > link-speed %u",
+			max_tx_rate, vf, speed);
+		return -EINVAL;
+	}
+	pktsize = be16_to_cpu(port_rpl.u.info.mtu);
+	/* subtract ethhdr size and 4 bytes crc since, f/w appends it */
+	pktsize = pktsize - sizeof(struct ethhdr) - 4;
+	/* subtract ipv4 hdr size, tcp hdr size to get typical IPv4 MSS size */
+	pktsize = pktsize - sizeof(struct iphdr) - sizeof(struct tcphdr);
+	/* configure Traffic Class for rate-limiting */
+	ret = t4_sched_params(adap, SCHED_CLASS_TYPE_PACKET,
+			      SCHED_CLASS_LEVEL_CL_RL,
+			      SCHED_CLASS_MODE_CLASS,
+			      SCHED_CLASS_RATEUNIT_BITS,
+			      SCHED_CLASS_RATEMODE_ABS,
+			      pi->port_id, class_id, 0,
+			      max_tx_rate * 1000, 0, pktsize);
+	if (ret) {
+		dev_err(adap->pdev_dev, "Err %d for Traffic Class config\n",
+			ret);
+		return -EINVAL;
+	}
+	dev_info(adap->pdev_dev,
+		 "Class %d with MSS %u configured with rate %u\n",
+		 class_id, pktsize, max_tx_rate);
+
+	/* bind VF to configured Traffic Class */
+	fw_pfvf = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_PFVF) |
+		   FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_PFVF_SCHEDCLASS_ETH));
+	fw_class = class_id;
+	ret = t4_set_params(adap, adap->mbox, adap->pf, vf + 1, 1, &fw_pfvf,
+			    &fw_class);
+	if (ret) {
+		dev_err(adap->pdev_dev,
+			"Err %d in binding VF %d to Traffic Class %d\n",
+			ret, vf, class_id);
+		return -EINVAL;
+	}
+	dev_info(adap->pdev_dev, "PF %d VF %d is bound to Class %d\n",
+		 adap->pf, vf, class_id);
+	adap->vfinfo[vf].tx_rate = max_tx_rate;
+	return 0;
+}
+
 #endif
 
 static int cxgb_set_mac_addr(struct net_device *dev, void *p)
@@ -2766,6 +2871,7 @@ static const struct net_device_ops cxgb4_mgmt_netdev_ops = {
 	.ndo_open             = dummy_open,
 	.ndo_set_vf_mac       = cxgb_set_vf_mac,
 	.ndo_get_vf_config    = cxgb_get_vf_config,
+	.ndo_set_vf_rate      = cxgb_set_vf_rate,
 	.ndo_get_phys_port_id = cxgb_get_phys_port_id,
 };
 #endif
-- 
2.1.0
