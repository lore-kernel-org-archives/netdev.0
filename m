From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v5 0/2] Add support for the ethernet switch on the ESPRESSObin
Date: Thu, 19 Jan 2017 17:07:46 -0500
Message-ID: <874m0u1z65.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170119214934.27442-1-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

Gregory CLEMENT <gregory.clement@free-electrons.com> writes:

> I created a new family for this switch and filled the ops structure by
> selecting which seems the more appropriate functions.

We don't create families, this information comes from the Marvell
DSDT. If you don't know which switch family Marvell put the 6341 in, you
should be able to use MV88E6XXX_FAMILY_NONE safely.

Note that this is anyway not a useful information since the Marvell
chips have lots of per-models specificities... Any family related code
(e.g. the mv88e6xxx_*_family() helpers) are likely to be removed soon.
    
> While comparing the datasheet and the ops functions used, some
> question came to me. They should not prevent applying this series,
> but their answer would help me to have a better understanding of the
> dsa subsystem.
>
> - Are the temperature related operation still useful with dsa2 ?
>
> Indeed the hwmon initialization is only done from dsa_probe which is
> not called if we use dsa2.

HWMON is not supported anymore in dsa2. Andrew is in the process of
moving its support to the PHY driver instead. However you can still test
it locally with this patch:

    http://ix.io/1QvY

The temperature is accessed via ethtool -e|-E.

> - Why the setup is done differently between the 6390 and the 6352
>   families when the have exactly the same register?
>
>   - On the Port Controller 2, the bit PORT_CONTROL_2_MAP_DA is set for
>     6352 and not for 6390 whereas the same bit exists in 6360 and the
>     description for this bit is the same for both datasheet.
>
>
>   - Register PORT_ATU_CONTROL and PORT_PRI_OVERRIDE are reset on 6352
>     and not on 6390. While here again the registers description are
>     the same.

You are totally correct here. We are in the process of moving every old
pieces of code such as this:

	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
	    mv88e6xxx_6095_family(chip) || mv88e6xxx_6320_family(chip) ||
	    mv88e6xxx_6185_family(chip))
		reg = PORT_CONTROL_2_MAP_DA;

into proper "library" functions defined in the correct internal SMI
device specific file (here, port.c), to be used in the mv88e6xxx_ops
structure, if a given model support the feature described in the
datasheet.

So the two registers you mentioned don't have proper ops yet.

Thanks!

        Vivien
