From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [net-next 5/5] PCI: disable FLR for 82579 device
Date: Wed, 28 Sep 2016 11:26:23 -0500
Message-ID: <20160928162623.GA5658@localhost>
References: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1474612741-75681-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20160923140136.GC1514@localhost>
 <1474664726.2389.7.camel@intel.com>
 <176f2366-e225-75fb-8cad-909a8f7e808c@intel.com>
 <20160927181702.GA7275@localhost>
 <20160927131335.2edd72cb@t450s.home>
 <CAKgT0UczaC-5z9GB74xhU11iWLu5_n75najKzBZcvk1T3C16Og@mail.gmail.com>
 <630A6B92B7EDEB45A87E20D3D286660153E14465@hasmsx109.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Alex Williamson <alex.williamson@redhat.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Ruinskiy, Dima" <dima.ruinskiy@intel.com>,
        "Avargil, Raanan" <raanan.avargil@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Netdev <netdev@vger.kernel.org>,
        Neil Horman <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        John Greene <jogreene@redhat.com>,
        "guru.anbalagane@oracle.com" <guru.anbalagane@oracle.com>
To: "Neftin, Sasha" <sasha.neftin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:34882 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932731AbcI1Q0j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 12:26:39 -0400
Content-Disposition: inline
In-Reply-To: <630A6B92B7EDEB45A87E20D3D286660153E14465@hasmsx109.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 03:33:52PM +0000, Neftin, Sasha wrote:
> 
> Since I worked with Sasha on this I will provide a bit of information from what I understand of this bug as well.
> 
> On Tue, Sep 27, 2016 at 12:13 PM, Alex Williamson <alex.williamson@redhat.com> wrote:
> > On Tue, 27 Sep 2016 13:17:02 -0500
> > Bjorn Helgaas <helgaas@kernel.org> wrote:
> >
> >> On Sun, Sep 25, 2016 at 10:02:43AM +0300, Neftin, Sasha wrote:
> >> > On 9/24/2016 12:05 AM, Jeff Kirsher wrote:
> >> > >On Fri, 2016-09-23 at 09:01 -0500, Bjorn Helgaas wrote:
> >> > >>On Thu, Sep 22, 2016 at 11:39:01PM -0700, Jeff Kirsher wrote:
> >> > >>>From: Sasha Neftin <sasha.neftin@intel.com>
> >> > >>>
> >> > >>>82579 has a problem reattaching itself after the device is detached.
> >> > >>>The bug was reported by Redhat. The suggested fix is to disable 
> >> > >>>FLR capability in PCIe configuration space.
> >> > >>>
> >> > >>>Reproduction:
> >> > >>>Attach the device to a VM, then detach and try to attach again.
> >> > >>>
> >> > >>>Fix:
> >> > >>>Disable FLR capability to prevent the 82579 from hanging.
> >> > >>Is there a bugzilla or other reference URL to include here?  
> >> > >>Should this be marked for stable?
> >> > >So the author is in Israel, meaning it is their weekend now.  I do 
> >> > >not believe Sasha monitors email over the weekend, so a response 
> >> > >to your questions won't happen for a few days.
> >> > >
> >> > >I tried searching my archives for more information, but had no 
> >> > >luck finding any additional information.
> >> > >
> 
> I agree that we do probably need to update the patch description since it isn't exactly clear what this is fixing or what was actually broken.
> 
> >> > >>>Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
> >> > >>>Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> >> > >>>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> > >>>---
> >> > >>>  drivers/pci/quirks.c | 21 +++++++++++++++++++++
> >> > >>>  1 file changed, 21 insertions(+)
> >> > >>>
> >> > >>>diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c index 
> >> > >>>44e0ff3..59fba6e 100644
> >> > >>>--- a/drivers/pci/quirks.c
> >> > >>>+++ b/drivers/pci/quirks.c
> >> > >>>@@ -4431,3 +4431,24 @@ static void quirk_intel_qat_vf_cap(struct 
> >> > >>>pci_dev *pdev)
> >> > >>>         }
> >> > >>>  }
> >> > >>>  DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x443, 
> >> > >>>quirk_intel_qat_vf_cap);
> >> > >>>+/*
> >> > >>>+ * Workaround FLR issues for 82579
> >> > >>>+ * This code disables the FLR (Function Level Reset) via PCIe, 
> >> > >>>+in
> >> > >>>order
> >> > >>>+ * to workaround a bug found while using device passthrough, 
> >> > >>>+ where the
> >> > >>>+ * interface would become non-responsive.
> >> > >>>+ * NOTE: the FLR bit is Read/Write Once (RWO) in config space, 
> >> > >>>+ so if
> >> > >>>+ * the BIOS or kernel writes this register * then this 
> >> > >>>+ workaround will
> >> > >>>+ * not work.
> >> > >>This doesn't sound like a root cause.  Is the issue a hardware 
> >> > >>erratum?  Linux PCI core bug?  VFIO bug?  Device firmware bug?
> >> > >>
> >> > >>The changelog suggests that the problem only affects passthrough, 
> >> > >>which suggests some sort of kernel bug related to how passthrough 
> >> > >>is implemented.
> >>
> >> If this bug affects all scenarios, not just passthrough, the 
> >> changelog should not mention passthrough.
> >>
> >> > >>>+ */
> >> > >>>+static void quirk_intel_flr_cap_dis(struct pci_dev *dev) {
> >> > >>>+        int pos = pci_find_capability(dev, PCI_CAP_ID_AF);
> >> > >>>+        if (pos) {
> >> > >>>+                u8 cap;
> >> > >>>+                pci_read_config_byte(dev, pos + PCI_AF_CAP, &cap);
> >> > >>>+                cap = cap & (~PCI_AF_CAP_FLR);
> >> > >>>+                pci_write_config_byte(dev, pos + PCI_AF_CAP, cap);
> >> > >>>+        }
> >> > >>>+}
> >> > >>>+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1502,
> >> > >>>quirk_intel_flr_cap_dis);
> >> > >>>+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1503,
> >> > >>>quirk_intel_flr_cap_dis);
> >> > >>>--
> >> > >>>2.7.4
> >> > >>>
> >> > >>>--
> >> > >>>To unsubscribe from this list: send the line "unsubscribe 
> >> > >>>linux-pci" in the body of a message to majordomo@vger.kernel.org 
> >> > >>>More majordomo info at  
> >> > >>>http://vger.kernel.org/majordomo-info.html
> >> >
> >> > Hello,
> >> >
> >> > Original bugzilla thread could be found here:
> >> > https://bugzilla.redhat.com/show_bug.cgi?format=multiple&id=966840
> >>
> >> That bugzilla is private and I can't read it.
> >
> > Hmm, I can, but I don't see anything in it that supports this.  Is 
> > that really the right bz?  It's the right hardware, but has all sorts 
> > of FUD about the version of various other components in the stack.
> 
> It looks like we had a local copy of the bugzilla saved here, though it only goes up to comment 13 which is where I think we started working this on our side.  I believe what this patch is attempting to resolve is related to comment 8 where the driver returned "probe of
> 0000:00:19.0 failed with error ‐2" instead of correctly probing the interface.
> 
> So the bug as reported was that e1000e had a problem reattaching itself to the PHY after it was attached to a VM.  Sasha, please feel free to correct me if I have this bit wrong.  I had been told the problem was the FLR functionality wasn't fully implemented so that was why they were wanting to defeature it.  I had assumed that there was support for a reset on D0->D3->D0, but I just realized that probably isn't the case since it looks like my local system sets the NoSoftRST bit.
> 
> >> > This is our HW bug, exist only in 82579 devices. More new devices 
> >> > have no such problem. We have found root cause and suggested this 
> >> > solution.
> >>
> >> Is there an erratum you can reference?
> >>
> >> > This solution should work for a 95% of cases, so I do not think 
> >> > that this is fragile. For another cases possible solution is get up 
> >> > working system and manually disable FLR, before VM start use our 
> >> > adapter.
> >>
> >> I don't think a 95% solution is sufficient.  Can you use the
> >> pci_dev_specific_reset() framework to make a 100% solution?
> 
> I can try working with Sasha on this to see what we can do.
> 
> > Right, plus when this does work I suspect it removes the one mechanism 
> > we have to reset the device, which depending on how obscure the 
> > failure scenario is, isn't a clear cut improvement for device assignment.
> > Thanks,
> >
> > Alex
> 
> I'll work with Sasha to see what we can do.  Odds are there is some sort of problem between the MAC/PHY that needs to be resolved when we perform the function level reset so we will probably need to add code so that we reset the part and re-establish the link with the PHY after the reset.
> 
> - Alex
> 
> 
> Hello,
> I would like clarify a few points.
> 
> 1. 82579 client devices do not support functional level reset (FLR).
> Unfortunately, it advertises FLR capability -  this is a bug. So,
> when VM software even accidentally tries to access FLR, that causes
> our device to hang. To eliminate this problem we decided to disable
> FLR via drivers/pci/quirks.c 

That makes sense.  To me, the problem is that writing the AF
capability to disable FLR is unreliable.  We can't tell whether BIOS
has already written it, and there's no way to debug the corner cases
where BIOS *has* written it and the device doesn't reset correctly.

Maybe it is in fact weird for a BIOS to write that, and the corner
case will never arise.  But I have no way of knowing that, and I don't
like making assumptions about what a BIOS will or won't do.

Here are two ideas:

  1) Implement a device-specific reset quirk.  The problem here is
  that you'd have to duplicate the body of __pci_dev_reset(), omitting
  the pcie_flr() and pci_af_flr() calls.  This might be a maintenance
  issue because future changes to __pci_dev_reset() should also be
  made to the quirk.

  2) Add some sort of "broken_flr_reset" bit in struct pci_dev, set it
  with a quirk, and change pci_af_flr() to return -ENOTTY when it is
  set.

> In previous e-mail I wrote that the solution should work for a 95% of cases. Cases where it might not work if BIOS writes FLR capability before the OS (In 82579 device FLR capability is RWO - read write once). But this is a very weird scenario, so probably the workaround will work close to 100%. Also, I would like to add that we have run lots of tests over 82579 in our lab and ensured that all flows work properly.
> 
> 2. D0->D3-D0 flow is not affected and is in fact supported by 82579.
> 
> 3. I will look for an erratum explaining this.
> 
> Thanks,
> Sasha
> 
> 
> 
> 
> 
