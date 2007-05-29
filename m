From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
Date: Mon, 28 May 2007 23:13:28 -0400
Message-ID: <465B9A58.5000404@garzik.org>
References: <465B4DB0.1080701@pmc-sierra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Marc St-Jean <Marc_St-Jean@pmc-sierra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49919 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638AbXE2DNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 23:13:39 -0400
In-Reply-To: <465B4DB0.1080701@pmc-sierra.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marc St-Jean wrote:
> Jeff Garzik wrote:
>> Marc St-Jean wrote:
>>  > +     res = platform_get_resource(pldev, IORESOURCE_MEM, 0);
>>  > +     if (!res) {
>>  > +             printk(KERN_ERR "MSPETH(probe) %s: "
>>  > +                     "IOMEM resource not found for eth%d\n",
>>  > +                     dev->name, unit);
>>  > +             goto out_netdev;
>>  > +     }
>>  > +
>>  > +     /* reserve the memory region */
>>  > +     if (!request_mem_region(res->start, res->end - res->start + 1,
>>  > +                             cardname)) {
>>  > +             printk(KERN_ERR "MSPETH(probe) %s: unable to "
>>  > +                     "get memory/io address region 0x08%lx\n",
>>  > +                     dev->name, dev->base_addr);
>>  > +             goto out_netdev;
>>  > +     }
>>  > +
>>  > +     /* remap the memory */
>>  > +     mapaddr = ioremap_nocache(res->start, res->end - res->start + 1);
>>  > +     if (!mapaddr) {
>>  > +             printk(KERN_WARNING "MSPETH(probe) %s: "
>>  > +                     "unable to ioremap address 0x%08x\n",
>>  > +                     dev->name, res->start);
>>  > +             goto out_unreserve;
>>  > +     }
>>  > +
>>  > +     lp->mapaddr = mapaddr;
>>  > +     dev->base_addr = res->start;
>>  > +     dev->irq = platform_get_irq(pldev, 0);
>>  > +
>>  > +     /* remap the system reset registers */
>>  > +     lp->rstaddr = ioremap_nocache(MSP_RST_BASE, MSP_RST_SIZE);
>>  > +     if (!lp->rstaddr) {
>>  > +             printk(KERN_ERR "MSPETH(probe) %s: unable to "
>>  > +                     "ioremap address 0x%08x\n",
>>  > +                     dev->name, MSP_RST_BASE);
>>  > +             goto out_unmap;
>>  > +     }
>>  > +
>>  > +     /* set the logical and hardware units */
>>  > +     lp->unit = unit;
>>  > +     lp->hwunit = hwunit;
>>  > +
>>  > +     /* probe for PHYS attached to this MACs MDIO interface */
>>  > +     if (mspeth_phyprobe(dev))
>>  > +             goto out_unmap;
>>  > +
>>  > +     /* parse the environment and command line */
>>  > +     mspeth_init_cmdline(dev);
>>  > +     mspeth_init_phyaddr(dev);
>>  > +
>>  > +     /* MAC address */
>>  > +     dev->addr_len = ETH_ALEN;
>>  > +     for (i = 0; i < dev->addr_len; i++)
>>  > +             dev->dev_addr[i] = macaddr[i];
>>  > +
>>  > +     /* register the /proc entry */
>>  > +     snprintf(tmp_str, 128, "pmcmspeth%d", unit);
>>  > +     create_proc_read_entry(tmp_str, 0644, proc_net,
>>  > +                             mspeth_proc_info, dev);
>>
>> use sysfs
> 
> I thought sysfs was only required if the file was to be writable?
> Is this no longer the case?

That was never the case.

And these days, additions to procfs are insta-deprecated.  New code 
should start out with sysfs.


>>  > 
>> +/************************************************************************** 
>>
>>  > + * Probe the hardware and fill out the array of PHY control elements
>>  > + */
>>  > +static int
>>  > +mspeth_phyprobe(struct net_device *dev)
>>  > +{
>>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>>  > +     u32 reg1;
>>  > +     int phyaddr;
>>  > +     struct mspeth_phy tmp_phy;
>>  > +     struct mspeth_phy **tail_pp;
>>  > +
>>  > +     tmp_phy.next_phy = NULL;
>>  > +     tmp_phy.hwunit = lp->hwunit;
>>  > +     tmp_phy.phyaddr = 0;
>>  > +     tmp_phy.memaddr = lp->mapaddr + MSPETH_MD_DATA;
>>  > +     tmp_phy.assigned = false;
>>  > +     tmp_phy.linkup = false;
>>  > +     spin_lock_init(&tmp_phy.lock);
>>  > +
>>  > +     /* find the tail of the phy list */
>>  > +     for (tail_pp = &root_phy_dev; *tail_pp != NULL;
>>  > +          tail_pp = &(*tail_pp)->next_phy) {;}
>>  > +
>>  > +     /* probe the phys and add to list */
>>  > +     for (phyaddr = 0; phyaddr < MD_MAX_PHY; phyaddr++) {
>>
>> for standard MII, you should start at PHY ID 1, since PHY ID 0 is often
>> a ghost.  normal loop looks like
>>
>>                 for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
>>                  int phyx = phy & 0x1f;
> 
> I'm not sure what you mean by ghost, an alias for ID 1?

An alias for a non-zero PHY ID.


> We have several boards which access either stand-alone or switch/phy-combos
> at ID 0. We don't have access to all boards (some are customers) and can't
> risk breaking them at this point.

Did you read my example code?  It clearly scans PHY ID 0.  What would break?


> I've only looked at mii.c briefly but it appears that it would involve a complete
> re-write of your mspeth_phy struct and all code accessing it. That is risky
> for a driver that has been solid for the last couple years and is already in
> production.
> 
> Is this mandatory?

We are not inclined to merge Yet Another Duplicate of mii.c, which means 
twice the maintenance headache over the lifetime of the Linux kernel.


>>  > + * cleared afterwards, although we don't change the pointers so
>>  > + * they don't need to be reallocated.
>>  > + */
>>  > +static void
>>  > +mspeth_mac_reset(struct net_device *dev)
>>  > +{
>>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>>  > +     int i;
>>  > +     u32 rstpat;
>>  > +
>>  > +     /* hardware reset */
>>  > +     switch (lp->hwunit) {
>>  > +     case 0:
>>  > +             rstpat = MSP_EA_RST;
>>  > +             break;
>>  > +     case 1:
>>  > +             rstpat = MSP_EB_RST;
>>  > +             break;
>>  > +     case 2:
>>  > +             rstpat = MSP_EC_RST;
>>  > +             break;
>>  > +     default:
>>  > +             printk(KERN_WARNING
>>  > +                     "MSPETH(mac_reset) %s: Unsupported hwunit %d\n",
>>  > +                     dev->name, lp->hwunit);
>>  > +             return;
>>  > +     }
>>  > +
>>  > +     __raw_writel(rstpat, lp->rstaddr + MSPRST_SET);
>>  > +     mdelay(100);
>>  > +     __raw_writel(rstpat, lp->rstaddr + MSPRST_CLR);
>>
>> host bus posting bug?
> 
> Not sure what you mean here? The above lines reset one of the MACs within the
> SoC device.

Are writes delayed or posted in any way?

If yes, then the timing of mdelay() is not guaranteed.  Normally you 
must issue a read, following a write, before your delay.  That 
guarantees the full delay occurs after the write reaches the MAC.


>>  > +     /* load station address to ARC */
>>  > +     mspeth_set_arc_entry(dev, ARC_ENTRY_SOURCE, dev->dev_addr);
>>  > +
>>  > +     /* Enable ARC (broadcast and unicast) */
>>  > +     msp_write(lp, MSPETH_ARC_Ena, ARC_Ena_Bit(ARC_ENTRY_SOURCE));
>>  > +     msp_write(lp, MSPETH_ARC_Ctl, ARC_CompEn | ARC_BroadAcc);
>>  > +
>>  > +     /* configure DMA */
>>  > +     msp_write(lp, MSPETH_DMA_Ctl, DMA_CTL_CMD);
>>  > +
>>  > +     /* configure the RX/TX mac */
>>  > +     msp_write(lp, MSPETH_RxFragSize, 0);
>>  > +     msp_write(lp, MSPETH_TxPollCtr, TX_POLL_CNT);
>>  > +     msp_write(lp, MSPETH_TxThrsh, TX_THRESHOLD);
>>  > +
>>  > +     /* zero and enable the interrupts */
>>  > +     lp->fatal_icnt = 0;
>>  > +     msp_write(lp, MSPETH_Int_En, INT_EN_CMD);
>>  > +
>>  > +     /*
>>  > +      * Set queues
>>  > +      *
>>  > +      * hammtrev, 2005-11-25:
>>  > +      * Using the formula used in the old driver, which gives a
>>  > +      * little bit less than (RX_BUF_NUM - 1) << 5, allowing for more
>>  > +      * buffer descriptors attached to a frame descriptor.
>>  > +      */
>>  > +     msp_write(lp, MSPETH_FDA_Bas, (u32)lp->rxfd_base);
>>  > +     msp_write(lp, MSPETH_FDA_Lim, (RX_BUF_NUM - 1) << 5);
>>
>> you should be using DMA mapping functions (if only silly wrappers), not
>> direct casts
> 
> A bit of background to clarify the drivers use...
> This driver is for a proprietary MAC sitting across a proprietary bus. It is
> also device and arch specific, it will never be on a PCI card.
> 
> By mapping the frame and buffer descriptors to a uncached memory segment and
> allowing the DMA to make use of those addresses, we avoid a lot of extra
> code/cycles when manipulating those structures throughout the driver.
> 
> In order to accomplish this the MAC must be given the uncached address above.

See the "if only silly wrappers" comment.  You should create a 
DMA-mapping API, even if it intentionally degenerates inside the 
compiler's optimizer to a direct memory access and/or no-ops.  The gives 
the driver well-defined access points for accessing memory with unusual 
attributes such as uncached memory segments.


>>  > + * Open/initialize the board. This is called (in the current kernel)
>>  > + * sometime after booting when the 'ifconfig' program is run.
>>  > + *
>>  > + * This routine should set everything up anew at each open, even
>>  > + * registers that "should" only need to be set once at boot, so that
>>  > + * there is non-reboot way to recover if something goes wrong.
>>  > + */
>>  > +static int
>>  > +mspeth_open(struct net_device *dev)
>>  > +{
>>  > +     struct mspeth_priv *lp = netdev_priv(dev);
>>  > +     int err = -EBUSY;
>>  > +
>>  > +     /* reset the hardware, disabling/clearing all interrupts */
>>  > +     mspeth_mac_reset(dev);
>>  > +     mspeth_phy_reset(dev);
>>  > +
>>  > +     /* determine preset speed and duplex settings */
>>  > +     if (lp->option & MSP_OPT_10M)
>>  > +             lp->speed = 10;
>>  > +     else
>>  > +             lp->speed = 100;
>>  > +
>>  > +     if (lp->option & MSP_OPT_FDUP)
>>  > +             lp->fullduplex = true;
>>  > +     else
>>  > +             lp->fullduplex = false;
>>  > +
>>  > +     /* initialize the queues and the hardware */
>>  > +     if (!mspeth_init_queues(dev)) {
>>  > +             printk(KERN_ERR "MSPETH(open) %s: "
>>  > +                     "Unable to allocate queues\n", dev->name);
>>  > +             goto out_err;
>>  > +     }
>>  > +
>>  > +     /* allocate and initialize the tasklets */
>>  > +#ifndef CONFIG_MSPETH_NAPI
>>  > +     tasklet_init(&lp->rx_tasklet, mspeth_rx, (u32)dev);
>>  > +     tasklet_init(&lp->tx_tasklet, mspeth_txdone, (u32)dev);
>>  > +#endif
>>
>> with tasklets you don't need NAPI.  also, the casts are bogus
> 
> Some of our customers prefer NAPI over tasklets, that is why we have
> a configuration options so each one can choose the preferred method.

This again revisits the issue of /not/ duplicating code that exists 
elsewhere.  The CONFIG_MSPETH_NAPI choice is essentially between "NAPI" 
and "NAPI implemented solely within our driver".  Drivers that permit a 
NAPI compilation choice allow the user to choose between no software 
mitigation (no-NAPI) or software mitigation.  That is a reasonable choice.

But including your own software mitigation scheme is wasteful, and 
different from the NAPI/no-NAPI configurations that normally get accepted.

	Jeff


