From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [PATCH 4/4] atl1: Ancillary C files for Attansic L1 driver
Date: Tue, 23 Jan 2007 22:19:17 +0100
Message-ID: <20070123211917.GA22109@dreamland.darkstar.lan>
References: <20070121210737.GE2702@osprey.hogchain.net> <20070121183151.4be61ebf.randy.dunlap@oracle.com> <45B43093.6060500@bellsouth.net> <20070122200004.GA12553@dreamland.darkstar.lan> <20070123112522.65aac61b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Jay Cliburn <jacliburn@bellsouth.net>,
	Randy Dunlap <randy.dunlap@oracle.com>, jeff@garzik.org,
	shemminger@osdl.org, csnook@redhat.com, hch@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:51737 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965120AbXAWVTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 16:19:24 -0500
Received: by nf-out-0910.google.com with SMTP id o25so377588nfa
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 13:19:22 -0800 (PST)
To: Stephen Hemminger <shemminger@linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20070123112522.65aac61b@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il Tue, Jan 23, 2007 at 11:25:22AM -0800, Stephen Hemminger ha scritto: 
> On Mon, 22 Jan 2007 21:00:04 +0100
> Luca Tettamanti <kronos.it@gmail.com> wrote:
> 
> > Il Sun, Jan 21, 2007 at 09:33:39PM -0600, Jay Cliburn ha scritto: 
> > > Randy Dunlap wrote:
> > > >On Sun, 21 Jan 2007 15:07:37 -0600 Jay Cliburn wrote:
> > > [snip]
> > > >>+
> > > >>+int enable_msi;
> > > >>+module_param(enable_msi, int, 0444);
> > > >>+MODULE_PARM_DESC(enable_msi, "Enable PCI MSI");
> > > >
> > > >Hm, I thought that we didn't want individual drivers having MSI config
> > > >options...
> > > 
> > > Luca?  This one was yours IIRC.  Care to chime in?
> > 
> > I remember that discussion, but since there's no sistem-wide MSI
> > blacklist (or whitelist) I don't think it's safe to enable it
> > unconditionally. Judging from bug reports on lkml it's not safe to
> > assume that MSI support is sane on non-Intel chipsets.
> > 
> > Luca
> 
> There is MSI blacklisting see drivers/pci/quirks.c code.
> But the blacklist isn't complete enough yet.
> 
> IMHO the MSI disabling should be removed from drivers and be done
> in the PCI core. But it doesn't seem to have gotten widespread
> support.

Does the INTx madness (like this one:
http://marc.theaimsgroup.com/?l=linux-kernel&m=116668921431574&w=2
) affect also PCI-E INTx emulation?

Anyway...

Unconditionally enable MSI in atl1 driver. Also remove some useless
#ifdef since pci_{en,dis}able_msi() are no-op when MSI support is not
configured in.

Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
---
 Patch against current netdev tree.

 drivers/net/atl1/atl1.h       |    1 -
 drivers/net/atl1/atl1_main.c  |   22 +++++++---------------
 drivers/net/atl1/atl1_param.c |   13 -------------
 3 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index 1d13e8f..0b30e1c 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -281,7 +281,6 @@ struct atl1_adapter {
 	struct atl1_smb smb;
 	struct atl1_cmb cmb;
 
-	int enable_msi;
 	u32 pci_state[16];
 };
 
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index c0b1555..68e6cd1 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1793,18 +1793,12 @@ s32 atl1_up(struct atl1_adapter *adapter)
 		goto err_up;
 	}
 
-#ifdef CONFIG_PCI_MSI
-	if (adapter->enable_msi) {
-		err = pci_enable_msi(adapter->pdev);
-		if (err) {
-			dev_info(&adapter->pdev->dev, "Unable to enable MSI: %d\n", err);
-			adapter->enable_msi = 0;
-		}
-	}
-#endif
-	if (!adapter->enable_msi)
+	err = pci_enable_msi(adapter->pdev);
+	if (err) {
+		dev_info(&adapter->pdev->dev, "Unable to enable MSI: %d\n", err);
 		irq_flags |= IRQF_SHARED;
-
+	}
+	
 	err = request_irq(adapter->pdev->irq, &atl1_intr, irq_flags,
 			netdev->name, netdev);
 	if (unlikely(err))
@@ -1821,6 +1815,7 @@ s32 atl1_up(struct atl1_adapter *adapter)
 	free_irq(adapter->pdev->irq, netdev);
 
 err_up:
+	pci_disable_msi(adapter->pdev);
 	/* free rx_buffers */
 	atl1_clean_rx_ring(adapter);
 	return err;
@@ -1836,10 +1831,7 @@ void atl1_down(struct atl1_adapter *adapter)
 
 	atl1_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
-#ifdef CONFIG_PCI_MSI
-	if (adapter->enable_msi)
-		pci_disable_msi(adapter->pdev);
-#endif
+	pci_disable_msi(adapter->pdev);
 	atl1_reset_hw(&adapter->hw);
 	adapter->cmb.cmb->int_stats = 0;
 
diff --git a/drivers/net/atl1/atl1_param.c b/drivers/net/atl1/atl1_param.c
index 4732f43..caa2d83 100644
--- a/drivers/net/atl1/atl1_param.c
+++ b/drivers/net/atl1/atl1_param.c
@@ -68,10 +68,6 @@ static int num_flash_vendor = 0;
 module_param_array_named(flash_vendor, flash_vendor, int, &num_flash_vendor, 0);
 MODULE_PARM_DESC(flash_vendor, "SPI flash vendor");
 
-int enable_msi;
-module_param(enable_msi, int, 0444);
-MODULE_PARM_DESC(enable_msi, "Enable PCI MSI");
-
 #define DEFAULT_INT_MOD_CNT	100	/* 200us */
 #define MAX_INT_MOD_CNT		65000
 #define MIN_INT_MOD_CNT		50
@@ -211,13 +207,4 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 			adapter->hw.flash_vendor = (u8) (opt.def);
 		}
 	}
-
-	{			/* PCI MSI usage */
-
-#ifdef CONFIG_PCI_MSI
-		adapter->enable_msi = enable_msi;
-#else
-		adapter->enable_msi = 0;
-#endif
-	}
 }



Luca
-- 
Inquietudine sintetica
Solo, davanti all'ignoto
Tienimi stretto a te
