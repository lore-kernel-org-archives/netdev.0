From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 3/3] net: bgmac: use PHY subsystem for initializing PHY
Date: Sun, 29 Jan 2017 14:36:39 -0800
Message-ID: <e76bfeec-8bcd-4c9e-c5e7-5a5b50f4b36e@gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com>
 <20170128210832.26174-4-zajec5@gmail.com>
 <08f74e19-f9b2-a0ea-ee21-d35cbdf6ee76@gmail.com>
 <a041cb98-1555-7838-4e02-1d7a71cea90f@gmail.com>
 <03584f21-6ea2-a6ea-3100-cf5b1ead4f0f@gmail.com>
 <CACna6rzgX0PcNg77_hLs5XCvHnJF110Psyg3eES-ZejgVwb7rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Jon Mason <jon.mason@broadcom.com>,
        Felix Fietkau <nbd@openwrt.org>,
        Network Development <netdev@vger.kernel.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:34478 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbdA2Xam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 18:30:42 -0500
Received: by mail-ot0-f194.google.com with SMTP id 73so36703104otj.1
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 15:30:41 -0800 (PST)
In-Reply-To: <CACna6rzgX0PcNg77_hLs5XCvHnJF110Psyg3eES-ZejgVwb7rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/29/17 à 13:31, Rafał Miłecki a écrit :
> On 29 January 2017 at 21:22, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 01/29/2017 12:14 PM, Rafał Miłecki wrote:
>>> On 01/29/2017 04:08 AM, Florian Fainelli wrote:
>>>> On 01/28/2017 01:08 PM, Rafał Miłecki wrote:
>>>>> From: Rafał Miłecki <rafal@milecki.pl>
>>>>>
>>>>> This adds support for using bgmac with PHYs supported by standalone PHY
>>>>> drivers. Having any PHY initialization in bgmac is hacky and shouldn't
>>>>> be extended but rather removed if anyone has hardware to test it.
>>>>>
>>>>> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
>>>>> ---
>>>>>  drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c | 10 ++++++++++
>>>>>  1 file changed, 10 insertions(+)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
>>>>> b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
>>>>> index 9d9984999dce..6ce80cbcb48e 100644
>>>>> --- a/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
>>>>> +++ b/drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
>>>>> @@ -132,6 +132,10 @@ static void bcma_mdio_phy_init(struct bgmac *bgmac)
>>>>>      struct bcma_chipinfo *ci = &bgmac->bcma.core->bus->chipinfo;
>>>>>      u8 i;
>>>>>
>>>>> +    /* For some legacy hardware we do chipset-based PHY
>>>>> initialization here
>>>>> +     * without even detecting PHY ID. It's hacky and should be
>>>>> cleaned as
>>>>> +     * soon as someone can test it.
>>>>> +     */
>>>>>      if (ci->id == BCMA_CHIP_ID_BCM5356) {
>>>>>          for (i = 0; i < 5; i++) {
>>>>>              bcma_mdio_phy_write(bgmac, i, 0x1f, 0x008b);
>>>>> @@ -140,6 +144,7 @@ static void bcma_mdio_phy_init(struct bgmac *bgmac)
>>>>>              bcma_mdio_phy_write(bgmac, i, 0x12, 0x2aaa);
>>>>>              bcma_mdio_phy_write(bgmac, i, 0x1f, 0x000b);
>>>>>          }
>>>>> +        return;
>>>>
>>>> That part is clearly initializing the built-in Ethernet switch's PHYs,
>>>> and so the natural place for that would be to stick these init values
>>>> into the Broadcom PHY driver. When b53-srab/b53_common attaches the
>>>> switch, it will scan all of these port's builtin PHYs and bind to an
>>>> appropriate PHY driver which could have this initialization as part of
>>>> the config_init routine for instance. Right now, we are most likely
>>>> using the Generic PHY.
>>>
>>> I don't think this code is for switch's PHYs. I believe this code is for
>>> wireless access points that have no switch and have Ethernet interface
>>> connected
>>> directly to some single-port PHY. I saw 2 or 3 devices like this. They
>>> often
>>> also use PoE.
>>
>> Humm, built-in PHYs would typically appear as 0-5 on the MDIO bus,
>> whereas external PHYs would have a different (and non conflicting)
>> address, also, there are restrictions on the Roboswitch devices as to
>> where you could wire these external PHYs (to port 5, or 7, 8).
> 
> From BCM47186B0:
> [    0.942419] bgmac_bcma bcma0:2: Found PHY addr: 25
> 
> From BCM47189:
> [    1.758079] bgmac_bcma bcma0:5: Found PHY addr: 0

Address 0 is usually a broadcast address, although with most Broadcom
switches, it just maps to the first port's built-in PHY.

> 
> I got one more AP device but I bricked it by corrupting NVRAM
> (bootloader doesn't start due to that).
> 
> 
> My BCM47186B0 seems to not have any switch. It isn't that clear in
> BCM47189 case. You may be right, some sources say BCM47189 has
> built-in switch so maybe it's indeed BCM54210E connected to switch's
> port. On the other hand I'm not using any switch driver on my BCM47189
> AP board, so how does it work? Just an accidentally working setup left
> by the bootloader?

That's what I suspect is happening yes. Do you have the different FCC
IDs of these routers so maybe looking at pictures of the inside would
tell us what kind of internal vs. external PHYs are populated?
-- 
Florian
