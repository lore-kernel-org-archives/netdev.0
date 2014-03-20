From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 20 Mar 2014 22:00:09 +0800
Message-ID: <CAMj5Bkiaw=BT_EUdjthPjgk_pp0z44yPjh4_AfHXqiJLUiDe=g@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
	<1395132017-15928-4-git-send-email-zhangfei.gao@linaro.org>
	<4611515.XyVGvsaLcW@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:36554 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbaCTOAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 10:00:10 -0400
In-Reply-To: <4611515.XyVGvsaLcW@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Arnd

On Tue, Mar 18, 2014 at 7:25 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Tuesday 18 March 2014 16:40:17 Zhangfei Gao wrote:
>
>> +
>> +static void __iomem *ppebase;
>
> The global 'ppebase' seems hacky. Isn't that a SoC-specific register area, while
> the rest of the driver is reusable across SoCs?
>
> What does 'ppe' stand for?
>
> What if there are multiple instances of this, which each have their own ppebase?

In this specific platform,
ppe is the only module controlling all the fifos for all the net controller.
And each controller connect to specific port.
ppe has 2048 channels, sharing by all the controller, only if not overlapped.

So the static ppebase is required, which I don't like too.
Two inputs required, one is port, which is connect to the controller.
The other is start channel, currently I use id, and start channel is
RX_DESC_NUM * priv->id;  /* start_addr */

>
>> +static void hip04_config_port(struct hip04_priv *priv, u32 speed, u32 duplex)
>> +{
>> +     u32 val;
>> +
>> +     priv->speed = speed;
>> +     priv->duplex = duplex;
>> +
>> +     switch (speed) {
>> +     case SPEED_1000:
>> +             val = 8;
>> +             break;
>> +     case SPEED_100:
>> +             if (priv->id)
>> +                     val = 7;
>> +             else
>> +                     val = 1;
>> +             break;
>> +     default:
>> +             val = 0;
>> +             break;
>> +     }
>> +     writel_relaxed(val, priv->base + GE_PORT_MODE)
>
> This also seems to encode knowledge about a particular implementation
> into the driver. Maybe it's better to add a property for the port
> mode?

After check Documentation/devicetree/bindings/net/ethernet.txt,
I think phy-mode is more suitable here.

        switch (priv->phy_mode) {
        case PHY_INTERFACE_MODE_SGMII:
                if (speed == SPEED_1000)
                        val = 8;
                else
                        val = 7;
                break;
        case PHY_INTERFACE_MODE_MII:
                val = 1;        /* SPEED_100 */
                break;
        default:
                val = 0;
                break;
        }
        writel_relaxed(val, priv->base + GE_PORT_MODE);

probe:
priv->phy_mode = of_get_phy_mode(node);

>
>
>> +static void hip04_set_xmit_desc(struct hip04_priv *priv, dma_addr_t phys)
>> +{
>> +     writel_relaxed(phys, priv->base + PPE_CFG_TX_PKT_BD_ADDR);
>> +}
>> +
>> +static void hip04_set_recv_desc(struct hip04_priv *priv, dma_addr_t phys)
>> +{
>> +     writel_relaxed(phys, ppebase + priv->port * 4 + PPE_CFG_RX_CFF_ADDR);
>> +}
>> +
>> +static u32 hip04_recv_cnt(struct hip04_priv *priv)
>> +{
>> +     return readl_relaxed(priv->base + PPE_HIS_RX_PKT_CNT);
>> +}
>
> At the very least, the hip04_set_xmit_desc() function needs to use 'writel'
> rather than 'writel_relaxed'. Otherwise data that is being sent out
> can be stuck in the CPU's write buffers and you send stale data on the wire.
>
> For the receive path, you may or may not need to use 'readl', depending
> on how DMA is serialized by this device. If you have MSI interrupts, the
> interrupt message should already do the serialization, but if you have
> edge or level triggered interrupts, you normally need to have one readl()
> from the device register between the IRQ and the data access.

Really, will update to readl/wirtel in xmit and hip04_rx_poll.
I just got impression, use *_relaxed as much as possible for better performance.

>
>
>> +static void endian_change(void *p, int size)
>> +{
>> +     unsigned int *to_cover = (unsigned int *)p;
>> +     int i;
>> +
>> +     size = size >> 2;
>> +     for (i = 0; i < size; i++)
>> +             *(to_cover+i) = htonl(*(to_cover+i));
>> +}
>> +
>> +static int hip04_rx_poll(struct napi_struct *napi, int budget)
>> +{
>> +     struct hip04_priv *priv = container_of(napi,
>> +                           struct hip04_priv, napi);
>> +     struct net_device *ndev = priv->ndev;
>> +     struct sk_buff *skb;
>> +     struct rx_desc *desc;
>> +     unsigned char *buf;
>> +     int rx = 0;
>> +     unsigned int cnt = hip04_recv_cnt(priv);
>> +     unsigned int len, tmp[16];
>> +
>> +     while (cnt) {
>> +             buf = priv->rx_buf[priv->rx_head];
>> +             skb = build_skb(buf, priv->rx_buf_size);
>> +             if (unlikely(!skb))
>> +                     net_dbg_ratelimited("build_skb failed\n");
>> +             dma_map_single(&ndev->dev, skb->data,
>> +                     RX_BUF_SIZE, DMA_FROM_DEVICE);
>> +             memcpy(tmp, skb->data, 64);
>> +             endian_change((void *)tmp, 64);
>> +             desc = (struct rx_desc *)tmp;
>> +             len = desc->pkt_len;
>
> The dma_map_single() seems misplaced here, for all I can tell, the
> data has already been transferred. Maybe you mean dma_unmap_single?
>
> I don't see why you copy 64 bytes out of the buffer using endian_change,
> rather than just looking at the first word, which seems to have the
> only value you are interested in.
Russell suggested using be16_to_cpu etc to replace memcpy.

>
>> +             if (len > RX_BUF_SIZE)
>> +                     len = RX_BUF_SIZE;
>> +             if (0 == len)
>> +                     break;
>> +
>> +             skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
>> +             skb_put(skb, len);
>> +             skb->protocol = eth_type_trans(skb, ndev);
>> +             napi_gro_receive(&priv->napi, skb);
>> +
>> +             buf = netdev_alloc_frag(priv->rx_buf_size);
>> +             if (!buf)
>> +                     return -ENOMEM;
>> +             priv->rx_buf[priv->rx_head] = buf;
>> +             dma_map_single(&ndev->dev, buf, RX_BUF_SIZE, DMA_TO_DEVICE);
>
> Maybe you mean DMA_FROM_DEVICE? The call here doesn't seem to make any
> sense. You also need to use the return value of dma_map_single() every
> time you call it.
>
>> +             hip04_set_recv_desc(priv, virt_to_phys(buf));
>
> and put it right here in the next line. virt_to_phys() is not the correct
> function call, that is what dma_map_single() is meant for.

OK.
>
>> +             priv->rx_head = RX_NEXT(priv->rx_head);
>> +             if (rx++ >= budget)
>> +                     break;
>> +
>> +             if (--cnt == 0)
>> +                     cnt = hip04_recv_cnt(priv);
>> +     }
>> +
>> +     if (rx < budget) {
>> +             napi_gro_flush(napi, false);
>> +             __napi_complete(napi);
>> +     }
>> +
>> +     /* enable rx interrupt */
>> +     priv->reg_inten |= RCV_INT | RCV_NOBUF;
>> +     writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
>
>
> Why do you unconditionally turn on interrupts here? Shouldn't you
> only do that after calling napi_complete()?
Yes, right.

>
>
>> +
>> +static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>> +{
>> +     struct hip04_priv *priv = netdev_priv(ndev);
>> +     struct tx_desc *desc = priv->td_ring[priv->tx_head];
>> +     unsigned int tx_head = priv->tx_head;
>> +     int ret;
>> +
>> +     hip04_tx_reclaim(ndev, false);
>> +
>> +     spin_lock_irq(&priv->txlock);
>> +     if (priv->tx_count++ >= TX_DESC_NUM) {
>> +             net_dbg_ratelimited("no TX space for packet\n");
>> +             netif_stop_queue(ndev);
>> +             ret = NETDEV_TX_BUSY;
>> +             goto out_unlock;
>> +     }
>> +
>> +     priv->tx_skb[tx_head] = skb;
>> +     dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
>> +     memset((void *)desc, 0, sizeof(*desc));
>> +     desc->send_addr = (unsigned int)virt_to_phys(skb->data);
>
> Just like above: you must not use virt_to_phys here, but rather use
> the output of dma_map_single.
>
> IIRC, you can't generally call dma_map_single() under a spinlock, so
> better move that ahead. It may also be a slow operation.
The spinlock will be removed here, since it is protected by rcu outside.

>
>> +
>> +static int hip04_mac_open(struct net_device *ndev)
>> +{
>> +     struct hip04_priv *priv = netdev_priv(ndev);
>> +     int i;
>> +
>> +     hip04_reset_ppe(priv);
>> +     for (i = 0; i < RX_DESC_NUM; i++) {
>> +             dma_map_single(&ndev->dev, priv->rx_buf[i],
>> +                             RX_BUF_SIZE, DMA_TO_DEVICE);
>> +             hip04_set_recv_desc(priv, virt_to_phys(priv->rx_buf[i]));
>> +     }
>
> And one more. Also DMA_FROM_DEVICE.
>
>> +static int hip04_alloc_ring(struct net_device *ndev, struct device *d)
>> +{
>> +     struct hip04_priv *priv = netdev_priv(ndev);
>> +     int i;
>> +
>> +     priv->rx_buf_size = RX_BUF_SIZE +
>> +                         SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>> +
>> +     priv->desc_pool = dma_pool_create(DRV_NAME, d, sizeof(struct tx_desc),
>> +                             SKB_DATA_ALIGN(sizeof(struct tx_desc)), 0);
>> +     if (!priv->desc_pool)
>> +             return -ENOMEM;
>> +
>> +     for (i = 0; i < TX_DESC_NUM; i++) {
>> +             priv->td_ring[i] = dma_pool_alloc(priv->desc_pool,
>> +                                     GFP_ATOMIC, &priv->td_phys[i]);
>> +             if (!priv->td_ring[i])
>> +                     return -ENOMEM;
>> +     }
>
> Why do you create a dma pool here, when you do all the allocations upfront?
>
> It looks to me like you could simply turn the td_ring array of pointers
> to tx descriptors into a an array of tx descriptors (no pointers) and allocate
> that one using dma_alloc_coherent.

dma pool used here mainly because of alignment,
the desc has requirement of SKB_DATA_ALIGN,
so use the simplest way
        priv->desc_pool = dma_pool_create(DRV_NAME, d, sizeof(struct tx_desc),
                                SKB_DATA_ALIGN(sizeof(struct tx_desc)), 0);

>
>
>> +     if (!ppebase) {
>> +             struct device_node *n;
>> +
>> +             n = of_find_compatible_node(NULL, NULL, "hisilicon,hip04-ppebase");
>> +             if (!n) {
>> +                     ret = -EINVAL;
>> +                     netdev_err(ndev, "not find hisilicon,ppebase\n");
>> +                     goto init_fail;
>> +             }
>> +             ppebase = of_iomap(n, 0);
>> +     }
>
> How about using syscon_regmap_lookup_by_phandle() here? That way, you can have
> a more generic abstraction of the ppe, and stick the port and id in there as
> well, e.g.
>
>         ppe-syscon = <&hip04ppe 1 4>; // ppe, port, id

To be honest, I am not familiar with syscon_regmap_lookup_by_phandle.

Florian has suggested
              ppe: ppe@28c0000 {
                        compatible = "hisilicon,hip04-ppe";
                        reg = <0x28c0000 0x10000>;
                        #address-cells = <1>;
                        #size-cells = <0>;

                        eth0_port: port@1f {
                                reg = <31>;
                        };

                        eth1_port: port@0 {
                                reg = <0>;
                        };

                        eth2_port: port@8 {
                                reg = <8>;
                        };
                };
                fe: ethernet@28b0000 {
                        compatible = "hisilicon,hip04-mac";
                        reg = <0x28b0000 0x10000>;
                        interrupts = <0 413 4>;
                        phy-mode = "mii";
                        port-handle = <&eth0_port>;
                };
And the port info can be found from port-handle
n = of_parse_phandle(node, "port-handle", 0);
ret = of_property_read_u32(n, "reg", &priv->port);

The id is the controller start channel in ppe, either use alias or
another property in the port.

>
>> +     ret = of_property_read_u32(node, "speed", &val);
>> +     if (ret) {
>> +             dev_warn(d, "not find speed info\n");
>> +             priv->speed = SPEED_1000;
>> +     }
>> +
>> +     if (SPEED_100 == val)
>> +             priv->speed = SPEED_100;
>> +     else
>> +             priv->speed = SPEED_1000;
>> +     priv->duplex = DUPLEX_FULL;
>
> Why do you even need the speed here, shouldn't you get that information
> from the phy through hip04_adjust_link?

There still 100M mac does not have phy, as well adjust_link.
Will use phy-mode instead of speed.

Thanks
