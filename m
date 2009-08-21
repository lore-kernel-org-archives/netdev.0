From: Frans Pop <elendil@planet.nl>
Subject: [PATCH] Re: e1000e: why does pci_enable_pcie_error_reporting() fail on my hp2510p?
Date: Fri, 21 Aug 2009 08:29:09 +0200
Message-ID: <200908210829.10471.elendil@planet.nl>
References: <200908201714.30638.elendil@planet.nl> <4A8E01AE.5070900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Danny Feng <dfeng@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml104.kpnxchange.com ([195.121.3.8]:61686 "EHLO
	CPSMTPM-EML104.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752442AbZHUG3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 02:29:11 -0400
In-Reply-To: <4A8E01AE.5070900@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 21 August 2009, Danny Feng wrote:
> On 08/20/2009 11:14 PM, Frans Pop wrote:
> > e1000e 0000:00:19.0: pci_enable_pcie_error_reporting failed
>
> I think this messages comes from hardware does not support pcie aer.
> In fact the messages is not fatal and can be ignored. Some drivers
> is silence with pci_enable_pcie_error_reporting ....

Right. The only error returned by the function is -EIO, which looks to be
"not supported". That's really not an issue to shout about in dmesg...

> My patch is just to fix the logic of pcie aer usage ...
>
> > - as the error is non-fatal, should it maybe be changed from dev_err
> >    to dev_info, so that at least it does not show up during a boot
> >    with 'quiet'?
>
> I agree with this.... Maybe some of other drivers needs this too
> (igb,ixgbe)...

Here's a patch that simply drops the message.
Note: the two scsi drivers that call the function (arcmsr and qla2xxx)
also don't check the return code.

Alternatives would be:
- change the message to something like "device does not support advanced
  error reporting (AER)" and make it dev_debug
- suppress the error in case of -EIO, but I'm not sure that makes sense
  as -EIO is the only error returned and you might not want to ignore other
  errors

If you'd prefer the alternatives, let me know and I'll modify the patch.

Cheers,
FJP


From: Frans Pop <elendil@planet.nl>
Subject: net: Don't report an error if devices don't support AER

The only error returned by pci_enable_pcie_error_reporting() is -EIO
which simply means that Advanced Error Reporting is not supported.
There is no need to report that, so remove the error check from e1001e,
igb and ixgbe.

Signed-off-by: Frans Pop <elendil@planet.nl>
    ---

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fa92a68..42ac8f1 100644
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
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index adb09d3..8e80859 100644
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
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 77b0381..4e0b523 100644
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
