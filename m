From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Fri, 21 Mar 2014 15:56:04 +0800
Message-ID: <CAMj5BkgAv-6fBvf73mXULPF+Cw3VqWfPhi0YRR6WyUS75uD4yw@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
 <201403201531.20416.arnd@arndb.de>
 <CAMj5BkgMuw-O7b7KnVgZ9gmTGDv=OhCxvAYBu+wZy=j6m8Anmg@mail.gmail.com>
 <4951263.YfedV5kHCP@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>, netdev <netdev@vger.kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4951263.YfedV5kHCP@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Dear Arnd

On Fri, Mar 21, 2014 at 3:37 PM, Arnd Bergmann <arnd@arndb.de> wrote:

>> >> >> +static int hip04_alloc_ring(struct net_device *ndev, struct device *d)
>> >> >> +{
>> >> >> +     struct hip04_priv *priv = netdev_priv(ndev);
>> >> >> +     int i;
>> >> >> +
>> >> >> +     priv->rx_buf_size = RX_BUF_SIZE +
>> >> >> +                         SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>> >> >> +
>> >> >> +     priv->desc_pool = dma_pool_create(DRV_NAME, d, sizeof(struct tx_desc),
>> >> >> +                             SKB_DATA_ALIGN(sizeof(struct tx_desc)), 0);
>> >> >> +     if (!priv->desc_pool)
>> >> >> +             return -ENOMEM;
>> >> >> +
>> >> >> +     for (i = 0; i < TX_DESC_NUM; i++) {
>> >> >> +             priv->td_ring[i] = dma_pool_alloc(priv->desc_pool,
>> >> >> +                                     GFP_ATOMIC, &priv->td_phys[i]);
>> >> >> +             if (!priv->td_ring[i])
>> >> >> +                     return -ENOMEM;
>> >> >> +     }
>> >> >
>> >> > Why do you create a dma pool here, when you do all the allocations upfront?
>> >> >
>> >> > It looks to me like you could simply turn the td_ring array of pointers
>> >> > to tx descriptors into a an array of tx descriptors (no pointers) and allocate
>> >> > that one using dma_alloc_coherent.
>> >>
>> >> dma pool used here mainly because of alignment,
>> >> the desc has requirement of SKB_DATA_ALIGN,
>> >> so use the simplest way
>> >>         priv->desc_pool = dma_pool_create(DRV_NAME, d, sizeof(struct tx_desc),
>> >>                                 SKB_DATA_ALIGN(sizeof(struct tx_desc)), 0);
>> >
>> > dma_alloc_coherent() will actually give you PAGE_SIZE alignment, so that's
>> > still easier.
>> However since the alignment requirement, it can not simply use desc[i]
>> to get each desc.
>> desc = dma_alloc_coherent(d, size, &phys, GFP_KERNEL);
>> desc[i] is not what we want.
>> So still prefer using dma_pool_alloc here.
>
> Ah, I see what you mean: struct tx_desc is actually smaller than the
> required alignment. You can fix that by marking the structure
> "____cacheline_aligned".
>

Yes, after recheck the method carefully, it works with __aligned(0x40).
"____cacheline_aligned" is much better.
The desc can be get with either table or pointer.

Will update accordingly, it is simpler.

Thanks
