From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH,v3] Re: e1000e: why does pci_enable_pcie_error_reporting() fail on my hp2510p?
Date: Fri, 21 Aug 2009 09:39:00 +0200
Message-ID: <200908210939.02329.elendil@planet.nl>
References: <200908201714.30638.elendil@planet.nl> <200908210848.39377.elendil@planet.nl> <1250838372.9489.8.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Danny Feng <dfeng@redhat.com>, Netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml109.kpnxchange.com ([195.121.3.13]:53634 "EHLO
	CPSMTPM-EML109.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753113AbZHUHjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 03:39:03 -0400
In-Reply-To: <1250838372.9489.8.camel@fnki-nb00130>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 21 August 2009, Jens Rosenboom wrote:
> While you're at it, why don't you also remove the "err =" here, which
> allows you to drop the variable from that function completely? This
> applies to all three *_remove() functions.

Argh! Sloppy. Shouldn't do this kind of thing before breakfast :-/
Thanks. Hope this version will pass muster.


From: Frans Pop <elendil@planet.nl>
Subject: net: Don't report an error if devices don't support AER

The only error returned by pci_{en,dis}able_pcie_error_reporting() is
-EIO which simply means that Advanced Error Reporting is not supported.
There is no need to report that, so remove the error check from e1001e,
igb and ixgbe.

Signed-off-by: Frans Pop <elendil@planet.nl>

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fa92a68..2d421da 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4983,12 +4983,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 
 	/* AER (Advanced Error Reporting) hooks */
-	err = pci_enable_pcie_error_reporting(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
-		        "0x%x\n", err);
-		/* non-fatal, continue */
-	}
+	pci_enable_pcie_error_reporting(pdev);
 
 	pci_set_master(pdev);
 	/* PCI config space info */
@@ -5264,7 +5259,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	int err;
 
 	/*
 	 * flush_scheduled work may reschedule our watchdog task, so
@@ -5300,10 +5294,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 
 	/* AER disable */
-	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
+	pci_disable_pcie_error_reporting(pdev);
 
 	pci_disable_device(pdev);
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index adb09d3..f4393df 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1232,12 +1232,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_pci_reg;
 
-	err = pci_enable_pcie_error_reporting(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
-		        "0x%x\n", err);
-		/* non-fatal, continue */
-	}
+	pci_enable_pcie_error_reporting(pdev);
 
 	pci_set_master(pdev);
 	pci_save_state(pdev);
@@ -1613,7 +1608,6 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	int err;
 
 	/* flush_scheduled work may reschedule our watchdog task, so
 	 * explicitly disable watchdog tasks from being rescheduled  */
@@ -1667,10 +1661,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
-	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
+	pci_disable_pcie_error_reporting(pdev);
 
 	pci_disable_device(pdev);
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 77b0381..6520496 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5430,12 +5430,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 	}
 
-	err = pci_enable_pcie_error_reporting(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
-		                    "0x%x\n", err);
-		/* non-fatal, continue */
-	}
+	pci_enable_pcie_error_reporting(pdev);
 
 	pci_set_master(pdev);
 	pci_save_state(pdev);
@@ -5743,7 +5738,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int err;
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	/* clear the module not found bit to make sure the worker won't
@@ -5794,10 +5788,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 
-	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
+	pci_disable_pcie_error_reporting(pdev);
 
 	pci_disable_device(pdev);
 }
