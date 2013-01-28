From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] igbvf: be sane about random MAC addresses
Date: Mon, 28 Jan 2013 01:04:29 -0800
Message-ID: <1359363869-32391-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23510 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754710Ab3A1JEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:43 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

Tighten up some of the code surrounding MAC addresses. Since the PF is
now giving all zeros instead of a random address, check for this case
and generate a random address. This ensures that we always know when we
have a random address and udev won't get upset about it.

Additionally, tighten up some of the log messages and clean up the
formatting.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 8f66d45..8224889 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2735,26 +2735,22 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
 		dev_info(&pdev->dev,
-			 "PF still in reset state, assigning new address."
-			 " Is the PF interface up?\n");
-		eth_hw_addr_random(netdev);
-		memcpy(adapter->hw.mac.addr, netdev->dev_addr,
-			netdev->addr_len);
+			 "PF still in reset state. Is the PF interface up?\n");
 	} else {
 		err = hw->mac.ops.read_mac_addr(hw);
-		if (err) {
-			dev_err(&pdev->dev, "Error reading MAC address\n");
-			goto err_hw_init;
-		}
+		if (err)
+			dev_info(&pdev->dev, "Error reading MAC address.\n");
+		else if (is_zero_ether_addr(adapter->hw.mac.addr))
+			dev_info(&pdev->dev, "MAC address not assigned by administrator.\n");
 		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
-			netdev->addr_len);
+		       netdev->addr_len);
 	}
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		dev_err(&pdev->dev, "Invalid MAC Address: %pM\n",
-		        netdev->dev_addr);
-		err = -EIO;
-		goto err_hw_init;
+		dev_info(&pdev->dev, "Assigning random MAC address.\n");
+		eth_hw_addr_random(netdev);
+		memcpy(adapter->hw.mac.addr, netdev->dev_addr,
+			netdev->addr_len);
 	}
 
 	setup_timer(&adapter->watchdog_timer, &igbvf_watchdog,
-- 
1.7.11.7
