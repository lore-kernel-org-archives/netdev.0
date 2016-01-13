From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 03/10] net: mvneta: bm: add support for hardware buffer management
Date: Wed, 13 Jan 2016 18:38:35 +0100
Message-ID: <87lh7twfac.fsf@free-electrons.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
	<1452625834-22166-4-git-send-email-gregory.clement@free-electrons.com>
	<CAPv3WKeEXUmH4gqBm7=gkNYwjhR1YybCBZJND_Vidj+Q6U_8=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKeEXUmH4gqBm7=gkNYwjhR1YybCBZJND_Vidj+Q6U_8=g@mail.gmail.com>
	(Marcin Wojtas's message of "Tue, 12 Jan 2016 21:12:25 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
 On mar., janv. 12 2016, Marcin Wojtas <mw@semihalf.com> wrote:

> Hi Gregory,
>
> I have two remarks to my own code. Please let me know before patch v2,
> I will provide you with corrected version (I already did it locally).

OK I will asked your version before the next submitting.

Thanks,

Gregory

>
>> @@ -1556,17 +1777,20 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
>>         int rx_done, i;
>>
>>         rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
>> +       if (rx_done)
>> +               mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_done);
>> +
>> +       if (pp->bm_priv)
>> +               return;
>> +
>
> This is wrong - buffers that are supposed to be dropped should return
> to bm_pool.
>
>> @@ -1587,23 +1812,35 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
>>
>>         rx_done = 0;
>>
>> +       bm_in_use = pp->bm_priv ? true : false;
>> +
>>         /* Fairness NAPI loop */
>>         while (rx_done < rx_todo) {
>>                 struct mvneta_rx_desc *rx_desc = mvneta_rxq_next_desc_get(rxq);
>> +               struct mvneta_bm_pool *bm_pool = NULL;
>>                 struct sk_buff *skb;
>>                 unsigned char *data;
>>                 dma_addr_t phys_addr;
>> -               u32 rx_status;
>> +               u32 rx_status, frag_size;
>>                 int rx_bytes, err;
>> +               u8 pool_id;
>>
>>                 rx_done++;
>>                 rx_status = rx_desc->status;
>>                 rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
>>                 data = (unsigned char *)rx_desc->buf_cookie;
>>                 phys_addr = rx_desc->buf_phys_addr;
>> +               if (bm_in_use) {
>> +                       pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
>> +                       bm_pool = &pp->bm_priv->bm_pools[pool_id];
>> +               }
>>
>>                 if (!mvneta_rxq_desc_is_first_last(rx_status) ||
>>                     (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
>> +                       /* Return the buffer to the pool */
>> +                       if (bm_in_use)
>> +                               mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
>> +                                                     rx_desc->buf_phys_addr);
>>                 err_drop_frame:
>>                         dev->stats.rx_errors++;
>>                         mvneta_rx_error(pp, rx_desc);
>> @@ -1633,25 +1870,38 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
>>                         rcvd_pkts++;
>>                         rcvd_bytes += rx_bytes;
>>
>> +                       /* Return the buffer to the pool */
>> +                       if (bm_in_use)
>> +                               mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
>> +                                                     rx_desc->buf_phys_addr);
>> +
>>                         /* leave the descriptor and buffer untouched */
>>                         continue;
>>                 }
>>
>>                 /* Refill processing */
>> -               err = mvneta_rx_refill(pp, rx_desc);
>> +               err = bm_in_use ? mvneta_bm_pool_refill(pp->bm_priv, bm_pool) :
>> +                                 mvneta_rx_refill(pp, rx_desc);
>>                 if (err) {
>>                         netdev_err(dev, "Linux processing - Can't refill\n");
>>                         rxq->missed++;
>>                         goto err_drop_frame;
>
> Wrong - on refill fail, original buffer should be returned to bm_pool.
> Same case is, when netdev_alloc_skb_ip_align fail inside copybreak
> (this should also be fixed).
>
> Best regards,
> Marcin

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
