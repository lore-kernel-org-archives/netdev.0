From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 00:31:36 +0100
Message-ID: <200901310031.37660.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901302354.27497.rjw@sisk.pl> <alpine.DEB.2.00.0901301811530.4994@parag-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:50786 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753457AbZA3XcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 18:32:19 -0500
In-Reply-To: <alpine.DEB.2.00.0901301811530.4994@parag-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Parag Warudkar wrote:
> 
> On Fri, 30 Jan 2009, Rafael J. Wysocki wrote:
> 
> > On Friday 30 January 2009, Parag Warudkar wrote:
> > > 
> > > On Fri, 30 Jan 2009, Rafael J. Wysocki wrote:
> > > 
> > > > 
> > > > I still am interested if it makes any difference for Parag.
> > > 
> > > No difference - tg3 is still dead after resume.
> > 
> > Thanks for testing.
> > 
> > Well, I'm not sure if tg3 is at fault, really.
> > 
> > What happens if you unload tg3 before suspend and load it back after the
> > resume?
> 
> This time it fails with different error on loading after suspend/resume 
> cycle -
> 
>  1196.873608] tg3 0000:0e:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [ 1196.873620] tg3 0000:0e:00.0: setting latency timer to 64
> [ 1196.880017] tg3 0000:0e:00.0: PME# disabled
> [ 1196.996270] tg3: (0000:0e:00.0) phy probe failed, err -19
> [ 1197.508033] tg3: Problem fetching invariants of chip, aborting.
> [ 1197.508048] tg3 0000:0e:00.0: PCI INT A disabled

It seems like something between the tg3 chip and the host CPU doesn't work
correctly after resume, Linus is right.

I wonder if this change makes any difference:

--- linux-2.6.orig/drivers/pci/pci-driver.c
+++ linux-2.6/drivers/pci/pci-driver.c
@@ -501,6 +501,9 @@ static int pci_pm_suspend(struct device
 	if (pci_has_legacy_pm_support(pci_dev))
 		return pci_legacy_suspend(dev, PMSG_SUSPEND);
 
+	if (!drv || !drv->pm)
+		return 0;
+
 	if (drv && drv->pm && drv->pm->suspend) {
 		error = drv->pm->suspend(dev);
 		suspend_report_result(drv->pm->suspend, error);


Rafael
