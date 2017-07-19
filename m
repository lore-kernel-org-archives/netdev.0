From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: at803x: Fix RGMII RX and TX clock delays
 setup
Date: Wed, 19 Jul 2017 14:44:15 -0700
Message-ID: <b3b785bf-750c-5f09-8c0c-2c49be48a26d@gmail.com>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
 <33ed5f4f-9939-dc00-b973-db39c16f2393@sigmadesigns.com>
 <5ea9905f-e74a-4a43-dc5b-883ec9daf030@ti.com>
 <abbcd40c-5ecd-2197-73d0-2046cf1e7b5c@gmail.com>
 <03f68f8b-edd6-f976-39d0-a580ccb888d5@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>, Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35167 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754090AbdGSVoU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 17:44:20 -0400
Received: by mail-qt0-f195.google.com with SMTP id p25so1610737qtp.2
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 14:44:20 -0700 (PDT)
In-Reply-To: <03f68f8b-edd6-f976-39d0-a580ccb888d5@free.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2017 02:29 PM, Mason wrote:
> On 19/07/2017 21:30, Florian Fainelli wrote:
>> On 07/19/2017 12:24 PM, Grygorii Strashko wrote:
>>> Hi
>>>
>>> On 07/19/2017 10:31 AM, Marc Gonzalez wrote:
>>>> The current code supports enabling RGMII RX and TX clock delays.
>>>> The unstated assumption is that these settings are disabled by
>>>> default at reset, which is not the case.
>>>>
>>>> RX clock delay is enabled at reset. And TX clock delay "survives"
>>>> across SW resets. Thus, if the bootloader enables TX clock delay,
>>>> it will remain enabled at reset in Linux.
>>>>
>>>> Provide disable functions to configure the RGMII clock delays
>>>> exactly as specified in the fwspec.
>>>>
>>>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>>>> ---
>>>>   drivers/net/phy/at803x.c | 32 ++++++++++++++++++++++++--------
>>>>   1 file changed, 24 insertions(+), 8 deletions(-)
>>> This patch breaks am335x-evm networking.
>>>
>>> To restore it I've had to apply below diff:
>>> diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
>>> index 200d6ab..9578bdf 100644
>>> --- a/arch/arm/boot/dts/am335x-evm.dts
>>> +++ b/arch/arm/boot/dts/am335x-evm.dts
>>> @@ -724,12 +724,12 @@
>>>  
>>>  &cpsw_emac0 {
>>>         phy_id = <&davinci_mdio>, <0>;
>>> -       phy-mode = "rgmii-txid";
>>> +       phy-mode = "rgmii-id";
>>>  };
>>>  
>>>  &cpsw_emac1 {
>>>         phy_id = <&davinci_mdio>, <1>;
>>> -       phy-mode = "rgmii-txid";
>>> +       phy-mode = "rgmii-id";
>>>  };
>>>  
>>>  &tscadc {
>>>
>>> Sry, can't comment here to much - not E-PHY expert.
>>
>> It's useful feedback, since we had poorly defined "phy-mode" semantics
>> for too long, this is totally expected, Marc this is exactly why Mans is
>> suggesting additional MAC-specific properties to define delays.
> 
> In the current situation, it is impossible to configure
> the at803x to disable RX clock delay or TX clock delay
> (in case the boot loader enabled it).
> 
> Are you saying that, because no one has had a problem
> so far, it is not possible to fix it now, as it would
> break boards like am335x-evm.dts which didn't request
> RX clock delay, but got one anyway?

First it means that your patch as-is broke Grygorii's board, and you
need to at least integrate his patch if you plan on having your own
patch accepted. This will fix am335x-evm.dts, but we have no visibility
into the other DTSes out there that may be using an at803x PHY. If you u
break something you need to fix it, and touching how PHY delays are

> 
> Does that mean we cannot support boards using AR8035
> that need the RX and TX clock delays disabled?

No, that is not what that means, it means that you cannot change how an
existing PHY driver with active and existing deployments is interpreting
the phy_interface_t value in a way that it breaks people setups, which
your patch just did. Yes this makes it non-conforming to the revised
definition of "phy-mode", but it is just how it is, people did not know
any better before.

See below for what you could do.

> 
> I'm not sure how the MAC-specific properties can save
> the day?

If you introduced PHY and/or MAC specific properties to configure the
delays in the appropriate unit of time (say ps), you could use a
non-compliant 'phy-mode' just to satisfy the driver/PHY library and
still override the delays you need.
-- 
Florian
