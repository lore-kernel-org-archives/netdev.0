From: Sebastian Frias <sf84-QFKgK+z4sOrR7s880joybQ@public.gmane.org>
Subject: Re: [net-next PATCH v1 0/2] stmmac: dwmac-meson8b: configurable RGMII
 TX delay
Date: Mon, 28 Nov 2016 11:34:13 +0100
Message-ID: <6dfb67a8-2825-6256-3244-c99316531885@laposte.net>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
 <1480002964.17538.131.camel@baylibre.com>
 <CAFBinCB7sXjXor++W+PW0-j_VxATRzhexjqHgXj2jD10tBpZFg@mail.gmail.com>
 <e6ca0941-e2e3-dd93-d4d3-8fbd76b60e17@gmail.com>
 <6a6af561-4e83-ca6e-d989-f421e18bce1e@laposte.net>
 <1b7f113e-34f9-69f4-a45f-9fd687d87990@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        peppe.cavallaro-qxv4g6HH51o@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org,
        Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        mason <slash.tmp-GANU6spQydw@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1b7f113e-34f9-69f4-a45f-9fd687d87990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 25/11/16 18:44, Florian Fainelli wrote:
> On 11/25/2016 03:13 AM, Sebastian Frias wrote:
>> On 24/11/16 19:55, Florian Fainelli wrote:
<snip>
>>> Correct, the meaning of PHY_INTERFACE_MODE should be from the
>>> perspective of the PHY device:
>>>
>>> - PHY_INTERFACE_MODE_RGMII_TXID means that the PHY is responsible for
>>> adding a delay when the MAC transmits (TX MAC -> PHY (delay) -> wire)
>>> - PHY_INTERFACE_MODE_RGMII_RXID means that the PHY is responsible for
>>> adding a delay when the MAC receives (RX MAC <- (delay) PHY) <- wire)
>>>
>>
>> Thanks for the explanation.
>> Actually I had thought that the delay was to account for board routing
>> (wires) between the MAC and the PHY.
>> From your explanation it appears that the delay is to account for board
>> routing (wires) between the PHY and the RJ45 socket.
> 
> The placement of the (delay) was not meant to be exact, but it was
> wrongly place anyway, so it should be between the MAC and PHY, always.
> This is why you see people either fixing the need for a delay by
> appropriately programming the PHY, or the MAC, or by just inserting a
> fixed delay on the PCB between the PHY and the MAC and programming no
> delays (or using the default values and hoping this works).

Thanks.
Your patch "[PATCH net-next 3/4] Documentation: net: phy: Add blurb about
RGMII" on the documentation makes it clear.

>>>
>>> This also seems reasonable to do, provided that the PHY is also properly
>>> configured not to add delays in both directions, and therefore assumes
>>> that the MAC does it.
>>>
>>> We have a fairly large problem with how RGMII delays are done in PHYLIB
>>> and Ethernet MAC drivers (or just in general), where we can't really
>>> intersect properly what a PHY is supporting (in terms of internal
>>> delays), and what the MAC supports either. One possible approach could
>>> be to update PHY drivers a list of PHY_INTERFACE_MODE_* that they
>>> support (ideally, even with normalized nanosecond delay values), 
>>
>> Just to make sure I understood this, the DT would say something like:
>>
>> phy-connection-type = "rgmii-txid";
>> txid-delay-ns = <3>;
>>
>> For a 3ns TX delay, would that be good?
> 
> That's one possibility, although, see below, some PHYs support
> sub-nanosecond values, but in general, that seems like a good
> representation. If the "txid-delay-ns" property is omitted, a standard
> 2ns delay is assumed.

Sounds good.
I did not see the "txid-delay-ns" property documented in your patches, if
it is not too late, maybe it could be "txid-delay-ps" using picoseconds as
unit, right?

>>> and
>>> then intersect that with the requested phy_interface_t during
>>> phy_{attach,connect} time, and feed this back to the MAC with a special
>>> error code/callback, so we could gracefully try to choose another
>>> PHY_INTERFACE_MODE_* value that the MAC supports....
>>>
>>> A larger problem is that a number of drivers have been deployed, and
>>> Device Trees, possibly with the meaning of "phy-mode" and
>>> "phy-connection-type" being from the MAC perspective, and not the PHY
>>> perspective *sigh*, good luck auditing those.
>>>
>>> So from there, here is possibly what we could do
>>>
>>> - submit a series of patches that update the PHYLIB documentation (there
>>> are other things missing here) and make it clear from which entity (PHY
>>> or MAC) does the delay apply to, document the "intersection" problem here
>>
>> I think documenting is necessary, thanks in advance!
>>
>> However, I'm wondering if there's a way to make this work in all cases.
>> Indeed, if we consider for example that TX delay is required, we have 4
>> cases:
>>
>>        PHY         |       MAC          | Who applies?
>> TXID supported     | TXID supported     | PHY
>> TXID supported     | TXID not supported | PHY
>> TXID not supported | TXID supported     | MAC
>> TXID not supported | TXID not supported | cannot be done
>>
>> That is basically what my patch:
>>
>> https://marc.info/?l=linux-netdev&m=147869658031783&w=2
>>
>> attempted to achieve. That would allow more combinations of MAC<->PHY to
>> work, right?
> 
> Yes, indeed.

Just one thing, from your patch "[PATCH net-next 3/4] Documentation: net:
phy: Add blurb about RGMII" I have the impression that the 3rd option from
the table above, would be a little bit more complex to implement.

I will comment on the patch.

>> Nevertheless, I think we also need to keep in mind that most of this
>> discussion assumes the case where both, MAC and PHY have equal capabilities.
>> Could it happen that the PHY supports only 2ns delay, and the MAC only
>> 1ns delay?
> 
> I doubt this exists at the MAC level what we should have is either a 2ns
> delay, in either RX or TX path, or nothing, because that's the value
> that results in shifting the data lines and the RX/TX lines by 90
> degrees at 125Mhz (1/125^6 = 8 ns, one quarter shift is 90 degrees =
> 2ns). The PHY may have a similar set of pre-programmed, fixed 2ns
> delays, but it is not uncommon to see 0.X ns resolution available:
> 
> drivers/net/phy/mscc.c
> drivers/net/phy/dp83867.c w/ arch/arm/boot/dts/dra72-evm-revc.dts
> 
> In these cases, if you end-up using a non 2ns delay, you are fixing a
> PCB problem more than an interoperability problem between your MAC and PHY.

I see, thanks.

>> Could it happen that the delay is bigger than what is supported by
>> either the PHY or MAC alone? maybe if combined it could work, for example
>> a 3ns delay required and the PHY supporting 2ns and the MAC 1ns, combined
>> it could work?
> 
> I suppose such a thing would work yes, but it would be difficult to
> report correctly to the core PHYLIB how this can work considering the
> vast array of options available to introduce delays in that case:
> MAC-level, PHY-level, pinctrl/pad level and possibly at the PCB itself.
> 
> Once we can't rely on the fixed 2ns delay to work, we are going to have
> people do various experiments until they can either measure what the
> right delay value is for the specific PCB, or they just found the value
> that happens to work. I don't think we can do much at that point from a
> core PHYLIB perspective other than tell the network driver that the PHY
> supports delay in either RX, TX or both directions, and have the MAC
> decide what to apply that makes sense here, considering that this is
> already kind of an exceptional situation to be in.


Fair enough.

And thanks again for documenting this.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
