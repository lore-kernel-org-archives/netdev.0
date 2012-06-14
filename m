From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] e1000e: use more informative logging macros when netdev not yet registered
Date: Thu, 14 Jun 2012 03:18:04 -0700
Message-ID: <1339669089-27955-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1339669089-27955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6172 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755566Ab2FNKSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 06:18:13 -0400
In-Reply-To: <1339669089-27955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Based on a report from Ethan Zhao, before calling register_netdev() the
driver should be using logging macros that do not display the potentially
confusing "(unregistered net_device)" yet still display the useful driver
name and PCI bus/device/function.

Reported-by: Ethan Zhao <ethan.kernel@gmail.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   11 ++++---
 drivers/net/ethernet/intel/e1000e/param.c  |   43 +++++++++++++++++-----------
 2 files changed, 34 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 31d37a2..ba86b3f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6238,7 +6238,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	}
 
 	if (hw->phy.ops.check_reset_block && hw->phy.ops.check_reset_block(hw))
-		e_info("PHY reset is blocked due to SOL/IDER session.\n");
+		dev_info(&pdev->dev,
+			 "PHY reset is blocked due to SOL/IDER session.\n");
 
 	/* Set initial default active device features */
 	netdev->features = (NETIF_F_SG |
@@ -6288,7 +6289,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		if (e1000_validate_nvm_checksum(&adapter->hw) >= 0)
 			break;
 		if (i == 2) {
-			e_err("The NVM Checksum Is Not Valid\n");
+			dev_err(&pdev->dev, "The NVM Checksum Is Not Valid\n");
 			err = -EIO;
 			goto err_eeprom;
 		}
@@ -6298,13 +6299,15 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* copy the MAC address */
 	if (e1000e_read_mac_addr(&adapter->hw))
-		e_err("NVM Read Error while reading MAC address\n");
+		dev_err(&pdev->dev,
+			"NVM Read Error while reading MAC address\n");
 
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		e_err("Invalid MAC Address: %pM\n", netdev->perm_addr);
+		dev_err(&pdev->dev, "Invalid MAC Address: %pM\n",
+			netdev->perm_addr);
 		err = -EIO;
 		goto err_eeprom;
 	}
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 55cc156..dfbfa7f 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -199,16 +199,19 @@ static int __devinit e1000_validate_option(unsigned int *value,
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			e_info("%s Enabled\n", opt->name);
+			dev_info(&adapter->pdev->dev, "%s Enabled\n",
+				 opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			e_info("%s Disabled\n", opt->name);
+			dev_info(&adapter->pdev->dev, "%s Disabled\n",
+				 opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			e_info("%s set to %i\n", opt->name, *value);
+			dev_info(&adapter->pdev->dev, "%s set to %i\n",
+				 opt->name, *value);
 			return 0;
 		}
 		break;
@@ -220,7 +223,8 @@ static int __devinit e1000_validate_option(unsigned int *value,
 			ent = &opt->arg.l.p[i];
 			if (*value == ent->i) {
 				if (ent->str[0] != '\0')
-					e_info("%s\n", ent->str);
+					dev_info(&adapter->pdev->dev, "%s\n",
+						 ent->str);
 				return 0;
 			}
 		}
@@ -230,8 +234,8 @@ static int __devinit e1000_validate_option(unsigned int *value,
 		BUG();
 	}
 
-	e_info("Invalid %s value specified (%i) %s\n", opt->name, *value,
-	       opt->err);
+	dev_info(&adapter->pdev->dev, "Invalid %s value specified (%i) %s\n",
+		 opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -251,8 +255,10 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 	int bd = adapter->bd_number;
 
 	if (bd >= E1000_MAX_NIC) {
-		e_notice("Warning: no configuration for board #%i\n", bd);
-		e_notice("Using defaults for all values\n");
+		dev_notice(&adapter->pdev->dev,
+			   "Warning: no configuration for board #%i\n", bd);
+		dev_notice(&adapter->pdev->dev,
+			   "Using defaults for all values\n");
 	}
 
 	{ /* Transmit Interrupt Delay */
@@ -366,27 +372,32 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			 * default values
 			 */
 			if (adapter->itr > 4)
-				e_info("%s set to default %d\n", opt.name,
-				       adapter->itr);
+				dev_info(&adapter->pdev->dev,
+					 "%s set to default %d\n", opt.name,
+					 adapter->itr);
 		}
 
 		adapter->itr_setting = adapter->itr;
 		switch (adapter->itr) {
 		case 0:
-			e_info("%s turned off\n", opt.name);
+			dev_info(&adapter->pdev->dev, "%s turned off\n",
+				 opt.name);
 			break;
 		case 1:
-			e_info("%s set to dynamic mode\n", opt.name);
+			dev_info(&adapter->pdev->dev,
+				 "%s set to dynamic mode\n", opt.name);
 			adapter->itr = 20000;
 			break;
 		case 3:
-			e_info("%s set to dynamic conservative mode\n",
-			       opt.name);
+			dev_info(&adapter->pdev->dev,
+				 "%s set to dynamic conservative mode\n",
+				 opt.name);
 			adapter->itr = 20000;
 			break;
 		case 4:
-			e_info("%s set to simplified (2000-8000 ints) mode\n",
-			       opt.name);
+			dev_info(&adapter->pdev->dev,
+				 "%s set to simplified (2000-8000 ints) mode\n",
+				 opt.name);
 			break;
 		default:
 			/*
-- 
1.7.10.2
