From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [PATCH] Code changes to handle dev private ioctl
Date: Fri, 22 May 2009 19:03:25 +0530
Message-ID: <20090522133315.GA13610@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:1519 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756253AbZEVNkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 09:40:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Please accept this patch into net-next tree to handle dev private ioctls.
Thanks,
Sarvesh

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   20 ++++++++++++++++++
 drivers/net/benet/be_cmds.h |    2 ++
 drivers/net/benet/be_main.c |   48 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index d444aed..21263e2 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -859,3 +859,23 @@ int be_cmd_query_fw_cfg(struct be_ctrl_i
 	spin_unlock(&ctrl->cmd_lock);
 	return status;
 }
+
+int be_cmd_pass_ext_ioctl(struct be_ctrl_info *ctrl, dma_addr_t dma,
+			  int req_size)
+{
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
+	struct be_sge *sge = nonembedded_sgl(wrb);
+	int status;
+
+	spin_lock(&ctrl->cmd_lock);
+	memset(wrb, 0, sizeof(*wrb));
+	be_wrb_hdr_prepare(wrb, req_size, false, 1);
+	sge->pa_hi = cpu_to_le32(upper_32_bits(dma));
+	sge->pa_lo = cpu_to_le32(dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(req_size);
+
+	status = be_mbox_db_ring(ctrl);
+
+	spin_unlock(&ctrl->cmd_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index e499e2d..b147286 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -686,3 +686,5 @@ extern int be_cmd_set_flow_control(struc
 extern int be_cmd_get_flow_control(struct be_ctrl_info *ctrl,
 			u32 *tx_fc, u32 *rx_fc);
 extern int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num);
+extern int be_cmd_pass_ext_ioctl(struct be_ctrl_info *ctrl, dma_addr_t dma,
+			  int req_size);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ae2f6b5..8329e07 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -562,6 +562,53 @@ static void be_vlan_rem_vid(struct net_d
 	be_vid_config(netdev);
 }
 
+static int be_do_ioctl(struct net_device *netdev,
+			struct ifreq *ifr, int cmd)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_cmd_req_hdr req;
+	struct be_cmd_resp_hdr *resp;
+	void *data = ifr->ifr_data;
+	void *va;
+	dma_addr_t dma;
+	u32 req_size, resp_size;
+	int status;
+
+	switch (cmd) {
+	case SIOCDEVPRIVATE:
+		if (copy_from_user(&req, (struct be_cmd_req_hdr *)data,
+			sizeof(struct be_cmd_req_hdr)))
+			return -EFAULT;
+
+		req_size = req.request_length + sizeof(struct be_cmd_req_hdr);
+
+		va = pci_alloc_consistent(adapter->pdev, req_size, &dma);
+		if (copy_from_user(va, (void *)data, req_size)) {
+			pci_free_consistent(adapter->pdev, req_size, va, dma);
+			return -EFAULT;
+		}
+
+		status = be_cmd_pass_ext_ioctl(&adapter->ctrl, dma, req_size);
+		if (!status) {
+			resp = (struct be_cmd_resp_hdr *) va;
+			resp_size = resp->response_length + sizeof(*resp);
+			if (copy_to_user((void *)data, va, resp_size)) {
+				pci_free_consistent(adapter->pdev,
+							req_size, va, dma);
+				return -EFAULT;
+			}
+		} else {
+			pci_free_consistent(adapter->pdev, req_size, va, dma);
+			return -EFAULT;
+		}
+		pci_free_consistent(adapter->pdev, req_size, va, dma);
+		break;
+	default:
+		return -EFAULT;
+	}
+	return 0;
+}
+
 static void be_set_multicast_filter(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -1632,6 +1679,7 @@ static struct net_device_ops be_netdev_o
 	.ndo_vlan_rx_register	= be_vlan_register,
 	.ndo_vlan_rx_add_vid	= be_vlan_add_vid,
 	.ndo_vlan_rx_kill_vid	= be_vlan_rem_vid,
+	.ndo_do_ioctl		= be_do_ioctl,
 };
 
 static void be_netdev_init(struct net_device *netdev)
-- 
1.4.0

