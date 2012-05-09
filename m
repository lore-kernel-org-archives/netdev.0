From: Nix <nix@esperi.org.uk>
Subject: Re: [net-next 5/9] e1000e: Disable ASPM L1 on 82574
Date: Wed, 09 May 2012 15:02:55 +0100
Message-ID: <87d36dbgfk.fsf@spindle.srvr.nix>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1336038992-3144-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<87d36ld1as.fsf@spindle.srvr.nix>
	<9BBC4E0CF881AA4299206E2E1412B6261882C3A9@FMSMSX151.amr.corp.intel.com>
	<87sjfhaukf.fsf@spindle.srvr.nix> <87fwbea8pi.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matthew Garrett <mjg@redhat.com>,
	"Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	Chris Boot <bootc@bootc.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo\@redhat.com" <gospo@redhat.com>,
	"sassmann\@redhat.com" <sassmann@redhat.com>
To: "Wyborny\, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:56859 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755693Ab2EIODU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 10:03:20 -0400
In-Reply-To: <87fwbea8pi.fsf@spindle.srvr.nix> (nix@esperi.org.uk's message of
	"Sat, 05 May 2012 17:33:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 May 2012, nix@esperi.org.uk outgrape:

> The question here is how to fix it. It appears that the motherboard or
> BIOS on this machine does not grant _OSC control even (especially?) if
> you have turned on PCIe ASPM in the BIOS. But perhaps even if _OSC is
> not granted you should permit PCIe to be *disabled* by drivers, just not
> enabled? (The BIOS appears to be buggy in this area: if you turn off
> ASPM, save, and go back into setup, ASPM has turned itself back on
> again!)

This turned out to be me not knowing how to drive the BIOS's deeply
unintuitive configuration program. If I turn PCIe ASPM off in the BIOS,
the kernel does exactly the same as it does in my previous message (i.e.
decides that ASPM is disabled due to the failure of an _OSC request,
then refuses to change the ASPM link state of the e1000e), but since the
BIOS has already disabled ASPM, the card is not in crash-happy mode and
I don't need to force anything off by hand.

But if I turn ASPM on, as reported in my previous message the kernel
promptly bans itself from changing any PCIe ASPM link states whatsoever,
and the e1000e locks up about an hour later.

I presume that

May  5 17:06:53 spindle info: [    0.629699]  pci0000:00: Requesting ACPI _OSC control (0x1d)
May  5 17:06:53 spindle info: [    0.629941]  pci0000:00: ACPI _OSC request failed (AE_NOT_FOUND), returned control mask: 0x1d
May  5 17:06:53 spindle info: [    0.630373] ACPI _OSC control for PCIe not granted, disabling ASPM

is reporting some sort of BIOS bug, but it is at best confusing to have
the boot messages reporting that ASPM is disabled: better perhaps to
describe this as 'leaving ASPM on all devices how the BIOS set it' and
have the e1000e driver emit a giant flaming warning if it spots this
happening on an 82574L with ASPM turned on. (Or, alternatively, permit
ASPM to be turned off when the system is in this state, but not on,
whereupon the existing code in the e1000e driver will do the right
thing. But I don't know if that will break any laptops. This machine is
very much not a laptop.)

> I'm not sure what the right thing to do is here: I don't know enough
> about this area. But it does seem very strange that the only way I have
> to turn off PCIe ASPM reliably on this device is to tell the kernel to
> forcibly turn it *on*!

This is still strange, though it seems that turning ASPM completely off
in the BIOS will also serve.
