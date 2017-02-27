From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH net-next 5/6] drivers: net: xgene-v2: Add transmit and
 receive
Date: Sun, 26 Feb 2017 21:08:51 -0800
Message-ID: <CAKh23FkiqEBWdErHg5paJP0jV5JzZ=m9TrKySKJ+QsyRpZiV5Q@mail.gmail.com>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
 <1485889401-13909-6-git-send-email-isubramanian@apm.com>
 <fb8fcd33-4b5b-5999-7662-4165aeb179e1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Keyur Chudgar <kchudgar@apm.com>,
 patches <patches@apm.com>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <fb8fcd33-4b5b-5999-7662-4165aeb179e1@gmail.com>
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

Hi Florian,

On Tue, Jan 31, 2017 at 12:33 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 01/31/2017 11:03 AM, Iyappan Subramanian wrote:
>> This patch adds,
>>     - Transmit
>>     - Transmit completion poll
>>     - Receive poll
>>     - NAPI handler
>>
>> and enables the driver.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
>> ---
>
>> +
>> +     tx_ring = pdata->tx_ring;
>> +     tail = tx_ring->tail;
>> +     len = skb_headlen(skb);
>> +     raw_desc = &tx_ring->raw_desc[tail];
>> +
>> +     /* Tx descriptor not available */
>> +     if (!GET_BITS(E, le64_to_cpu(raw_desc->m0)) ||
>> +         GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0)))
>> +             return NETDEV_TX_BUSY;
>> +
>> +     /* Packet buffers should be 64B aligned */
>> +     pkt_buf = dma_alloc_coherent(dev, XGENE_ENET_STD_MTU, &dma_addr,
>> +                                  GFP_ATOMIC);
>> +     if (unlikely(!pkt_buf))
>> +             goto out;
>
> Can't you obtain a DMA-API mapping for skb->data and pass it down to the
> hardware? This copy here is inefficient.

This hardware requires 64-byte alignment.

>
>> +
>> +     memcpy(pkt_buf, skb->data, len);
>> +
>> +     addr_hi = GET_BITS(NEXT_DESC_ADDRH, le64_to_cpu(raw_desc->m1));
>> +     addr_lo = GET_BITS(NEXT_DESC_ADDRL, le64_to_cpu(raw_desc->m1));
>> +     raw_desc->m1 = cpu_to_le64(SET_BITS(NEXT_DESC_ADDRL, addr_lo) |
>> +                                SET_BITS(NEXT_DESC_ADDRH, addr_hi) |
>> +                                SET_BITS(PKT_ADDRH,
>> +                                         dma_addr >> PKT_ADDRL_LEN));
>> +
>> +     dma_wmb();
>> +
>> +     raw_desc->m0 = cpu_to_le64(SET_BITS(PKT_ADDRL, dma_addr) |
>> +                                SET_BITS(PKT_SIZE, len) |
>> +                                SET_BITS(E, 0));
>> +
>> +     skb_tx_timestamp(skb);
>> +     xge_wr_csr(pdata, DMATXCTRL, 1);
>> +
>> +     pdata->stats.tx_packets++;
>> +     pdata->stats.tx_bytes += skb->len;
>
> This is both racy and incorrect. Racy because after you wrote DMATXCTRL,
> your TX completion can run, and it can do that while interrupting your
> CPU presumably, and free the SKB, therefore making you access a freed
> SKB (or it should, if it does not), it's also incorrect, because before
> you get signaled a TX completion, there is no guarantee that the packets
> did actually make it through, you must update your stats in the TX
> completion handler.

Thanks.  I'll move the tx stats part to Tx completion.

>
>> +
>> +     tx_ring->skbs[tail] = skb;
>> +     tx_ring->pkt_bufs[tail] = pkt_buf;
>> +     tx_ring->tail = (tail + 1) & (XGENE_ENET_NUM_DESC - 1);
>> +
>> +out:
>> +     dev_kfree_skb_any(skb);
>
> Don't do this, remember a pointer to the SKB, free the SKB in TX
> completion handler, preferably in NAPI context.

I'll implement this.

>
>> +
>> +     return NETDEV_TX_OK;
>> +}
>> +
>> +static void xge_txc_poll(struct net_device *ndev, unsigned int budget)
>> +{
>> +     struct xge_pdata *pdata = netdev_priv(ndev);
>> +     struct device *dev = &pdata->pdev->dev;
>> +     struct xge_desc_ring *tx_ring;
>> +     struct xge_raw_desc *raw_desc;
>> +     u64 addr_lo, addr_hi;
>> +     dma_addr_t dma_addr;
>> +     void *pkt_buf;
>> +     bool pktsent;
>> +     u32 data;
>> +     u8 head;
>> +     int i;
>> +
>> +     tx_ring = pdata->tx_ring;
>> +     head = tx_ring->head;
>> +
>> +     data = xge_rd_csr(pdata, DMATXSTATUS);
>> +     pktsent = data & TX_PKT_SENT;
>> +     if (unlikely(!pktsent))
>> +             return;
>> +
>> +     for (i = 0; i < budget; i++) {
>
> TX completion handlers should run unbound and free the entire TX ring,
> don't make it obey to an upper bound.

I'll do as suggested.

>
>> +             raw_desc = &tx_ring->raw_desc[head];
>> +
>> +             if (!GET_BITS(E, le64_to_cpu(raw_desc->m0)))
>> +                     break;
>> +
>> +             dma_rmb();
>> +
>> +             addr_hi = GET_BITS(PKT_ADDRH, le64_to_cpu(raw_desc->m1));
>> +             addr_lo = GET_BITS(PKT_ADDRL, le64_to_cpu(raw_desc->m0));
>> +             dma_addr = (addr_hi << PKT_ADDRL_LEN) | addr_lo;
>> +
>> +             pkt_buf = tx_ring->pkt_bufs[head];
>> +
>> +             /* clear pktstart address and pktsize */
>> +             raw_desc->m0 = cpu_to_le64(SET_BITS(E, 1) |
>> +                                        SET_BITS(PKT_SIZE, 0));
>> +             xge_wr_csr(pdata, DMATXSTATUS, 1);
>> +
>> +             dma_free_coherent(dev, XGENE_ENET_STD_MTU, pkt_buf, dma_addr);
>> +
>> +             head = (head + 1) & (XGENE_ENET_NUM_DESC - 1);
>> +     }
>> +
>> +     tx_ring->head = head;
>> +}
>> +
>> +static int xge_rx_poll(struct net_device *ndev, unsigned int budget)
>> +{
>> +     struct xge_pdata *pdata = netdev_priv(ndev);
>> +     struct device *dev = &pdata->pdev->dev;
>> +     dma_addr_t addr_hi, addr_lo, dma_addr;
>> +     struct xge_desc_ring *rx_ring;
>> +     struct xge_raw_desc *raw_desc;
>> +     struct sk_buff *skb;
>> +     int i, npkts, ret = 0;
>> +     bool pktrcvd;
>> +     u32 data;
>> +     u8 head;
>> +     u16 len;
>> +
>> +     rx_ring = pdata->rx_ring;
>> +     head = rx_ring->head;
>> +
>> +     data = xge_rd_csr(pdata, DMARXSTATUS);
>> +     pktrcvd = data & RXSTATUS_RXPKTRCVD;
>> +
>> +     if (unlikely(!pktrcvd))
>> +             return 0;
>> +
>> +     npkts = 0;
>> +     for (i = 0; i < budget; i++) {
>
> So pktrcvd is not an indication of the produced number of packets, just
> that there are packets, that's not very convenient, and it's redundant
> with the very fact of being interrupted.

Agree, but the interrupt is common for Tx completion and Rx, this
check is still required.

>
>> +             raw_desc = &rx_ring->raw_desc[head];
>> +
>> +             if (GET_BITS(E, le64_to_cpu(raw_desc->m0)))
>> +                     break;
>> +
>> +             dma_rmb();
>> +
>> +             addr_hi = GET_BITS(PKT_ADDRH, le64_to_cpu(raw_desc->m1));
>> +             addr_lo = GET_BITS(PKT_ADDRL, le64_to_cpu(raw_desc->m0));
>> +             dma_addr = (addr_hi << PKT_ADDRL_LEN) | addr_lo;
>> +             len = GET_BITS(PKT_SIZE, le64_to_cpu(raw_desc->m0));
>
> Is not there some kind of additional status that would indicate if the
> packet is possibly invalid (oversize, undersize, etc.)?

I'll add error checking.

>
>> +
>> +             dma_unmap_single(dev, dma_addr, XGENE_ENET_STD_MTU,
>> +                              DMA_FROM_DEVICE);
>> +
>> +             skb = rx_ring->skbs[head];
>> +             skb_put(skb, len);
>> +
>> +             skb->protocol = eth_type_trans(skb, ndev);
>> +
>> +             pdata->stats.rx_packets++;
>> +             pdata->stats.rx_bytes += len;
>> +             napi_gro_receive(&pdata->napi, skb);
>> +             npkts++;
>
> --
> Florian
