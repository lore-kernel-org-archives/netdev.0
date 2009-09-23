From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 chips on some Intel D945GSEJT boards fail to work after
	PXE boot
Date: Wed, 23 Sep 2009 22:57:23 +0200
Message-ID: <20090923205723.GA28058@electric-eye.fr.zoreil.com>
References: <4ABA535E.2010801@onelan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Simon Farnsworth <simon.farnsworth@onelan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39555 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751377AbZIWUvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 16:51:51 -0400
Content-Disposition: inline
In-Reply-To: <4ABA535E.2010801@onelan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Farnsworth <simon.farnsworth@onelan.com> :
[...]
> Some boards are good, and just work, whether I boot via PXE or boot from
> the local disk; dmesg.working and lspci.working are from a good board.
> 
> Some boards are bad; they work fine if I boot from local disk (including
> network), but the kernel cannot detect link, or send or receive data if
> I PXE boot. dmesg.broken and lspci.broken are from a bad board.

No cunning theroy in sight but does reducing the amount of memory on a
bad board from 1 Go to 512 Mo turn it into a good one ?

The failing board exhibits a correctable error status bit. Clearing it
is the least we can do.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 50c6a3c..79bc4ab 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2200,6 +2200,11 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (!tp->pcie_cap && netif_msg_probe(tp))
 		dev_info(&pdev->dev, "no PCI Express capability\n");
+	else {
+		pci_write_config_word(pdev, tp->pcie_cap + PCI_EXP_DEVSTA,
+				      PCI_EXP_DEVSTA_CED | PCI_EXP_DEVSTA_NFED |
+				      PCI_EXP_DEVSTA_FED | PCI_EXP_DEVSTA_URD);
+	}
 
 	RTL_W16(IntrMask, 0x0000);
 
-- 
Ueimor
