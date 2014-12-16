From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Tue, 16 Dec 2014 09:20:31 -0700
Message-ID: <CAErSpo5dqQE7nZ6zf2odgpHBWA3ZpTjhbgQKnY8YxQW+a+298w@mail.gmail.com>
References: <20141213210251.GA12812@teela.fritz.box> <548EF90A.5070607@gmail.com>
 <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Nils Holland <nholland@tisys.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Rajat Jain <rajatxjain@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:60230 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbaLPQUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 11:20:52 -0500
Received: by mail-qg0-f50.google.com with SMTP id i50so10301801qgf.37
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 08:20:52 -0800 (PST)
In-Reply-To: <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+cc Rafael, Prashant, Michael]

On Tue, Dec 16, 2014 at 9:04 AM, Rajat Jain <rajatxjain@gmail.com> wrote:
> Hello All,
>
> Apologies for jumping in late, but for some reason I do not see the
> original mail in my inbox. However I am taking a look at the mails as
> sent on linux-pci (and I will keep an eye out for the bug report that
> Bjorn asked for).
>
>
>>
>> I'm getting, with commit 89665a6a71408796565bfd29cfa6a7877b17a667:
>>
>> $ grep 'pci 0000:02' tg3.bad
>> [    0.190733] pci 0000:02:00.0: 1st 165a14e4 14e4
>> [    0.190736] pci 0000:02:00.0: 1st 165a14e4 14e4
>> [    0.190810] pci 0000:02:00.0: [14e4:165a] type 00 class 0x020000
>> [    0.190885] pci 0000:02:00.0: reg 0x10: [mem 0xf7c40000-0xf7c4ffff 64bit]
>> [    0.191048] pci 0000:02:00.0: reg 0x30: [mem 0xf7c00000-0xf7c3ffff pref]
>> [    0.191382] pci 0000:02:00.0: PME# supported from D3hot D3cold
>> [    0.191438] pci 0000:02:00.0: System wakeup disabled by ACPI
>> [    1.561555] pci 0000:02:00.0: 1st 1 1
>> [    1.561558] pci 0000:02:00.0: crs_timeout: 0
>> [   20.412021] pci 0000:02:00.0: 1st 1 1
>> [   20.412022] pci 0000:02:00.0: crs_timeout: 0
>> [   20.413596] pci 0000:02:00.0: 1st 1 1
>> [   20.413598] pci 0000:02:00.0: crs_timeout: 0
>>
>> And without it:
>>
>> $ grep 'pci 0000:02' tg3.good
>> [    0.190734] pci 0000:02:00.0: 1st 165a14e4 14e4
>> [    0.190738] pci 0000:02:00.0: 1st 165a14e4 14e4
>> [    0.190811] pci 0000:02:00.0: [14e4:165a] type 00 class 0x020000
>> [    0.190884] pci 0000:02:00.0: reg 0x10: [mem 0xf7c40000-0xf7c4ffff 64bit]
>> [    0.191047] pci 0000:02:00.0: reg 0x30: [mem 0xf7c00000-0xf7c3ffff pref]
>> [    0.191380] pci 0000:02:00.0: PME# supported from D3hot D3cold
>> [    0.191439] pci 0000:02:00.0: System wakeup disabled by ACPI
>> [    1.576778] pci 0000:02:00.0: 1st 1 1
>> [   19.068517] pci 0000:02:00.0: 1st 165a14e4 14e4
>>
>
> It seems that in the first 2 attempts that were made to probe the
> device are all OK and return regular device ID and vendor ID for TG3
> (CRS does not have a role to play). However, later attempts return a
> CRS.
>
> 1) May I ask if you are using acpihp or pciehp? I assume pciehp?
>
> 2) Can you please also send dmesg output while passing
> pciehp.pciehp_debug=1? In the fail case, do you see a message
> indicating the pciehp gave up since it got CRS for a long time
> (something like "pci 0000:02:00.0 id reading try 50 times with
> interval 20 ms to get ffff0001")?
>
> 3) Currently the pciehp passes "0" for the argument "crs_timeout" to
> pci_bus_read_dev_vendor_id(). Can you please try increasing it to, say
> 30 seconds (30 * 1000). (For comparison data, acpihp uses the value
> 60*1000 i.e. 60 seconds today) and run the fail case once again?

Using zero for the timeout seems bogus to me.  But I doubt pciehp is
involved in this situation.

I think we're in this path:

    tg3_init_hw
      tg3_reset_hw
        tg3_disable_ints
        tg3_stop_fw
        tg3_write_sig_pre_reset
        tg3_chip_reset
          pci_device_is_present
            pci_bus_read_dev_vendor_id

and in this case pci_device_is_present() also passes a timeout of zero
to pci_bus_read_dev_vendor_id().  My guess is that tg3 is resetting
the device, so it's not too surprising that the config read returns
CRS status immediately afterward.

Bjorn
