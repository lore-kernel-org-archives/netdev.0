From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] add driver for enc28j60 ethernet chip
Date: Fri, 14 Dec 2007 10:56:53 -0800
Message-ID: <20071214105653.787ab4c6@deepthought>
References: <475EA546.7030202@eptar.com>
	<20071211090648.24ee1742@freepuppy.rosehill>
	<47624B2F.9010503@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56352 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753728AbXLNS7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 13:59:07 -0500
In-Reply-To: <47624B2F.9010503@eptar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2007 10:21:51 +0100
Claudio Lanconelli <lanconelli.claudio@eptar.com> wrote:

> Hi Stephen,
> thank you for your suggestions.
> I already applied trivial fixes, but I have questions on some points, 
> see inline.
> 
> Stephen Hemminger wrote:
> > General comments:
> >   * device driver does no carrier detection. This makes it useless
> >     for bridging, bonding, or any form of failover.
> >
> >   * use msglevel method (via ethtool) to control debug messages
> >     rather than kernel configuration. This allows enabling debugging
> >     without recompilation which is important in distributions.
> >
> >   * Please add ethtool support
> >
> >   * Consider using NAPI
> >
> >   
> Can you point me to a possibly simple driver that uses ethtool and NAPI? 

No driver stays simple! but look at tg3, sky2, r8169 for examples.

> Or other example that I can use for reference.
> May be the skeleton should be updated.
> 
> >  * use netdev_priv(netdev) rather than netdev->priv
> 
> I can't find where I used netdev->priv, may be do you mean priv->netdev?

yes

(skipping other comments)

> >
> > +static int __devinit enc28j60_probe(struct spi_device *spi)
> > +{
> > +	struct net_device *dev;
> > +	struct enc28j60_net_local *priv;
> > +	int ret = 0;
> > +
> > +	dev_dbg(&spi->dev, "%s() start\n", __FUNCTION__);
> > +
> > +	dev = alloc_etherdev(sizeof(struct enc28j60_net_local));
> > +	if (!dev) {
> > +		ret = -ENOMEM;
> > +		goto error_alloc;
> > +	}
> > +	priv = netdev_priv(dev);
> > +
> > +	priv->netdev = dev;	/* priv to netdev reference */
> > +	priv->spi = spi;	/* priv to spi reference */
> > +	priv->spi_transfer_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
> >
> > Why not declare the transfer buffer as an array in spi?
> >   
> I don't understand exactly what do you mean here.
> spi field point to struct spi_device from SPI subsystem.
> Other SPI client driver uses an allocated buffer too.

I just noticed that you alloc an ether device then do an additional
allocation for the buffer.  It makes sense if there is other uses.
You do need to be careful for cases where transfer_buf might be used
after free: module unload (your probably safe), and client driver
using during shutdown.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
