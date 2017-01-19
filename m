From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next v3 06/10] net: dsa: Migrate to
 device_find_class()
Date: Thu, 19 Jan 2017 16:51:55 +0000
Message-ID: <20170119165155.GH27312@n2100.armlinux.org.uk>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170114214713.28109-7-f.fainelli@gmail.com>
 <20170115110628.GF26374@kroah.com>
 <fc247aeb-a8d6-5ba9-c26d-cb057a5ac34d@gmail.com>
 <20170115173949.GA19268@kroah.com>
 <a9ea1f45-b9a5-d840-68e0-9bf9bc7a6598@gmail.com>
 <20170115191632.GD5643@lunn.ch>
 <912e6143-c67a-d909-2a6c-939de79efc5d@gmail.com>
 <20170119142820.GA494@kroah.com>
 <20170119145315.GD21805@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170119145315.GD21805@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(This is mainly for Greg's benefit to help him understand the issue.)

I think the diagram you gave initially made this confusing, as it
talks about a CPU(sic) producing the "RGMII" and "MII-MGMT".

Let's instead show a better representation that hopefully helps Greg
understand networking. :)


  CPU
System <-B->  Ethernet controller <-P-> } PHY <---> network cable
                                        } - - - - - - - or - - - - - - -
                  MDIO bus -------M---> } Switch <-P-> PHYs <--> network
                                              `----M----^        cables

'B' can be an on-SoC bus or something like PCI.

'P' are the high-speed connectivity between the ethernet controller and
PHY which carries the packet data.  It has no addressing, it's a point
to point link.  RGMII is just one wiring example, there are many
different interfaces there (SGMII, AUI, XAUI, XGMII to name a few.)

'M' are the MDIO bus, which is the bus by which ethernet PHYs and
switches can be identified and controlled.

The MDIO bus has a bus_type, has host drivers which are sometimes
part of the ethernet controller, but can also be stand-alone devices
shared between multiple ethernet controllers.

PHYs are a kind of MDIO device which are members of the MDIO bus
type.  Each PHY (and switch) has a numerical address, and identifying
numbers within its register set which identifies the manufacturer
and device type.  We have device_driver objects for these.

Expanding the above diagram to make it (hopefully) even clearer,
we can have this classic setup:

  CPU
System <-B-> Ethernet controller <-P-> PHY <---> network cable
                 MDIO bus -------M------^

Or, in the case of two DSA switches attached to an Ethernet controller:

                                     |~~~~~~~~|
System <-B-> Ethernet controller <-P-> Switch <-P-> PHY1 <--> network cable
                 MDIO bus ----+--M--->   1    <-P-> PHY2 <--> network cable
                              |      |        ...    |
                              |      |        <-P-> PHYn <--> network cable
                              |      |....^...|      |
                              |           |  `---M---'
                              |           P
                              |           |
                              |      |~~~~v~~~|
                              `------> Switch <-P-> PHY1 <--> network cable
                                     |   2    ...    |
                                     |        <-P-> PHYn <--> network cable
                                     |........|      |
                                             `---M---'

The problem that the DSA guys are trying to deal with is how to
represent the link between the DSA switches (which are devices
sitting off their controlling bus - the MDIO bus) and the ethernet
controller associated with that collection of devices, be it a
switch or PHY.

Merely changing the parent/child relationships to try and solve
one issue just creates exactly the same problem elsewhere.

So, I hope with these diagrams, you can see that trying to make
the ethernet controller a child device of the DSA switches
means that (eg) it's no longer a PCI device, which is rather
absurd, especially when considering that what happens to the
right of the ethernet controller in the diagrams above is
normally external chips to the SoC or ethernet device.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
