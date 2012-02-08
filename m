From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 30/50] atheros eth: set addr_assign_type if random_ether_addr() used
Date: Wed,  8 Feb 2012 22:10:37 +0100
Message-ID: <1328735457-29986-31-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jiri Pirko <jpirko@redhat.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Decotigny <decot@google.com>
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set addr_assign_type correctly to NET_ADDR_RANDOM in case
a random MAC address was generated and assigned to the netdevice.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c   |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   11 ++++++-----
 drivers/net/ethernet/atheros/atlx/atl1.c        |   12 +++++++++---
 drivers/net/ethernet/atheros/atlx/atlx.c        |    3 +++
 4 files changed, 19 insertions(+), 9 deletions(-)

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
index b859124..edc0442 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -467,6 +467,9 @@ static int atl1c_set_mac_addr(struct net_device *netdev, void *p)
 		return -EBUSY;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	/* reset to NET_ADDR_PERM if was random */
+	if (netdev->addr_assign_type & NET_ADDR_RANDOM)
+		netdev->addr_assign_type ^= NET_ADDR_RANDOM;
 	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
 
 	atl1c_hw_set_mac_addr(&adapter->hw);
@@ -2746,10 +2749,9 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
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
@@ -2774,7 +2776,6 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
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
index 8ff7411..77d2925 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -83,6 +83,9 @@ static int atlx_set_mac(struct net_device *netdev, void *p)
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	/* reset to NET_ADDR_PERM if was random */
+	if (netdev->addr_assign_type & NET_ADDR_RANDOM)
+		netdev->addr_assign_type ^= NET_ADDR_RANDOM;
 	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
 
 	atlx_set_mac_addr(&adapter->hw);
-- 
1.7.7.3
