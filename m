From: Matteo Croce <technoboy85@gmail.com>
Subject: Re: [PATCH][MIPS][7/7] AR7: ethernet
Date: Fri, 7 Sep 2007 01:21:41 +0200
Message-ID: <200709070121.42629.technoboy85@gmail.com>
References: <200708201704.11529.technoboy85@gmail.com> <200709061734.11170.technoboy85@gmail.com> <20070906153025.7cb71cb1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ejka@imfi.kspu.ru, jgarzik@pobox.com,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@coreworks.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:23221 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932432AbXIFXVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 19:21:46 -0400
Received: by an-out-0708.google.com with SMTP id d31so54392and
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2007 16:21:45 -0700 (PDT)
In-Reply-To: <20070906153025.7cb71cb1.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il Friday 07 September 2007 00:30:25 Andrew Morton ha scritto:
> > On Thu, 6 Sep 2007 17:34:10 +0200 Matteo Croce <technoboy85@gmail.com> wrote:
> > Driver for the cpmac 100M ethernet driver.
> > It works fine disabling napi support, enabling it gives a kernel panic
> > when the first IPv6 packet has to be forwarded.
> > Other than that works fine.
> > 
> 
> I'm not too sure why I got cc'ed on this (and not on patches 1-6?) but
> whatever.

I mailed every maintainer in the respective section in the file MAINTAINERS
and you were in the "NETWORK DEVICE DRIVERS" section

> This patch introduces quite a number of basic coding-style mistakes. 
> Please run it through scripts/checkpatch.pl and review the output.

Already done. I'm collecting other suggestions before committing

> The patch introduces vast number of volatile structure fields.  Please see
> Documentation/volatile-considered-harmful.txt.

Removing them and the kernel hangs at module load

> The patch inroduces a modest number of unneeded (and undesirable) casts of
> void*, such as
> 
> +	struct cpmac_mdio_regs *regs = (struct cpmac_mdio_regs *)bus->priv;
> 
> please check for those and fix them up.

Done

> The driver implements a driver-private skb pool.  I don't know if this is
> something which we like net drivers doing?  If it is approved then surely
> there should be a common implementation for it somewhere?

Are you referring at cpmac_poll?

> The driver has some LINUX_VERSION_CODE ifdefs.  We usually prefer that such
> code not be present in a merged-up driver.

I will remove in the final release, now I need for testing: my running kernel
is older than current git

> 
> > +			priv->regs->mac_hash_low = 0xffffffff;
> > +			priv->regs->mac_hash_high = 0xffffffff;
> > +		} else {
> > +			for (i = 0, iter = dev->mc_list; i < dev->mc_count;
> > +			    i++, iter = iter->next) {
> > +				hash = 0;
> > +				tmp = iter->dmi_addr[0];
> > +				hash  ^= (tmp >> 2) ^ (tmp << 4);
> > +				tmp = iter->dmi_addr[1];
> > +				hash  ^= (tmp >> 4) ^ (tmp << 2);
> > +				tmp = iter->dmi_addr[2];
> > +				hash  ^= (tmp >> 6) ^ tmp;
> > +				tmp = iter->dmi_addr[4];
> > +				hash  ^= (tmp >> 2) ^ (tmp << 4);
> > +				tmp = iter->dmi_addr[5];
> > +				hash  ^= (tmp >> 4) ^ (tmp << 2);
> > +				tmp = iter->dmi_addr[6];
> > +				hash  ^= (tmp >> 6) ^ tmp;
> > +				hash &= 0x3f;
> > +				if (hash < 32) {
> > +					hashlo |= 1<<hash;
> > +				} else {
> > +					hashhi |= 1<<(hash - 32);
> > +				}
> > +			}
> > +
> > +			priv->regs->mac_hash_low = hashlo;
> > +			priv->regs->mac_hash_high = hashhi;
> > +		}
> 
> Do we not have a library function anywhere which will perform this little
> multicasting hash?

Can you tell me the function so i'll implement it?

> > +static inline struct sk_buff *cpmac_rx_one(struct net_device *dev,
> > +					   struct cpmac_priv *priv,
> > +					   struct cpmac_desc *desc)
> > +{
> > +	unsigned long flags;
> > +	char *data;
> > +	struct sk_buff *skb, *result = NULL;
> > +
> > +	priv->regs->rx_ack[0] = virt_to_phys(desc);
> > +	if (unlikely(!desc->datalen)) {
> > +		if (printk_ratelimit())
> > +			printk(KERN_WARNING "%s: rx: spurious interrupt\n",
> > +			       dev->name);
> > +		priv->stats.rx_errors++;
> > +		return NULL;
> > +	}
> > +
> > +	spin_lock_irqsave(&priv->lock, flags);
> > +	skb = cpmac_get_skb(dev);
> > +	if (likely(skb)) {
> > +		data = (char *)phys_to_virt(desc->hw_data);
> > +		dma_cache_inv((u32)data, desc->datalen);
> > +		skb_put(desc->skb, desc->datalen);
> > +		desc->skb->protocol = eth_type_trans(desc->skb, dev);
> > +		desc->skb->ip_summed = CHECKSUM_NONE;
> > +		priv->stats.rx_packets++;
> > +		priv->stats.rx_bytes += desc->datalen;
> > +		result = desc->skb;
> > +		desc->skb = skb;
> > +	} else {
> > +#ifdef CPMAC_DEBUG
> > +		if (printk_ratelimit())
> > +			printk("%s: low on skbs, dropping packet\n",
> > +			       dev->name);
> > +#endif
> > +		priv->stats.rx_dropped++;
> > +	}
> > +	spin_unlock_irqrestore(&priv->lock, flags);
> > +
> > +	desc->hw_data = virt_to_phys(desc->skb->data);
> > +	desc->buflen = CPMAC_SKB_SIZE;
> > +	desc->dataflags = CPMAC_OWN;
> > +	dma_cache_wback((u32)desc, 16);
> > +
> > +	return result;
> > +}
> 
> This function is far too large to be inlined.
> 
> > +static irqreturn_t cpmac_irq(int irq, void *dev_id)
> > +{
> > +	struct net_device *dev = (struct net_device *)dev_id;
> 
> unneeded cast

fixed

> > +static int __devinit cpmac_probe(struct platform_device *pdev)
> > +{
> > +	int i, rc, phy_id;
> > +	struct resource *res;
> > +	struct cpmac_priv *priv;
> > +	struct net_device *dev;
> > +	struct plat_cpmac_data *pdata;
> > +
> > +	if (strcmp(pdev->name, "cpmac") != 0)
> > +		return -ENODEV;
> 
> I don't think this can happen?  If it can, something is pretty screwed up?

Hehe, so screwed that you won't care about your ethernet ;)

> > +	pdata = pdev->dev.platform_data;
> > +
> > +	for (phy_id = 0; phy_id < PHY_MAX_ADDR; phy_id++) {
> > +		if (!(pdata->phy_mask & (1 << phy_id)))
> > +			continue;
> > +		if (!cpmac_mii.phy_map[phy_id])
> > +			continue;
> > +		break;
> > +	}
> > +
> > +	if (phy_id == PHY_MAX_ADDR) {
> > +		if (external_switch) {
> > +			phy_id = 0;
> > +		} else {
> > +			printk("cpmac: no PHY present\n");
> > +			return -ENODEV;
> > +		}
> > +	}
> > +
> > +	dev = alloc_etherdev(sizeof(struct cpmac_priv));
> > +
> > +	if (!dev) {
> > +		printk(KERN_ERR "cpmac: Unable to allocate net_device structure!\n");
> > +		return -ENOMEM;
> > +	}
> > +
> > +	SET_MODULE_OWNER(dev);
> > +	platform_set_drvdata(pdev, dev);
> > +	priv = netdev_priv(dev);
> > +
> > +	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
> > +	if (!res) {
> > +		rc = -ENODEV;
> > +		goto fail;
> > +	}
> > +
> > +	dev->mem_start = res->start;
> > +	dev->mem_end = res->end;
> > +	dev->irq = platform_get_irq_byname(pdev, "irq");
> > +
> > +	dev->mtu                = 1500;
> > +	dev->open               = cpmac_open;
> > +	dev->stop               = cpmac_stop;
> > +	dev->set_config         = cpmac_config;
> > +	dev->hard_start_xmit    = cpmac_start_xmit;
> > +	dev->do_ioctl           = cpmac_ioctl;
> > +	dev->get_stats          = cpmac_stats;
> > +	dev->change_mtu         = cpmac_change_mtu;
> > +	dev->set_mac_address    = cpmac_set_mac_address;
> > +	dev->set_multicast_list = cpmac_set_multicast_list;
> > +	dev->tx_timeout         = cpmac_tx_timeout;
> > +	dev->ethtool_ops        = &cpmac_ethtool_ops;
> > +	if (!disable_napi) {
> > +		dev->poll = cpmac_poll;
> > +		dev->weight = min(rx_ring_size, 64);
> > +	}
> > +
> > +	memset(priv, 0, sizeof(struct cpmac_priv));
> 
> I think alloc_etherdev() already did that?

What? zeroing the memory or other stuff?

> > +	spin_lock_init(&priv->lock);
> > +	priv->msg_enable = netif_msg_init(NETIF_MSG_WOL, 0x3fff);
> > +	priv->config = pdata;
> > +	priv->dev = dev;
> > +	memcpy(dev->dev_addr, priv->config->dev_addr, sizeof(dev->dev_addr));
> > +	if (phy_id == 31) {
> > +		snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT,
> > +			 cpmac_mii.id, phy_id);
> > +	} else {
> > +		snprintf(priv->phy_name, BUS_ID_SIZE, "fixed@%d:%d", 100, 1);
> > +	}
> > +
> > +	if ((rc = register_netdev(dev))) {
> > +		printk("cpmac: error %i registering device %s\n",
> > +		       rc, dev->name);
> > +		goto fail;
> > +	}
> > +
> > +	printk("cpmac: device %s (regs: %p, irq: %d, phy: %s, mac: ",
> > +	       dev->name, (u32 *)dev->mem_start, dev->irq,
> > +	       priv->phy_name);
> > +	for (i = 0; i < 6; i++)
> > +		printk("%02x%s", dev->dev_addr[i], i < 5 ? ":" : ")\n");
> > +
> > +	return 0;
> > +
> > +fail:
> > +	free_netdev(dev);
> > +	return rc;
> > +}
> > +

What about this?

Thanks for Your attention,
Matteo Croce
