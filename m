From: Darek Marcinkiewicz <reksio@newterm.pl>
Subject: Re: [PATCH v2 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Wed, 30 Apr 2014 07:54:18 +0200
Message-ID: <20140430055418.GC20080@newterm.pl>
References: <20140428053658.GA20916@newterm.pl>
 <20140429.154508.1310732534931361787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140429.154508.1310732534931361787.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2014 at 03:45:08PM -0400, David Miller wrote:
> From: Darek Marcinkiewicz <reksio@newterm.pl>
> Date: Mon, 28 Apr 2014 07:36:58 +0200
> 
> > +void *ec_bh_alloc_dma_mem(struct bh_priv *priv,
> > +			     int channel,
> > +			     u8 **buf,
> > +			     dma_addr_t *phys,
> > +			     dma_addr_t *phys_buf,
> > +			     size_t *len) {
> > +	u32 mask;
> > +	int offset = channel * DMA_CHAN_SIZE + DMA_CHAN_OFFSET;
> > +
> > +	iowrite32(0xffffffff, priv->dma_io + offset);
> > +
> > +	mask = ioread32(priv->dma_io + offset);
> > +	mask &= 0xfffffffc;
> > +	dev_info(PRIV_TO_DEV(priv),
> > +		 "Read mask %x for channel %d\n",
> > +		 mask, channel);
> > +	*len = ~mask + 1;
> > +
> > +	dev_info(PRIV_TO_DEV(priv),
> > +		 "Allocating %d bytes for channel %d",
> > +		 (int)*len, channel);
> > +	*buf = pci_alloc_consistent(priv->dev,
> > +				    *len * 2,
> > +				    phys_buf);
> 
> This is really confusing, the log message says that it allocates
> "*len" bytes, but actually you are allocating "*len * 2" bytes as
> per the arguments you are passing into pci_alloc_consistent.
> 
> Either one or the other is wrong, and if "*len * 2" is the correct
> size then it should be explained why you're doubling this value
> but providing just plain "*len" to the caller.
> 
> All of these *len values seem to be doubled over and over again,
> in the memset() calls, in the pci_free_consistent() calls during
> resource release on probe error and driver shutdown.
> 
> Why not just assign X * 2 to *len and get rid of this doubling all
> over the place?
> 
This device imposes some limitations on location and size of the buffers
that it dma data from/to. It has a "mask" parameter saying two things:
1. RX/TX buffers have to be aligned to "mask" bits.
2. Their max size is 2^mask.
In order to have a buffer meeting above criteria driver allocates
chunk of size 2 * max buffer size, and half of this chunk gets
used later on. So, len here is the size of that aligned buffer, whereas
2 * len is how much memory was actually allocated. 

So, yes, this is a little bit confusing. I'll try to clean this up
a little bit and send updated patch.

Thank you!

-- 
DM
