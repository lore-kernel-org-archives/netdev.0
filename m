From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next] net/mlx4_core: Add extra check for total vfs for SRIOV
Date: Mon,  6 Jul 2015 09:20:19 -0500
Message-ID: <1436192419-25303-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, jackm@mellanox.com,
	Carol Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:47820 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378AbbGFOYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 10:24:55 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Mon, 6 Jul 2015 11:24:49 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 269CA3520027
	for <netdev@vger.kernel.org>; Mon,  6 Jul 2015 10:23:41 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t66ENSGi6553860
	for <netdev@vger.kernel.org>; Mon, 6 Jul 2015 11:23:28 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t66EOhd8021072
	for <netdev@vger.kernel.org>; Mon, 6 Jul 2015 11:24:44 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol Soto <clsoto@linux.vnet.ibm.com>

Add extra check for total vfs for SRIOV to check if that value is 
bigger than total vfs in pci SRIOV capabalities. Fix a check and 
print of the number of maximum vfs that hw can handle. Fix a check 
and print of the number of maximum vfs per port that driver can handle. 

Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 12fbfcb..d76f425 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2907,6 +2907,8 @@ static u64 mlx4_enable_sriov(struct mlx4_dev *dev, struct pci_dev *pdev,
 {
 	u64 dev_flags = dev->flags;
 	int err = 0;
+	int fw_enabled_sriov_vfs = min(pci_sriov_get_totalvfs(pdev),
+					MLX4_MAX_NUM_VF);
 
 	if (reset_flow) {
 		dev->dev_vfs = kcalloc(total_vfs, sizeof(*dev->dev_vfs),
@@ -2932,6 +2934,12 @@ static u64 mlx4_enable_sriov(struct mlx4_dev *dev, struct pci_dev *pdev,
 	}
 
 	if (!(dev->flags &  MLX4_FLAG_SRIOV)) {
+		if (total_vfs > fw_enabled_sriov_vfs) {
+			mlx4_err(dev, "requested vfs (%d) > available vfs (%d). Continuing without SR_IOV\n",
+				 total_vfs, fw_enabled_sriov_vfs);
+			err = -ENOMEM;
+			goto disable_sriov;
+		}
 		mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n", total_vfs);
 		err = pci_enable_sriov(pdev, total_vfs);
 	}
@@ -3413,20 +3421,20 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
 			goto err_disable_pdev;
 		}
 	}
-	if (total_vfs >= MLX4_MAX_NUM_VF) {
+	if (total_vfs > MLX4_MAX_NUM_VF) {
 		dev_err(&pdev->dev,
-			"Requested more VF's (%d) than allowed (%d)\n",
-			total_vfs, MLX4_MAX_NUM_VF - 1);
+			"Requested more VF's (%d) than allowed by hw (%d)\n",
+			total_vfs, MLX4_MAX_NUM_VF);
 		err = -EINVAL;
 		goto err_disable_pdev;
 	}
 
 	for (i = 0; i < MLX4_MAX_PORTS; i++) {
-		if (nvfs[i] + nvfs[2] >= MLX4_MAX_NUM_VF_P_PORT) {
+		if (nvfs[i] + nvfs[2] > MLX4_MAX_NUM_VF_P_PORT) {
 			dev_err(&pdev->dev,
-				"Requested more VF's (%d) for port (%d) than allowed (%d)\n",
+				"Requested more VF's (%d) for port (%d) than allowed by driver (%d)\n",
 				nvfs[i] + nvfs[2], i + 1,
-				MLX4_MAX_NUM_VF_P_PORT - 1);
+				MLX4_MAX_NUM_VF_P_PORT);
 			err = -EINVAL;
 			goto err_disable_pdev;
 		}
-- 
1.8.3.1
