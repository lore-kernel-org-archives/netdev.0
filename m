From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: "sky2: set VPD size" triggers card recognition failure
Date: Thu, 11 Jun 2009 10:03:47 -0700
Message-ID: <20090611100347.7c4160a4@nehalam>
References: <20090611122942.GA7554@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andy Whitcroft <apw@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41905 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbZFKRDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 13:03:51 -0400
In-Reply-To: <20090611122942.GA7554@shadowen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009 13:29:42 +0100
Andy Whitcroft <apw@canonical.com> wrote:

> We have reports[1] of sky2 cards failing to be recognised with the latest
> 2.6.30-rc8 kernels.  We are seeing what appears to be failures to
> obtains the chip id correctly:
> 
>     sky2 driver version 1.22
>     sky2 0000:02:00.0: enabling device (0000 -> 0003)
>     sky2 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
>     sky2 0000:02:00.0: setting latency timer to 64
>     sky2 0000:02:00.0: Can't set VPD size
>     sky2 0000:02:00.0: unsupported chip type 0xff
>     sky2 0000:02:00.0: PCI INT A disabled
>     sky2: probe of 0000:02:00.0 failed with error -95
> 
> Based on the VPD size failure message we reverted just the commit below,
> which restored the card:
> 
>     commit 3834507d0c5480a0f05486c2fb57ed18fd179a83
>     Author: Stephen Hemminger <shemminger@vyatta.com>
>     Date:   Tue Feb 3 11:27:30 2009 +0000
> 
> 	sky2: set VPD size
> 	
> 	Read configuration register during probe and use it to size the
> 	available VPD. Move existing code using same register slightly
> 	earlier in probe handling.
> 	
> 	Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 	Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Steven, any thoughts?

Some of the chip version have different registers, and some hardware vendors build
boards without VPD.  Does this help:

---------
Subject: sky2: don't look for VPD size

The code to compute VPD size didn't handle some systems that use
chip without VPD. Also some of the newer chips use some additional
registers to store the actual size, and wasn't worth putting the
additional complexity in, so just remove the code.

No big loss since the code to set the VPD size was only a 
convenience so that utilities would not read the extra space past
the end of the available VPD.

Move the first PCI config read earlier to detect bad hardware
where it returns all ones and refuse loading driver before furthur
damage.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-06-11 09:26:05.420060719 -0700
+++ b/drivers/net/sky2.c	2009-06-11 09:28:27.004211122 -0700
@@ -4431,6 +4431,22 @@ static int __devinit sky2_probe(struct p
 		goto err_out;
 	}
 
+	/* Get configuration information
+	 * Note: only regular PCI config access once to test for HW issues
+	 *       other PCI access through shared memory for speed and to
+	 *	 avoid MMCONFIG problems.
+	 */
+	err = pci_read_config_dword(pdev, PCI_DEV_REG2, &reg);
+	if (err) {
+		dev_err(&pdev->dev, "PCI read config failed\n");
+		goto err_out;
+	}
+
+	if (~reg == 0) {
+		dev_err(&pdev->dev, "PCI configuration read error\n");
+		goto err_out;
+	}
+
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
@@ -4456,21 +4472,6 @@ static int __devinit sky2_probe(struct p
 		}
 	}
 
-	/* Get configuration information
-	 * Note: only regular PCI config access once to test for HW issues
-	 *       other PCI access through shared memory for speed and to
-	 *	 avoid MMCONFIG problems.
-	 */
-	err = pci_read_config_dword(pdev, PCI_DEV_REG2, &reg);
-	if (err) {
-		dev_err(&pdev->dev, "PCI read config failed\n");
-		goto err_out_free_regions;
-	}
-
-	/* size of available VPD, only impact sysfs */
-	err = pci_vpd_truncate(pdev, 1ul << (((reg & PCI_VPD_ROM_SZ) >> 14) + 8));
-	if (err)
-		dev_warn(&pdev->dev, "Can't set VPD size\n");
 
 #ifdef __BIG_ENDIAN
 	/* The sk98lin vendor driver uses hardware byte swapping but
