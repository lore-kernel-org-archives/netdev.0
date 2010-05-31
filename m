From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sun, 30 May 2010 21:43:05 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B78147576@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
 <87ocfxzpvf.fsf@basil.nowhere.org>
 <C27F8246C663564A84BB7AB3439772421B78147574@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20100530173014.GB14556@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-pci@vger.kernel.org'" <linux-pci@vger.kernel.org>
To: "'Andi Kleen'" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4718 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933Ab0EaEnN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 00:43:13 -0400
In-Reply-To: <20100530173014.GB14556@basil.fritz.box>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:

> On Sun, May 30, 2010 at 09:12:15AM -0700, Michael Chan wrote:
> > Andi Kleen wrote:
> >
> > > "Michael Chan" <mchan@broadcom.com> writes:
> > >
> > > > When switching from the crashed kernel to the kdump kernel
> without
> > > going
> > > > through PCI reset, IRQs may not work if a different IRQ mode is
> used
> > > on
> > >
> > > PCIe with AER actually does support per link root port reset
> > > (e.g. used for AER)
> >
> > Do you mean the slot_reset function in the pci_error_handlers?  This
> 
> Well the fallback code in the PCIE root port driver
> that does the actual resets.

aer_root_reset() in aerdrv.c?

> 
> It could be called directly before kexec.
> 
> > needs to be called in the context of the crashed kernel, right?
> 
> It could be done on kexec, however of course you would rely
> on PCI root port data structures still being intact on a crash
> (I guess that's reasonable, they are not very complicated)
> 
> >
> > >
> > > I've been wondering for some time if kexec should not simply
> > > use that to reset all the devices, instead of addings hacks
> > > around this to all drivers.
> > >
> > > That would fix your problems too, right?
> >
> > If it is called in the context of the crashed kernel, it won't work.
> > We would reset it and put in back into the same IRQ mode.
> 
> Who would put it back? Your driver wouldn't be called anymore.

The bnx2 driver like many other drivers has a slot_reset function in the
pci_driver struct's err_handler.  If the AER code calls this function,
we would reset the chip and put it back to the same IRQ mode.  Without
calling this per driver reset function, I'm not sure if you can reset
the device if the device does not support Function Level Reset.

> 
> >
> > >
> > > The question is just if AER is widely enough supported for this.
> > >
> >
> > Some newer PCIe devices support Function Level Reset, and that would
> > be ideal.  But most existing devices including bnx2 devices don't
> have
> > this feature.
> 
> Root port reset should be fine for this case. Even if some
> innocent device on the same root port gets reset too that shouldn't
> matter.
> Only drawback for the NIC would be that you have to renegotiate links I
> think.
> 
> Also there are systems without AER support.
> 
> -Andi
> --
> ak@linux.intel.com -- Speaking for myself only.


