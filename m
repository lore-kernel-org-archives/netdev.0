From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next v3 06/10] net: dsa: Migrate to device_find_class()
Date: Fri, 10 Feb 2017 14:02:17 +0100
Message-ID: <20170210130217.GA4570@kroah.com>
References: <20170114214713.28109-7-f.fainelli@gmail.com>
 <20170115110628.GF26374@kroah.com>
 <fc247aeb-a8d6-5ba9-c26d-cb057a5ac34d@gmail.com>
 <20170115173949.GA19268@kroah.com>
 <a9ea1f45-b9a5-d840-68e0-9bf9bc7a6598@gmail.com>
 <20170115191632.GD5643@lunn.ch>
 <912e6143-c67a-d909-2a6c-939de79efc5d@gmail.com>
 <20170119142820.GA494@kroah.com> <20170119145315.GD21805@lunn.ch>
 <20170119165155.GH27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 open list <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM SUB-ARCHITECTURES" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170119165155.GH27312@n2100.armlinux.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2017 at 04:51:55PM +0000, Russell King - ARM Linux wrote:
> (This is mainly for Greg's benefit to help him understand the issue.)
> 
> I think the diagram you gave initially made this confusing, as it
> talks about a CPU(sic) producing the "RGMII" and "MII-MGMT".
> 
> Let's instead show a better representation that hopefully helps Greg
> understand networking. :)
> 
> 
>   CPU
> System <-B->  Ethernet controller <-P-> } PHY <---> network cable
>                                         } - - - - - - - or - - - - - - -
>                   MDIO bus -------M---> } Switch <-P-> PHYs <--> network
>                                               `----M----^        cables
> 
> 'B' can be an on-SoC bus or something like PCI.
> 
> 'P' are the high-speed connectivity between the ethernet controller and
> PHY which carries the packet data.  It has no addressing, it's a point
> to point link.  RGMII is just one wiring example, there are many
> different interfaces there (SGMII, AUI, XAUI, XGMII to name a few.)
> 
> 'M' are the MDIO bus, which is the bus by which ethernet PHYs and
> switches can be identified and controlled.
> 
> The MDIO bus has a bus_type, has host drivers which are sometimes
> part of the ethernet controller, but can also be stand-alone devices
> shared between multiple ethernet controllers.
> 
> PHYs are a kind of MDIO device which are members of the MDIO bus
> type.  Each PHY (and switch) has a numerical address, and identifying
> numbers within its register set which identifies the manufacturer
> and device type.  We have device_driver objects for these.
> 
> Expanding the above diagram to make it (hopefully) even clearer,
> we can have this classic setup:
> 
>   CPU
> System <-B-> Ethernet controller <-P-> PHY <---> network cable
>                  MDIO bus -------M------^
> 
> Or, in the case of two DSA switches attached to an Ethernet controller:
> 
>                                      |~~~~~~~~|
> System <-B-> Ethernet controller <-P-> Switch <-P-> PHY1 <--> network cable
>                  MDIO bus ----+--M--->   1    <-P-> PHY2 <--> network cable
>                               |      |        ...    |
>                               |      |        <-P-> PHYn <--> network cable
>                               |      |....^...|      |
>                               |           |  `---M---'
>                               |           P
>                               |           |
>                               |      |~~~~v~~~|
>                               `------> Switch <-P-> PHY1 <--> network cable
>                                      |   2    ...    |
>                                      |        <-P-> PHYn <--> network cable
>                                      |........|      |
>                                              `---M---'
> 
> The problem that the DSA guys are trying to deal with is how to
> represent the link between the DSA switches (which are devices
> sitting off their controlling bus - the MDIO bus) and the ethernet
> controller associated with that collection of devices, be it a
> switch or PHY.

Why do they have to represent that link?  This is a driver that somehow
binds the two togther in some sort of "control plane"?

> Merely changing the parent/child relationships to try and solve
> one issue just creates exactly the same problem elsewhere.

Fair enough.

> So, I hope with these diagrams, you can see that trying to make
> the ethernet controller a child device of the DSA switches
> means that (eg) it's no longer a PCI device, which is rather
> absurd, especially when considering that what happens to the
> right of the ethernet controller in the diagrams above is
> normally external chips to the SoC or ethernet device.

Ok, thanks for the long explainations and diagrams.

_BUT_ my original point remains.  These new functions you all are trying
to get into the driver core, do NOT do what they say they are doing.
They are mucking around with a "known topology" and just happen to work
because the device you are trying to find shares a common parent with
yourself.

That is not what the function says it does, and as such, I do not want
that function in the driver core at all.

If you wish to keep it in your own subsystem, that's fine, but call it
what it really is:
	hack_to_find_peer_device_on_random_bus()
and pass in a _real_ pointer to a bus type.  Not some random string
please.

Or better yet, have the DSA code accept pointers to the two devices in
the first place, so it "knows" what to do here in a much better way.
Right now it is a bad hack.  You all can not argue that is not true.

thanks,

greg k-h
