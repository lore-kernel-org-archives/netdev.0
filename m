From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 09/10] atheros eth: set addr_assign_type if random_ether_addr() used
Date: Fri, 17 Feb 2012 16:43:30 +0100
Message-ID: <1329493411-25750-10-git-send-email-danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set addr_assign_type correctly to NET_ADDR_RANDOM in case
a random MAC address was generated and assigned to the netdevice.

Fix error handling in atl1c_probe(). If atl1c_read_mac_addr()
couldn't get the hw mac address, and a random mac address get
set return the error code. Don't go to err_eeprom in
atl1c_probe(), use the generated MAC address in this case.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

v2: use bitops

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c   |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    9 ++++-----
 drivers/net/ethernet/atheros/atlx/atl1.c        |   12 +++++++++---
 drivers/net/ethernet/atheros/atlx/atlx.c        |    1 +
 4 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 23f2ab0..bd1667c 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -224,7 +224,7 @@ int atl1c_read_mac_addr(struct atl1c_hw *hw)
 		random_ether_addr(hw->perm_mac_addr);
 
 	memcpy(hw->mac_addr, hw->perm_mac_addr, sizeof(hw->perm_mac_addr));
-	return 0;
+	return err;
 }
 
 /*
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index b859124..1e4e645 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -468,6 +468,7 @@ static int atl1c_set_mac_addr(struct net_device *netdev, void *p)
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
+	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	atl1c_hw_set_mac_addr(&adapter->hw);
 
@@ -2746,10 +2747,9 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 		err = -EIO;
 		goto err_reset;
 	}
-	if (atl1c_read_mac_addr(&adapter->hw) != 0) {
-		err = -EIO;
-		dev_err(&pdev->dev, "get mac address failed\n");
-		goto err_eeprom;
+	if (atl1c_read_mac_addr(&adapter->hw)) {
+		/* got a random MAC address, set NET_ADDR_RANDOM to netdev */
+		netdev->addr_assign_type |= NET_ADDR_RANDOM;
 	}
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
@@ -2774,7 +2774,6 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 err_reset:
 err_register:
 err_sw_init:
-err_eeprom:
 	iounmap(adapter->hw.hw_addr);
 err_init_netdev:
 err_ioremap:
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 9bd2049..40ac414 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -534,14 +534,17 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
  */
 static s32 atl1_read_mac_addr(struct atl1_hw *hw)
 {
+	s32 ret = 0;
 	u16 i;
 
-	if (atl1_get_permanent_address(hw))
+	if (atl1_get_permanent_address(hw)) {
 		random_ether_addr(hw->perm_mac_addr);
+		ret = 1;
+	}
 
 	for (i = 0; i < ETH_ALEN; i++)
 		hw->mac_addr[i] = hw->perm_mac_addr[i];
-	return 0;
+	return ret;
 }
 
 /*
@@ -3007,7 +3010,10 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	}
 
 	/* copy the MAC address out of the EEPROM */
-	atl1_read_mac_addr(&adapter->hw);
+	if (atl1_read_mac_addr(&adapter->hw)) {
+		/* mark random mac */
+		netdev->addr_assign_type |= NET_ADDR_RANDOM;
+	}
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
diff --git a/drivers/net/ethernet/atheros/atlx/atlx.c b/drivers/net/ethernet/atheros/atlx/atlx.c
index 8ff7411..3cd8837 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -84,6 +84,7 @@ static int atlx_set_mac(struct net_device *netdev, void *p)
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
+	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	atlx_set_mac_addr(&adapter->hw);
 	return 0;
-- 
1.7.8.3
