From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH V4 0/2] pci: Provide a flag to access VPD through
 function 0
Date: Tue, 21 Jul 2015 13:24:19 -0500
Message-ID: <20150721182419.GF21967@google.com>
References: <20150713183821.19985.52157.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Mark D Rustad <mark.d.rustad@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150713183821.19985.52157.stgit@mdrustad-wks.jf.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[+cc Alex]

On Mon, Jul 13, 2015 at 11:39:54AM -0700, Mark D Rustad wrote:
> Many multi-function devices provide shared registers in extended
> config space for accessing VPD. The behavior of these registers
> means that the state must be tracked and access locked correctly
> for accesses not to hang or worse. One way to meet these needs is
> to always perform the accesses through function 0, thereby using
> the state tracking and mutex that already exists.
> 
> To provide this behavior, add a dev_flags bit to indicate that this
> should be done. This bit can then be set for any non-zero function
> that needs to redirect such VPD access to function 0. Do not set
> this bit on the zero function or there will be an infinite recursion.
> 
> The second patch uses this new flag to invoke this behavior on all
> multi-function Intel Ethernet devices.
> 
> Any hardware that shares VPD registers with multiple functions has
> been suffering these problems forever. The hangs result in the log
> message:
> 
> vpd r/w failed.  This is likely a firmware bug on this device.
> 
> Both read and write data corruption are also possible during
> overlapping accesses in addition to hangs.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> 
> ---
> Changes in V2:
> - Corrected a spelling error in a log message
> - Added checks to see that the referenced function 0 is reasonable
> Changes in V3:
> - Don't leak a device reference
> - Check that function 0 has VPD
> - Make a helper for the function 0 checks
> - Moved a multifunction check to the quirk patch
> Changes in V4:
> - Provide a more extensive commit log for patch 1

I applied these to pci/misc for v4.3 with changelogs as follows.  I added
Alex's ack, since he acked v3 and the only difference here is the
changelog.  I also added a stable tag.  Thanks!

Bjorn


commit 932c435caba8a2ce473a91753bad0173269ef334
Author: Mark Rustad <mark.d.rustad@intel.com>
Date:   Mon Jul 13 11:40:02 2015 -0700

    PCI: Add dev_flags bit to access VPD through function 0
    
    Add a dev_flags bit, PCI_DEV_FLAGS_VPD_REF_F0, to access VPD through
    function 0 to provide VPD access on other functions.  This is for hardware
    devices that provide copies of the same VPD capability registers in
    multiple functions.  Because the kernel expects that each function has its
    own registers, both the locking and the state tracking are affected by VPD
    accesses to different functions.
    
    On such devices for example, if a VPD write is performed on function 0,
    *any* later attempt to read VPD from any other function of that device will
    hang.  This has to do with how the kernel tracks the expected value of the
    F bit per function.
    
    Concurrent accesses to different functions of the same device can not only
    hang but also corrupt both read and write VPD data.
    
    When hangs occur, typically the error message:
    
      vpd r/w failed.  This is likely a firmware bug on this device.
    
    will be seen.
    
    Never set this bit on function 0 or there will be an infinite recursion.
    
    Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
    Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
    Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
    CC: stable@vger.kernel.org

commit 7aa6ca4d39edf01f997b9e02cf6d2fdeb224f351
Author: Mark Rustad <mark.d.rustad@intel.com>
Date:   Mon Jul 13 11:40:07 2015 -0700

    PCI: Add VPD function 0 quirk for Intel Ethernet devices
    
    Set the PCI_DEV_FLAGS_VPD_REF_F0 flag on all Intel Ethernet device
    functions other than function 0, so that on multi-function devices, we will
    always read VPD from function 0 instead of from the other functions.
    
    [bhelgaas: changelog]
    Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
    Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
    Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
    CC: stable@vger.kernel.org
