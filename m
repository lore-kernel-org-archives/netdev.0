From: Olof Johansson <olof@lixom.net>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 09:23:29 -0800
Message-ID: <CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com>
References: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
	<20160126044624.GH3880@lunn.ch>
	<20160126121435.GK22974@ak-desktop.emea.nsn-net.net>
	<20160126133417.GI3880@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aaro Koskinen <aaro.koskinen@nokia.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:36288 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966830AbcAZRXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 12:23:30 -0500
Received: by mail-yk0-f182.google.com with SMTP id v14so208020148ykd.3
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 09:23:29 -0800 (PST)
In-Reply-To: <20160126133417.GI3880@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 26, 2016 at 5:34 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, Jan 26, 2016 at 02:14:35PM +0200, Aaro Koskinen wrote:
>> Hi,
>>
>> On Tue, Jan 26, 2016 at 05:46:24AM +0100, Andrew Lunn wrote:
>> > On Mon, Jan 25, 2016 at 05:45:21PM +0200, Aaro Koskinen wrote:
>> > > I get the below crash on OCTEON (with octeon_mgmt interface, genphy)
>> > > always during systemd boot.
>> >
>> > I think i know what is going on now.
>> >
>> > What does your phy look like in DT?
>>
>> It's using the in-kernel DT:
>>
>>       arch/mips/boot/dts/cavium-octeon/octeon_3xxx.dts
>>
>> The management interface is "mix0: ethernet@1070000100000". The phy entry
>> might be bogus for this specific board, and I don't have MARVELL_PHY
>> enabled...
>
>                         phy1: ethernet-phy@1 {
>                                 cavium,qlm-trim = "4,sgmii";
>                                 reg = <1>;
>                                 compatible = "marvell,88e1149r";
>                                 marvell,reg-init = <3 0x10 0 0x5777>,
>                                         <3 0x11 0 0x00aa>,
>                                         <3 0x12 0 0x4105>,
>                                         <3 0x13 0 0x0a60>;
>                         };
>
> Dove Cubox is the other board which Olof has problems with. It has
>
> &ethphy {
>         compatible = "marvell,88e1310";
>         reg = <1>;
> };
>
> The issue here is the compatible string. The binding says:
>
> Optional Properties:
>
> - compatible: Compatible list, may contain
>   "ethernet-phy-ieee802.3-c22" or "ethernet-phy-ieee802.3-c45" for
>   PHYs that implement IEEE802.3 clause 22 or IEEE802.3 clause 45
>   specifications. If neither of these are specified, the default is to
>   assume clause 22. The compatible list may also contain other
>   elements.
>
>   If the phy's identifier is known then the list may contain an entry
>   of the form: "ethernet-phy-idAAAA.BBBB" where
>      AAAA - The value of the 16 bit Phy Identifier 1 register as
>             4 hex digits. This is the chip vendor OUI bits 3:18
>      BBBB - The value of the 16 bit Phy Identifier 2 register as
>             4 hex digits. This is the chip vendor OUI bits 19:24,
>             followed by 10 bits of a vendor specific ID.
>
> We are in a grey area, it does not say you can specifically exactly
> what PHY you have, but it also does not rule it out, since "may also
> contain other elements".
>
> When adding support for generic MDIO device, like switches, i have to
> differentiate between PHYs and generic MDIO devices in DT. What i
> implemented is:
>
> /*
>  * Return true if the child node is for a phy. It must either:
>  * o Compatible string of "ethernet-phy-idX.X"
>  * o Compatible string of "ethernet-phy-ieee802.3-c45"
>  * o Compatible string of "ethernet-phy-ieee802.3-c22"
>  * o No compatibility string
>  *
>  * A device which is not a phy is expected to have a compatible string
>  * indicating what sort of device it is.
>  */
> static bool of_mdiobus_child_is_phy(struct device_node *child)
> {
>
> The last rule is the issue. Before this patch, saying
> "marvell,88e1149r" would be totally ignored, never used. The PHY
> drivers don't have an of_device_id table to match against.  Now it
> means the device is a generic MDIO device, and use the compatible
> string to find the correct driver for it.
>
> The first part of the fix is clear. If we have a generic MDIO device,
> but somebody asks for a PHY device, return an error. I've not checked
> the code paths yet, but i expect the generic MDIO device is being
> returned, container_of() into a phydev, and then the non-existent
> mutex is lock. The code already have a flag to indicate if it is a PHY
> or not, so it looks like a check is missing somewhere.
>
> The harder problem, is what to do with these compatible strings, and
> how to decide if we have a generic MDIO device, or a PHY. Grep'ing the
> DTS files, it seems to be an issue for octeon_68xx.dts,
> octeon_3xxx.dts, k2e-evm.dts, k2he-evm.dts, k2l-evm.dts,
> kirkwood-dockstar.dts, moxart-uc7112lx.dts, dove-cubox.dts and maybe
> others my grep foo missed.
>
> This is too many to ignore. Having a useless compatible string for a
> PHY needs to be supported. So i guess i need a bool property,
> "generic-mdio", and assume anything without that is a PHY.
>
> Florian, are you O.K. with this?

General solution of having a boolean property to indicate that the
mdio device is not a phy sounds good to me. Alternatively, have a
generic compatible that all non-phys must set (same way as you're
expecting the ethernet-phy-id* above). Either way is alright with me.

I hate to bikeshed, but I'm not sure if "generic-mdio" is too...
generic? Will someone writing a DT be thinking "well, this is a
generic mdio PHY, I should set it"?  "mdio-device"?
"generic-nonphy-mdio"? Neither of those seem much better.


-Olof
