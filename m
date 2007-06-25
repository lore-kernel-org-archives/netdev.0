From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [PATCH] atl1: disable 64bit DMA
Date: Mon, 25 Jun 2007 23:18:55 +0200
Message-ID: <20070625211855.GA19275@dreamland.darkstar.lan>
References: <467B12CA.5060405@esuna.co.uk> <467BE118.4090308@redhat.com> <467BE4F1.7040308@esuna.co.uk> <467D0EB0.9030100@esuna.co.uk> <20070624125957.2e27820c@osprey.hogchain.net> <467ED4A8.4080500@esuna.co.uk> <20070624164519.04f215b8@osprey.hogchain.net> <467FB237.2030703@esuna.co.uk> <467FB844.6060702@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	"Jay L. T. Cornwall" <jay@esuna.co.uk>,
	linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:6865 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbXFYVS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 17:18:59 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1379826ugf
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 14:18:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <467FB844.6060702@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il Mon, Jun 25, 2007 at 07:42:44AM -0500, Jay Cliburn ha scritto: 
> Jay L. T. Cornwall wrote:
> >Jay Cliburn wrote:
> >
> >>For reasons not yet clear to me, it appears the L1 driver has a bug or
> >>the device itself has trouble with DMA in high memory.  This patch,
> >>drafted by Luca Tettamanti, is being explored as a workaround.  I'd be
> >>interested to know if it fixes your problem.
> >
> >Yes, it certainly seems to. Now running with this patch and 4GB active,
> >I've transferred about 15GB with no problem so far. It usually oopses
> >after a GB or two.
> >
> >I guess it's not an ideal solution, architecturally speaking, but it's a
> >good deal better than an unstable driver. If there's any other patches
> >you'd like me to test or traces to capture, I'm happy to help out.
> >Otherwise I'll run with this one for now since it does the job!
> 
> Okay Jay, thanks.
> 
> Luca, would you please submit your patch to Jeff Garzik and netdev?

Hi Jeff,
a couple of users reported hard lockups when using L1 NICs on machines
with 4GB or more of RAM. We're still waiting official confirmation from
the vendor, but it seems that L1 has problems doing DMA to/from high
memory (physical address above the 4GB limit). Passing 32bit DMA mask
cures the problem.

Signed-Off-By: Luca Tettamanti <kronos.it@gmail.com>

---
I think that the patch should be included in 2.6.22.

 drivers/net/atl1/atl1_main.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 6862c11..a730f15 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2097,21 +2097,16 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct atl1_adapter *adapter;
 	static int cards_found = 0;
-	bool pci_using_64 = true;
 	int err;
 
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
 
-	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (err) {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
-		if (err) {
-			dev_err(&pdev->dev, "no usable DMA configuration\n");
-			goto err_dma;
-		}
-		pci_using_64 = false;
+		dev_err(&pdev->dev, "no usable DMA configuration\n");
+		goto err_dma;
 	}
 	/* Mark all PCI regions associated with PCI device
 	 * pdev as being reserved by owner atl1_driver_name
@@ -2176,7 +2171,6 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 
 	netdev->ethtool_ops = &atl1_ethtool_ops;
 	adapter->bd_number = cards_found;
-	adapter->pci_using_64 = pci_using_64;
 
 	/* setup the private structure */
 	err = atl1_sw_init(adapter);
@@ -2193,9 +2187,6 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	 */
 	/* netdev->features |= NETIF_F_TSO; */
 
-	if (pci_using_64)
-		netdev->features |= NETIF_F_HIGHDMA;
-
 	netdev->features |= NETIF_F_LLTX;
 
 	/*


Luca
-- 
Non ho ancora capito se il mio cane e` maschio o femmina:
quando fa la pipi` si chiude in bagno
