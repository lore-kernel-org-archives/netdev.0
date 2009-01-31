From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 17:41:13 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901301714080.3150@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310059.17746.rjw@sisk.pl> <alpine.DEB.2.00.0901301924550.5056@parag-desktop> <200901310138.51214.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60162 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752241AbZAaBl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 20:41:29 -0500
In-Reply-To: <200901310138.51214.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> 
> Can you test the patch below, please?

Rafael, you're making this _way_ too difficult.

Don't make it use the new PM infrastructure, because that one is certainly 
broken: pci_pm_default_suspend_generic() is total crap.

It's saving the disabled state. No WAY is that correct.

That "pci_disable_enabled_device()" should be removed, but even then 
that's wrong, because if the driver suspend disabled it, you're now 
(again) saving the disabled state.

But all of that is only called if you use the new PM infrastructure. So 
the thing is, when you're trying to move the PCI-E drive to the new pm 
infrastructure, you're making things _worse_.

The legacy PM infrastructure at least does the whole

	pci_dev->state_saved = false;
	i = drv->suspend(pci_dev, state);
	..
	if (pci_dev->state_saved)
		goto Fixup;

thing, which will avoid overwriting the state if it was already saved.

HOWEVER. The problem here (I think) is that PCI-E actually does the state 
save late, so it won't ever see the "state_saved" in the early ->suspend. 
I think a patch like the one below at least simplifies this all, and lets 
the PCI layer itself do all the core restore stuff.

The new PM infrastructure gets this totally wrong, and
 (a) disables the device before saving state
and
 (b) overwrites the (now corrupted) saved state that the driver perhaps 
     already saved, after the driver may even have put it to sleep.

So let's not use the new PM infrastructure - I don't think it's ready yet.

Let's start simplifying first. Start off by getting rid of the 
suspend_early/resume_late, since the PCI layer now does it for us.

I don't see why we don't resume with IO/MEM on, though. The legacy suspend 
sequence shouldn't disable them, afaik.

		Linus

---
 drivers/pci/pcie/portdrv_pci.c |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/drivers/pci/pcie/portdrv_pci.c b/drivers/pci/pcie/portdrv_pci.c
index 99a914a..08a8e3c 100644
--- a/drivers/pci/pcie/portdrv_pci.c
+++ b/drivers/pci/pcie/portdrv_pci.c
@@ -55,16 +55,6 @@ static int pcie_portdrv_suspend(struct pci_dev *dev, pm_message_t state)
 
 }
 
-static int pcie_portdrv_suspend_late(struct pci_dev *dev, pm_message_t state)
-{
-	return pci_save_state(dev);
-}
-
-static int pcie_portdrv_resume_early(struct pci_dev *dev)
-{
-	return pci_restore_state(dev);
-}
-
 static int pcie_portdrv_resume(struct pci_dev *dev)
 {
 	pcie_portdrv_restore_config(dev);
@@ -72,8 +62,6 @@ static int pcie_portdrv_resume(struct pci_dev *dev)
 }
 #else
 #define pcie_portdrv_suspend NULL
-#define pcie_portdrv_suspend_late NULL
-#define pcie_portdrv_resume_early NULL
 #define pcie_portdrv_resume NULL
 #endif
 
@@ -292,8 +280,6 @@ static struct pci_driver pcie_portdriver = {
 	.remove		= pcie_portdrv_remove,
 
 	.suspend	= pcie_portdrv_suspend,
-	.suspend_late	= pcie_portdrv_suspend_late,
-	.resume_early	= pcie_portdrv_resume_early,
 	.resume		= pcie_portdrv_resume,
 
 	.err_handler 	= &pcie_portdrv_err_handler,
