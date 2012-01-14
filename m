From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing probe
Date: Fri, 13 Jan 2012 22:44:55 -0800
Message-ID: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com>
Cc: Darren Hart <dvhart@linux.intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Alan Cox <alan@linux.intel.com>,
	Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com> (commit_signer:1/3=33%
	,commit_signer:1/8=12%), "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the MAC is invalid or not implemented, use a randomly generated one rather
than failing the probe. Store the generated addr in a new sw_mac array in the
pch_gbe_mac_info structure. Take care to allow for assigning the MAC via
ifconfig by reusing sw_addr to store an assigned mac if probe populated it with
a random one (otherwise the assignment would rely on the ROM and the reset would
fail to write a valid MAC to the rx filter).

Tested on two platforms, one with a valid MAC, the other without a MAC. The
real MAC is used if present, a randomly generated one otherwise. Both are
capable of changing the MAC with ifconfig. They successfully get an IP over
DHCP and pass a simple ping and login over ssh test.

This does not make any attempt to address a missing or invalid MAC for the
pch_phub driver.

Signed-off-by: Darren Hart <dvhart@linux.intel.com>
CC: Arjan van de Ven <arjan@linux.intel.com>
CC: Alan Cox <alan@linux.intel.com>
CC: Tomoya MORINAGA <tomoya.rohm@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com> (commit_signer:1/3=33%,commit_signer:1/8=12%)
CC: "David S. Miller" <davem@davemloft.net>
CC: Paul Gortmaker <paul.gortmaker@windriver.com>
CC: Jon Mason <jdmason@kudzu.us>
CC: netdev@vger.kernel.org
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    3 ++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   25 ++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index a09a071..3a451a9 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -356,6 +356,8 @@ struct pch_gbe_functions {
 /**
  * struct pch_gbe_mac_info - MAC information
  * @addr[6]:		Store the MAC address
+ * @sw_addr[6]:		Store a random or specified MAC address if the
+ *			ROM is invalid or missing.
  * @fc:			Mode of flow control
  * @fc_autoneg:		Auto negotiation enable for flow control setting
  * @tx_fc_enable:	Enable flag of Transmit flow control
@@ -367,6 +369,7 @@ struct pch_gbe_functions {
  */
 struct pch_gbe_mac_info {
 	u8 addr[6];
+	u8 sw_addr[6];
 	u8 fc;
 	u8 fc_autoneg;
 	u8 tx_fc_enable;
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 964e9c0..6453a71 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -116,6 +116,16 @@ s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
 {
 	u32  adr1a, adr1b;
 
+	/*
+	 * If we generated a random mac address during probe, then the one in
+	 * the ROM is either invalid or missing, use the generated one instead.
+	 */
+	if (is_valid_ether_addr(hw->mac.sw_addr)) {
+		memcpy(hw->mac.addr, hw->mac.sw_addr, 6);
+		pr_debug("hw->mac.addr : %pM (using random generated addr)\n", hw->mac.addr);
+		return 0;
+	}
+
 	adr1a = ioread32(&hw->reg->mac_adr[0].high);
 	adr1b = ioread32(&hw->reg->mac_adr[0].low);
 
@@ -2036,6 +2046,8 @@ static int pch_gbe_set_mac(struct net_device *netdev, void *addr)
 		ret_val = -EADDRNOTAVAIL;
 	} else {
 		memcpy(netdev->dev_addr, skaddr->sa_data, netdev->addr_len);
+		if (is_valid_ether_addr(adapter->hw.mac.sw_addr))
+			memcpy(adapter->hw.mac.sw_addr, skaddr->sa_data, netdev->addr_len);
 		memcpy(adapter->hw.mac.addr, skaddr->sa_data, netdev->addr_len);
 		pch_gbe_mac_mar_set(&adapter->hw, adapter->hw.mac.addr, 0);
 		ret_val = 0;
@@ -2444,6 +2456,19 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	pch_gbe_set_ethtool_ops(netdev);
 
 	pch_gbe_mac_load_mac_addr(&adapter->hw);
+
+	/*
+	 * Try to read the MAC address. If it is invalid (or just missing),
+	 * generate a random one to use from here on out.
+	 */
+	pch_gbe_mac_read_mac_addr(&adapter->hw);
+	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
+		dev_err(&pdev->dev, "Invalid MAC address, "
+		                    "using a random generated one.\n");
+		random_ether_addr(adapter->hw.mac.sw_addr);
+		memcpy(adapter->hw.mac.addr, adapter->hw.mac.sw_addr, netdev->addr_len);
+	}
+
 	pch_gbe_mac_reset_hw(&adapter->hw);
 
 	/* setup the private structure */
-- 
1.7.6.5
