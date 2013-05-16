From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: is L1 really disabled in iwlwifi
Date: Thu, 16 May 2013 16:55:35 -0600
Message-ID: <20130516225535.GA27962@google.com>
References: <CANUX_P2Hy02SnyYS24dyUGLv3wB3L5xkXt8Y1s+8_RG9d5ReAw@mail.gmail.com>
 <CAErSpo6OCyTy19u6Xaf=xr0TSDriwCD3n-oMc7eJyLzuJ9d60g@mail.gmail.com>
 <20130510225257.GA10847@google.com>
 <1725435.3DlCxYF2FV@vostro.rjw.lan>
 <1368303730.2425.47.camel@x230>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Emmanuel Grumbach <egrumbach@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>,
	Roman Yepishev <roman.yepishev@gmail.com>,
	"Guy, Wey-Yi" <wey-yi.w.guy@intel.com>,
	Mike Miller <mike.miller@hp.com>,
	"iss_storagedev@hp.com" <iss_storagedev@hp.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"aacraid@adaptec.com" <aacraid@adaptec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Matthew Garrett <matthew.garrett@nebula.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1368303730.2425.47.camel@x230>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 11, 2013 at 08:22:11PM +0000, Matthew Garrett wrote:
> On Sat, 2013-05-11 at 22:26 +0200, Rafael J. Wysocki wrote:
> > On Friday, May 10, 2013 04:52:57 PM Bjorn Helgaas wrote:
> > > I propose the following patch.  Any comments?
> > 
> > In my opinion this is dangerous, because it opens us to bugs that right now
> > are prevented from happening due to the way the code works.
> 
> Right, I'm also not entirely comfortable with this. The current
> behaviour may be confusing, but we could reduce that by renaming the
> functions. I'm still not clear on whether anyone's actually seeing
> problems caused by the existing behaviour.

I couldn't imagine that silently ignoring the request to disable ASPM
would be the right thing, but I spent a long time experimenting with
Windows on qemu, and I think you're right.  Windows 7 also seems to
ignore the "PciASPMOptOut" directive when we don't have permission
to manage ASPM.  All the gory details are at
https://bugzilla.kernel.org/show_bug.cgi?id=57331

The current behavior is definitely confusing.  I hate to rename or change
pci_disable_link_state() because it's exported and we'd have to maintain
the old interface for a while anyway.  And I don't really want to return
failure to drivers, because I think that would encourage people to fiddle
with the Link Control register directly in the driver, which doesn't seem
like a good idea.

And you're also right that (as far as I know) there's not an actual
problem with the current behavior other than the confusion it causes.

So, how about something like the following patch, which just prints a
warning when we can't do what the driver requested?  I suppose this may
also be a nuisance, because users will be worried, but they can't actually
*do* anything about it.  Maybe it should be dev_info() instead.

commit f1956960fa0759c53b28e3a2810bd7e1b6e8925f
Author: Bjorn Helgaas <bhelgaas@google.com>
Date:   Wed May 15 17:02:37 2013 -0600

    PCI/ASPM: Warn when driver asks to disable ASPM, but we can't do it
    
    Some devices have hardware problems related to using ASPM.  Drivers for
    these devices use pci_disable_link_state() to prevent their device from
    entering L0s or L1.  But on platforms where the OS doesn't have permission
    to manage ASPM, pci_disable_link_state() doesn't actually disable ASPM.
    
    Windows has a similar mechanism ("PciASPMOptOut"), and when the OS doesn't
    have control of ASPM, it doesn't actually disable ASPM either.
    
    This patch just adds a warning in dmesg about the fact that
    pci_disable_link_state() is doing nothing.
    
    Reported-by: Emmanuel Grumbach <egrumbach@gmail.com>
    Reference: https://lkml.kernel.org/r/CANUX_P3F5YhbZX3WGU-j1AGpbXb_T9Bis2ErhvKkFMtDvzatVQ@mail.gmail.com
    Reference: https://bugzilla.kernel.org/show_bug.cgi?id=57331
    Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

diff --git a/drivers/pci/pcie/aspm.c b/drivers/pci/pcie/aspm.c
index d320df6..faa83b6 100644
--- a/drivers/pci/pcie/aspm.c
+++ b/drivers/pci/pcie/aspm.c
@@ -724,9 +724,6 @@ static void __pci_disable_link_state(struct pci_dev *pdev, int state, bool sem,
 	struct pci_dev *parent = pdev->bus->self;
 	struct pcie_link_state *link;
 
-	if (aspm_disabled && !force)
-		return;
-
 	if (!pci_is_pcie(pdev))
 		return;
 
@@ -736,6 +733,19 @@ static void __pci_disable_link_state(struct pci_dev *pdev, int state, bool sem,
 	if (!parent || !parent->link_state)
 		return;
 
+	/*
+	 * A driver requested that ASPM be disabled on this device, but
+	 * if we don't have permission to manage ASPM (e.g., on ACPI
+	 * systems we have to observe the FADT ACPI_FADT_NO_ASPM bit and
+	 * the _OSC method), we can't honor that request.  Windows has
+	 * a similar mechanism using "PciASPMOptOut", which is also
+	 * ignored in this situation.
+	 */
+	if (aspm_disabled && !force) {
+		dev_warn(&pdev->dev, "can't disable ASPM; OS doesn't have ASPM control\n");
+		return;
+	}
+
 	if (sem)
 		down_read(&pci_bus_sem);
 	mutex_lock(&aspm_lock);
