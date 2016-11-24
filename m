From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 1/4] net: mvneta: Convert to be 64 bits compatible
Date: Thu, 24 Nov 2016 16:01:35 +0100
Message-ID: <8760ncly5s.fsf@free-electrons.com>
References: <20161122164844.19566-1-gregory.clement@free-electrons.com>
        <CAPv3WKf0a63qQT+xwXfUatbgLFF58e6L8J10VtBOUTam+kUcjg@mail.gmail.com>
        <20161124163327.1cc261ab@xhacker> <21520380.oWTKcrq8DS@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-arm-kernel@lists.infradead.org,
        Jisheng Zhang <jszhang@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:40908 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965876AbcKXPCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 10:02:03 -0500
In-Reply-To: <21520380.oWTKcrq8DS@wuerfel> (Arnd Bergmann's message of "Thu,
        24 Nov 2016 10:00:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,
 
 On jeu., nov. 24 2016, Arnd Bergmann <arnd@arndb.de> wrote:

> On Thursday, November 24, 2016 4:37:36 PM CET Jisheng Zhang wrote:
>> solB (a SW shadow cookie) perhaps gives a better performance: in hot path,
>> such as mvneta_rx(), the driver accesses buf_cookie and buf_phys_addr of
>> rx_desc which is allocated by dma_alloc_coherent, it's noncacheable if the
>> device isn't cache-coherent. I didn't measure the performance difference,
>> because in fact we take solA as well internally. From your experience,
>> can the performance gain deserve the complex code?
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

I agree we can optimize this code but it is not related to the 64 bits
conversion. Indeed this part is running when we use the HW buffer
management, however currently this part is not ready at all for 64
bits. The virtual address is directly handled by the hardware but it has
only 32 bits to store it in the cookie. So if we want to use the HWBM in
64 bits we need to redesign the code, (maybe by storing the virtual
address in a array and pass the index in the cookie).

Gregory

>
> Generally speaking, I'd recommend using READ_ONCE()/WRITE_ONCE()
> to access the descriptor fields, to ensure the compiler doesn't
> add extra references as well as to annotate the expensive
> operations.
>
> 	Arnd

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
