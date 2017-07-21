From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 3/4] net: ethernet: nb8800: Fix RGMII TX clock delay
 setup
Date: Fri, 21 Jul 2017 11:15:49 -0700
Message-ID: <31862e0c-398a-3e54-656d-bb43eb03c79d@gmail.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
 <5a68bec8-0b1d-bcfe-65fb-b10399ec75be@sigmadesigns.com>
 <yw1xy3riosag.fsf@mansr.com>
 <53fbf5e1-8d37-9734-be3f-77128ada9dfb@sigmadesigns.com>
 <yw1xtw25q4vb.fsf@mansr.com>
 <168bfa24-1dfe-e389-ab75-367e6bd2141a@sigmadesigns.com>
 <yw1xpoctq34z.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:38628 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdGUSQD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 14:16:03 -0400
Received: by mail-wm0-f65.google.com with SMTP id 143so7788062wmu.5
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 11:16:03 -0700 (PDT)
In-Reply-To: <yw1xpoctq34z.fsf@mansr.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2017 07:24 AM, Måns Rullgård wrote:
> Marc Gonzalez <marc_gonzalez@sigmadesigns.com> writes:
> 
>> On 21/07/2017 15:47, Måns Rullgård wrote:
>>
>>> Marc Gonzalez wrote:
>>>
>>>> On 21/07/2017 15:04, Måns Rullgård wrote:
>>>>
>>>>> Marc Gonzalez wrote:
>>>>>
>>>>>> According to commit e5f3a4a56ce2a707b2fb8ce37e4414dcac89c672
>>>>>> ("Documentation: devicetree: clarify usage of the RGMII phy-modes")
>>>>>> there are 4 RGMII modes to handle:
>>>>>>
>>>>>> "rgmii" (RX and TX delays are added by the MAC when required)
>>>>>> "rgmii-id" (RGMII with internal RX and TX delays provided by the PHY,
>>>>>> 	the MAC should not add the RX or TX delays in this case)
>>>>>> "rgmii-rxid" (RGMII with internal RX delay provided by the PHY,
>>>>>> 	the MAC should not add an RX delay in this case)
>>>>>> "rgmii-txid" (RGMII with internal TX delay provided by the PHY,
>>>>>> 	the MAC should not add an TX delay in this case)
>>>>>>
>>>>>> Add TX delay in the MAC only for rgmii and rgmii-rxid.
>>>>>>
>>>>>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>>>>>> ---
>>>>>>  drivers/net/ethernet/aurora/nb8800.c | 6 ++++--
>>>>>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>>>>>
>>>>>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>>>>>> index ded041dbafe7..f3ed320eb4ad 100644
>>>>>> --- a/drivers/net/ethernet/aurora/nb8800.c
>>>>>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>>>>>> @@ -1268,11 +1268,13 @@ static int nb8800_tangox_init(struct net_device *dev)
>>>>>>  		break;
>>>>>>
>>>>>>  	case PHY_INTERFACE_MODE_RGMII:
>>>>>> -		pad_mode = PAD_MODE_RGMII;
>>>>>> +	case PHY_INTERFACE_MODE_RGMII_RXID:
>>>>>> +		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>>>>>>  		break;
>>>>>>
>>>>>> +	case PHY_INTERFACE_MODE_RGMII_ID:
>>>>>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>>>>>> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>>>>>> +		pad_mode = PAD_MODE_RGMII;
>>>>>>  		break;
>>>>>>
>>>>>>  	default:
>>>>>
>>>>> I still don't like this.  Having both the MAC and PHY drivers react to
>>>>> the phy-connection-type property is bound to cause trouble somewhere.
>>>>>
>>>>> The only way out of the current mess is to define new properties for
>>>>> both MAC and PHY that override the existing ones if present.
>>>>
>>>> Do you mean defining 4 new bindings and their corresponding
>>>> phy_interface_t enum values? For example:
>>>>
>>>> "rgmii-v2"
>>>> "rgmii-id-v2"
>>>> "rgmii-rxid-v2"
>>>> "rgmii-txid-v2"
>>>>
>>>> 	PHY_INTERFACE_MODE_RGMII_V2,
>>>> 	PHY_INTERFACE_MODE_RGMII_ID_V2,
>>>> 	PHY_INTERFACE_MODE_RGMII_RXID_V2,
>>>> 	PHY_INTERFACE_MODE_RGMII_TXID_V2,
>>>>
>>>> And then handling these new enums in the at803x and nb8800 drivers?
>>>
>>> It has already been suggested to add new properties specifying desired
>>> delays in picoseconds.  If present on the MAC node, the MAC driver
>>> should attempt to provide the delay, and if present on the PHY node, the
>>> PHY driver is responsible.
>>
>> Sorry, I had already forgotten about Florian's suggestion:
>>> If you introduced PHY and/or MAC specific properties to configure the
>>> delays in the appropriate unit of time (say ps), you could use a
>>> non-compliant 'phy-mode' just to satisfy the driver/PHY library and
>>> still override the delays you need.
>>
>> So we would need two properties (RX and TX).
>> "rgmii_rx_skew_ps" and "rgmii_tx_skew_ps"
>>
>> but it's not clear to me how the MAC probe function communicates
>> the arguments to the phy driver. Looks like we would need to add
>> two fields to struct phy_device, and maybe define a new phy-mode
>> to instruct the PHY driver to look for the two fields.
> 
> There's no need for the drivers to communicate.  The location of the
> properties in the device tree determines which driver should deal with
> it.

Exactly. I really like how the PHY delay properties are defined in
Documentation/devicetree/bindings/net/micrel-ksz90x1.txt because they
are quite generic and for a MAC counterpart those defined in
Documentation/devicetree/bindings/net/dwmac-sun8i.txt and
Documentation/devicetree/bindings/net/meson-dwmac.txt are also good
examples.

> 
>> I don't have time to work on that for now, but I do need to
>> fix the nb8800 driver now. Can we apply the following patch
>> in the interim?
>>
>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>> index ded041dbafe7..e94159507847 100644
>> --- a/drivers/net/ethernet/aurora/nb8800.c
>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>> @@ -1268,11 +1268,10 @@ static int nb8800_tangox_init(struct net_device *dev)
>>                 break;
>>
>>         case PHY_INTERFACE_MODE_RGMII:
>> -               pad_mode = PAD_MODE_RGMII;
>> -               break;
>> -
>> +       case PHY_INTERFACE_MODE_RGMII_ID:
>> +       case PHY_INTERFACE_MODE_RGMII_RXID:
>>         case PHY_INTERFACE_MODE_RGMII_TXID:
>> -               pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>> +               pad_mode = PAD_MODE_RGMII;
>>                 break;
>>
>>         default:
> 
> Simply stop reacting to the delay aspect of the phy-connection-type
> property?  Yes, I'm fine with that.
> 


-- 
Florian
