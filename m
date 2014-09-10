From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v5 11/13] net: dsa: add Broadcom SF2 switch driver
Date: Tue, 09 Sep 2014 19:17:16 -0700
Message-ID: <540FB4AC.3060705@gmail.com>
References: <1409184267-1696-1-git-send-email-f.fainelli@gmail.com>	<1409184267-1696-12-git-send-email-f.fainelli@gmail.com> <CAKgT0UciNUu_AsSmxx62S26Ywbzo4hPZEu00fSsPmXpHMoqPSA@mail.gmail.com> <540F58E5.7070009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	John Linville <linville@tuxdriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:50070 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbaIJCRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 22:17:17 -0400
Received: by mail-pa0-f49.google.com with SMTP id lf10so4715340pab.36
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 19:17:16 -0700 (PDT)
In-Reply-To: <540F58E5.7070009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2014 12:45 PM, Florian Fainelli wrote:
> On 09/09/2014 12:32 PM, Alexander Duyck wrote:
>> On Wed, Aug 27, 2014 at 5:04 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> Add support for the Broadcom Starfigther 2 switch chip using a DSA
>>> driver. This switch driver supports the following features:
>>>
>>> - configuration of the external switch port interface: MII, RevMII,
>>>   RGMII and RGMII_NO_ID are supported
>>> - support for the per-port MIB counters
>>> - support for link interrupts for special ports (e.g: MoCA)
>>> - powering up/down of switch memories to conserve power when ports are
>>>   unused
>>>
>>> Finally, update the compatible property for the DSA core code to match
>>> our switch top-level compatible node.
>>>
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>> ---
>>> Changes in v4:
>>> - fixed typo on the word Starfighter
>>> - fixed a few checkpatch.pl warnings
>>>
>>> No changes in v3
>>>
>>> Changes in v2:
>>> - add support for reading to special MDIO phys (0 and 30)
>>> - added more power down optimization
>>> - added VLAN separation
>>>
>>>  drivers/net/dsa/Kconfig        |  11 +
>>>  drivers/net/dsa/Makefile       |   1 +
>>>  drivers/net/dsa/bcm_sf2.c      | 626 +++++++++++++++++++++++++++++++++++++++++
>>>  drivers/net/dsa/bcm_sf2.h      | 140 +++++++++
>>>  drivers/net/dsa/bcm_sf2_regs.h | 227 +++++++++++++++
>>>  net/dsa/dsa.c                  |   1 +
>>>  6 files changed, 1006 insertions(+)
>>>  create mode 100644 drivers/net/dsa/bcm_sf2.c
>>>  create mode 100644 drivers/net/dsa/bcm_sf2.h
>>>  create mode 100644 drivers/net/dsa/bcm_sf2_regs.h
>> [...]
>>
>>> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
>>> new file mode 100644
>>> index 000000000000..bb7cb8e283b1
>>> --- /dev/null
>>> +++ b/drivers/net/dsa/bcm_sf2.c
>> [...]
>>
>>> +static char *bcm_sf2_sw_probe(struct mii_bus *bus, int sw_addr)
>>> +{
>>> +       return "Broadcom Starfighter 2";
>>> +}
>>> +
>> I hadn't noticed before but with this driver it seems like you could
>> potentially load on any DSA enabled device could you not?  It seems
>> like this would be problematic since you could end up registering
>> before another DSA driver and prevent it from being able to load since
>> you always return success.  Isn't there any test you could run to
>> determine if the switch is actually there or not?
> Unfortunately the current DSA device/driver model is kind of messed up
> for that, which is something I plan on fixing, although it would take a
> little bit more time. The way it works currently is:
>
> - you register a DSA platform device, feed it with Device Tree or
> C-struct configuration data
> - you register a switch driver
> - the DSA platform code will eventually iterate over all switch devices,
> call into their probe function and based on a non-NULL return, accept to
> register this switch device
> - the probe function only accepts MDIO connected switches, anything else
> has to find another way to tell that it is there
>
> so all of this works okay until you have a switch which is memory-mapped
> into the CPU address space and which is not on the MDIO bus.
>
> A short term solution could be to change the probe argument to be more
> generic and pass a void *bus pointer or something allowing us to do a
> tad more things, including verifying a register to see if the switch is
> there.

I would probably just rewrite the call to accept dsa_chip_data instead
of passing it the mii_bus and sw_addr.  Then you can just access data
like the of_node directly.  I'm also thinking it might make more sense
to make the mii_bus pointer in the dsa_chip_data a bit more type
agnostic by simply treating it as a parent device.  It seems like most
of the code is already there in dsa via the dev_find_class check that is
checking for "mdio_bus".

> The way I would like to fix this model though is to allow switch drivers to:
>
> - specify their own configuration data, since for instance, external
> switches usually have a pretty fixed set of configuration options:
> number of ports, fixed CPU port, while keeping platform-driven
> configuration data as well
>
> - be backed by their host interface device/driver, e.g: allow a SPI,
> PHY, PCI(e), USB drivers to register a switch driver, such that there
> really is a struct device pointer we can refer to for various operations
> (DMA, PM...)

This is the kind of situation I am looking at.  In my case I have a PCIe
interface with one of the BARs providing access to switch registers.  As
such I would want to be able to provide a PCI device and sort out the
eligibility to run the driver by checking for the PCI vendor and device ID.

> I will cook some patches that do that in the next few days.
> --
> Florian

I'll keep an eye open for them.  I might start submitting a few patches
myself as I should be pushing my driver in the next week or two.

Thanks,

Alex
