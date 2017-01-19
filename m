From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next v3 06/10] net: dsa: Migrate to device_find_class()
Date: Thu, 19 Jan 2017 15:28:20 +0100
Message-ID: <20170119142820.GA494@kroah.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170114214713.28109-7-f.fainelli@gmail.com>
 <20170115110628.GF26374@kroah.com>
 <fc247aeb-a8d6-5ba9-c26d-cb057a5ac34d@gmail.com>
 <20170115173949.GA19268@kroah.com>
 <a9ea1f45-b9a5-d840-68e0-9bf9bc7a6598@gmail.com>
 <20170115191632.GD5643@lunn.ch>
 <912e6143-c67a-d909-2a6c-939de79efc5d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Russell King <linux@armlinux.org.uk>, open list <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM SUB-ARCHITECTURES" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <912e6143-c67a-d909-2a6c-939de79efc5d@gmail.com>
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

On Mon, Jan 16, 2017 at 12:01:02PM -0800, Florian Fainelli wrote:
> On 01/15/2017 11:16 AM, Andrew Lunn wrote:
> >>> What exactly is the relationship between these devices (a ascii-art tree
> >>> or sysfs tree output might be nice) so I can try to understand what is
> >>> going on here.
> > 
> > Hi Greg, Florian
> > 
> > A few diagrams and trees which might help understand what is going on.
> > 
> > The first diagram comes from the 2008 patch which added all this code:
> > 
> >             +-----------+       +-----------+
> >             |           | RGMII |           |
> >             |           +-------+           +------ 1000baseT MDI ("WAN")
> >             |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
> >             |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
> >             |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
> >             |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> >             |           |       |           |
> >             +-----------+       +-----------+
> > 
> > We have an ethernet switch and a host CPU. The switch is connected to
> > the CPU in two different ways. RGMII allows us to get Ethernet frames
> > from the CPU into the switch. MIImgmt, is the management bus normally
> > used for Ethernet PHYs, but Marvell switches also use it for Managing
> > switches.
> > 
> > The diagram above is the simplest setup. You can have multiple
> > Ethernet switches, connected together via switch ports. Each switch
> > has its own MIImgmt connect to the CPU, but there is only one RGMII
> > link.
> > 
> > When this code was designed back in 2008, it was decided to represent
> > this is a platform device, and it has a platform_data, which i have
> > slightly edited to keep it simple:
> > 
> > struct dsa_platform_data {
> >         /*
> >          * Reference to a Linux network interface that connects
> >          * to the root switch chip of the tree.
> >          */
> >         struct device   *netdev;

This I think is the oddest thing, why do you need to have the "root
switch" here?  You seem to have dropped the next value in this
structure:
	struct net_device *of_netdev;

Isn't that the "real" net_device you need/want to get to here?

Or, when you set netdev, can't you also point to the "real" net_device
you want to later get to?

> >         /*
> >          * Info structs describing each of the switch chips
> >          * connected via this network interface.
> >          */
> >         int             nr_chips;
> >         struct dsa_chip_data    *chip;
> > };
> > 
> > This netdev is the CPU side of the RGMII interface.
> > 
> > Each switch has a dsa_chip_data, again edited:
> > 
> > struct dsa_chip_data {
> >         /*
> >          * How to access the switch configuration registers.
> >          */
> >         struct device   *host_dev;
> >         int             sw_addr;
> > ...
> > }

If each switch only has one dsa_chip_data, can't you point directly from
that structure back to the dsa_platform_device?  Or is that what this
"host_dev" pointer is pointing to?

> > The host_dev is the CPU side of the MIImgmt, and we have the address
> > the switch is using on the bus.

"cpu side" means what?  What 'struct device' is this?  The host
controller?  The platform device?  Something else?

> > During probe of this platform device, we need to get from the
> > struct device *netdev to a struct net_device *dev.

Wait, what exactly is this "struct device *"?  Who created it?

And why are you using a platform device?  Shouldn't this be a custom
bus?  I know people like to abuse platform devices, is that the case
here, or is it really driven only by a device tree representation?

Shouldn't you have a bus for RGMII devices?  Is that the real problem
here, you don't have a representation for your RGMII "bus" with a
controller to bundle everything under (like a USB host controller, it
bridges from one bus to another).

> > So the code looks in the device net class to find the device
> > 
> > |   |   |   |-- f1074000.ethernet
> > |   |   |   |   |-- deferred_probe
> > |   |   |   |   |-- driver -> ../../../../../bus/platform/drivers/mvneta
> > |   |   |   |   |-- driver_override
> > |   |   |   |   |-- modalias
> > |   |   |   |   |-- net
> > |   |   |   |   |   `-- eth1
> > |   |   |   |   |       |-- addr_assign_type
> > |   |   |   |   |       |-- address
> > |   |   |   |   |       |-- addr_len
> > |   |   |   |   |       |-- broadcast
> > |   |   |   |   |       |-- carrier
> > |   |   |   |   |       |-- carrier_changes
> > |   |   |   |   |       |-- deferred_probe
> > |   |   |   |   |       |-- device -> ../../../f1074000.ethernet
> > 
> > and then use container_of() to get the net_device.

What 'struct device *' are you passing to container_of() here?  The one
representing eth1?  What call is this?  And where are you trying to go
from there, to a peer?  Why?

> > Similarly, the code needs to get from struct device *host_dev to a struct mii_bus *.
> > 
> > |   |   |   |-- f1072004.mdio
> > |   |   |   |   |-- deferred_probe
> > |   |   |   |   |-- driver -> ../../../../../bus/platform/drivers/orion-mdio
> > |   |   |   |   |-- driver_override
> > |   |   |   |   |-- mdio_bus
> > |   |   |   |   |   `-- f1072004.mdio-mi
> > |   |   |   |   |       |-- deferred_probe
> > |   |   |   |   |       |-- device -> ../../../f1072004.mdio

Ok, this looks like the "peer" you want to get to from eth1, you want
f1072004.mdio-mi, right?

If so, why is eth1 not below f1072004.mdio-mi in the heirachy already?

Why is it up attached to the parent device, making this a "flat"
heirachy?

That's what is confusing about your functions, you are just walking all
of the "child" devices of a specific struct device, trying to find the
first random one that happens to belong to a specific 'bus' because you
are related to it.

Which is wrong, eth1 should be a child of your bus device, that way you
"know" how to get to it (it's your parent!).

So, I'm still confused, and still think this is all wrong, but feel free
to prove me wrong about this :)

thanks,

greg k-h
