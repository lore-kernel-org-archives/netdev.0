From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC
 level
Date: Fri, 4 Nov 2016 09:28:52 -0700
Message-ID: <b792b229-6126-c3a7-e071-bdd93fe51626@gmail.com>
References: <581CA300.1060609@laposte.net>
 <yw1xlgwzjmti.fsf@unicorn.mansr.com> <581CAB12.3030604@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: Sebastian Frias <sf84@laposte.net>,
        =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <581CAB12.3030604@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/04/2016 08:36 AM, Sebastian Frias wrote:
> Hi Måns,
> 
> On 11/04/2016 04:18 PM, Måns Rullgård wrote:
>> Sebastian Frias <sf84@laposte.net> writes:
>>
>>> The delay can be applied at PHY or MAC level, but since
>>> PHY drivers will apply the delay at PHY level when using
>>> one of the "internal delay" declinations of RGMII mode
>>> (like PHY_INTERFACE_MODE_RGMII_TXID), applying it again
>>> at MAC level causes issues.
>>
>> The Broadcom GENET driver does the same thing.
>>
> 
> Well, I don't know who uses that driver, or why they did it that way.

I do use this driver and it works for me (tm), although I tested mostly
with Broadcom PHYs and Ethernet switches, rarely with third party PHYs,
but had that too, but all of that is in tree though,
drivers/net/phy/broadcom.com, drivers/net/dsa/b53/ so feel free to
"audit" that part of the code too.

The configuration of the GENET port multiplexer requires us to specify
how we want to align the clock and data, if we don't do that, and the
PHY is also not agreeing with how its own delays should be configured,
mayhem ensues, ranging from occasional transmit success, to high rates
of CRC/FCS errors in best cases.

I did verify that the settings were correct using a scope FWIW.

> 
> However, with the current code and DT bindings, if one requires
> the delay, phy-connection-type="rgmii-txid" must be set.

Yes, and we would set it correctly for our Broadcom reference boards
using this driver.

> 
> But when doing so, both the Atheros 8035 and the Aurora NB8800 drivers
> will apply the delay.
> 
> I think a better way of dealing with this is that both, PHY and MAC
> drivers exchange information so that the delay is applied only once.

Exchange what information? The PHY device interface (phydev->interface)
conveys the needed information for both entities.

> 
> I can see how to do that in another patch set.
> 
>>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>>> ---
>>>  drivers/net/ethernet/aurora/nb8800.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>>> index b59aa35..d2855c9 100644
>>> --- a/drivers/net/ethernet/aurora/nb8800.c
>>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>>> @@ -1282,7 +1282,7 @@ static int nb8800_tangox_init(struct net_device *dev)
>>>  		break;
>>>
>>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>>> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>>> +		pad_mode = PAD_MODE_RGMII;
>>>  		break;
>>>
>>>  	default:
>>> -- 
>>> 1.7.11.2
>>
>> If this change is correct (and I'm not convinced it is), that case
>> should be merged with the one above it and PHY_INTERFACE_MODE_RGMII_RXID
>> added as well.
>>
> 
> I can do a single patch.
> 
> The reason I made two patches was that it was clear what this patch
> does, i.e.: do not apply the delay at MAC level, and what the subsequent
> patch does, i.e.: handle all RGMII declinations.
> 
> Best regards,
> 
> Sebastian
> 

-- 
Florian
