From: Frans Pop <elendil@planet.nl>
Subject: [PATCH,v2] Re: e1000e: why does pci_enable_pcie_error_reporting() fail on my hp2510p?
Date: Fri, 21 Aug 2009 08:48:38 +0200
Message-ID: <200908210848.39377.elendil@planet.nl>
References: <200908201714.30638.elendil@planet.nl> <200908210829.10471.elendil@planet.nl> <4A8E3FC1.50201@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Danny Feng <dfeng@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml110.kpnxchange.com ([195.121.3.14]:55140 "EHLO
	CPSMTPM-EML110.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752796AbZHUGsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 02:48:39 -0400
In-Reply-To: <4A8E3FC1.50201@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 21 August 2009, Danny Feng wrote:
> You may also need to silence pci_disable_pcie_error_reporting,
> otherwise rmmod/shutdown, you will get
>
> e1000e 0000:00:19.0: pci_disable_pcie_error_reporting failed

Yes, thanks. Exactly the same thing there. Updated patch below.


From: Frans Pop <elendil@planet.nl>
Subject: net: Don't report an error if devices don't support AER

The only error returned by pci_{en,dis}able_pcie_error_reporting() is
-EIO which simply means that Advanced Error Reporting is not supported.
There is no need to report that, so remove the error check from e1001e,
igb and ixgbe.

Signed-off-by: Frans Pop <elendil@planet.nl>

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fa92a68..d67798f 100644
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
@@ -5301,9 +5296,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 
 	/* AER disable */
 	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
 
 	pci_disable_device(pdev);
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index adb09d3..1533d6f 100644
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
@@ -1668,9 +1663,6 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 
 	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
 
 	pci_disable_device(pdev);
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 77b0381..777556d 100644
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
@@ -5795,9 +5790,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 
 	err = pci_disable_pcie_error_reporting(pdev);
-	if (err)
-		dev_err(&pdev->dev,
-		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
 
 	pci_disable_device(pdev);
 }
