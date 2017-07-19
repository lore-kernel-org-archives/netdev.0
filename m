From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH 2/2] net: ethernet: nb8800: Fix RGMII TX clock delay setup
Date: Wed, 19 Jul 2017 23:15:42 +0200
Message-ID: <05cbc32e-a4af-1c81-128b-bc5d2206d24a@free.fr>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
 <61b71d12-4e3a-edbe-1d69-c66e7cf46d8e@sigmadesigns.com>
 <yw1xzic0qrcg.fsf@mansr.com> <001a7afd-364d-359e-1478-e057c9083f73@free.fr>
 <d8121f82-dffd-22c7-1209-a3c2329703e5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
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
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:2674 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753888AbdGSVQV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 17:16:21 -0400
In-Reply-To: <d8121f82-dffd-22c7-1209-a3c2329703e5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/07/2017 20:30, Florian Fainelli wrote:
> On 07/19/2017 10:36 AM, Mason wrote:
>> On 19/07/2017 19:17, Måns Rullgård wrote:
>>
>>> Marc Gonzalez writes:
>>>
>>>> According to commit e5f3a4a56ce2a707b2fb8ce37e4414dcac89c672
>>>> ("Documentation: devicetree: clarify usage of the RGMII phy-modes")
>>>> there are 4 RGMII phy-modes to handle:
>>>>
>>>> "rgmii" (RX and TX delays are added by the MAC when required)
>>>> "rgmii-id" (RGMII with internal RX and TX delays provided by the PHY,
>>>> 	the MAC should not add the RX or TX delays in this case)
>>>> "rgmii-rxid" (RGMII with internal RX delay provided by the PHY,
>>>> 	the MAC should not add an RX delay in this case)
>>>> "rgmii-txid" (RGMII with internal TX delay provided by the PHY,
>>>> 	the MAC should not add an TX delay in this case)
>>>>
>>>> Let the MAC handle TX clock delay for rgmii and rgmii-rxid.
>>>>
>>>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>>>> ---
>>>>  drivers/net/ethernet/aurora/nb8800.c | 8 +++++---
>>>>  1 file changed, 5 insertions(+), 3 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>>>> index 041cfb7952f8..f3ed320eb4ad 100644
>>>> --- a/drivers/net/ethernet/aurora/nb8800.c
>>>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>>>> @@ -609,7 +609,7 @@ static void nb8800_mac_config(struct net_device *dev)
>>>>  		mac_mode |= HALF_DUPLEX;
>>>>
>>>>  	if (gigabit) {
>>>> -		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
>>>> +		if (phy_interface_is_rgmii(dev->phydev))
>>>>  			mac_mode |= RGMII_MODE;
>>>>
>>>>  		mac_mode |= GMAC_MODE;
>>>
>>> This is a separate issue, and the change is obviously correct.
>>>
>>>> @@ -1268,11 +1268,13 @@ static int nb8800_tangox_init(struct net_device *dev)
>>>>  		break;
>>>>
>>>>  	case PHY_INTERFACE_MODE_RGMII:
>>>> -		pad_mode = PAD_MODE_RGMII;
>>>> +	case PHY_INTERFACE_MODE_RGMII_RXID:
>>>> +		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>>>>  		break;
>>>>
>>>> +	case PHY_INTERFACE_MODE_RGMII_ID:
>>>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>>>> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>>>> +		pad_mode = PAD_MODE_RGMII;
>>>>  		break;
>>>
>>> Won't this just make it break in a different set of circumstances?
>>
>> I don't think so, and here's my reasoning:
>>
>> AFAIU, the HW block always requires a TX clock delay
>> (I don't know what the "safe" interval is. PHY adds
>> 2.4 ns, MAC adds ~1 ns, both work.)
> 
> The nominal delay should be 2ns because that's exactly what a 90 degrees
> shift at a 125Mhz would be. The RGMII specification defines the following:
> 
> TskewT - Data to Clock output Skew (At Transmitter) Min: -500ns, Nom: 0,
> Max: + 500 ns
> TskewR - Data to Clock input Skew (At Receiver) Min: 1ns, Nom: 0, Max:
> 2.6ns (see note 1)
> 
> note 1: This implies that PC board design will require clocks to be
> routed such that an additional trace delay of greater than 1.5ns and
> less than 2.0ns will be added to the associated clock signal. For 10/100
> the Max value is unspecified.
> 
> So it seems to me like you are borderline spec in both delays you gave
> here and the "HW block always requires a TX clock delay" statement is
> true for a given board design only.

I must confess that my understanding of clock delays,
clock skew, routing, traces, etc is nil.

Is TskewT the TX clock delay?
And TskewR the RX clock delay?

Doesn't wire delay factor in too?
(So longer wires require more delay.)

>> RX clock delay seems to be "Don't Care" (tested both
>> enabled and disabled by PHY)
>> By "tested", I mean ability to ping remote system.
> 
> Can you do something a bit more stressful than just a ping, also if you
> have the ability to change the inter-packet gap, do it, and see if you
> start seeing FCS or any other decoding errors.

Errr... "Inter-packet gap"?
Is there supposed to be a HW knob to tweak how long
the HW waits between sending two frames?

>> If phy-mode is RGMII or RGMII_RXID, then don't add
>> TX clock delay from PHY, therefore add it from MAC.
>>
>> If phy_mode is RGMII_ID or RGMII_TXID, then do add
>> TX clock delay from PHY, therefore don't add it from MAC.
>>
>> What set of circumstances would create an issue?
> 
> Existing Device Tree sources that do not correspond to that description
> you just did, I suppose they are all out of tree?

The problem with PHY drivers is that there is no
simple compatible string to grep for.

The tango boards use "ethernet-phy-id004d.d072"
but not a single other DT uses that string.
For example, am335x-evm.dts doesn't seem to name the PHY.
Hmmm, how does the at803x probe function match for that
board?

How does one estimate the impact of driver changes in
the eth PHY layer?

Regards.
