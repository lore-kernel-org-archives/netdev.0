From: Marc Bertola <marc.bertola@prolucid.ca>
Subject: Correct method for initializing Pause and Asymmetrical Pause support
 in phy drivers
Date: Thu, 12 Jan 2017 10:21:29 -0500
Message-ID: <CAMqDo0XxvtjD+uJQeHJuSyN71zEEa5AB9YE1CUYK8wq2NGeAbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36223 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdALPWK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:22:10 -0500
Received: by mail-oi0-f52.google.com with SMTP id u143so26085471oif.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 07:21:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev list,

I am currently investigating a problem related to Ethernet
auto-negotiation of Pause and Asymmetrical Pause capabilities.

TL;DR: I am using a Picozed system-on-module with a Xilinx Gigabit
Ethernet MAC and a Marvell PHY. It does not appear to be advertising
support for Pause and Asym Pause, which seems strange to me given that
this is relatively recent hardware. I suspect that may be due to a
problem in the way phydev->supported is initialized in
drivers/net/phy/marvell.c.

I am trying to confirm what the proper method is to initialize
phydev->supported such that it advertises SUPPORTED_Pause and
SUPPORTED_Asym_Pause.  Adding these flags to (phy_driver).features
seems to work, but I would like to confirm with people who are more
knowledgeable than me in this regard.

Read on for details about what I have observed and tried so far.

# The System #

The application I am working on uses Avnet's Picozed 7020
System-on-Module (SOM), which contains:
* An on-chip MAC (on a Xilinx Zynq 7000 chip)
* A Marvell 1512 Alaska PHY.
* A daughtercard that provides the actual RJ45 connector.

The Zynq is running a Xilinx fork of Linux. I am working with the
following drivers:

The MAC is the built-in Gigabit Ethernet MAC on a Xilinx Zynq 7000
chip. It uses the xemacps.c driver, which can be found on Xilinx's
official Linux fork:
* RAW: https://raw.githubusercontent.com/Xilinx/linux-xlnx/master/drivers/net/ethernet/xilinx/xilinx_emacps.c
* GITHUB: https://github.com/Xilinx/linux-xlnx/blob/master/drivers/net/ethernet/xilinx/xilinx_emacps.c

The PHY is a Marvell 1512 Alaska device that comes on the Picozed 7020
SOM that is the heart of the application I am working on.
The version of the driver I am using for this PHY can be found here
(note that this version is slightly different (older?) to the mainline
Linux repo):
* RAW: https://raw.githubusercontent.com/Xilinx/linux-xlnx/master/drivers/net/phy/marvell.c
* GITHUB: https://github.com/Xilinx/linux-xlnx/blob/master/drivers/net/phy/marvell.c

# The Problem: No Flow Control via Auto-Negotiation #

I have noticed that when I connect to the Picozed using a PC, the
connection speed and duplex are negotiated correctly, and the signal
integrity is good. However, its autonegotiation capabilities do not
report support for the Pause or Asymmetrical Pause capabilities. Flow
control is thus disabled as a result. I verified this by dumping the
Link Partner capabilities PHY register on my PC.

If I connect another regular PC or a smart switch (on which I have
enabled flow control) to my PC, flow control capability is reported
and thus Pause frames are enabled.

Based on the Zynq's Technical Reference Manual, the MAC supports Pause
frames and Asymmetrical Pause, so I am working with the assumption
that these features should be advertised, contrary to what I am
seeing.

I spent most of the day looking at the PHY abstraction layer, the
marvell driver, and the xemacps driver to figure out where the missing
flow control capability information needed to be added. I also looked
at the phy.txt where I found the following:

"Now just make sure that phydev->supported and phydev->advertising
have any values pruned from them which don't make sense for your
controller a 10/100 controller may be connected to a gigabit capable
PHY, so you would need to mask off SUPPORTED_1000baseT*).  See
include/linux/ethtool.h for definitions for these bitfields. Note that
you should not SET any bits, or the PHY may get put into an
unsupported state."

Source: https://raw.githubusercontent.com/Xilinx/linux-xlnx/master/Documentation/networking/phy.txt

So my understanding is as follows:

1. The PHY driver sets all of the flags for the capabilities it
supports in phydev->supported.
2. The MAC driver then prunes the capabilities it does not support
from phydev->supported to see what can be safely advertised.

In xemacps.c, the following code appears to be performing this
pruning, by removing all capabilities other than PHY_GBIT_FEATURES and
the Flow Control capability bits.

phydev->supported &= (PHY_GBIT_FEATURES | SUPPORTED_Pause |
SUPPORTED_Asym_Pause);

So, if the PHY had advertised that it supported Flow Control / Pause
Frames, these capabilities would have been preserved. However, with
some variable dumping to dmesg, I can see that SUPPORTED_Pause and
SUPPORTED_Asym_Pause are not present in phydev->supported. What I
observe is that phydev->supported has a value of 0x02ff, and we would
expect bits 13 and 14 to be set, resulting in 0x62ff.

I dug a bit deeper to see how the PHY driver populates the value of
phydev->supported before it gets passed to the MAC for pruning. I
found that it comes from the .features field in the phy_driver structs
defined at the bottom of the marvell.c file. In the version I am
using, this field only contains PHY_GBIT_FEATURES, which explains why
the SUPPORTED_Pause and SUPPORTED_Asym_Pause flags are not set.

{
    .phy_id = MARVELL_PHY_ID_88E1510,
    .phy_id_mask = MARVELL_PHY_ID_MASK,
    .name = "Marvell 88E1510",
    .features = PHY_GBIT_FEATURES,      <--- This!
    .flags = PHY_HAS_INTERRUPT,
    ...
}

# Solution Ideas... #

My first question is: Was this done on purpose? I find it hard to
believe that a relatively recent PHY would not support Pause and Asym
Pause advertisement. If this is indeed an accidental oversight, what
would the proper fix be?

I have tried to OR in the appropriate SUPPORTED_Pause and
SUPPORTED_Asym_Pause values into the .features field, like this:

{
    ...
    .features = (PHY_GBIT_FEATURES | SUPPORTED_Pause | SUPPORTED_Asym_Pause),
    ...
}

Now I see that auto-negotiation works as I would expect it to: Flow
Control is advertised in the Link Partner register, and my PC reports
that flow control is enabled. One caveat is that ethtool -a eth0 on
the Zynq still claims flow control is off, so I might still have some
adjustments to make for this to be displayed correctly.

What are your thoughts on this? Is my reasoning correct, or is there a
different best practice to follow in this situation?

This is my first post on this mailing list. Thanks in advance for your
help and patience.

Marc Bertola, Prolucid Technologies
