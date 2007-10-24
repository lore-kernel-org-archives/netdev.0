From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] e1000, e1000e valid-addr fixes
Date: Tue, 23 Oct 2007 20:55:29 -0400
Message-ID: <471E9801.2000006@garzik.org>
References: <471E2AD0.1000500@intel.com>	<471E5C21.8030908@garzik.org>	<20071023212026.GF7793@redhat.com> <20071023.145339.55504234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060508080304030905080901"
Cc: davej@redhat.com, auke-jan.h.kok@intel.com, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36557 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454AbXJXAzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 20:55:35 -0400
In-Reply-To: <20071023.145339.55504234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060508080304030905080901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Actually, looking over the code I see obvious bugs in the logic:

An invalid ethernet address should not cause device loading to fail, 
because the user is given the opportunity to supply a MAC address via 
userspace (ifconfig or whatever) before the interface goes up.

I just created the attached -bug fix- patch as illustration, though I 
have not committed it, waiting for comment.

This patch will make no difference for users hitting invalid-eep-csum 
rather than invalid-MAC-addr condition, but it's a problem I noticed 
while reviewing Adam's patch in detail.

	Jeff





--------------060508080304030905080901
Content-Type: text/plain;
 name="patch.e1000-addr"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.e1000-addr"

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f1ce348..8936d48 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1022,11 +1022,6 @@ e1000_probe(struct pci_dev *pdev,
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
-		goto err_eeprom;
-	}
-
 	e1000_get_bus_info(&adapter->hw);
 
 	init_timer(&adapter->tx_fifo_stall_timer);
@@ -1134,7 +1129,9 @@ e1000_probe(struct pci_dev *pdev,
 		 "32-bit"));
 	}
 
-	printk("%s\n", print_mac(mac, netdev->dev_addr));
+	printk("%s%s\n",
+	       print_mac(mac, netdev->dev_addr),
+	       is_valid_ether_addr(netdev->dev_addr) ? "" : " (INVALID)");
 
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
@@ -1396,6 +1393,9 @@ e1000_open(struct net_device *netdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int err;
 
+	if (!is_valid_ether_addr(netdev->dev_addr))
+		return -EINVAL;
+
 	/* disallow open during test */
 	if (test_bit(__E1000_TESTING, &adapter->flags))
 		return -EBUSY;
@@ -2377,7 +2377,7 @@ e1000_set_mac(struct net_device *netdev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
+		return -EINVAL;
 
 	/* 82542 2.0 needs to be in reset to write receive address registers */
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 033e124..0e3216c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2557,6 +2557,9 @@ static int e1000_open(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	int err;
 
+	if (!is_valid_ether_addr(netdev->dev_addr))
+		return -EINVAL;
+
 	/* disallow open during test */
 	if (test_bit(__E1000_TESTING, &adapter->state))
 		return -EBUSY;
@@ -2670,7 +2673,7 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
+		return -EINVAL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(adapter->hw.mac.addr, addr->sa_data, netdev->addr_len);
@@ -3960,14 +3963,16 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 
 	/* print bus type/speed/width info */
 	ndev_info(netdev, "(PCI Express:2.5GB/s:%s) "
-		  "%02x:%02x:%02x:%02x:%02x:%02x\n",
+		  "%02x:%02x:%02x:%02x:%02x:%02x%s\n",
 		  /* bus width */
 		 ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
 		  "Width x1"),
 		  /* MAC address */
 		  netdev->dev_addr[0], netdev->dev_addr[1],
 		  netdev->dev_addr[2], netdev->dev_addr[3],
-		  netdev->dev_addr[4], netdev->dev_addr[5]);
+		  netdev->dev_addr[4], netdev->dev_addr[5],
+		  is_valid_ether_addr(netdev->dev_addr) ?
+		  	"" : " (INVALID)");
 	ndev_info(netdev, "Intel(R) PRO/%s Network Connection\n",
 		  (hw->phy.type == e1000_phy_ife)
 		   ? "10/100" : "1000");
@@ -4170,16 +4175,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		ndev_err(netdev, "Invalid MAC Address: "
-			 "%02x:%02x:%02x:%02x:%02x:%02x\n",
-			 netdev->perm_addr[0], netdev->perm_addr[1],
-			 netdev->perm_addr[2], netdev->perm_addr[3],
-			 netdev->perm_addr[4], netdev->perm_addr[5]);
-		err = -EIO;
-		goto err_eeprom;
-	}
-
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &e1000_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;

--------------060508080304030905080901--
