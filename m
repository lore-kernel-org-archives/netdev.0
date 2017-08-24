From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Thu, 24 Aug 2017 12:59:07 -0700
Message-ID: <dfc8e7f3-e374-b30b-b320-017f1c50ab58@gmail.com>
References: <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
 <20170821132015.GB1703@lunn.ch> <20170821133104.qvrhvwin2rdg4aqo@flea.lan>
 <20170821142321.GE1703@lunn.ch>
 <CAGb2v64E4T=1ff3POGuXZA=MvjGAnKQ6OF6A3sT_cU-=jh6zNw@mail.gmail.com>
 <bfe784b6-5137-8fcd-dbd0-ad96974f4060@gmail.com> <20170822181140.GA11596@Red>
 <352ae66b-78a4-e88b-4544-a8edd9390b0c@gmail.com>
 <20170823074942.yt3c5gvnmdw5pqge@flea.home>
 <f14fe754-6339-32a0-3439-2daff6dd1d7e@gmail.com> <20170824082124.GA14302@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170824082124.GA14302@Red>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/24/2017 01:21 AM, Corentin Labbe wrote:
> On Wed, Aug 23, 2017 at 09:31:53AM -0700, Florian Fainelli wrote:
>> On 08/23/2017 12:49 AM, Maxime Ripard wrote:
>>> Hi Florian,
>>>
>>> On Tue, Aug 22, 2017 at 11:35:01AM -0700, Florian Fainelli wrote:
>>>>>>> So I think what you are saying is either impossible or engineering-wise
>>>>>>> a very stupid design, like using an external MAC with a discrete PHY
>>>>>>> connected to the internal MAC's MDIO bus, while using the internal MAC
>>>>>>> with the internal PHY.
>>>>>>>
>>>>>>> Now can we please decide on something? We're a week and a half from
>>>>>>> the 4.13 release. If mdio-mux is wrong, then we could have two mdio
>>>>>>> nodes (internal-mdio & external-mdio).
>>>>>>
>>>>>> I really don't see a need for a mdio-mux in the first place, just have
>>>>>> one MDIO controller (current state) sub-node which describes the
>>>>>> built-in STMMAC MDIO controller and declare the internal PHY as a child
>>>>>> node (along with 'phy-is-integrated'). If a different configuration is
>>>>>> used, then just put the external PHY as a child node there.
>>>>>>
>>>>>> If fixed-link is required, the mdio node becomes unused anyway.
>>>>>>
>>>>>> Works for everyone?
>>>>>
>>>>> If we put an external PHY with reg=1 as a child of internal MDIO,
>>>>> il will be merged with internal PHY node and get
>>>>> phy-is-integrated.
>>>>
>>>> Then have the .dtsi file contain just the mdio node, but no internal or
>>>> external PHY and push all the internal and external PHY node definition
>>>> (in its entirety) to the per-board DTS file, does not that work?
>>>
>>> If possible, I'd really like to have the internal PHY in the
>>> DTSI. It's always there in hardware anyway, and duplicating the PHY,
>>> with its clock, reset line, and whatever info we might need in the
>>> future in each and every board DTS that uses it will be very error
>>> prone and we will have the usual bunch of issues that come up with
>>> duplication.
>>
>> OK, then what if you put the internal PHY in the DTSI, mark it with a
>> status = "disabled" property, and have the per-board DTS put a status =
>> "okay" property along with a "phy-is-integrated" boolean property? Would
>> that work?
> 
> No, I tested and for example with sun8i-h3-orangepi-plus.dts, the external PHY (ethernet-phy@1) is still merged.

Is not there is a mistake in the unit address not matching the "reg"
property, or am I not looking at the right tree?

&mdio {
        ext_rgmii_phy: ethernet-phy@1 {
                compatible = "ethernet-phy-ieee802.3-c22";
                reg = <0>;
        };
};

If the PHY is really at MDIO address 0, then it should be
ethernet-phy@0, and not ethernet-phy@1, and then no problem with the
merging?


> So that adding a 'status = "disabled"' does not bring anything.
> 
>>
>> What I really don't think is necessary is:
>>
>> - duplicating the "mdio" controller node for external vs. internal PHY,
>> because this is not accurate, there is just one MDIO controller, but
>> there may be different kinds of MDIO/PHY devices attached
> 
> For me, if we want to represent the reality, we need two MDIO:
> - since two PHY at the same address could co-exists
> - since they are isolated so not on the same MDIO bus

Is that really true? It might be, but from experience with e.g:
bcmgenet, the integrated PHY and the external PHYs are on the same MDIO
bus, which is convenient, except when you have an address conflict.

> 
>> - having the STMMAC driver MDIO probing code having to deal with a
>> "mdio" sub-node or an "internal-mdio" sub-node because this is confusing
>> and requiring more driver-level changes that are error prone
> 
> My patch for stmmac is really small, only the name of my variable ("need_mdio_mux_ids")
> have to be changed to something like "register_parent_mdio"
> 
> 
> So I agree with Maxime, we need to avoid merging PHY nodes, and we can avoid it only by having two separate MDIO nodes.
> Furthermore, with only one MDIO, we will face with lots of small patch for adding phy-is-integrated, with two we do not need to change any board DT, all is simply clean.
> Really having two MDIO seems cleaner.

The only valid thing that you have provided so far is this merging
problem. Anything else ranging from "we will face with lots of small
patch for adding phy-is-integrated" to "Really having two MDIO seems
cleaner." are hard to receive as technical arguments for correctness.

What happens if someone connects an external PHY at the same MDIO
address than the internal PHY, which one do you get responses from? If
you shutdown the internal PHY and it stops responding, then this
probably becomes deterministic, but it still supports the fact there is
just one MDIO bus controller per MAC.

Anyway, do whatever works best for you I guess.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
