From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 00/26] Phylink & SFP support
Date: Sun, 27 Dec 2015 18:08:03 -0800
Message-ID: <25790BAC-5B24-4702-87AF-0772F12630E3@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <20151215072621.GA6953@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Dustin Byford <dustin@cumulusnetworks.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34380 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbbL1CIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 21:08:10 -0500
Received: by mail-pa0-f49.google.com with SMTP id uo6so80401456pac.1
        for <netdev@vger.kernel.org>; Sun, 27 Dec 2015 18:08:09 -0800 (PST)
In-Reply-To: <20151215072621.GA6953@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On December 14, 2015 11:26:21 PM PST, Dustin Byford <dustin@cumulusnetworks.com> wrote:
>On Mon Dec 07 17:35, Russell King - ARM Linux wrote:
>> Hi,
>
>Hello.
>
>> SFP modules are hot-pluggable ethernet transceivers; they can be
>> detected at runtime and accordingly configured.  There are a range of
>> modules offering many different features.
>> 
>> Some SFP modules have PHYs conventional integrated into them, others
>> drive a laser diode from the Serdes bus.  Some have monitoring,
>others
>> do not.
>> 
>> Some SFP modules want to use SGMII over the Serdes link, others want
>> to use 1000base-X over the Serdes link.
>> 
>> This makes it non-trivial to support with the existing code
>structure.
>> Not wanting to write something specific to the mvneta driver, I
>decided
>> to have a go at coming up with something more generic.
>> 
>> My initial attempts were to provide a PHY driver, but I found that
>> phylib's state machine got in the way, and it was hard to support two
>> chained PHYs.  Conversely, having a fixed DT specified setup (via
>> the fixed phy infrastructure) would allow some SFP modules to work,
>but
>> not others.  The same is true of the "managed" in-band status (which
>> is SGMII.)
>> 
>> The result is that I came up with phylink - an infrastructure layer
>> which sits between the network driver and any attached PHY, and a
>> SFP module layer detects the SFP module, and configures phylink
>> accordingly.
>> 
>> Overall, this supports:
>> 
>> * switching the serdes mode at the NIC driver
>> * controlling autonegotiation and autoneg results
>> * allowing PHYs to be hotplugged
>> * allowing SFP modules to be hotplugged with proper link indication
>> * fixed-mode links without involving phylib
>> * flow control
>> * EEE support
>> * reading SFP module EEPROMs
>> 
>> Overall, phylink supports several link modes, with dynamic switching
>> possible between these:
>> * A true fixed link mode, where the parameters are set by DT.
>> * PHY mode, where we read the negotiation results from the PHY
>registers
>>   and pass them to the NIC driver.
>> * SGMII mode, where the in-band status indicates the speed, duplex
>and
>>   flow control settings of the link partner.
>> * 1000base-X mode, where the in-band status indicates only duplex and
>>   flow control settings (different, incompatible bit layout from
>SGMII.)
>
>I've been working on some similar code to handle interactions with a
>wide range of SFF modules, 1G to 100G, on Linux network switches for
>some time.  For practical reasons a lot of that was in userspace but
>I've been planning and recently working on an SFF kernel driver that
>does some of what's done in this series.  I think the model you're
>proposing is right on, and since you're further along in implementation
>I'd like to help round out support for the other SFF modules if I can.
>Then make this work on the network ASICs I have access to.
>
>Any concrete plans for QSFP or the new 25G modules?
>
>> Ethtool support is included, as well as emulation of the MII
>registers
>> for situations where a PHY is not attached, giving compatible
>emulation
>> of existing user interfaces where required.
>> 
>> The patches here include modification of mvneta (against 4.4-rc1, so
>> probably won't apply to current development tips.)  It basically
>> hooks into the places where the phylib would hook into.
>> 
>> DT wise, the changes needed to support SFP look like this (example
>> taken from Clearfog):
>> 
>>  			ethernet@34000 {
>> +				managed = "in-band-status";
>>  				phy-mode = "sgmii";
>>  				status = "okay";
>> -
>> -				fixed-link {
>> -					speed = <1000>;
>> -					full-duplex;
>> -				};
>>  			};
>> ...
>> +	sfp: sfp {
>> +		compatible = "sff,sfp";
>> +		i2c-bus = <&i2c1>;
>> +		los-gpio = <&expander0 12 GPIO_ACTIVE_HIGH>;
>> +		moddef0-gpio = <&expander0 15 GPIO_ACTIVE_LOW>;
>> +		sfp,ethernet = <&eth2>;
>
>Using &eth2 is unambiguous in the this case because there's only one
>serdes and one mac involved.  To specify the mac/serdes/cage
>associations at the same level of detail as the gpios it might be nice
>(at least for some devices) to point to a serdes node (or 4 in the case
>of QSFP) instead of &eth2.  Any thoughts on that?

Using a phandle here allows for quite a lot of flexibility on how you want to associate a given SFP to its data plane partner. I do not think we need to get more strict than that strictly mandate an actual Ethernet controller node. These Marvell adapters typically have one or more " ports", each of them being backed by a netdev. The same could be true with a switch properly modeled.

>Switch ASICs, and I imagine at least some NICs, are really flexible in
>terms of how serdes are wired to a cage.  Both in the sense that the
>board designer gets to pick which wires route to the cage based on
>physical constraints and the user gets to pick which serdes or group of
>serdes compose the ethernet device.  For example, using a breakout
>cable
>to get 4xSFP out of a QSFP or the other way around.
>
>Perhaps the simple case (sfp,ethernet -> &eth2) can remain simple, but
>I'd be interested in any thoughts you have on introducing a serdes
>layer here.
>
>I think adding such a layer would make it easier to 1) make serdes to
>cage mappings part of the platform description (DT or ACPI) and 2)
>allow
>automatic reconfiguration of the mac based on the SFF module.  For
>example, if a user plugs in a QSFP->4xSFP breakout cable why not
>automatically create four netdevs instead of one?

Would this be something you expect to happen dynamically? Not that this does not seem reasonable but would these netdevs serve a different purpose than being control endpoints, or would they become real logical netdevs with separate data planes at the MAC they would be linked to?

>
>> +		tx-disable-gpio = <&expander0 14 GPIO_ACTIVE_HIGH>;
>> +		tx-fault-gpio = <&expander0 13 GPIO_ACTIVE_HIGH>;
>> +	};
>> 
>> These DT changes are omitted from this patch set as the baseline DT
>> file is not in mainline yet (has been submitted.)
>
>Cool.  Do you have a link to the DT patches?
>
>
>In short, I think this is awesome, and I'd like to help where I can.
>I'll start by having a look at the rest of the series.  I'd like to
>apply it and see if I can make it work on one of my systems.
>
>Thanks,
>
>		--Dustin


-- 
Florian
