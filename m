From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 6/6] Modify tag_ksz.c to support other KSZ switch
 drivers
Date: Mon, 18 Sep 2017 20:55:17 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41124D7C@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
 <20170907214834.GT11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D2E@CHN-SV-EXMX02.mchp-main.com>
 <20170918195708.GE15606@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918195708.GE15606@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > This is ugly. We have a clean separation between a switch driver and a
> > > tag driver. Here you are mixing them together. Don't. Look at the
> > > mailing lists for what Florian and I suggested to Pavel. It will also
> > > solve your include file issue above.
> >
> > It seems to me all tag_*.c are hard-coded.  They do not have access to
> > the switch device and just use the bit definitions defined in the top to
> > do the job.
> >
> > This creates a problem for all KSZ switch devices as they have different
> > tail tag formats and lengths.  There will be potentially 4 additional
> > DSA_TAG_PROT_KSZ* just to handle them.  Extra files will be added
> > with about the same code.
> 
> Hi Tristram
> 
> Think about factoring out the common code into a shared functions.
>

I am a little unsure what you have in mind.  Can you elaborate?

Like creating an additional ksz_xmit function and passing a function pointer
to it to do the job?
 
> > But the most important thing is how do we support the offload_fwd_mark
> > bit in skb when the only place that has access to skb does not have access
> to
> > the switch hardware?
> 
> Well, so far, nothing has set offload_fwd_mark. This is about to
> change, since i need it for IGMP snooping on the brX interface, for
> Marvell at least. Bit i just need to set it to true for all frames.
> 
> What use cases do you have in mind where you need information from the
> switch driver to decide on its value?
>

In the old DSA implementation all the ports are partitioned into its own device
and the bridge joining them will do all the forwarding.  This is useful for quick
testing with some protocols like RSTP but it is probably useless for real
operation.

The new switchdev model tries to use the switch hardware as much as
possible.  This offload_fwd_mark bit means the frame is forwarded by the
hardware switch, so the software bridge does not need to do it again.  Without
this bit there will be duplicated multicast frames coming out the ports if internal
forwarding is enabled.

When the DSA device is first created all ports are independent devices.  When
a bridge is created and those devices are attached the ports share the same
membership so all frames will be forwarded internally.

When RSTP is used the port can be put in blocked state and so the forwarding
will stop for that port.   Currently the switch driver will check that membership
to decide whether to set that bit.

> > A little out-of-topic is the MAC driver may have problem receiving the
> frame if
> > the tail tag length is too big.  Most of the MAC drivers have big enough
> receive
> > buffer or require 64-bytes multiple so there are extra room to
> accommodate
> > the big tail tag at the end of the frame.  Still some MAC drivers use exactly
> 1500
> > MTU and some additional length and may run into this problem.  Currently
> the
> > Atmel Cadence MAC driver has this potential problem when certain
> conditions
> > are met.
> 
> This is a know problem. I just fixed the FEC driver which also
> discarded DSA tagged frames when they were bigger than the MTU.
> 
> So far, it has not been too much of an issue, because most boards with
> a switch, use an Ethernet interface from the same manufacture. Marvell
> Switches with a Marvell Ethernet interface. Broadcom switch with a
> Broadcom Interface. Atheros switch with an Atheros interface. And
> naturally, these combinations just work. But Freescale FEC and Marvell
> had not been combined before, and it was broken.
> 
> So i would not be surprised if the Cadence MAC driver had an issue.

The KSZ switches never have a built-in MAC controller, so it is always a support
issue for us.
