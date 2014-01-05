From: Eyal Perry <eyalpe@mellanox.com>
Subject: [PATCH net-next V1] net/mlx4_core: Warn if device doesn't have enough PCI bandwidth
Date: Sun,  5 Jan 2014 17:41:08 +0200
Message-ID: <1388936468-5293-1-git-send-email-eyalpe@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60273 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751186AbaAEPlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 10:41:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check if the device get enough bandwidth from the entire PCI chain to satisfy
its capabilities. This patch determines the PCIe device's bandwidth capabilities
by reading its PCIe Link Capabilities registers and then call the
pcie_get_minimum_link function to ensure that the adapter is hooked into a slot
which is capable of providing the necessary bandwidth capabilities.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---

Changes from V0:
Make mlx4_check_pcie_caps return value void, since it is ignored anyway.

 drivers/net/ethernet/mellanox/mlx4/main.c | 84 +++++++++++++++++++++++++++++++
 1 file changed, 84 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index fbebfb0..a93913f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -388,6 +388,84 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 
 	return 0;
 }
+
+static int mlx4_get_pcie_dev_link_caps(struct mlx4_dev *dev,
+				       enum pci_bus_speed *speed,
+				       enum pcie_link_width *width)
+{
+	u32 lnkcap1, lnkcap2;
+	int err1, err2;
+
+#define  PCIE_MLW_CAP_SHIFT 4	/* start of MLW mask in link capabilities */
+
+	*speed = PCI_SPEED_UNKNOWN;
+	*width = PCIE_LNK_WIDTH_UNKNOWN;
+
+	err1 = pcie_capability_read_dword(dev->pdev, PCI_EXP_LNKCAP, &lnkcap1);
+	err2 = pcie_capability_read_dword(dev->pdev, PCI_EXP_LNKCAP2, &lnkcap2);
+	if (!err2 && lnkcap2) { /* PCIe r3.0-compliant */
+		if (lnkcap2 & PCI_EXP_LNKCAP2_SLS_8_0GB)
+			*speed = PCIE_SPEED_8_0GT;
+		else if (lnkcap2 & PCI_EXP_LNKCAP2_SLS_5_0GB)
+			*speed = PCIE_SPEED_5_0GT;
+		else if (lnkcap2 & PCI_EXP_LNKCAP2_SLS_2_5GB)
+			*speed = PCIE_SPEED_2_5GT;
+	}
+	if (!err1) {
+		*width = (lnkcap1 & PCI_EXP_LNKCAP_MLW) >> PCIE_MLW_CAP_SHIFT;
+		if (!lnkcap2) { /* pre-r3.0 */
+			if (lnkcap1 & PCI_EXP_LNKCAP_SLS_5_0GB)
+				*speed = PCIE_SPEED_5_0GT;
+			else if (lnkcap1 & PCI_EXP_LNKCAP_SLS_2_5GB)
+				*speed = PCIE_SPEED_2_5GT;
+		}
+	}
+
+	if (*speed == PCI_SPEED_UNKNOWN || *width == PCIE_LNK_WIDTH_UNKNOWN) {
+		return err1 ? err1 :
+			err2 ? err2 : -EINVAL;
+	}
+	return 0;
+}
+
+static void mlx4_check_pcie_caps(struct mlx4_dev *dev)
+{
+	enum pcie_link_width width, width_cap;
+	enum pci_bus_speed speed, speed_cap;
+	int err;
+
+#define PCIE_SPEED_STR(speed) \
+	(speed == PCIE_SPEED_8_0GT ? "8.0GT/s" : \
+	 speed == PCIE_SPEED_5_0GT ? "5.0GT/s" : \
+	 speed == PCIE_SPEED_2_5GT ? "2.5GT/s" : \
+	 "Unknown")
+
+	err = mlx4_get_pcie_dev_link_caps(dev, &speed_cap, &width_cap);
+	if (err) {
+		mlx4_warn(dev,
+			  "Unable to determine PCIe device BW capabilities\n");
+		return;
+	}
+
+	err = pcie_get_minimum_link(dev->pdev, &speed, &width);
+	if (err || speed == PCI_SPEED_UNKNOWN ||
+	    width == PCIE_LNK_WIDTH_UNKNOWN) {
+		mlx4_warn(dev,
+			  "Unable to determine PCI device chain minimum BW\n");
+		return;
+	}
+
+	if (width != width_cap || speed != speed_cap)
+		mlx4_warn(dev,
+			  "PCIe BW is different than device's capability\n");
+
+	mlx4_info(dev, "PCIe link speed is %s, device supports %s\n",
+		  PCIE_SPEED_STR(speed), PCIE_SPEED_STR(speed_cap));
+	mlx4_info(dev, "PCIe link width is x%d, device supports x%d\n",
+		  width, width_cap);
+	return;
+}
+
 /*The function checks if there are live vf, return the num of them*/
 static int mlx4_how_many_lives_vf(struct mlx4_dev *dev)
 {
@@ -2292,6 +2370,12 @@ slave_start:
 			goto err_mfunc;
 	}
 
+	/* check if the device is functioning at its maximum possible speed.
+	 * No return code for this call, just warn the user in case of PCI
+	 * express device capabilities are under-satisfied by the bus.
+	 */
+	mlx4_check_pcie_caps(dev);
+
 	/* In master functions, the communication channel must be initialized
 	 * after obtaining its address from fw */
 	if (mlx4_is_master(dev)) {
-- 
1.7.11.3
