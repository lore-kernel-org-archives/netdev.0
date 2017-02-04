From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 6/6] net: dsa: introduce bridge notifier
Date: Sat, 04 Feb 2017 13:26:32 -0500
Message-ID: <87tw89yfqf.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com> <20170203182021.14246-7-vivien.didelot@savoirfairelinux.com> <20170204175517.GC8364@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, cphealy@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170204175517.GC8364@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +#define DSA_NOTIFIER_BRIDGE_JOIN		1
>> +#define DSA_NOTIFIER_BRIDGE_LEAVE		2
>
> Is one notifier per event sufficient?

Yes. What a switch chip in a fabric needs to know is what action is
currently triggered on another chip, so that it can react accordingly.

> I've not looked at what actually needs to happen when a port joins a
> bridge, in a D in DSA setup. Do we need to both enable the flow of
> frames around the switch fabric, but also block those frames going out
> ports they should not? Do we need a first notifier to put in place
> the blocks, and then a second notifier to enable the flow of packets?

I gave examples in the cover letter as well as the limitation of
non-switchdev operations.

Basic (non VLAN-filtering enabled) cross-chip hardware bridging in
Marvell consists of configuring a cross-chip port based VLAN table (PVT)
in the chip, which basically is a matrice of external chip/port IDs from
which a local port will accept frames.

In mv88e6xxx, this table defaults to being configured with all ones,
meaning that frames from any external ports are allowed to ingress any
local ports of the chip.

My next patchset will change this behavior to configure the PVT as all
zero by default (except for DSA and CPU links). A new switch-wide
operation will be added to inform a chip that an external port 3.2 got
(un)bridged with something like:

    ds->ops->crosschip_bridge_join(ds, 3, 2, br0);

The mv88e6xxx will then write the PVT to allowed the external port 3.2
to ingress frames on local ports member of br0 (if any).

> What we don't want is a window of time during the fabric setup as a
> whole is inconsistent, and frames a leaking out ports they should not.

There is no such window. A switch notifier is registered once the switch
chip is setup. Chips that are not setup yet won't receive fabric
notifier events.

Thanks,

        Vivien
