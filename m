From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH net-next 1/4] net: mvneta: Convert to be 64 bits
 compatible
Date: Thu, 24 Nov 2016 17:11:59 +0800
Message-ID: <20161124171159.2a82da4f@xhacker>
References: <20161122164844.19566-1-gregory.clement@free-electrons.com>
        <CAPv3WKf0a63qQT+xwXfUatbgLFF58e6L8J10VtBOUTam+kUcjg@mail.gmail.com>
        <20161124163327.1cc261ab@xhacker>       <21520380.oWTKcrq8DS@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
        Marcin Wojtas <mw@semihalf.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "Jason Cooper" <jason@lakedaemon.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21520380.oWTKcrq8DS@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Nov 2016 10:00:36 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> On Thursday, November 24, 2016 4:37:36 PM CET Jisheng Zhang wrote:
> > solB (a SW shadow cookie) perhaps gives a better performance: in hot path,
> > such as mvneta_rx(), the driver accesses buf_cookie and buf_phys_addr of
> > rx_desc which is allocated by dma_alloc_coherent, it's noncacheable if the
> > device isn't cache-coherent. I didn't measure the performance difference,
> > because in fact we take solA as well internally. From your experience,
> > can the performance gain deserve the complex code?  
> 
> Yes, a read from uncached memory is fairly slow, so if you have a chance
> to avoid that it will probably help. When adding complexity to the code,
> it probably makes sense to take a runtime profile anyway quantify how
> much it gains.
> 
> On machines that have cache-coherent DMA, accessing the descriptor
> should be fine, as you already have to load the entire cache line
> to read the status field.
> 
> Looking at this snippet:
> 
>                 rx_status = rx_desc->status;
>                 rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
>                 data = (unsigned char *)rx_desc->buf_cookie;
>                 phys_addr = rx_desc->buf_phys_addr;
>                 pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
>                 bm_pool = &pp->bm_priv->bm_pools[pool_id];
> 
>                 if (!mvneta_rxq_desc_is_first_last(rx_status) ||
>                     (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
> err_drop_frame_ret_pool:
>                         /* Return the buffer to the pool */
>                         mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
>                                               rx_desc->buf_phys_addr);
> err_drop_frame:
> 
> 
> I think there is more room for optimizing if you start: you read
> the status field twice (the second one in MVNETA_RX_GET_BM_POOL_ID)
> and you can cache the buf_phys_addr along with the virtual address
> once you add that.

oh, yeah! buf_phy_addr could be included too.

> 
> Generally speaking, I'd recommend using READ_ONCE()/WRITE_ONCE()
> to access the descriptor fields, to ensure the compiler doesn't
> add extra references as well as to annotate the expensive
> operations.
> 
> 	Arnd

Got it. Thanks so much for the detailed guide. 
