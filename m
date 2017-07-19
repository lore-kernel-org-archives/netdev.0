From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: nb8800: Fix RGMII TX clock delay setup
Date: Wed, 19 Jul 2017 14:34:39 -0700
Message-ID: <bf484952-15ae-b385-6b54-4d07b3bc2b29@gmail.com>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
 <61b71d12-4e3a-edbe-1d69-c66e7cf46d8e@sigmadesigns.com>
 <yw1xzic0qrcg.fsf@mansr.com> <001a7afd-364d-359e-1478-e057c9083f73@free.fr>
 <d8121f82-dffd-22c7-1209-a3c2329703e5@gmail.com>
 <05cbc32e-a4af-1c81-128b-bc5d2206d24a@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Mans Rullgard <mans@mansr.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:37359 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753539AbdGSVew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 17:34:52 -0400
Received: by mail-wr0-f196.google.com with SMTP id 12so1095345wrb.4
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 14:34:51 -0700 (PDT)
In-Reply-To: <05cbc32e-a4af-1c81-128b-bc5d2206d24a@free.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2017 02:15 PM, Mason wrote:
> On 19/07/2017 20:30, Florian Fainelli wrote:
>> On 07/19/2017 10:36 AM, Mason wrote:
>>> On 19/07/2017 19:17, Måns Rullgård wrote:
>>>
>>>> Marc Gonzalez writes:
>>>>
>>>>> According to commit e5f3a4a56ce2a707b2fb8ce37e4414dcac89c672
>>>>> ("Documentation: devicetree: clarify usage of the RGMII phy-modes")
>>>>> there are 4 RGMII phy-modes to handle:
>>>>>
>>>>> "rgmii" (RX and TX delays are added by the MAC when required)
>>>>> "rgmii-id" (RGMII with internal RX and TX delays provided by the PHY,
>>>>> 	the MAC should not add the RX or TX delays in this case)
>>>>> "rgmii-rxid" (RGMII with internal RX delay provided by the PHY,
>>>>> 	the MAC should not add an RX delay in this case)
>>>>> "rgmii-txid" (RGMII with internal TX delay provided by the PHY,
>>>>> 	the MAC should not add an TX delay in this case)
>>>>>
>>>>> Let the MAC handle TX clock delay for rgmii and rgmii-rxid.
>>>>>
>>>>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>>>>> ---
>>>>>  drivers/net/ethernet/aurora/nb8800.c | 8 +++++---
>>>>>  1 file changed, 5 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>>>>> index 041cfb7952f8..f3ed320eb4ad 100644
>>>>> --- a/drivers/net/ethernet/aurora/nb8800.c
>>>>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>>>>> @@ -609,7 +609,7 @@ static void nb8800_mac_config(struct net_device *dev)
>>>>>  		mac_mode |= HALF_DUPLEX;
>>>>>
>>>>>  	if (gigabit) {
>>>>> -		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
>>>>> +		if (phy_interface_is_rgmii(dev->phydev))
>>>>>  			mac_mode |= RGMII_MODE;
>>>>>
>>>>>  		mac_mode |= GMAC_MODE;
>>>>
>>>> This is a separate issue, and the change is obviously correct.
>>>>
>>>>> @@ -1268,11 +1268,13 @@ static int nb8800_tangox_init(struct net_device *dev)
>>>>>  		break;
>>>>>
>>>>>  	case PHY_INTERFACE_MODE_RGMII:
>>>>> -		pad_mode = PAD_MODE_RGMII;
>>>>> +	case PHY_INTERFACE_MODE_RGMII_RXID:
>>>>> +		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>>>>>  		break;
>>>>>
>>>>> +	case PHY_INTERFACE_MODE_RGMII_ID:
>>>>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>>>>> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>>>>> +		pad_mode = PAD_MODE_RGMII;
>>>>>  		break;
>>>>
>>>> Won't this just make it break in a different set of circumstances?
>>>
>>> I don't think so, and here's my reasoning:
>>>
>>> AFAIU, the HW block always requires a TX clock delay
>>> (I don't know what the "safe" interval is. PHY adds
>>> 2.4 ns, MAC adds ~1 ns, both work.)
>>
>> The nominal delay should be 2ns because that's exactly what a 90 degrees
>> shift at a 125Mhz would be. The RGMII specification defines the following:
>>
>> TskewT - Data to Clock output Skew (At Transmitter) Min: -500ns, Nom: 0,
>> Max: + 500 ns
>> TskewR - Data to Clock input Skew (At Receiver) Min: 1ns, Nom: 0, Max:
>> 2.6ns (see note 1)
>>
>> note 1: This implies that PC board design will require clocks to be
>> routed such that an additional trace delay of greater than 1.5ns and
>> less than 2.0ns will be added to the associated clock signal. For 10/100
>> the Max value is unspecified.
>>
>> So it seems to me like you are borderline spec in both delays you gave
>> here and the "HW block always requires a TX clock delay" statement is
>> true for a given board design only.
> 
> I must confess that my understanding of clock delays,
> clock skew, routing, traces, etc is nil.
> 
> Is TskewT the TX clock delay?
> And TskewR the RX clock delay?
> 
> Doesn't wire delay factor in too?
> (So longer wires require more delay.)

How about you start reading the RGMII specification so we can at least,
if nothing else agree on the terminology? It's public:

http://web.archive.org/web/20160303171328/http://www.hp.com/rnd/pdfs/RGMIIv2_0_final_hp.pdf

> 
>>> RX clock delay seems to be "Don't Care" (tested both
>>> enabled and disabled by PHY)
>>> By "tested", I mean ability to ping remote system.
>>
>> Can you do something a bit more stressful than just a ping, also if you
>> have the ability to change the inter-packet gap, do it, and see if you
>> start seeing FCS or any other decoding errors.
> 
> Errr... "Inter-packet gap"?
> Is there supposed to be a HW knob to tweak how long
> the HW waits between sending two frames?

Some Ethernet controllers let you change it, some don't, if nb8800
allows it, it's good for testing in that it packs more frames per
quantum of time. If not, do you have at least a FCS error counter?

> 
>>> If phy-mode is RGMII or RGMII_RXID, then don't add
>>> TX clock delay from PHY, therefore add it from MAC.
>>>
>>> If phy_mode is RGMII_ID or RGMII_TXID, then do add
>>> TX clock delay from PHY, therefore don't add it from MAC.
>>>
>>> What set of circumstances would create an issue?
>>
>> Existing Device Tree sources that do not correspond to that description
>> you just did, I suppose they are all out of tree?
> 
> The problem with PHY drivers is that there is no
> simple compatible string to grep for.

That does not help for sure.

> 
> The tango boards use "ethernet-phy-id004d.d072"
> but not a single other DT uses that string.
> For example, am335x-evm.dts doesn't seem to name the PHY.
> Hmmm, how does the at803x probe function match for that
> board?

of_mdiobus_register() scans the Device Tree and for each populated PHY
node, reads its OUI register and and matches the PHY OUI with the driver
list that it has. Quite similar to PCI or USB in fact.

> 
> How does one estimate the impact of driver changes in
> the eth PHY layer?

It's hard, because there are many Ethernet MACs and PHY drivers that are
all inter-operable with each other, which is both a blessing and a curse.

I completely understand what you want to solve but I suspect you will
have to do it in a way where you either accept that you may not be fully
compliant with the now clarified "phy-mode" description, in order not to
break other people's set up that were already non-compliant (can't blame
them, they did not know back then), or you will have to use additional
MAC properties to override the delay settings on the MAC or PHY side.
-- 
Florian
