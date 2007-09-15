From: Domen Puncer <domen@coderock.org>
Subject: Re: [RFC PATCH v0.2] net driver: mpc52xx fec
Date: Sat, 15 Sep 2007 14:14:44 +0200
Message-ID: <20070915121444.GA19857@nd47.coderock.org>
References: <20070810095153.GC13994@moe.telargo.com>
	<20070902074143.GB2642@nd47.coderock.org>
	<fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On 03/09/07 09:57 -0600, Grant Likely wrote:
> On 9/2/07, Domen Puncer <domen@coderock.org> wrote:
> > Hi!
> >
> > new in this version:
> > - fixed stuff that was commented on.
> > - added 7-wire support (compile at least, if someone has the hardware,
> >         please test!)
> > - ethtool support
> 
> Thanks for this work Domen, comments below...

Thanks for reviewing and sorry for not replying sooner, I lost the
mail.

> 
> This is a large patch, and it should be broken up into logical
> changes.  ie. split into dts changes, bestcomm changes, fec driver and
> mdio driver.  Easier to review that way.  The bestcomm and dts changes
> don't need to go to the netdev list.

OK.

> > +config FEC_MPC52xx
> > +       tristate "FEC Ethernet"
> > +       depends on NET_ETHERNET
> > +       select PPC_BESTCOMM
> > +       select PPC_BESTCOMM_FEC
> > +       select CRC32
> > +       ---help---
> > +         This option enables support for the MPC5200's on-chip
> > +         Fast Ethernet Controller
> > +
> > +config FEC_MPC52xx_MDIO
> > +       bool "Use external Ethernet MII PHY"
> > +       depends on FEC_MPC52xx
> > +       select PHYLIB
> > +       default y
> > +       ---help---
> > +         The MPC5200's FEC can connect to the Ethernet either with
> > +         an external MII PHY chip or 10 Mbps 7-wire interface
> > +         (Motorola? industry standard).
> > +         If your board uses an external PHY, say y, else n.
> 
> This option should change.  Either build the MDIO driver into the FEC
> driver unconditionally and drop this option, or make the MDIO driver
> independent from the FEC driver (it does use the MDIO bus
> infrastructure after all).  Either way the FEC driver should detect
> the phy type at runtime (possibly based on the presence/absence of a
> phy-handle property) instead of being hard compiled.  5200 support is
> now multiplatform after all.
> 
> If you drop the MDIO config option, then I'd also consider eliminating
> driver/net/fec_mpc52xx/Kconfig entirely and rolling the single
> MPC52xx_FEC option into drivers/net/Kconfig.

Right. I separated it.

> > +static irqreturn_t fec_interrupt(int, void *);
> > +static irqreturn_t fec_rx_interrupt(int, void *);
> > +static irqreturn_t fec_tx_interrupt(int, void *);
> > +static struct net_device_stats *fec_get_stats(struct net_device *);
> > +static void fec_set_multicast_list(struct net_device *dev);
> > +static void fec_hw_init(struct net_device *dev);
> > +static void fec_stop(struct net_device *dev);
> > +static void fec_start(struct net_device *dev);
> > +static void fec_reset(struct net_device *dev);
> 
> Nit: Are all these forward decls needed?

Some aren't - cleaned.

> 
> > +
> > +static u8 mpc52xx_fec_mac_addr[6];
> 
> Why isn't this part of struct fec_priv?

Because at __setup time, there's no fec_priv instance.
OTOH, does anyone even use mpc52xx-mac=?

> 
> > +static const u8 null_mac[6];
> 
> null_mac?!?  Just for comparing a mac addr against 0?

right, is_zero_ether_addr is the right thing.

> 
> <snip>
> 
> > +#ifdef CONFIG_FEC_MPC52xx_MDIO
> 
> Once again; don't make this a conditional compile; detect at runtime.
> 
> <snip>
> 
> > +static void __init fec_str2mac(char *str, unsigned char *mac)
> > +{
> > +       int i;
> > +       u64 val64;
> > +
> > +       val64 = simple_strtoull(str, NULL, 16);
> > +
> > +       for (i = 0; i < 6; i++)
> > +               mac[5-i] = val64 >> (i*8);
> > +}
> > +
> > +static int __init mpc52xx_fec_mac_setup(char *mac_address)
> > +{
> > +       fec_str2mac(mac_address, mpc52xx_fec_mac_addr);
> > +       return 0;
> > +}
> 
> fec_str2mac is called in *1* place.  I'd roll it into mpc52xx_fec_mac_setup.
> 
> > +
> > +__setup("mpc52xx-mac=", mpc52xx_fec_mac_setup);
> > +
> 

OK.

Updated and split version at:
http://coderock.org/tmp/fec-v3rc1/

I'll repost to lists once I run-test them.


	Domen

> 
> 
> -- 
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
> grant.likely@secretlab.ca
> (403) 399-0195
> _______________________________________________
> Linuxppc-embedded mailing list
> Linuxppc-embedded@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-embedded
