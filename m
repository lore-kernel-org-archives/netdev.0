From: Marc St-Jean <Marc_St-Jean@pmc-sierra.com>
Subject: Re: [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
Date: Mon, 28 May 2007 14:46:24 -0700
Message-ID: <465B4DB0.1080701@pmc-sierra.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: akpm@linux-foundation.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from father.pmc-sierra.com ([216.241.224.13]:62254 "HELO
	father.pmc-sierra.bc.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752749AbXE1Vqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 17:46:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff, thanks for the feedback. If dropped your comments for the sections
I've either already implemented or will be doing shortly. The remaining
comments are below to help clarify the code in question or if I didn't
understand your comment.

Marc

Jeff Garzik wrote:
> Marc St-Jean wrote:
>  > [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
>  >
>  > Patch to add an ethernet driver for the PMC-Sierra MSP71xx devices.
>  >
>  > Patches 1 through 9 were posted to linux-mips@linux-mips.org as well
>  > as other sub-system lists/maintainers as appropriate. This patch has
>  > some dependencies on the first few patches in the set. If you would
>  > like to receive these or the entire set, please email me.
>  >
>  > Thanks,
>  > Marc
>  >
>  > Signed-off-by: Marc St-Jean <Marc_St-Jean@pmc-sierra.com>
>  > ---
>  > Re-posting patch with recommended changes:
>  > -Removed support for SKB recycling.
>  >
>  >  arch/mips/pmc-sierra/msp71xx/msp_eth.c |  122 +
>  >  drivers/net/Kconfig                    |   12
>  >  drivers/net/Makefile                   |    1
>  >  drivers/net/pmcmspeth.c                | 2849 
> +++++++++++++++++++++++++++++++++
>  >  drivers/net/pmcmspeth.h                |  543 ++++++
>  >  5 files changed, 3527 insertions(+)
>  >

...

>  > 
> +/************************************************************************
>  > + * Read/Write a MDIO register.
>  > + */
>  > +static u32
>  > +mspphy_read(struct mspeth_phy *phyptr, int phy_reg)
>  > +{
>  > +     unsigned long flags;
>  > +     u32 data;
>  > +     int i;
>  > +
>  > +     BUG_ON(phyptr == NULL);
> 
> No need to BUG_ON() conditions that will obviously cause an immediate
> oops anyway
> 
> 
>  > +     /* protect access with spin lock */
>  > +     spin_lock_irqsave(&phyptr->lock, flags);
>  > +
>  > +     for (i = 0; i < PHY_BUSY_CNT &&
>  > +          __raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
>  > +          MD_CA_BUSY_BIT; i++)
>  > +             ndelay(100);
>  > +    
>  > +     __raw_writel(MD_CA_BUSY_BIT | phyptr->phyaddr << 5 | phy_reg,
>  > +                     phyptr->memaddr + MSPPHY_MII_CTRL);
>  > +                    
>  > +     for (i = 0; i < PHY_BUSY_CNT &&
>  > +          __raw_readl(phyptr->memaddr + MSPPHY_MII_CTRL) &
>  > +             MD_CA_BUSY_BIT; i++)
>  > +             ndelay(100);
> 
> what about error handling for the timeout case?

Not much can be done if we can no longer communicate with the phy. I've added
calls to reset the mac/phy through a tasklet.


>  > +     data = __raw_readl(phyptr->memaddr + MSPPHY_MII_DATA);
>  > +
>  > +     /* unlock */
>  > +     spin_unlock_irqrestore(&phyptr->lock, flags);
>  > +
>  > +     return data & 0xffff;
>  > +}
>  > +
...


> +/************************************************************************** 
> 
>  > + * Check for an mspeth ethernet device and return 0 if there is one.
>  > + * Also a good time to fill out some of the device fields and do some
>  > + * preliminary initialization. The mspeth resources are statically
>  > + * allocated.
>  > + */
>  > +
>  > +int mspeth_probe(struct platform_device *pldev)
>  > +{
>  > +     int unit, hwunit;
>  > +     int i, err;
>  > +     u8 macaddr[8];
>  > +     struct mspeth_priv *lp;
>  > +     char tmp_str[128];
>  > +     struct net_device *dev = NULL;
>  > +     struct resource *res;
>  > +     void *mapaddr;
>  > +
>  > +     unit = pldev->id;
>  > +
>  > +     /* default return value -- no device here */
>  > +     err = -ENODEV;
>  > +
>  > +     /*
>  > +      * Scan the hardware list and associate a logical unit with a
>  > +      * hardware unit it's important to keep these two straight.
>  > +      * hwunit is used for accessing the prom and all hardware.
>  > +      * unit is used when parsing the commandline and any other
>  > +      * uses that might refer to *all* eth devices (not just mspeth
>  > +      * devices) in the system.
>  > +      */
>  > +     for (i = 0, hwunit = 0; hwunit < MSPETH_MAX_UNITS; hwunit++) {
>  > +             if (identify_enet(hwunit) != FEATURE_NOEXIST)
>  > +                     if (i++ == unit)
>  > +                             break;
> 
> Is MSPETH_MAX_UNITS a hardware or software limit?
> 
> Software limits such as that are not needed or allowed


It is a hardware limit for different devices in this family.

...

>  > +     res = platform_get_resource(pldev, IORESOURCE_MEM, 0);
>  > +     if (!res) {
>  > +             printk(KERN_ERR "MSPETH(probe) %s: "
>  > +                     "IOMEM resource not found for eth%d\n",
>  > +                     dev->name, unit);
>  > +             goto out_netdev;
>  > +     }
>  > +
>  > +     /* reserve the memory region */
>  > +     if (!request_mem_region(res->start, res->end - res->start + 1,
>  > +                             cardname)) {
>  > +             printk(KERN_ERR "MSPETH(probe) %s: unable to "
>  > +                     "get memory/io address region 0x08%lx\n",
>  > +                     dev->name, dev->base_addr);
>  > +             goto out_netdev;
>  > +     }
>  > +
>  > +     /* remap the memory */
>  > +     mapaddr = ioremap_nocache(res->start, res->end - res->start + 1);
>  > +     if (!mapaddr) {
>  > +             printk(KERN_WARNING "MSPETH(probe) %s: "
>  > +                     "unable to ioremap address 0x%08x\n",
>  > +                     dev->name, res->start);
>  > +             goto out_unreserve;
>  > +     }
>  > +
>  > +     lp->mapaddr = mapaddr;
>  > +     dev->base_addr = res->start;
>  > +     dev->irq = platform_get_irq(pldev, 0);
>  > +
>  > +     /* remap the system reset registers */
>  > +     lp->rstaddr = ioremap_nocache(MSP_RST_BASE, MSP_RST_SIZE);
>  > +     if (!lp->rstaddr) {
>  > +             printk(KERN_ERR "MSPETH(probe) %s: unable to "
>  > +                     "ioremap address 0x%08x\n",
>  > +                     dev->name, MSP_RST_BASE);
>  > +             goto out_unmap;
>  > +     }
>  > +
>  > +     /* set the logical and hardware units */
>  > +     lp->unit = unit;
>  > +     lp->hwunit = hwunit;
>  > +
>  > +     /* probe for PHYS attached to this MACs MDIO interface */
>  > +     if (mspeth_phyprobe(dev))
>  > +             goto out_unmap;
>  > +
>  > +     /* parse the environment and command line */
>  > +     mspeth_init_cmdline(dev);
>  > +     mspeth_init_phyaddr(dev);
>  > +
>  > +     /* MAC address */
>  > +     dev->addr_len = ETH_ALEN;
>  > +     for (i = 0; i < dev->addr_len; i++)
>  > +             dev->dev_addr[i] = macaddr[i];
>  > +
>  > +     /* register the /proc entry */
>  > +     snprintf(tmp_str, 128, "pmcmspeth%d", unit);
>  > +     create_proc_read_entry(tmp_str, 0644, proc_net,
>  > +                             mspeth_proc_info, dev);
> 
> use sysfs

I thought sysfs was only required if the file was to be writable?
Is this no longer the case?


>  > +     /* set the various call back functions */
>  > +     dev->open               = mspeth_open;
>  > +     dev->stop               = mspeth_close;
>  > +     dev->tx_timeout         = mspeth_tx_timeout;
>  > +     dev->watchdog_timeo     = TX_TIMEOUT * HZ;
>  > +     dev->hard_start_xmit    = mspeth_send_packet;
>  > +     dev->get_stats          = mspeth_get_stats;
>  > +     dev->set_multicast_list = mspeth_set_multicast_list;
>  > +#ifdef CONFIG_MSPETH_NAPI
>  > +     dev->poll               = mspeth_poll;
>  > +     dev->weight             = NAPI_WEIGHT;
>  > +#endif
>  > +     SET_ETHTOOL_OPS(dev, &mspeth_ethtool_ops);
>  > +
>  > +     /* debugging output */
>  > +     if (netif_msg_drv(lp))
>  > +             printk(KERN_INFO
>  > +                     "eth%d: found at physical address %lx, irq %d\n",
>  > +                     unit, dev->base_addr, dev->irq);
>  > +     if (netif_msg_probe(lp)) {
>  > +             printk(KERN_INFO "MSPETH(probe) eth%d: "
>  > +                     "associated with hardware unit %d\n",
>  > +                     unit, hwunit);
>  > +             printk(KERN_INFO "MSPETH(probe) eth%d: assigned "
>  > +                     "MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
>  > +                     unit, macaddr[0], macaddr[1], macaddr[2],
>  > +                     macaddr[3], macaddr[4], macaddr[5]);
>  > +             printk(KERN_INFO "MSPETH(probe) eth%d: "
>  > +                     "phytype %c, phyclk %c\n",
>  > +                     unit, identify_enet(hwunit),
>  > +                     identify_enetTxD(hwunit));
>  > +     }
>  > +
>  > +     err = register_netdev(dev);
>  > +     if (err) {
>  > +             printk(KERN_WARNING "MSPETH(probe) eth%d: "
>  > +                     "unable to register network device\n", unit);
>  > +             goto out_unmap;
>  > +     }
>  > +
>  > +     return 0;
> 
> need to unregister sysfs entry on error
> 

...


>  > 
> +/************************************************************************** 
> 
>  > + * Probe the hardware and fill out the array of PHY control elements
>  > + */
>  > +static int
>  > +mspeth_phyprobe(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     u32 reg1;
>  > +     int phyaddr;
>  > +     struct mspeth_phy tmp_phy;
>  > +     struct mspeth_phy **tail_pp;
>  > +
>  > +     tmp_phy.next_phy = NULL;
>  > +     tmp_phy.hwunit = lp->hwunit;
>  > +     tmp_phy.phyaddr = 0;
>  > +     tmp_phy.memaddr = lp->mapaddr + MSPETH_MD_DATA;
>  > +     tmp_phy.assigned = false;
>  > +     tmp_phy.linkup = false;
>  > +     spin_lock_init(&tmp_phy.lock);
>  > +
>  > +     /* find the tail of the phy list */
>  > +     for (tail_pp = &root_phy_dev; *tail_pp != NULL;
>  > +          tail_pp = &(*tail_pp)->next_phy) {;}
>  > +
>  > +     /* probe the phys and add to list */
>  > +     for (phyaddr = 0; phyaddr < MD_MAX_PHY; phyaddr++) {
> 
> for standard MII, you should start at PHY ID 1, since PHY ID 0 is often
> a ghost.  normal loop looks like
> 
>                 for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
>                  int phyx = phy & 0x1f;

I'm not sure what you mean by ghost, an alias for ID 1?

We have several boards which access either stand-alone or switch/phy-combos
at ID 0. We don't have access to all boards (some are customers) and can't
risk breaking them at this point.

...

>  > 
> +/************************************************************************** 
> 
>  > + * Scan the environment to get the kernel command line options
>  > + * for ethernet.
>  > + */
>  > +static void
>  > +mspeth_init_cmdline(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     int index;
>  > +     int unit;
>  > +     char c = ' ';
>  > +     char command_line[COMMAND_LINE_SIZE];
>  > +     char *ptr = command_line;
>  > +     char *ethptr = NULL;
>  > +
>  > +     /* default options */
>  > +     lp->option = MSP_OPT_AUTO;
>  > +
>  > +     /* scan the command line looking for static configurations */
>  > +     strcpy(command_line, prom_getcmdline());
>  > +     while (c != '\0') {
>  > +             if (c != ' ' || memcmp(ptr, "ip=", 3) != 0) {
>  > +                     c = *ptr++;
>  > +                     continue;
>  > +             }
>  > +
>  > +             c = *ptr++;
>  > +             index = 0;
>  > +             unit = -1;
>  > +
>  > +             while (index < 8) {
>  > +                     c = *ptr++;
>  > +
>  > +                     if (c == '\0' || c == ' ') {
>  > +                             if (index == 7) {
>  > +                                     index++;
>  > +                                     *--ptr = '\0';
>  > +                                     ptr++;
>  > +                             }
>  > +                             break;
>  > +                     }
>  > +
>  > +                     if (c == ':') {
>  > +                             index++;
>  > +                             if (index == 5) {
>  > +                                     if (memcmp(ptr, "eth", 3) != 0)
>  > +                                             break;
>  > +
>  > +                                     ethptr = &ptr[3];
>  > +                                     ptr = ethptr;
>  > +                             }
>  > +
>  > +                             if (index == 6) {
>  > +                                     *--ptr = '\0';
>  > +                                     ptr++;
>  > +                                     unit = simple_strtol(
>  > +                                                     ethptr, NULL, 0);
>  > +                             }
>  > +
>  > +                             if (index == 7) {
>  > +                                     ethptr = ptr;
>  > +                             }
>  > +
>  > +                             if (index == 8) {
>  > +                                     *--ptr = '\0';
>  > +                                     ptr++;
>  > +                             }
>  > +                     }
>  > +             }
>  > +
>  > +             if (index < 8 || unit < 0 || unit > MSPETH_MAX_UNITS)
>  > +                     continue;
>  > +
>  > +             /* check to see if this our option and parse them out */
>  > +             if (lp->unit == unit) {
>  > +                     if (memcmp(ethptr, "100fs", 5) == 0)
>  > +                             /* 100M full-duplex switch */
>  > +                             lp->option = MSP_OPT_100M | MSP_OPT_FDUP |
>  > +                                             MSP_OPT_SWITCH;
>  > +                     else if (memcmp(ethptr, "100hs", 5) == 0)
>  > +                             /* 100M half-duplex switch */
>  > +                             lp->option = MSP_OPT_100M | MSP_OPT_HDUP |
>  > +                                             MSP_OPT_SWITCH;
>  > +                     else if (memcmp(ethptr, "10fs", 4) == 0)
>  > +                             /* 10M full-duplex switch */
>  > +                             lp->option = MSP_OPT_10M | MSP_OPT_FDUP |
>  > +                                             MSP_OPT_SWITCH;
>  > +                     else if (memcmp(ethptr, "10hs", 4) == 0)
>  > +                             /* 10M half-duplex switch */
>  > +                             lp->option = MSP_OPT_100M | MSP_OPT_HDUP |
>  > +                                             MSP_OPT_SWITCH;
>  > +                     else if (memcmp(ethptr, "100f", 4) == 0)
>  > +                             /* 100M full-duplex */
>  > +                             lp->option = MSP_OPT_100M | MSP_OPT_FDUP;
>  > +                     else if (memcmp(ethptr, "100h", 4) == 0)
>  > +                             /* 100M half-duplex */
>  > +                             lp->option = MSP_OPT_100M | MSP_OPT_HDUP;
>  > +                     else if (memcmp(ethptr, "10f", 3) == 0)
>  > +                             /* 10M full-duplex */
>  > +                             lp->option = MSP_OPT_10M | MSP_OPT_FDUP;
>  > +                     else if (memcmp(ethptr, "10h", 3) == 0)
>  > +                             /* 100M half-duplex */
>  > +                             lp->option = MSP_OPT_10M | MSP_OPT_HDUP;
>  > +
>  > +                     if (netif_msg_probe(lp))
>  > +                             printk(KERN_INFO "MSPETH(init_cmdline) 
> eth%d: "
>  > +                                     "boot = %s, option = %02x\n",
>  > +                                     lp->unit, command_line, 
> lp->option);
> 
> this seems unnecessary, with ethtool use at boot

Are you referring to the printk or the option parsing above it?


> +/************************************************************************** 
> 
>  > + * Initialize the phy -- set the speed and duplex. Wait for
>  > + * autonegotiation to complete. If it doesn't then force the
>  > + * renegotiation. If *that* fails then reset the phy and try
>  > + * again. Finally just make some assumptions. If autonegotiation
>  > + * is disabled then just force values.
>  > + */
>  > +static void
>  > +mspeth_phy_init(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     u32 ctl, neg_result;
>  > +     int i;
>  > +     enum {AUTONEG, AUTONEG_FORCE, PHYRESET} auto_status;
>  > +     char *link_type;
>  > +     char *link_stat;
>  > +
>  > +     /* check for defaults and autonegotiate */
>  > +     if (lp->option == MSP_OPT_AUTO) {
>  > +             /*
>  > +              * Make sure the autonegotiation is enabled and then wait
>  > +              * for the autonegotion to complete.
>  > +              */
>  > +             link_type = "Autoneg";
>  > +             for (auto_status = AUTONEG; auto_status <= PHYRESET;
>  > +                  auto_status++) {
>  > +                     /*
>  > +                      * Run through all the various autonegotion 
> methods
>  > +                      * until we fail
>  > +                      */
>  > +                     switch (auto_status) {
>  > +                     case AUTONEG:
>  > +                             mspphy_write(lp->phyptr, MII_BMCR,
>  > +                                             BMCR_ANENABLE);
>  > +                             break;
>  > +                     case AUTONEG_FORCE:
>  > +                             printk(KERN_INFO "MSPETH(phy_init) "
>  > +                                     "%s: Forcing autonegotiation\n",
>  > +                                     dev->name);
>  > +                             mspphy_write(lp->phyptr, MII_BMCR,
>  > +                                     BMCR_ANENABLE | BMCR_ANRESTART);
>  > +                             break;
>  > +                     case PHYRESET:
>  > +                             printk(KERN_INFO "MSPETH(phy_init) "
>  > +                                     "%s: Resetting phy\n", dev->name);
>  > +                             mspphy_write(lp->phyptr, MII_BMCR,
>  > +                                             BMCR_RESET);
>  > +                             for (i = 0; i < 10 &&
>  > +                                  (mspphy_read(lp->phyptr, MII_BMCR) &
>  > +                                     BMCR_RESET) != 0; i++)
>  > +                                     udelay(100);
>  > +                             mspphy_write(lp->phyptr, MII_BMCR,
>  > +                                     BMCR_ANENABLE | BMCR_ANRESTART);
>  > +                             break;
>  > +                     default:
>  > +                             printk(KERN_WARNING "MSPETH(phy_init) "
>  > +                                     "%s: Unknown autonegotation 
> mode?\n",
>  > +                                     dev->name);
>  > +                             return;
> 
> why not use the generic code in drivers/net/mii.c?

I've only looked at mii.c briefly but it appears that it would involve a complete
re-write of your mspeth_phy struct and all code accessing it. That is risky
for a driver that has been solid for the last couple years and is already in
production.

Is this mandatory?


>  > +                     /*
>  > +                      * Autoneg should be underway, so lets loop
>  > +                      * and wait for it to exit.
>  > +                      */
>  > +                     if (netif_msg_link(lp))
>  > +                             printk(KERN_INFO
>  > +                                     "%s: Auto Negotiation...", 
> dev->name);
>  > +
>  > +                     for (i = 0; i < 2000 &&
>  > +                          !(mspphy_read(lp->phyptr, MII_BMSR) &
>  > +                          BMSR_ANEGCOMPLETE); i++)
>  > +                             mdelay(1);
>  > +                     if (i == 2500) {
>  > +                             /*
>  > +                              * Autonegotiation failed to complete so
>  > +                              * go to next level of negotiation.
>  > +                              */
>  > +                             if (netif_msg_link(lp))
>  > +                                     printk(KERN_INFO " failed.\n");
>  > +                             continue;
>  > +                     }
>  > +
>  > +                     /* must have succeeded so we can set the speed, 
> etc */
>  > +                     if (netif_msg_link(lp))
>  > +                             printk(KERN_INFO " done.\n");
>  > +                     neg_result = mspphy_read(lp->phyptr, MII_LPA);
>  > +                     if (neg_result & (LPA_100FULL | LPA_100HALF))
>  > +                             lp->speed = 100;
>  > +                     else
>  > +                             lp->speed = 10;
>  > +
>  > +                     if (neg_result & (LPA_100FULL | LPA_10FULL))
>  > +                             lp->fullduplex = true;
>  > +                     else
>  > +                             lp->fullduplex = false;
> 
> ditto
> 
> 
>  > +              * Check to see if *everything* failed and try to set
>  > +              * some default values.
>  > +              */
>  > +             if (auto_status > PHYRESET) {
>  > +                     printk(KERN_WARNING "Autonegotion failed. "
>  > +                             "Assuming 10Mbps, half-duplex.\n");
>  > +                     link_type = "Autoneg (failed)";
>  > +                     lp->speed = 10;
>  > +                     lp->fullduplex = false;
>  > +             }
>  > +     } else {
>  > +             /*
>  > +              * If speed and duplex are statically configured then
>  > +              * set that here.
>  > +              */
>  > +             link_type = "Static";
>  > +             ctl = 0;
>  > +             if (lp->option & MSP_OPT_100M) {
>  > +                     lp->speed = 100;
>  > +                     ctl |= BMCR_SPEED100;
>  > +             } else {
>  > +                     lp->speed = 10;
>  > +                     ctl &= ~BMCR_SPEED100;
>  > +             }
>  > +
>  > +             if (lp->option & MSP_OPT_FDUP) {
>  > +                     lp->fullduplex = true;
>  > +                     ctl |= BMCR_FULLDPLX;
>  > +             } else {
>  > +                     lp->fullduplex = false;
>  > +                     ctl &= ~BMCR_FULLDPLX;
>  > +             }
>  > +
>  > +             /* stjeanma: Don't write to the PHY for a switch */
>  > +             if (!(lp->option & MSP_OPT_SWITCH))
>  > +                     mspphy_write(lp->phyptr, MII_BMCR, ctl);
>  > +     }
>  > +
>  > +     if (!(lp->option & MSP_OPT_SWITCH)) {
>  > +             /*
>  > +              * Wait for a little bit to see if we've got a carrier
>  > +              * -- don't go crazy though.
>  > +              */
>  > +             if (netif_msg_link(lp))
>  > +                     printk(KERN_INFO "%s: Waiting for carrier ...",
>  > +                             dev->name);
>  > +             for (i = 0; i < 1000 &&
>  > +                  !(mspphy_read(lp->phyptr, MII_BMSR) &
>  > +                  BMSR_LSTATUS); i++)
>  > +                     mdelay(1);
>  > +
>  > +             if (i == 1000) {
>  > +                     if (netif_msg_link(lp))
>  > +                             printk(KERN_INFO " no carrier.\n");
>  > +                     lp->phyptr->linkup = false;
>  > +                     netif_carrier_off(dev);
>  > +                     link_stat = "Link down";
>  > +             } else {
>  > +                     if (netif_msg_link(lp))
>  > +                             printk(KERN_INFO " carrier detected.\n");
>  > +                     lp->phyptr->linkup = true;
>  > +                     netif_carrier_on(dev);
>  > +                     link_stat = "Link up";
>  > +             }
>  > +     } else {
>  > +
>  > +             /*
>  > +              * Assume we're connected. If we're using a switch
>  > +              * we always will be.
>  > +              */
>  > +             if (netif_msg_link(lp))
>  > +                     printk(KERN_INFO "%s: Using internal switch\n",
>  > +                             dev->name);
>  > +
>  > +             /* stjeanma: PHY might not be allocated for a switch */
>  > +             if (lp->phyptr != NULL)
>  > +                     lp->phyptr->linkup = true;
>  > +
>  > +             /* Turn on the carrier */
>  > +             netif_carrier_on(dev);
>  > +             link_stat = "Link up";
>  > +     }
>  > +
>  > +     /*
>  > +      * Configure the MAC with the duplex setting
>  > +      * -- it doesn't care about speed.
>  > +      */
>  > +     if (lp->fullduplex)
>  > +             msp_write(lp, MSPETH_MAC_Ctl,
>  > +                     msp_read(lp, MSPETH_MAC_Ctl) | MAC_FullDup);
>  > +     else
>  > +             msp_write(lp, MSPETH_MAC_Ctl,
>  > +                     msp_read(lp, MSPETH_MAC_Ctl) & ~MAC_FullDup);
>  > +
>  > +     if (netif_msg_link(lp))
>  > +             printk(KERN_INFO
>  > +                     "%s: %s, %s, linkspeed %dMbps, %s Duplex\n",
>  > +                     dev->name, link_type, link_stat, lp->speed,
>  > +                     lp->fullduplex ? "Full" : "Half");
>  > +}
>  > +
>  > 
> +/************************************************************************** 
> 
>  > + * Check the link for a carrier when the link check timer expires.
>  > + * If the link is down and it has been down for a while (at least 1
>  > + * timer delay) then change the upper layer link state to match.
>  > + * Do a soft-restart if we're bringing the link up. Reschedule the
>  > + * timer of course.
>  > + */
>  > +static void
>  > +mspeth_link_check(unsigned long data)
>  > +{
>  > +     struct net_device *dev = (struct net_device *)data;
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     enum {LINKGOOD, LINKBAD, LINKUNKNOWN} linkstatus;
>  > +
>  > +     /* check the current link status */
>  > +     linkstatus = LINKUNKNOWN;
>  > +     if (mspphy_read(lp->phyptr, MII_BMSR) & BMSR_LSTATUS) {
>  > +             if (lp->phyptr->linkup)
>  > +                     linkstatus = LINKGOOD;
>  > +             lp->phyptr->linkup = true;
>  > +     } else {
>  > +             if (!lp->phyptr->linkup)
>  > +                     linkstatus = LINKBAD;
>  > +             lp->phyptr->linkup = false;
>  > +     }
>  > +
>  > +     /* check the upper layer status */
>  > +     if (netif_carrier_ok(dev)) {
>  > +             /*
>  > +              * Upper layer thinks we're ok but the link is bad, so
>  > +              * take the link down.
>  > +              */
>  > +             if (linkstatus == LINKBAD) {           
>  > +                     if (netif_msg_link(lp))
>  > +                             printk(KERN_INFO "MSPETH(link_check) %s: "
>  > +                                     "NO LINK DETECTED\n", dev->name);
>  > +                     netif_stop_queue(dev);
>  > +                     netif_carrier_off(dev);
>  > +             }
>  > +     } else {
>  > +             /*
>  > +              * Upper layer thinks we're broken but we've recovered so
>  > +              * do a soft-restart and bring the link back up.
>  > +              */
>  > +             if (linkstatus == LINKGOOD) {
>  > +                     if (netif_msg_link(lp))
>  > +                             printk(KERN_INFO "MSPETH(link_check) %s: "
>  > +                                     "LINK DETECTED\n", dev->name);
>  > +                     mspeth_soft_restart(dev);
>  > +                     netif_carrier_on(dev);
>  > +             }
>  > +     }
>  > +
>  > +     /* reschedule the timer */
>  > +     lp->link_timer.expires = jiffies + HZ / LINK_DELAY_DIV;
>  > +     add_timer(&lp->link_timer);
> 
> use generic MII code
> 
> 
>  > 
> +/************************************************************************** 
> 
>  > + * Reset the hardware and restore defaults. Queues etc must be
>  > + * cleared afterwards, although we don't change the pointers so
>  > + * they don't need to be reallocated.
>  > + */
>  > +static void
>  > +mspeth_mac_reset(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     int i;
>  > +     u32 rstpat;
>  > +
>  > +     /* hardware reset */
>  > +     switch (lp->hwunit) {
>  > +     case 0:
>  > +             rstpat = MSP_EA_RST;
>  > +             break;
>  > +     case 1:
>  > +             rstpat = MSP_EB_RST;
>  > +             break;
>  > +     case 2:
>  > +             rstpat = MSP_EC_RST;
>  > +             break;
>  > +     default:
>  > +             printk(KERN_WARNING
>  > +                     "MSPETH(mac_reset) %s: Unsupported hwunit %d\n",
>  > +                     dev->name, lp->hwunit);
>  > +             return;
>  > +     }
>  > +
>  > +     __raw_writel(rstpat, lp->rstaddr + MSPRST_SET);
>  > +     mdelay(100);
>  > +     __raw_writel(rstpat, lp->rstaddr + MSPRST_CLR);
> 
> host bus posting bug?

Not sure what you mean here? The above lines reset one of the MACs within the
SoC device.

> 
>  > +     /* Wait for the MAC to come out of reset */
>  > +     for (i = 0; i < 10; i++) {
>  > +             if ((__raw_readl(lp->rstaddr + MSPRST_STS) & rstpat) == 0)
>  > +                     break;
>  > +             ndelay(100);
>  > +     }
>  > +    
>  > +     if (netif_msg_hw(lp))
>  > +             printk(KERN_INFO "MSPETH(mac_reset) eth%d", lp->unit);
>  > +
>  > +     /* initialize registers to default value */
>  > +     msp_write(lp, MSPETH_MAC_Ctl, 0);
>  > +     msp_write(lp, MSPETH_DMA_Ctl, 0);
>  > +     msp_write(lp, MSPETH_TxThrsh, 0);
>  > +     msp_write(lp, MSPETH_TxPollCtr, 0);
>  > +     msp_write(lp, MSPETH_RxFragSize, 0);
>  > +     msp_write(lp, MSPETH_Int_En, 0);
>  > +     msp_write(lp, MSPETH_FDA_Bas, 0);
>  > +     msp_write(lp, MSPETH_FDA_Lim, 0);
>  > +     msp_write(lp, MSPETH_Int_Src, 0xffffffff); /* Write 1 to clear */
>  > +     msp_write(lp, MSPETH_ARC_Ctl, 0);
>  > +     msp_write(lp, MSPETH_Tx_Ctl, 0);
>  > +     msp_write(lp, MSPETH_Rx_Ctl, 0);
>  > +     msp_write(lp, MSPETH_ARC_Ena, 0);
>  > +     (void)msp_read(lp, MSPETH_Miss_Cnt);    /* Read to clear */
>  > +}
>  > +
>  > 
> +/************************************************************************** 
> 
>  > + * Initialize the hardware and start the DMA/MAC RX/TX. The queues must
>  > + * be setup before this is called.
>  > + */
>  > +static void
>  > +mspeth_mac_init(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     int flags;
>  > +
>  > +     /* do not interrupt me while I'm configuring the MAC */
>  > +     local_irq_save(flags);
> 
> use a spinlock
> 
> 
>  > +     /* configure the BRCTL RMII registers if we're an RMII device */
>  > +     if (identify_enet(lp->hwunit) == ENET_RMII) {
>  > +             u32 brctl = msp_read(lp, MSPETH_BCTRL_Reg) & ~RMII_Reset;
>  > +             if (identify_enetTxD(lp->hwunit) == ENETTXD_RISING)
>  > +                     brctl |= RMII_ClkRising;
>  > +             if (identify_enetTxD(lp->hwunit) == ENETTXD_FALLING)
>  > +                     brctl &= ~RMII_ClkRising;
>  > +             if (lp->speed == 10)
>  > +                     brctl |= RMII_10MBIT;
>  > +             else
>  > +                     brctl &= ~RMII_10MBIT;
>  > +             msp_write(lp, MSPETH_BCTRL_Reg, brctl);
>  > +     }
>  > +
>  > +     /* set some device structure parameters */
>  > +     dev->tx_queue_len = TX_BUF_NUM;
> 
> NAK, use the ethernet default

Again I'm not sure exactly what you are referring to. Assuming it's not the
TX queue length, but the code above that controls device specific clocking
for RMII. I'm not aware of any standard defaults for that.


>  > +     /* load station address to ARC */
>  > +     mspeth_set_arc_entry(dev, ARC_ENTRY_SOURCE, dev->dev_addr);
>  > +
>  > +     /* Enable ARC (broadcast and unicast) */
>  > +     msp_write(lp, MSPETH_ARC_Ena, ARC_Ena_Bit(ARC_ENTRY_SOURCE));
>  > +     msp_write(lp, MSPETH_ARC_Ctl, ARC_CompEn | ARC_BroadAcc);
>  > +
>  > +     /* configure DMA */
>  > +     msp_write(lp, MSPETH_DMA_Ctl, DMA_CTL_CMD);
>  > +
>  > +     /* configure the RX/TX mac */
>  > +     msp_write(lp, MSPETH_RxFragSize, 0);
>  > +     msp_write(lp, MSPETH_TxPollCtr, TX_POLL_CNT);
>  > +     msp_write(lp, MSPETH_TxThrsh, TX_THRESHOLD);
>  > +
>  > +     /* zero and enable the interrupts */
>  > +     lp->fatal_icnt = 0;
>  > +     msp_write(lp, MSPETH_Int_En, INT_EN_CMD);
>  > +
>  > +     /*
>  > +      * Set queues
>  > +      *
>  > +      * hammtrev, 2005-11-25:
>  > +      * Using the formula used in the old driver, which gives a
>  > +      * little bit less than (RX_BUF_NUM - 1) << 5, allowing for more
>  > +      * buffer descriptors attached to a frame descriptor.
>  > +      */
>  > +     msp_write(lp, MSPETH_FDA_Bas, (u32)lp->rxfd_base);
>  > +     msp_write(lp, MSPETH_FDA_Lim, (RX_BUF_NUM - 1) << 5);
> 
> you should be using DMA mapping functions (if only silly wrappers), not
> direct casts

A bit of background to clarify the drivers use...
This driver is for a proprietary MAC sitting across a proprietary bus. It is
also device and arch specific, it will never be on a PCI card.

By mapping the frame and buffer descriptors to a uncached memory segment and
allowing the DMA to make use of those addresses, we avoid a lot of extra
code/cycles when manipulating those structures throughout the driver.

In order to accomplish this the MAC must be given the uncached address above.

>  > +     /*
>  > +      * Activation method:
>  > +      * First, enable the MAC Transmitter and the DMA Receive circuits.
>  > +      * Then enable the DMA Transmitter and the MAC Receive circuits.
>  > +      */
>  > +     /* start DMA receiver */
>  > +     msp_write(lp, MSPETH_BLFrmPtr, (u32)lp->blfd_ptr);
> 
> ditto
> 
> 
>  > +     /* start MAC receiver */
>  > +     msp_write(lp, MSPETH_Rx_Ctl, RX_CTL_CMD);
>  > +
>  > +     /* start the DMA transmitter */
>  > +     msp_write(lp, MSPETH_TxFrmPtr, (u32)lp->txfd_base);
>  > +
>  > +#ifdef CONFIG_MSPETH_NAPI
>  > +     /* start the MAC transmitter */
>  > +     msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD & ~Tx_EnComp);
>  > +#else
>  > +     msp_write(lp, MSPETH_Tx_Ctl, TX_CTL_CMD);
>  > +#endif /* CONFIG_MSPETH_NAPI */
>  > +
>  > +     /* turn the interrupts back on */
>  > +     local_irq_restore(flags);
>  > +}
>  > +
>  > 

...


>  > +             /*
>  > +              * Move frame descriptors to uncached addresses. This
>  > +              * prevents spurious IntBLEx interrupts.
>  > +              */
>  > +             lp->fd_base = (void*)KSEG1ADDR((u32)lp->fd_base);
>  > +             memset(lp->fd_base, 0, size + (L1_CACHE_BYTES - 1));
> 
> use DMA mapping

Same reasoning as I described above for the Rx side.

...

>  > 
> +/************************************************************************** 
> 
>  > + * Do a *hard* restart of the device. This *will* cause packet loss, so
>  > + * it's only used as a recovery mechanism
>  > + */
>  > +static void
>  > +mspeth_hard_restart(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     int flags;
>  > +
>  > +     if (netif_msg_hw(lp))
>  > +             printk(KERN_INFO "MSPETH(hard_restart) %s: "
>  > +                     "Hard device restart\n", dev->name);
>  > +
>  > +     netif_stop_queue(dev);
>  > +
>  > +     /* please don't interrupt me while I'm resetting everything */
>  > +     local_irq_save(flags);
> 
> ditto
> 
> 
>  > +     /* Try to restart the adaptor. */
>  > +     mspeth_mac_reset(dev);
>  > +     mspeth_phy_reset(dev);
>  > +     mspeth_free_queues(dev);
>  > +     mspeth_init_queues(dev);
>  > +     mspeth_mac_init(dev);
>  > +     mspeth_phy_init(dev);
>  > +
>  > +     /* turn back on the interrupts */
>  > +     local_irq_restore(flags);
>  > +
>  > +     /* and start up the queue! We should be fixed .... */
>  > +     dev->trans_start = jiffies;
>  > +     netif_wake_queue(dev);
> 
> plus, this code is 95% duplicating the function before it

I will look at using a flag to handle the two different cases required by
error types.

>  > 
> +/************************************************************************** 
> 
>  > + * Open/initialize the board. This is called (in the current kernel)
>  > + * sometime after booting when the 'ifconfig' program is run.
>  > + *
>  > + * This routine should set everything up anew at each open, even
>  > + * registers that "should" only need to be set once at boot, so that
>  > + * there is non-reboot way to recover if something goes wrong.
>  > + */
>  > +static int
>  > +mspeth_open(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     int err = -EBUSY;
>  > +
>  > +     /* reset the hardware, disabling/clearing all interrupts */
>  > +     mspeth_mac_reset(dev);
>  > +     mspeth_phy_reset(dev);
>  > +
>  > +     /* determine preset speed and duplex settings */
>  > +     if (lp->option & MSP_OPT_10M)
>  > +             lp->speed = 10;
>  > +     else
>  > +             lp->speed = 100;
>  > +
>  > +     if (lp->option & MSP_OPT_FDUP)
>  > +             lp->fullduplex = true;
>  > +     else
>  > +             lp->fullduplex = false;
>  > +
>  > +     /* initialize the queues and the hardware */
>  > +     if (!mspeth_init_queues(dev)) {
>  > +             printk(KERN_ERR "MSPETH(open) %s: "
>  > +                     "Unable to allocate queues\n", dev->name);
>  > +             goto out_err;
>  > +     }
>  > +
>  > +     /* allocate and initialize the tasklets */
>  > +#ifndef CONFIG_MSPETH_NAPI
>  > +     tasklet_init(&lp->rx_tasklet, mspeth_rx, (u32)dev);
>  > +     tasklet_init(&lp->tx_tasklet, mspeth_txdone, (u32)dev);
>  > +#endif
> 
> with tasklets you don't need NAPI.  also, the casts are bogus

Some of our customers prefer NAPI over tasklets, that is why we have
a configuration options so each one can choose the preferred method.

I've fixed the cast for unsigned long.

...

>  > 
> +/************************************************************************** 
> 
>  > + * The inverse routine to mspeth_open(). Close the device and clean up
>  > + */
>  > +static int
>  > +mspeth_close(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     u32 flags;
>  > +
>  > +     /* please don't interrupt me while I'm shutting down everything */
>  > +     local_irq_save(flags);
> 
> NAK

Will switch to a lock ...

>  > +     /* stop the queue & let the world know about it */
>  > +     netif_stop_queue(dev);
>  > +     netif_carrier_off(dev);
>  > +
>  > +     /* kill the tasklets before resetting devices */
>  > +#ifndef CONFIG_MSPETH_NAPI
>  > +     tasklet_kill(&lp->rx_tasklet);
>  > +     tasklet_kill(&lp->tx_tasklet);
>  > +#endif
>  > +     tasklet_kill(&lp->hard_restart_tasklet);
>  > +
>  > +     /* smite the link check timers */
>  > +     del_timer_sync(&lp->link_timer);
> 
> BUG to do this while interrupts disabled

... eliminating calling del_timer_sync() with interrupts disabled.


>  > +     /* Clean up the adaptor. */
>  > +     mspeth_mac_reset(dev);
>  > +     mspeth_phy_reset(dev);
>  > +
>  > +     /* free the the queue memeory */
>  > +     mspeth_free_queues(dev);
>  > +
>  > +     /* free up the resources */
>  > +     free_irq(dev->irq, dev);
>  > +
>  > +     /*
>  > +      * Deassign the phy.
>  > +      * stjeanma: PHY might not be allocated for a switch.
>  > +      */
>  > +     if (lp->phyptr != NULL)
>  > +             lp->phyptr->assigned = false;
>  > +
>  > +     /* turn back on the interrupts */
>  > +     local_irq_restore(flags);
>  > +
>  > +     return 0;
>  > +}
>  > +
>  > 

...

>  > 
> +/************************************************************************** 
> 
>  > + * Process a single RX packet, including sending it up the stack and
>  > + * reallocating the buffer. Return the next buffer in the RX queue.
>  > + * This routine assumes that the current FD pointed to by rxfd_curr
>  > + * has been invalidated with the cache and is current with main memory.
>  > + */
>  > +inline static struct q_desc *
>  > +mspeth_rx_onepkt(struct net_device *dev) {
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     u32 status;
>  > +     struct q_desc *next_rxfd;
>  > +     int bdnum, len;
>  > +     struct sk_buff *skb;
>  > +     dma_addr_t dma_skb;
>  > +
>  > +     /* collect all the relevent information */
>  > +     status = lp->rxfd_curr->fd.FDStat;
>  > +     /* Drop the FCS from the length */
>  > +     len = (lp->rxfd_curr->bd.BDCtl & BD_BuffLength_MASK) - 4;
>  > +     bdnum = (lp->rxfd_curr->bd.BDCtl & BD_RxBDID_MASK) >> 
> BD_RxBDID_SHIFT;
>  > +
>  > +     if (netif_msg_intr(lp))
>  > +             printk(KERN_INFO "MSPETH(rx_onepkt) %s: "
>  > +                     "RxFD.\n", dev->name);
>  > +     if (netif_msg_rx_status(lp))
>  > +             dump_qdesc(lp->rxfd_curr);
>  > +#ifdef MSPETH_DUMP_QUEUES
>  > +     if (netif_msg_rx_status(lp) &&
>  > +         (!bdnum && (rx_bdnums[lp->unit][rx_bdnums_ind[lp->unit]]
>  > +                                     != (RX_BUF_NUM << 1) - 1)))
>  > +             dump_qdesc(lp->rxfd_curr);
>  > +     catalog_rx_bdnum(lp->unit, bdnum);
>  > +#endif /* MSPETH_DUMP_QUEUES */
>  > +
>  > +     /*
>  > +      * The packet has been received correctly so prepare to send
>  > +      * it up the stack
>  > +      */
>  > +     if (likely(status & Rx_Good)) {
>  > +             skb = lp->rx_skbp[bdnum];
>  > +             dma_skb = lp->rx_dma_skbp[bdnum];
>  > +
>  > +             /*
>  > +              * If a replacement buffer can be allocated then send
>  > +              * the skb up the stack otherwise we drop the packet
>  > +              * and reuse the existing buffer
>  > +              */
>  > +             lp->rx_skbp[bdnum] = mspeth_alloc_skb(dev);
>  > +             if (likely(lp->rx_skbp[bdnum] != NULL)) {
>  > +#ifdef CONFIG_DMA_NONCOHERENT
>  > +                     /* Replacement buffer map and sync for dma */
>  > +                     lp->rx_dma_skbp[bdnum] = dma_map_single(
>  > +                                     lp->dev, lp->rx_skbp[bdnum]->data,
>  > +                                     MSP_END_BUFSIZE, DMA_FROM_DEVICE);
>  > +
>  > +                     /*
>  > +                      * Replacement buffer has been allocated
>  > +                      * successfully, so sync and un-map original
>  > +                      * buffer.
>  > +                      */
>  > +                     dma_sync_single_for_cpu(lp->dev, dma_skb,
>  > +                                             len, DMA_FROM_DEVICE);
>  > +                     dma_unmap_single(lp->dev, dma_skb,
>  > +                                     MSP_END_BUFSIZE, DMA_NONE);
>  > +#endif
>  > +
>  > +                     /* complete the skb and send it up the stack */
>  > +                     skb_put(skb, len);
>  > +                     skb->protocol = eth_type_trans(skb, dev);
>  > +
>  > +#ifdef CONFIG_MSPETH_NAPI
>  > +                     netif_receive_skb(skb);
>  > +#else
>  > +                     netif_rx(skb);
>  > +#endif /* CONFIG_MSPETH_NAPI */
>  > +                     dev->last_rx = jiffies;
>  > +
>  > +                     lp->stats.rx_packets++;
>  > +                     lp->stats.rx_bytes += len;
> 
> are you certain that len does not include FCS?

Yes fairly certain. Originally it wasn't included and the count didn't match
other hosts/test equipment. We also had a customer report the same finding.
Looking through existing drivers I see some doing both.


>  > +                     if (netif_msg_rx_status(lp))
>  > +                             print_eth(1, skb->data, len);
>  > +                     if (netif_msg_pktdata(lp))
>  > +                             print_buf(skb->data, len);
>  > +             } else {
>  > +                     if (netif_msg_rx_err(lp))
>  > +                             printk(KERN_WARNING "MSPETH(rx_onepkt) 
> %s: "
>  > +                                     "Memory squeeze, dropping 
> packet.\n",
>  > +                                     dev->name);
>  > +                     lp->rx_skbp[bdnum] = skb;
>  > +                     lp->stats.rx_dropped++;
>  > +             }
>  > +
>  > +             /* Do the rounding for the 32-bit data alignment */
>  > +             lp->blfd_ptr->bd[bdnum].BuffData =
>  > +                             (u32)lp->rx_skbp[bdnum]->data &
>  > +                             BD_DataAlign_MASK;
> 
> u32 casts usually indicate you should be using dma_addr_t instead

The cast is not done for DMA alignment but for IP header alignment.
 From the comment in mspeth_init_queues():
	/*
	 * Initialize the buffer list entries reserving 2 bytes
	 * in the skb results in a 16-byte aligned  IP header,
	 * but also puts the skb->data at a 16-bit boundary.
	 * The hardware requires a 32-bit aligned buffer. So we
	 * round back two bytes and then instruct the hardware
	 * to skip forward 2 bytes into the buffer.
	 */

> 
>  > +     } else {
>  > +             lp->stats.rx_errors++;
>  > +             /* WORKAROUND: LongErr and CRCErr means Overflow. */
>  > +             if ((status & Rx_LongErr) && (status & Rx_CRCErr)) {
>  > +                     status &= ~(Rx_LongErr | Rx_CRCErr);
>  > +                     status |= Rx_Over;
>  > +             }
>  > +             if (status & Rx_LongErr)
>  > +                     lp->stats.rx_length_errors++;
>  > +             if (status & Rx_Over)
>  > +                     lp->stats.rx_fifo_errors++;
>  > +             if (status & Rx_CRCErr)
>  > +                     lp->stats.rx_crc_errors++;
>  > +             if (status & Rx_Align)
>  > +                     lp->stats.rx_frame_errors++;
>  > +     }
>  > +
>  > +     /* allocate buffer back to controller */
>  > +     lp->blfd_ptr->bd[bdnum].BDCtl =
>  > +             (BD_CownsBD | (bdnum << BD_RxBDID_SHIFT) | 
> MSP_END_BUFSIZE);
>  > +     blocking_read_reg32(&lp->blfd_ptr->bd[bdnum].BDCtl);
>  > +
>  > +     /* save next FD before allocating current one to controller */
>  > +     next_rxfd = (struct q_desc *)lp->rxfd_curr->fd.FDNext;
>  > +
>  > +     /*
>  > +      * Return q_desc to the controller. Setting fd0.FDCtl last 
> prevents
>  > +      * the controller from using this q_desc until we're done.
>  > +      *
>  > +      * Writeback the changes back to the RAM so that MAC can see the
>  > +      * available buffers on a write-through cache this doesn't really
>  > +      * do anything, but on a writeback cache this is quite important.
>  > +      *
>  > +      * stjeanma, 2006-02-08:
>  > +      * Uncached writes need to be read back to ensure they reach RAM.
>  > +      */
>  > +     lp->rxfd_curr->fd0.FDNext = 0;
>  > +     lp->rxfd_curr->fd0.FDSystem = 0;
>  > +     lp->rxfd_curr->fd0.FDStat = 0;
>  > +     lp->rxfd_curr->fd1.FDNext = 0;
>  > +     lp->rxfd_curr->fd1.FDSystem = 0;
>  > +     lp->rxfd_curr->fd1.FDStat = 0;
>  > +     lp->rxfd_curr->fd1.FDCtl = FD_CownsFD;
>  > +     lp->rxfd_curr->fd0.FDCtl = FD_CownsFD;
>  > +     blocking_read_reg32(&lp->rxfd_curr->fd0.FDCtl);
>  > +
>  > +     return next_rxfd;
>  > +}
>  > +
>  > +#ifdef CONFIG_MSPETH_NAPI
>  > 

...

>  > 
> +/************************************************************************** 
> 
>  > + * Basic transmit function -- called from the upper network layers
>  > + */
>  > +static int
>  > +mspeth_send_packet(struct sk_buff *skb, struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +     struct q_desc *txfd_ptr;
>  > +
>  > +     /*
>  > +      * NOTE that if we cannot transmit then we must return 1 and
>  > +      * *not touch* the skb since it doesn't belong to us. The
>  > +      * networking layer above will take care of it.
>  > +      */
>  > +
>  > +#ifdef CONFIG_MSPETH_NAPI
>  > +     /*
>  > +      * We have no txdone interrupt on NAPI.
>  > +      * Free transmitted buffers here.
>  > +      */
>  > +     mspeth_txdone((unsigned long)dev);
> 
> any such casts are bogus.  fix the need for a cast.

I have redefined for NAPI declaration to eliminate this cast. However the
non-NAPI code needs it to be an unsigned long for tasklet_init().

...

>  > 
> +/************************************************************************** 
> 
>  > + * Free the buffers which have been transmitted from the transmit 
> queue.
>  > + * Called from the tx_tasklet which is scheduled by the interrupt 
> handler
>  > + */
>  > +#ifdef CONFIG_MSPETH_NAPI
>  > +inline static void
>  > +#else
>  > +static void
>  > +#endif
>  > +mspeth_txdone(unsigned long dev_addr)
>  > +{
>  > +     struct net_device *dev = (struct net_device *)dev_addr;
> 
> you don't need to use unsigned long here, kill it

See comment above.

...

>  > +/*
>  > + * Set or clear the multicast filter for this adaptor.
>  > + * num_addrs == -1   Promiscuous mode, receive all packets
>  > + * num_addrs == 0    Normal mode, clear multicast list
>  > + * num_addrs > 0     Multicast mode, receive normal and MC packets,
>  > + *                   and do best-effort filtering.
>  > + */
>  > +static void
>  > +mspeth_set_multicast_list(struct net_device *dev)
>  > +{
>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>  > +
>  > +     if (dev->flags & IFF_PROMISC) {
>  > +             /* Enable promiscuous mode */
>  > +             msp_write(lp, MSPETH_ARC_Ctl,
>  > +                             ARC_CompEn | ARC_BroadAcc |
>  > +                             ARC_GroupAcc | ARC_StationAcc);
>  > +     } else if ((dev->flags & IFF_ALLMULTI) ||
>  > +                dev->mc_count > ARC_ENTRY_MAX - 3) {
>  > +             /* ARC 0, 1, 20 are reserved. */
>  > +             /* Disable promiscuous mode, use normal mode. */
>  > +             msp_write(lp, MSPETH_ARC_Ctl,
>  > +                             ARC_CompEn | ARC_BroadAcc | ARC_GroupAcc);
>  > +     } else if (dev->mc_count) {
>  > +             struct dev_mc_list* cur_addr = dev->mc_list;
>  > +             int i;
>  > +             int ena_bits = ARC_Ena_Bit(ARC_ENTRY_SOURCE);
>  > +
>  > +             msp_write(lp, MSPETH_ARC_Ctl, 0);
>  > +             /* Walk the address list, and load the filter */
>  > +             for (i = 0; i < dev->mc_count; i++,
>  > +                  cur_addr = cur_addr->next) {
>  > +                     if (!cur_addr)
>  > +                             break;
>  > +
>  > +                     /* entry 0, 1 is reserved. */
>  > +                     mspeth_set_arc_entry(dev, i + 2, 
> cur_addr->dmi_addr);
>  > +                     ena_bits |= ARC_Ena_Bit(i + 2);
>  > +             }
>  > +             msp_write(lp, MSPETH_ARC_Ena, ena_bits);
>  > +             msp_write(lp, MSPETH_ARC_Ctl, ARC_CompEn | ARC_BroadAcc);
>  > +     } else {
>  > +             msp_write(lp, MSPETH_ARC_Ena, 
> ARC_Ena_Bit(ARC_ENTRY_SOURCE));
>  > +             msp_write(lp, MSPETH_ARC_Ctl, ARC_CompEn | ARC_BroadAcc);
>  > +     }
> 
> what is your hardware's dev->mc_count limit?

It's 'ARC_ENTRY_MAX - 3'. I've added a test to the 'else if (dev->mc_count)'
case's for loop.

...

Marc
