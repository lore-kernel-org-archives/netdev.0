From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Tue, 16 Dec 2014 16:00:04 -0200
Message-ID: <54907324.4040102@gmail.com>
References: <20141213210251.GA12812@teela.fritz.box> <548EF90A.5070607@gmail.com> <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nils Holland <nholland@tisys.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: rajatxjain@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:33020 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbaLPSAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 13:00:11 -0500
In-Reply-To: <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-2014 14:04, Rajat Jain wrote:
> Hello All,
>
> Apologies for jumping in late, but for some reason I do not see the
> original mail in my inbox. However I am taking a look at the mails as
> sent on linux-pci (and I will keep an eye out for the bug report that
> Bjorn asked for).
>

np!
Nils would you create that BZ please? As you did all the bisect.. :)

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

Well.. system doesn't support hotplug..
Chipset is a "Intel Corporation 5 Series/3400 Series", fwiw

> 2) Can you please also send dmesg output while passing
> pciehp.pciehp_debug=1? In the fail case, do you see a message
> indicating the pciehp gave up since it got CRS for a long time
> (something like "pci 0000:02:00.0 id reading try 50 times with
> interval 20 ms to get ffff0001")?

I did use that option anyway, but it resulted in no new messages.

> 3) Currently the pciehp passes "0" for the argument "crs_timeout" to
> pci_bus_read_dev_vendor_id(). Can you please try increasing it to, say
> 30 seconds (30 * 1000). (For comparison data, acpihp uses the value
> 60*1000 i.e. 60 seconds today) and run the fail case once again?
>
> Thanks a lot in advance for the debugging help ;-)
>

Seems it's not safe to do that with those backtraces..
I did it, system was very slow to boot, still didn't get the NIC on and 
got a bunch of "scheduling while atomic" due to that msleep() call.

The first invoke was fine:
Dec 16 15:40:00 odin kernel: [    0.190711] pci 0000:02:00.0: 1st 
165a14e4 14e4
Dec 16 15:40:00 odin kernel: [    0.190717] pci 0000:02:00.0: 1st 
165a14e4 14e4
Dec 16 15:40:00 odin kernel: [    0.191091] pci 0000:02:00.0: System 
wakeup disabled by ACPI
Dec 16 15:40:00 odin kernel: [    1.576061] pci 0000:02:00.0: 1st 1 1
Dec 16 15:40:00 odin kernel: [    1.577474] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    1.580487] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    1.585508] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    1.594499] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    1.611499] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    1.644521] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    1.709566] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    1.838654] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    2.095765] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    2.608956] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    3.634443] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    5.684388] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [    9.783279] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [   17.980060] pci 0000:02:00.0: 1 1
Dec 16 15:40:00 odin kernel: [   34.372640] pci 0000:02:00.0: not responding

The other two...
Dec 16 15:40:09 odin kernel: [   54.154688] pci 0000:02:00.0: 1st 1 1
Dec 16 15:40:09 odin kernel: [   54.154690] BUG: scheduling while 
atomic: ip/1575/0x00000200
Dec 16 15:40:09 odin kernel: pci 0000:02:00.0: 1st 1 1
Dec 16 15:40:09 odin kernel: BUG: scheduling while atomic: 
ip/1575/0x00000200
Dec 16 15:40:09 odin kernel: pci 0000:02:00.0: 1 1
Dec 16 15:40:09 odin kernel: BUG: scheduling while atomic: 
ip/1575/0x00000200
(...)

BUG backtraces were very similar to the 2nd and 3rd I posted on the 
other email, it just pointed to the msleep() call instead of my BUG_ON(1).

I can dig deeper if you think it's worth, but as the 1st call didn't 
have this issue and it didn't complete either, seems we are good about 
the test.. right?

Thanks,
Marcelo
