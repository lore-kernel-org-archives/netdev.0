From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next 1/4] net: mvneta: Convert to be 64 bits compatible
Date: Thu, 24 Nov 2016 16:09:15 +0100
Message-ID: <CAPv3WKec4kUEdfSVVdCwJQx2ktEGTaCcSi=MqbpKAYewAHOTkA@mail.gmail.com>
References: <20161122164844.19566-1-gregory.clement@free-electrons.com>
 <CAPv3WKf0a63qQT+xwXfUatbgLFF58e6L8J10VtBOUTam+kUcjg@mail.gmail.com>
 <20161124163327.1cc261ab@xhacker> <21520380.oWTKcrq8DS@wuerfel> <8760ncly5s.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd@arndb.de>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Jisheng Zhang <jszhang@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8760ncly5s.fsf@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

2016-11-24 16:01 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
> Hi Arnd,
>
>  On jeu., nov. 24 2016, Arnd Bergmann <arnd@arndb.de> wrote:
>
>> On Thursday, November 24, 2016 4:37:36 PM CET Jisheng Zhang wrote:
>>> solB (a SW shadow cookie) perhaps gives a better performance: in hot path,
>>> such as mvneta_rx(), the driver accesses buf_cookie and buf_phys_addr of
>>> rx_desc which is allocated by dma_alloc_coherent, it's noncacheable if the
>>> device isn't cache-coherent. I didn't measure the performance difference,
>>> because in fact we take solA as well internally. From your experience,
>>> can the performance gain deserve the complex code?
>>
>> Yes, a read from uncached memory is fairly slow, so if you have a chance
>> to avoid that it will probably help. When adding complexity to the code,
>> it probably makes sense to take a runtime profile anyway quantify how
>> much it gains.
>>
>> On machines that have cache-coherent DMA, accessing the descriptor
>> should be fine, as you already have to load the entire cache line
>> to read the status field.
>>
>> Looking at this snippet:
>>
>>                 rx_status = rx_desc->status;
>>                 rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
>>                 data = (unsigned char *)rx_desc->buf_cookie;
>>                 phys_addr = rx_desc->buf_phys_addr;
>>                 pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
>>                 bm_pool = &pp->bm_priv->bm_pools[pool_id];
>>
>>                 if (!mvneta_rxq_desc_is_first_last(rx_status) ||
>>                     (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
>> err_drop_frame_ret_pool:
>>                         /* Return the buffer to the pool */
>>                         mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
>>                                               rx_desc->buf_phys_addr);
>> err_drop_frame:
>>
>>
>> I think there is more room for optimizing if you start: you read
>> the status field twice (the second one in MVNETA_RX_GET_BM_POOL_ID)
>> and you can cache the buf_phys_addr along with the virtual address
>> once you add that.
>
> I agree we can optimize this code but it is not related to the 64 bits
> conversion. Indeed this part is running when we use the HW buffer
> management, however currently this part is not ready at all for 64
> bits. The virtual address is directly handled by the hardware but it has
> only 32 bits to store it in the cookie. So if we want to use the HWBM in
> 64 bits we need to redesign the code, (maybe by storing the virtual
> address in a array and pass the index in the cookie).
>

How about storing data (virt address and maybe other stuff) as a part
of data buffer and using rx_packet_offset? It has to be used for a3700
anyway. No need of additional rings whatsoever.

Best regards,
Marcin
