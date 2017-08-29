From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: Fwd: DA850-evm MAC Address is random
Date: Tue, 29 Aug 2017 20:46:20 +0530
Message-ID: <955b0b1b-9bb7-ad25-4d6c-676be1efb943@ti.com>
References: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
 <b7aab9fc-17ba-077b-3ff3-28087e0b25bc@ti.com>
 <CAHCN7xLHEjda9DcVw5iHA9RaJ7UnyMVxf7e4e8NTEj9Op1JaBw@mail.gmail.com>
 <20170828211217.GO6008@atomide.com>
 <94c4cbb0-1df3-2f2f-69f3-f9a788e610fa@ti.com>
 <CAHCN7x+-wymsqw96mt7Du=Huxh5rq=Rj9GidWPLXptJSW7taEA@mail.gmail.com>
 <f0f5e11f-cd7a-cb86-58b5-8ce44cdbc032@ti.com>
 <CAHCN7xK2=PN5MOr48HOkZnwKwkM4ypcvQct+Ko+ChNFG3Pv62w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tony Lindgren <tony@atomide.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>
To: Adam Ford <aford173@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:32188 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751394AbdH2PQ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 11:16:26 -0400
In-Reply-To: <CAHCN7xK2=PN5MOr48HOkZnwKwkM4ypcvQct+Ko+ChNFG3Pv62w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 August 2017 05:32 PM, Adam Ford wrote:
> On Tue, Aug 29, 2017 at 6:42 AM, Sekhar Nori <nsekhar@ti.com> wrote:
>> On Tuesday 29 August 2017 03:53 PM, Adam Ford wrote:
>>> On Tue, Aug 29, 2017 at 3:23 AM, Sekhar Nori <nsekhar@ti.com> wrote:
>>>> On Tuesday 29 August 2017 02:42 AM, Tony Lindgren wrote:
>>>>> * Adam Ford <aford173@gmail.com> [170828 13:33]:
>>>>>> On Mon, Aug 28, 2017 at 1:54 PM, Grygorii Strashko
>>>>>> <grygorii.strashko@ti.com> wrote:
>>>>>>> Cc: Sekhar
>>>>>>>
>>>>>>> On 08/28/2017 10:32 AM, Adam Ford wrote:
>>>>>>>>
>>>>>>>> The davinvi_emac MAC address seems to attempt a call to
>>>>>>>> ti_cm_get_macid in cpsw-common.c but it returns the message
>>>>>>>> 'davinci_emac davinci_emac.1: incompatible machine/device type for
>>>>>>>> reading mac address ' and then generates a random MAC address.
>>>>>>>>
>>>>>>>> The function appears to lookup varions boards using
>>>>>>>> 'of_machine_is_compaible' and supports dm8148, am33xx, am3517, dm816,
>>>>>>>> am4372 and dra7.  I don't see the ti,davinci-dm6467-emac which is
>>>>>>>> what's shown in the da850 device tree.
>>>>>>>>
>>>>>>>> Is there a patch somewhere for supporting the da850-evm?
>>>>>>>
>>>>>>>
>>>>>>> Not sure if MAC address can be read from Control module.
>>>>>>> May be Sekhar can say more?
>>>>>>
>>>>>> My understanding is that the MAC address is programmed by Logic PD
>>>>>> into the SPI flash.  The Bootloader reads this from either SPI or its
>>>>>> env variables.  Looking at the partition info listed in the
>>>>>> da850-evm.dts file, it appears as if they've reserved space for it.
>>>>>> Unfortunately, I don't see any code that reads it out.  I was hoping
>>>>
>>>> This code is present in U-Boot sources at
>>>> board/davinci/da8xxevm/da850evm.c. See the function get_mac_addr() and
>>>> its usage in misc_init_r().
>>>>
>>>>>> there might be a way to just pass cmdline parameter from the
>>>>>> bootloader to the kernel to accept the MAC address.
>>>>>>
>>>>>>>
>>>>>>>>
>>>>>>>> If not, is there a way to pass the MAC address from U-Boot to the
>>>>>>>> driver so it doesn't generate a random MAC?
>>>>>>>
>>>>>>>
>>>>>>> "local-mac-address" dt porp
>>>>>>
>>>>>> The downside here, is that we'd have to have the Bootloader modify the
>>>>>> device tree.
>>>>>
>>>>> That piece of code exists somewhere in u-boot already. Note how
>>>>
>>>> Yes, it is fdt_fixup_ethernet() and its usage is in common/image-fdt.c.
>>>>
>>>>> we are populating the mac address for USB Ethernet drivers in
>>>>> u-boot and then the Ethernet driver code parses it. See commit
>>>>> 055d31de7158 ("ARM: omap3: beagleboard-xm: dt: Add ethernet to
>>>>> the device tree") for some more information.
>>>>>
>>>>> I think u-boot needs the ethernet alias for finding the interface.
>>>>
>>>> That's exactly what was missing. I have sent a patch for fixing that and
>>>> copied you there.
>>>
>>> Thanks for doing that.
>>>
>>>>
>>>> Adam, if I can get your Tested-by, I will make an attempt to send it for
>>>> v4.13 itself.
>>>
>>> I will test it.  Do need to run some instruction or do something
>>> special in U-Boot to pass this in the proper place for the kernel to
>>> pull it?  Tony's patch reference showed
>>> command for fdt set, but I am not sure I fully understand the
>>> parameters that went along with that.
>>
>> Nope, just applying the patch and booting the with the new dtb should
>> result in the random mac address going away.
> 
> Unfortunately, I am not seeing any change with the patch (at least
> with Kernel 4.12.9 from stable).
> 
> netconsole: network logging started
> davinci_emac davinci_emac.1: incompatible machine/device type for
> reading mac address
> davinci_emac davinci_emac.1: using random MAC addr: ee:74:c3:3a:15:be
> 
> Looking at the source for cpsw-common.c function ti_cm_get_macid()
> doesn't have a case for the  ti,davinci-dm6467-emac so I wonder if
> there might be more to it.

Hmm, it did solve the issue for me when I tried latest -next. And
reverting the patch brought back the random mac address usage. Could you
try latest mainline or -next?

Meanwhile let me see whats going on with the observations you have.

Thanks,
Sekhar
