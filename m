From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next v3 06/10] net: dsa: Migrate to device_find_class()
Date: Thu, 19 Jan 2017 16:35:48 +0000
Message-ID: <20170119163548.GG27312@n2100.armlinux.org.uk>
References: <20170114214713.28109-7-f.fainelli@gmail.com>
 <20170115110628.GF26374@kroah.com>
 <fc247aeb-a8d6-5ba9-c26d-cb057a5ac34d@gmail.com>
 <20170115173949.GA19268@kroah.com>
 <a9ea1f45-b9a5-d840-68e0-9bf9bc7a6598@gmail.com>
 <20170115191632.GD5643@lunn.ch>
 <912e6143-c67a-d909-2a6c-939de79efc5d@gmail.com>
 <20170119142820.GA494@kroah.com> <20170119145315.GD21805@lunn.ch>
 <20170119163013.GA22777@kroah.com>
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
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170119163013.GA22777@kroah.com>
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

On Thu, Jan 19, 2017 at 05:30:13PM +0100, Greg KH wrote:
> On Thu, Jan 19, 2017 at 03:53:15PM +0100, Andrew Lunn wrote:
> > > > > struct dsa_platform_data {
> > > > >         /*
> > > > >          * Reference to a Linux network interface that connects
> > > > >          * to the root switch chip of the tree.
> > > > >          */
> > > > >         struct device   *netdev;
> > > 
> > > This I think is the oddest thing, why do you need to have the "root
> > > switch" here?  You seem to have dropped the next value in this
> > > structure:
> > > 	struct net_device *of_netdev;
> > 
> > We are implementing platform_data for devices which don't support
> > device tree. When using OF, we don't have any of these issues. We can
> > go straight to the device.
> > 
> > It is a bit convoluted, but look at
> > arch/arm/mach-orion5x/rd88f5181l-ge-setup.c. It defines the start of
> > the dsa_platform_data in that file. It then gets passed through
> > common.c: orion5x_eth_switch_init() to 
> > arch/arm/plat-orion/common.c:orion_ge00_switch_init() :
> > 
> > void __init orion_ge00_switch_init(struct dsa_platform_data *d)
> > {
> >         int i;
> > 
> >         d->netdev = &orion_ge00.dev;
> >         for (i = 0; i < d->nr_chips; i++)
> >                 d->chip[i].host_dev = &orion_ge_mvmdio.dev;
> > 
> >         platform_device_register_data(NULL, "dsa", 0, d, sizeof(d));
> > }
> > 
> > Where we have
> > 
> > static struct platform_device orion_ge00 = {
> >         .name           = MV643XX_ETH_NAME,
> >         .id             = 0,
> >         .num_resources  = 1,
> >         .resource       = orion_ge00_resources,
> >         .dev            = {
> >                 .coherent_dma_mask      = DMA_BIT_MASK(32),
> >         },
> > };
> > 
> > So this is the platform device for the Ethernet device. We cannot go
> > to the net_device, because it does not exist until this Ethernet
> > platform device is instantiated.
> 
> Ok, fine, but why isn't the ethernet device a child of this platform
> device?  Why is it floating around somewhere else?  You don't see that
> happening for other devices.

The ethernet device is not a child of the DSA device.  I'm going to
send a mail I've had queued up for a few hours redoing Andrew's
ASCII art, because I think that's what's causing the confusion here,
provided I haven't discarded it.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
