From: Nix <nix@esperi.org.uk>
Subject: Re: [net-next 5/9] e1000e: Disable ASPM L1 on 82574
Date: Sat, 05 May 2012 17:33:45 +0100
Message-ID: <87fwbea8pi.fsf@spindle.srvr.nix>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1336038992-3144-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<87d36ld1as.fsf@spindle.srvr.nix>
	<9BBC4E0CF881AA4299206E2E1412B6261882C3A9@FMSMSX151.amr.corp.intel.com>
	<87sjfhaukf.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	Chris Boot <bootc@bootc.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo\@redhat.com" <gospo@redhat.com>,
	"sassmann\@redhat.com" <sassmann@redhat.com>
To: "Wyborny\, Carolyn" <carolyn.wyborny@intel.com>,
	Matthew Garrett <mjg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:40416 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756219Ab2EEQeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2012 12:34:03 -0400
In-Reply-To: <87sjfhaukf.fsf@spindle.srvr.nix> (nix@esperi.org.uk's message of
	"Thu, 03 May 2012 21:17:04 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 May 2012, nix@esperi.org.uk outgrape:

> On 3 May 2012, Carolyn Wyborny told this:
>
>> It would be good to know why/how your system is re-enabling the
>> setting. The problem is not solvable in firmware unfortunately and is
>> somewhat platform dependent. MMIO-tracer might be used to try and see
>
> I entirely forgot about that tool! *Definitely* worth trying.
>
> I'll give it a try this weekend.

Well, mmiotrace was a total flop: massive numbers of unexpected
secondary interrupts and a hard lockup. Still, I've now diagnosed this
bug and it's right up Matthew Garrett's street!

Matthew: the problem here is a server with an 82574L (controlled by the
e1000e driver). This NIC has a hardware bug causing it to lock up in a
way that only a reboot can solve in an hour or two if PCIe ASPM is not
disabled during boot (leaving me with my home directory stuck behind a
dead NIC on a headless machine, most annoying). The driver is attempting
to disable it, but failing.

>> when the re-enabling config space is written, but it might be too
>> heavyweight for a live production system.
>
> Given that the re-enabling happens at around the same time as the boot
> scripts finish running (it's done by the time I can log in), that's not
> going to be a problem. Hence my speculation that it's being re-enabled
> when the interface stabilizes (which is, of course, asynchronous) or
> something like that.

This is wrong. The disable never happens. The BIOS has been told to
enable PCIe ASPM. However, the kernel log says:

May  5 17:06:53 spindle info: [    0.629699]  pci0000:00: Requesting ACPI _OSC control (0x1d)
May  5 17:06:53 spindle info: [    0.629941]  pci0000:00: ACPI _OSC request failed (AE_NOT_FOUND), returned control mask: 0x1d
May  5 17:06:53 spindle info: [    0.630373] ACPI _OSC control for PCIe not granted, disabling ASPM

Unless pcie_aspm=force has been specified on the kernel command line,
this flips aspm_disabled to 1.

The e1000e driver then says (with a bit of extra debugging info I
added):

May  5 17:06:53 spindle info: [    1.248153] e1000e 0000:03:00.0: Disabling ASPM L0s L1
May  5 17:06:53 spindle info: [    1.248393] e1000e 0000:03:00.0: Disabling ASPM via pci_disable_link_state_locked()
May  5 17:06:53 spindle info: [    1.248823] e1000e 0000:03:00.0: aspm disabled, not forcing

i.e. because aspm_disabled is set, pci/pcie/aspm.c refuses to make any
changes at all to ASPM link state, not even to turn *off* ASPM on a
device on which the BIOS turned it on at boot. So ASPM remains enabled
and the NIC eventually locks up.

The question here is how to fix it. It appears that the motherboard or
BIOS on this machine does not grant _OSC control even (especially?) if
you have turned on PCIe ASPM in the BIOS. But perhaps even if _OSC is
not granted you should permit PCIe to be *disabled* by drivers, just not
enabled? (The BIOS appears to be buggy in this area: if you turn off
ASPM, save, and go back into setup, ASPM has turned itself back on
again!)

I'm not sure what the right thing to do is here: I don't know enough
about this area. But it does seem very strange that the only way I have
to turn off PCIe ASPM reliably on this device is to tell the kernel to
forcibly turn it *on*!
