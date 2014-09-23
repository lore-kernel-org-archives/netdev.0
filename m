From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 3/9] Documentation: bindings: net: add the Marvell
 PXA168 Ethernet controller
Date: Tue, 23 Sep 2014 19:31:40 +0200
Message-ID: <5421AE7C.30504@gmail.com>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com> <9401592.hUYDkriFVO@wuerfel> <5421A28E.7060600@gmail.com> <5150779.ibmzDh88cj@wuerfel>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5150779.ibmzDh88cj@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/23/2014 07:02 PM, Arnd Bergmann wrote:
> On Tuesday 23 September 2014 18:40:46 Sebastian Hesselbarth wrote:
>> On 09/23/2014 06:29 PM, Arnd Bergmann wrote:
>>> On Tuesday 23 September 2014 17:45:52 Sebastian Hesselbarth wrote:
>>>> For reference, this is what we have for MVEBU SoCs with multiple ports
>>>> per controller:
>>>>
>>>> eth: ethernet-ctrl@72000 {
>>>>           compatible = "marvell,orion-eth";
>> ...
>>>>           reg = <0x72000 0x4000>;
>> ...
>>>>
>>>>           ethernet-port@0 {
>>>>                   compatible = "marvell,orion-eth-port";
>> ...
>>>>                   phy-handle = <&ethphy>;
>>>>           };
>>>> };
>>>>
>>>> mdio: mdio-bus@72004 {
>>>>           compatible = "marvell,orion-mdio";
>> ...
>>>>           reg = <0x72004 0x84>;
>> ..
>>>>           ethphy: ethernet-phy {
>>>>                   /* set phy address in board file */
>>>>           };
>>>> };
>>
>>> But in this example, you have the same registers and the same
>>> clocks in two nodes, which are even used by the same device driver
>>> at the moment. It's not a big issue, but my feeling is that Antoine's
>>> approach was actually better because it more closely reflects
>>> the way that the hardware is built.
>>
>> I was not referring to the separate mdio bus node, but putting the
>> ethernet-phy node as a child of ethernet-ctrl.
>
> Ah, got it (I think). Yes, that makes sense.

> The part I don't understand yet is how one uses multiple ports. pxa168_eth.c
> seems to be written with the assumption that only one port is ever used at
> a time, while mv643xx_eth.c can actually use multiple ports simultaneously.
>
> Do you think that is that a hardware limitation of pxa168_eth or a feature
> that nobody so far has needed from the driver?

It has been a while I looked it up in the pxa168 datasheet, but IIRC
there is only one port per controller. FWIW, there actually is also
just one port per controller for Orion SoCs. The multiple ports per
controller comes from the PPC system controllers, i.e. mv643xx hence
the name. We just made the binding look like it is more ports available
to make it backwards compatible.. although I doubt anyone is still using
mv643xx anywhere.

> If there is only one port and we just have to know which one that is,
> I don't think we need the child nodes, but if one can have multiple
> ports operate independently then the driver will need a rework
> to actually be usable with that configuration.

I doubt pxa168 needs port nodes at all, i.e. we have the phy-handle
directly as property of the controller node.

The HEC PHY node itself will be a sub-node of some future CEC node,
while the (internal) MII PHY node can stay as a sub-node of the
controller, e.g.

(one final example to make sure we agree on the same)

eth0: ethernet@f7b90000 {
	compatible = "marvell,pxa168-eth";
	reg = <...>;
	#address-cells = <1>;
	#size-cells = <0>;
	phy-handle = <&ethphy0>;

	ethphy0: ethernet-phy@0 {
		reg = <0>;
	};
};

cec0: cec@f7f00baa {
	compatible = "marvell,berlin-cec";
	reg = <...>;
	#address-cells = <1>;
	#size-cells = <0>;
	
	hecphy0: hdmi-ethernet-phy@0 {
		reg = <0>;
	};
};

With berlin2cd-google-chromecast.dts overwriting

&eth0 { phy-handle = <&hecphy0>; };

Sebastian

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
