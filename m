From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] Kernel 4.6.7-rt13: Intel Ethernet driver igb
 causes huge latencies in cyclictest
Date: Mon, 17 Oct 2016 08:39:40 -0700
Message-ID: <CAKgT0Uf-F9V+AeP0+92Gf=40Tye-687_GFbhp4Sex=Hat+Ha+w@mail.gmail.com>
References: <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com> <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com> <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
 <20161013161839.GV10625@jcartwri.amer.corp.natinst.com> <f395ea6cd1274fac83d2744121da7441@FE-MBX1012.de.bosch.com>
 <20161014195536.GB27124@jcartwri.amer.corp.natinst.com> <82dcd5bb210f4f82af1e88313c3ec742@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julia Cartwright <julia@ni.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Matthew Garrett <mjg59@coreos.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Greg <gvrose8192@gmail.com>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35338 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755480AbcJQPjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:39:42 -0400
In-Reply-To: <82dcd5bb210f4f82af1e88313c3ec742@FE-MBX1012.de.bosch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 8:00 AM, Koehrer Mathias (ETAS/ESW5)
<mathias.koehrer@etas.com> wrote:
> Hi Julia!
>> > > Have you tested on a vanilla (non-RT) kernel?  I doubt there is
>> > > anything RT specific about what you are seeing, but it might be nice
>> > > to get confirmation.  Also, bisection would probably be easier if you confirm on a
>> vanilla kernel.
>> > >
>> > > I find it unlikely that it's a kernel config option that changed
>> > > which regressed you, but instead was a code change to a driver.
>> > > Which driver is now the question, and the surface area is still big
>> > > (processor mapping attributes for this region, PCI root complex configuration,
>> PCI brige configuration, igb driver itself, etc.).
>> > >
>> > > Big enough that I'd recommend a bisection.  It looks like a
>> > > bisection between 3.18 and 4.8 would take you about 18 tries to narrow down,
>> assuming all goes well.
>> > >
>> >
>> > I have now repeated my tests using the vanilla kernel.
>> > There I got the very same issue.
>> > Using kernel 4.0 is fine, however starting with kernel 4.1, the issue appears.
>>
>> Great, thanks for confirming!  That helps narrow things down quite a bit.
>>
>> > Here is my exact (reproducible) test description:
>> > I applied the following patch to the kernel to get the igb trace.
>> > This patch instruments the igb_rd32() function to measure the call to
>> > readl() which is used to access registers of the igb NIC.
>>
>> I took your test setup and ran it between 4.0 and 4.1 on the hardware on my desk,
>> which is an Atom-based board with dual I210s, however I didn't see much
>> difference.
>>
>> However, it's a fairly simple board, with a much simpler PCI topology than your
>> workstation.  I'll see if I can find some other hardware to test on.
>>
>> [..]
>> > This means, that I think that some other stuff in kernel 4.1 has
>> > changed, which has impact on the igb accesses.
>> >
>> > Any idea what component could cause this kind of issue?
>>
>> Can you continue your bisection using 'git bisect'?  You've already narrowed it down
>> between 4.0 and 4.1, so you're well on your way.
>>
>
> OK - done.
> And finally I was successful!
> The following git commit is the one that is causing the trouble!
> (The full commit is in the attachment).
> +++++++++++++++++++++ BEGIN +++++++++++++++++++++++++++
> commit 387d37577fdd05e9472c20885464c2a53b3c945f
> Author: Matthew Garrett <mjg59@coreos.com>
> Date:   Tue Apr 7 11:07:00 2015 -0700
>
>     PCI: Don't clear ASPM bits when the FADT declares it's unsupported
>
>     Communications with a hardware vendor confirm that the expected behaviour
>     on systems that set the FADT ASPM disable bit but which still grant full
>     PCIe control is for the OS to leave any BIOS configuration intact and
>     refuse to touch the ASPM bits.  This mimics the behaviour of Windows.
>
>     Signed-off-by: Matthew Garrett <mjg59@coreos.com>
>     Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> +++++++++++++++++++++ HEADER +++++++++++++++++++++++++++
>
> The only files that are modified by this commit are
> drivers/acpi/pci_root.c
> drivers/pci/pcie/aspm.c
> include/linux/pci-aspm.h
>
> This is all generic PCIe stuff - however I do not really understand what
> the changes of the commit are...
>
> In my setup I am using a dual port igb Ethernet adapter.
> This has an onboard PCIe switch and it might be that the configuration of this
> PCIe switch on the Intel board is causing the trouble.
>
> Please see also the output of "lspci -v" in the attachment.
> The relevant PCI address of the NIC is 04:00.0 / 04:00.1
>
> Any feedback on this is welcome!
>
> Thanks
>
> Mathias

Hi Mathias,

If you could set the output of lspci -vvv it might be more useful as
most of the configuration data isn't present in the lspci dump you had
attached.  Specifically if you could do this for the working case and
the non-working case we could verify if this issue is actually due to
the ASPM configuration on the device.

Also one thing you might try is booting your kernel with the kernel
parameter "pcie_aspm=off".  It sounds like the extra latency is likely
due to your platform enabling ASPM on the device and this in turn will
add latency if the PCIe link is disabled when you attempt to perform a
read as it takes some time to bring the PCIe link up when in L1 state.

Thanks for bisecting this.

- Alex
