From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next PATCH v3] net: ethernet driver: Fujitsu OGMA
Date: Mon, 16 Jun 2014 21:41:49 -0700
Message-ID: <CAGVrzcbgeq=1yEfnfe=j2BzTJS1g2neFNGyJS44y+F12sDToUQ@mail.gmail.com>
References: <20140615042109.30580.8558.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>,
	patches@linaro.org, Francois Romieu <romieu@fr.zoreil.com>
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:43182 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbaFQEma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 00:42:30 -0400
Received: by mail-oa0-f54.google.com with SMTP id eb12so7178375oac.41
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 21:42:30 -0700 (PDT)
In-Reply-To: <20140615042109.30580.8558.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

2014-06-14 21:21 GMT-07:00 Andy Green <andy.green@linaro.org>:
> This driver adds support for "ogma", a Fujitsu Semiconductor Ltd IP Gigabit
> Ethernet + PHY IP used in a variety of their ARM-based ASICs.
>
> We are preparing to upstream the main platform support for these chips
> which is currently waiting for mailbox driver in v6 now and waiting for
> a final ACK
>
> https://lkml.org/lkml/2014/5/15/49
>
> This driver was originally written by guys inside Fujitsu as an abstracted
> "you can build this for Windows as well" type code, I've removed all that,
> modernized various things, added runtime_pm, and ported it to work with
> Device Tree, using only the bindings already mentioned in
>
> ./Documentation/devicetree/bindings/net/ethernet.txt
>
> There is only one checkpatch complaint, both about documentation for the
> DT vendor missing.  But we will document vendor "fujitsu" in the main mach
> support patches.  Bindings documentation is added by this patch.
>
> The patch is based on net-next f9da455b93f6ba076935 from today, and the unchanged
> patch has been tested on real hardware on an integration tree based on
> pre-3.16-rc1 from a couple of days ago.
>
> Allmodconfig doesn't generate any warnings (although on current net-next build
> is broken by a staging driver).
>
> Any comments about how to further improve and align it with current best-
> practice for upstream Ethernet drivers are appreciated.
>
> Changes since v2:
>
>  - Followed comments from Florian Fainelli and Joe Perches
>  - Use Phylib
>  - Register as mii device
>  - Fill out ethtool info
>  - Use ethtool coalesce control struct
>  - use netdev-related log apis
>  - Many other cleanups and normalizations

This looks much better now, thanks! Here are some more minor comments.
net-next is not open for new things now, so that buys you some time to
address the changes.

>
> Changes since v1:
>
>  - Followed comments from Francois Romieu about style issues and eliminate
>    spinlock wrappers
>
>  - Remove remaining excess ()
>  - Pass checkpatch --strict now
>  - Use netdev_alloc_skb_ip_align as suggested
>  - Set hardware endian support according to cpu endianess
>  - change error handling targets from "bailX" to "errX"
>
> Signed-off-by: Andy Green <andy.green@linaro.org>
> ---

[snip]

> +
> +struct ogma_desc_ring {
> +       unsigned int id;
> +       bool running;
> +       u32 full:1;
> +       u8 len;
> +       u16 head;
> +       u16 tail;
> +       u16 rx_num;
> +       u16 tx_done_num;
> +       spinlock_t spinlock_desc; /* protect descriptor access */
> +       void *ring_vaddr;
> +       phys_addr_t desc_phys;
> +       struct ogma_frag_info *frag;
> +       struct sk_buff **priv;
> +};

You might be able to better align this structure for efficiency.

[snip]

> +static int alloc_rx_pkt_buf(struct ogma_priv *priv, struct ogma_frag_info *info,
> +                           void **addr, phys_addr_t *pa, struct sk_buff **skb)
> +{
> +       *skb = netdev_alloc_skb_ip_align(priv->net_device, info->len);
> +       if (!*skb)
> +               return -ENOMEM;
> +
> +       ogma_mark_skb_type(*skb, OGMA_RING_RX);
> +       *addr = (*skb)->data;
> +       *pa = dma_map_single(priv->dev, *addr, info->len, DMA_FROM_DEVICE);

dma_map_single() returns a dma_addr_t, both types might boil down to
being the same, but that might not be true for all platforms.

> +       if (dma_mapping_error(priv->dev, *pa)) {
> +               dev_kfree_skb(*skb);
> +               return -ENOMEM;
> +       }
> +

[snip]

> +static int ogma_set_irq_coalesce_param(struct ogma_priv *priv, unsigned int id)
> +{
> +       int max_frames, tmr;
> +
> +       switch (id) {

You could make id an enum, such that you make sure you pass the
correct type here.

[snip

> +
> +void ogma_mac_write(struct ogma_priv *priv, u32 addr, u32 value)
> +{
> +       ogma_write_reg(priv, MAC_REG_DATA, value);
> +       ogma_write_reg(priv, MAC_REG_CMD, addr | OGMA_GMAC_CMD_ST_WRITE);
> +       ogma_wait_while_busy(priv, MAC_REG_CMD, OGMA_GMAC_CMD_ST_BUSY);

You should propagate the error from ogma_wait_while_busy() here.

> +}
> +
> +u32 ogma_mac_read(struct ogma_priv *priv, u32 addr)
> +{
> +       ogma_write_reg(priv, MAC_REG_CMD, addr | OGMA_GMAC_CMD_ST_READ);
> +       ogma_wait_while_busy(priv, MAC_REG_CMD, OGMA_GMAC_CMD_ST_BUSY);

Same here.

> +
> +       return ogma_read_reg(priv, MAC_REG_DATA);
> +}
> +
> +static int ogma_mac_wait_while_busy(struct ogma_priv *priv, u32 addr, u32 mask)
> +{
> +       u32 timeout = TIMEOUT_SPINS_MAC;
> +
> +       while (--timeout && ogma_mac_read(priv, addr) & mask)
> +               ;
> +       if (!timeout) {
> +               netdev_WARN(priv->net_device, "%s: timeout\n", __func__);
> +               return -ETIME;

-ETIMEDOUT is a better error code here.

[snip]

> +               value = priv->gmac_mode.half_duplex_flag ?
> +                       OGMA_GMAC_MCR_REG_HALF_DUPLEX_COMMON :
> +                       OGMA_GMAC_MCR_REG_FULL_DUPLEX_COMMON;

This should probably be done in the PHY library adjust_link() callback.

> +
> +               if (priv->gmac_mode.link_speed != SPEED_1000)
> +                       value |= OGMA_GMAC_MCR_PS;
> +
> +               if ((priv->phy_interface != PHY_INTERFACE_MODE_GMII) &&
> +                   (priv->gmac_mode.link_speed == SPEED_100))
> +                       value |= OGMA_GMAC_MCR_REG_FES;

And this here too.

[snip]

> +
> +static int ogma_phy_write(struct mii_bus *bus, int phy_addr, int reg, u16 val)
> +{
> +       struct ogma_priv *priv = bus->priv;
> +
> +       BUG_ON(phy_addr >= 32 || reg >= 32);

The phy_addr and reg conditions are unreachable, the PHY library
ensures that for you.

> +
> +       ogma_mac_write(priv, GMAC_REG_GDR, val);
> +       ogma_mac_write(priv, GMAC_REG_GAR,
> +                      phy_addr << OGMA_GMAC_GAR_REG_SHIFT_PA |
> +                      reg << OGMA_GMAC_GAR_REG_SHIFT_GR |
> +                      ogma_clk_type(priv->gmac_hz) << GMAC_REG_SHIFT_CR_GAR |
> +                      OGMA_GMAC_GAR_REG_GW | OGMA_GMAC_GAR_REG_GB);
> +
> +       return ogma_mac_wait_while_busy(priv, GMAC_REG_GAR,
> +                                       OGMA_GMAC_GAR_REG_GB);
> +}
> +
> +static int ogma_phy_read(struct mii_bus *bus, int phy_addr, int reg_addr)
> +{
> +       struct ogma_priv *priv = bus->priv;
> +
> +       BUG_ON(phy_addr >= 32 || reg_addr >= 32);

Same here.

> +
> +       ogma_mac_write(priv, GMAC_REG_GAR, OGMA_GMAC_GAR_REG_GB |
> +                      phy_addr << OGMA_GMAC_GAR_REG_SHIFT_PA |
> +                      reg_addr << OGMA_GMAC_GAR_REG_SHIFT_GR |
> +                      ogma_clk_type(priv->gmac_hz) << GMAC_REG_SHIFT_CR_GAR);
> +
> +       if (ogma_mac_wait_while_busy(priv, GMAC_REG_GAR, OGMA_GMAC_GAR_REG_GB))
> +               return 0;
> +
> +       return ogma_mac_read(priv, GMAC_REG_GDR);
> +}
> +
> +int ogma_mii_register(struct ogma_priv *priv)
> +{
> +       struct mii_bus *bus = mdiobus_alloc();
> +       struct resource res;
> +       int ret;
> +
> +       if (!bus)
> +               return -ENOMEM;
> +
> +       of_address_to_resource(priv->dev->of_node, 0, &res);
> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%p", (void *)(long)res.start);

If you kept a pointer to the device_node you are using, you could use
np->full_name which is already unique.

[snip]

> +
> +int ogma_netdev_napi_poll(struct napi_struct *napi_p, int budget)
> +{
> +       struct ogma_priv *priv = container_of(napi_p, struct ogma_priv, napi);
> +       struct net_device *net_device = priv->net_device;
> +       struct ogma_rx_pkt_info rx_info;
> +       int ret, done = 0, rx_num = 0;
> +       struct ogma_frag_info frag;
> +       struct sk_buff *skb;
> +       u16 len;
> +
> +       ogma_ring_irq_clr(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
> +       ogma_clean_tx_desc_ring(priv);
> +
> +       if (netif_queue_stopped(priv->net_device) &&
> +           ogma_get_tx_avail_num(priv) >= OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX)
> +               netif_wake_queue(priv->net_device);

I would really move the TX processing logic to a separate function for
clarity and logically breaking down things.

> +
> +       while (done < budget) {
> +               if (!rx_num) {
> +                       rx_num = ogma_get_rx_num(priv);
> +                       if (!rx_num)
> +                               break;
> +               }
> +
> +               ret = ogma_get_rx_pkt_data(priv, &rx_info, &frag, &len, &skb);
> +               if (unlikely(ret == -ENOMEM)) {
> +                       netif_err(priv, drv, priv->net_device,
> +                                 "%s: rx fail %d\n", __func__, ret);
> +                       net_device->stats.rx_dropped++;
> +               } else {
> +                       dma_unmap_single(priv->dev, frag.paddr, frag.len,
> +                                        DMA_FROM_DEVICE);
> +
> +                       skb_put(skb, len);
> +                       skb->protocol = eth_type_trans(skb, priv->net_device);
> +
> +                       if (priv->rx_cksum_offload_flag &&
> +                           rx_info.rx_cksum_result == OGMA_RX_CKSUM_OK)
> +                               skb->ip_summed = CHECKSUM_UNNECESSARY;
> +
> +                       napi_gro_receive(napi_p, skb);
> +
> +                       net_device->stats.rx_packets++;
> +                       net_device->stats.rx_bytes += len;
> +               }
> +
> +               done++;
> +               rx_num--;
> +       }
> +
> +       if (done == budget)
> +               return budget;
> +
> +       napi_complete(napi_p);
> +       ogma_write_reg(priv, OGMA_REG_TOP_INTEN_SET,
> +                      OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
> +
> +       return done;
> +}
> +
> +static int ogma_netdev_stop(struct net_device *net_device)
> +{
> +       struct ogma_priv *priv = netdev_priv(net_device);
> +
> +       netif_stop_queue(priv->net_device);

You should probably stop NAPI here too before you disable the hardware entirely.

> +       ogma_stop_gmac(priv);
> +       ogma_stop_desc_ring(priv, OGMA_RING_RX);
> +       ogma_stop_desc_ring(priv, OGMA_RING_TX);
> +       napi_disable(&priv->napi);
> +       phy_stop(priv->phydev);
> +       phy_disconnect(priv->phydev);
> +       priv->phydev = NULL;
> +
> +       pm_runtime_mark_last_busy(priv->dev);
> +       pm_runtime_put_autosuspend(priv->dev);
> +
> +       return 0;
> +}
> +
> +static netdev_tx_t ogma_netdev_start_xmit(struct sk_buff *skb,
> +                                         struct net_device *net_device)
> +{
> +       struct ogma_priv *priv = netdev_priv(net_device);
> +       struct ogma_tx_pkt_ctrl tx_ctrl;
> +       u16 pend_tx, tso_seg_len = 0;
> +       struct ogma_frag_info *scat;
> +       skb_frag_t *frag;
> +       u8 scat_num;
> +       int ret, i;
> +
> +       memset(&tx_ctrl, 0, sizeof(struct ogma_tx_pkt_ctrl));
> +
> +       ogma_ring_irq_clr(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
> +
> +       BUG_ON(skb_shinfo(skb)->nr_frags >= OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX);
> +       scat_num = skb_shinfo(skb)->nr_frags + 1;
> +
> +       scat = kcalloc(scat_num, sizeof(*scat), GFP_NOWAIT);
> +       if (!scat)
> +               return NETDEV_TX_OK;

Cannot you pre-allocate an array of MAX_SKB_FRAGS + 1 scat elements
and re-use them when you transmit packets? This is a fast-path that
should avoid allocations/re-allocations as much as possible.

> +
> +       if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +               if (skb->protocol == htons(ETH_P_IP))
> +                       ip_hdr(skb)->check = 0;

Not sure if that change is actually needed here.

> +               tx_ctrl.cksum_offload_flag = 1;
> +       }
> +
> +       if (skb_is_gso(skb)) {
> +               tso_seg_len = skb_shinfo(skb)->gso_size;
> +
> +               BUG_ON(skb->ip_summed != CHECKSUM_PARTIAL);
> +               BUG_ON(!tso_seg_len);
> +               BUG_ON(tso_seg_len > (priv->param.use_jumbo_pkt_flag ?
> +                           OGMA_TCP_JUMBO_SEG_LEN_MAX : OGMA_TCP_SEG_LEN_MAX));
> +
> +               if (tso_seg_len < OGMA_TCP_SEG_LEN_MIN) {
> +                       tso_seg_len = OGMA_TCP_SEG_LEN_MIN;
> +
> +                       if (skb->data_len < OGMA_TCP_SEG_LEN_MIN)
> +                               tso_seg_len = 0;
> +               }
> +       }
> +
> +       if (tso_seg_len > 0) {
> +               if (skb->protocol == htons(ETH_P_IP)) {
> +                       BUG_ON(!(skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4));
> +
> +                       ip_hdr(skb)->tot_len = 0;
> +                       tcp_hdr(skb)->check =
> +                               ~tcp_v4_check(0, ip_hdr(skb)->saddr,
> +                                             ip_hdr(skb)->daddr, 0);
> +               } else {
> +                       BUG_ON(!(skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6));
> +                       ipv6_hdr(skb)->payload_len = 0;
> +                       tcp_hdr(skb)->check =
> +                               ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +                                                &ipv6_hdr(skb)->daddr,
> +                                                0, IPPROTO_TCP, 0);
> +               }
> +
> +               tx_ctrl.tcp_seg_offload_flag = 1;
> +               tx_ctrl.tcp_seg_len = tso_seg_len;
> +       }
> +
> +       scat[0].paddr = dma_map_single(priv->dev, skb->data,
> +                                          skb_headlen(skb), DMA_TO_DEVICE);
> +       if (dma_mapping_error(priv->dev, scat[0].paddr)) {
> +               netif_err(priv, drv, priv->net_device,
> +                         "%s: DMA mapping failed\n", __func__);
> +               kfree(scat);
> +               return NETDEV_TX_OK;
> +       }
> +       scat[0].addr = skb->data;
> +       scat[0].len = skb_headlen(skb);
> +
> +       for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +               frag = &skb_shinfo(skb)->frags[i];
> +               scat[i + 1].paddr =
> +                       skb_frag_dma_map(priv->dev, frag, 0,
> +                                        skb_frag_size(frag), DMA_TO_DEVICE);
> +               scat[i + 1].addr = skb_frag_address(frag);
> +               scat[i + 1].len = frag->size;
> +       }
> +
> +       ogma_mark_skb_type(skb, OGMA_RING_TX);
> +
> +       ret = ogma_set_tx_pkt_data(priv, &tx_ctrl, scat_num, scat, skb);
> +       if (ret) {
> +               netif_err(priv, drv, priv->net_device,
> +                         "set tx pkt failed %d\n", ret);
> +               for (i = 0; i < scat_num; i++)
> +                       dma_unmap_single(priv->dev, scat[i].paddr,
> +                                        scat[i].len, DMA_TO_DEVICE);
> +               kfree(scat);
> +               net_device->stats.tx_dropped++;
> +
> +               return NETDEV_TX_OK;
> +       }
> +
> +       kfree(scat);
> +
> +       spin_lock(&priv->tx_queue_lock);
> +       pend_tx = ogma_get_tx_avail_num(priv);
> +
> +       if (pend_tx < OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX) {
> +               ogma_ring_irq_enable(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
> +               netif_stop_queue(net_device);
> +               goto err;
> +       }
> +       if (pend_tx <= DESC_NUM - 2) {
> +               ogma_ring_irq_enable(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
> +               goto err;
> +       }
> +       ogma_ring_irq_disable(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
> +
> +err:
> +       spin_unlock(&priv->tx_queue_lock);
> +
> +       return NETDEV_TX_OK;
> +}
> +
> +static struct net_device_stats *ogma_netdev_get_stats(struct net_device
> +                                                     *net_device)
> +{
> +       return &net_device->stats;
> +}

This should be the default, can be dropped.

> +
> +static int ogma_netdev_change_mtu(struct net_device *net_device, int new_mtu)
> +{
> +       struct ogma_priv *priv = netdev_priv(net_device);
> +
> +       if (!priv->param.use_jumbo_pkt_flag)
> +               return eth_change_mtu(net_device, new_mtu);
> +
> +       if ((new_mtu < 68) || (new_mtu > 9000))
> +               return -EINVAL;
> +
> +       net_device->mtu = new_mtu;
> +
> +       return 0;
> +}
> +
> +static int ogma_netdev_set_features(struct net_device *net_device,
> +                                   netdev_features_t features)
> +{
> +       struct ogma_priv *priv = netdev_priv(net_device);
> +
> +       priv->rx_cksum_offload_flag = !!(features & NETIF_F_RXCSUM);
> +
> +       return 0;
> +}
> +
> +static int ogma_phy_get_link_speed(struct ogma_priv *priv, bool *half_duplex)
> +{
> +       int link_speed = SPEED_10;
> +       u32 u;
> +
> +       *half_duplex = false;
> +
> +       if ((phy_read(priv->phydev, OGMA_PHY_ADDR_MSC) & MSC_1GBIT) &&
> +           (phy_read(priv->phydev, OGMA_PHY_ADDR_1000BASE_SR) & SR_1GBIT))
> +               link_speed = SPEED_1000;
> +       else {
> +               u = phy_read(priv->phydev, OGMA_PHY_ADDR_ANA) &
> +                   phy_read(priv->phydev, OGMA_PHY_ADDR_ANLPA);
> +
> +               if (u & OGMA_PHY_ANLPA_REG_TXF) {
> +                       link_speed = SPEED_100;
> +               } else if (u & OGMA_PHY_ANLPA_REG_TXD) {
> +                       link_speed = SPEED_100;
> +                       *half_duplex = true;
> +               }
> +       }

These are already provided by the PHY library in phydev->speed,
phydev->duplex and phydev->link.

> +
> +       return link_speed;
> +}
> +
> +static void ogma_phy_adjust_link(struct net_device *net_device)
> +{
> +       struct ogma_priv *priv = netdev_priv(net_device);
> +       bool half_duplex = false;
> +       int link_speed;
> +       u32 sr;
> +
> +       sr = phy_read(priv->phydev, OGMA_PHY_ADDR_SR);
> +
> +       if ((sr & OGMA_PHY_SR_REG_LINK) && (sr & OGMA_PHY_SR_REG_AN_C)) {

I do think this is required if the PHY device provides link status
information in MII_BMSR as it should do. If not, you would have to
write a custom PHY driver for this chip.

> +               link_speed = ogma_phy_get_link_speed(priv, &half_duplex);
> +               if (priv->actual_link_speed != link_speed ||
> +                   priv->actual_half_duplex != half_duplex) {
> +                       netif_info(priv, drv, priv->net_device,
> +                                  "Autoneg: %uMbps, half-duplex:%d\n",
> +                                  link_speed, half_duplex);
> +                       ogma_stop_gmac(priv);
> +                       priv->gmac_mode.link_speed = link_speed;
> +                       priv->gmac_mode.half_duplex_flag = half_duplex;
> +                       ogma_start_gmac(priv);

Do we really need to go through an expensive stop()/start() sequence
here? Cannot you just change the duplex/speed parameters on the fly?

> +
> +                       priv->actual_link_speed = link_speed;
> +                       priv->actual_half_duplex = half_duplex;
> +               }
> +       }
> +
> +       if (!netif_running(priv->net_device) && (sr & OGMA_PHY_SR_REG_LINK)) {
> +               netif_info(priv, drv, priv->net_device,
> +                          "%s: link up\n", __func__);
> +               netif_carrier_on(net_device);

The PHY library calls netif_carrier_{on,off} based on the link status
it read from the PHY device.

> +               netif_start_queue(net_device);

You cannot start the transmit queue like that, your TX ring might
still be congested.

> +       }
> +
> +       if (netif_running(priv->net_device) && !(sr & OGMA_PHY_SR_REG_LINK)) {
> +               netif_info(priv, drv, priv->net_device,
> +                          "%s: link down\n", __func__);
> +               netif_stop_queue(net_device);
> +               netif_carrier_off(net_device);
> +               priv->actual_link_speed = 0;
> +               priv->actual_half_duplex = 0;

Same here, you should not have to do all of this.

> +       }
> +}
> +
> +static int ogma_netdev_open_sub(struct ogma_priv *priv)
> +{
> +       napi_enable(&priv->napi);
> +
> +       if (ogma_start_desc_ring(priv, OGMA_RING_RX))
> +               goto err1;
> +       if (ogma_start_desc_ring(priv, OGMA_RING_TX))
> +               goto err2;
> +
> +       ogma_ring_irq_disable(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
> +
> +       return 0;
> +
> +err2:
> +       ogma_stop_desc_ring(priv, OGMA_RING_RX);
> +err1:
> +       napi_disable(&priv->napi);
> +
> +       return -EINVAL;
> +}
> +
> +static int ogma_netdev_open(struct net_device *net_device)
> +{
> +       struct ogma_priv *priv = netdev_priv(net_device);
> +       int ret;
> +
> +       pm_runtime_get_sync(priv->dev);
> +
> +       ret = ogma_clean_rx_desc_ring(priv);
> +       if (ret) {
> +               netif_err(priv, drv, priv->net_device,
> +                         "%s: clean rx desc fail\n", __func__);
> +               goto err;
> +       }
> +
> +       ret = ogma_clean_tx_desc_ring(priv);
> +       if (ret) {
> +               netif_err(priv, drv, priv->net_device,
> +                         "%s: clean tx desc fail\n", __func__);
> +               goto err;
> +       }
> +
> +       ogma_ring_irq_clr(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
> +
> +       priv->phydev = of_phy_connect(priv->net_device, priv->phy_np,
> +                                     &ogma_phy_adjust_link, 0,
> +                                     priv->phy_interface);
> +       if (!priv->phydev) {
> +               netif_err(priv, link, priv->net_device,
> +                         "could not find the PHY\n");
> +               goto err;
> +       }
> +
> +       phy_start(priv->phydev);
> +
> +       ret = ogma_netdev_open_sub(priv);
> +       if (ret) {
> +               phy_disconnect(priv->phydev);
> +               priv->phydev = NULL;
> +               netif_err(priv, link, priv->net_device,
> +                         "ogma_netdev_open_sub() failed\n");
> +               goto err;
> +       }
> +
> +       /* mask with MAC supported features */
> +       priv->phydev->supported &= PHY_BASIC_FEATURES;
> +       priv->phydev->advertising = priv->phydev->supported;

These are the defaults, even if you are using the Generic PHY driver,
setting the 'max-speed' property correctly limits the advertised and
supported capabilities.

[snip]

> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       if (!res) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "Missing base resource\n");
> +               goto err1;
> +       }
> +
> +       priv->ioaddr = ioremap_nocache(res->start, res->end - res->start + 1);
> +       if (!priv->ioaddr) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "ioremap_nocache() failed\n");
> +               err = -EINVAL;
> +               goto err1;
> +       }

You can simplify this by calling devm_ioremap_resource().

> +
> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +       if (!res) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "Missing rdlar resource\n");
> +               goto err1;
> +       }
> +       priv->rdlar_pa = res->start;
> +
> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
> +       if (!res) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "Missing tdlar resource\n");
> +               goto err1;
> +       }
> +       priv->tdlar_pa = res->start;
> +
> +       res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +       if (!res) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "Missing IRQ resource\n");
> +               goto err2;
> +       }
> +       priv->net_device->irq = res->start;
> +       err = request_irq(priv->net_device->irq, ogma_irq_handler,
> +                         IRQF_SHARED, "ogma", priv);

You should call request_irq() in the ndo_open() function such that the
interrupt remains disabled until your driver is ready to service them.
Conversely ndo_close() should call free_irq().

> +       if (err) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "request_irq() failed\n");
> +               goto err2;
> +       }
> +       disable_irq(priv->net_device->irq);
> +
> +       pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
> +       pdev->dev.dma_mask = &pdev->dev.coherent_dma_mask;
> +
> +       while (priv->clock_count < ARRAY_SIZE(priv->clk)) {
> +               priv->clk[priv->clock_count] =
> +                       of_clk_get(pdev->dev.of_node, priv->clock_count);
> +               if (IS_ERR(priv->clk[priv->clock_count])) {
> +                       if (!priv->clock_count) {
> +                               netif_err(priv, probe, priv->net_device,
> +                                         "Failed to get clock\n");
> +                               goto err3;
> +                       }
> +                       break;
> +               }
> +               priv->clock_count++;
> +       }
> +
> +       /* disable by default */
> +       priv->et_coalesce.rx_coalesce_usecs = 0;
> +       priv->et_coalesce.rx_max_coalesced_frames = 1;
> +       priv->et_coalesce.tx_coalesce_usecs = 0;
> +       priv->et_coalesce.tx_max_coalesced_frames = 1;
> +
> +       pm_runtime_set_autosuspend_delay(&pdev->dev, 2000); /* 2s delay */
> +       pm_runtime_use_autosuspend(&pdev->dev);
> +       pm_runtime_enable(&pdev->dev);
> +
> +       /* runtime_pm coverage just for probe, enable/disable also cover it */
> +       pm_runtime_get_sync(&pdev->dev);
> +
> +       priv->param.use_jumbo_pkt_flag = 0;
> +       p = of_get_property(pdev->dev.of_node, "max-frame-size", NULL);
> +       if (p)
> +               priv->param.use_jumbo_pkt_flag = !!(be32_to_cpu(*p) > 8000);
> +
> +       hw_ver = ogma_read_reg(priv, OGMA_REG_F_TAIKI_VER);
> +
> +       if (OGMA_F_NETSEC_VER_MAJOR_NUM(hw_ver) !=
> +           OGMA_F_NETSEC_VER_MAJOR_NUM(OGMA_REG_OGMA_VER_F_TAIKI)) {
> +               ret = -ENODEV;
> +               goto err3b;
> +       }
> +
> +       if (priv->param.use_jumbo_pkt_flag)
> +               priv->rx_pkt_buf_len = OGMA_RX_JUMBO_PKT_BUF_LEN;
> +       else
> +               priv->rx_pkt_buf_len = OGMA_RX_PKT_BUF_LEN;
> +
> +       for (i = 0; i <= OGMA_RING_MAX; i++) {
> +               ret = ogma_alloc_desc_ring(priv, (u8) i);
> +               if (ret) {
> +                       netif_err(priv, probe, priv->net_device,
> +                                 "%s: alloc ring failed\n", __func__);
> +                       goto err3b;
> +               }
> +       }

If your interface remains "down", you will be eating memory for
nothing. This is not a whole lot of memory but still, could be some
hundreds of KiB. Better do that in your ndo_open() when your interface
really gets used.

> +
> +       ret = ogma_setup_rx_desc(priv, &priv->desc_ring[OGMA_RING_RX]);
> +       if (ret) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "%s: fail setup ring\n", __func__);
> +               goto err3b;
> +       }
> +
> +       netif_info(priv, probe, priv->net_device,
> +                  "IP version: 0x%08x\n", hw_ver);
> +
> +       priv->gmac_mode.flow_start_th = OGMA_FLOW_CONTROL_START_THRESHOLD;
> +       priv->gmac_mode.flow_stop_th = OGMA_FLOW_CONTROL_STOP_THRESHOLD;
> +       priv->gmac_mode.pause_time = pause_time;
> +       priv->gmac_hz = clk_get_rate(priv->clk[0]);
> +
> +       priv->gmac_mode.half_duplex_flag = 0;
> +       priv->gmac_mode.flow_ctrl_enable_flag = 0;
> +
> +       scb_irq_temp = ogma_read_reg(priv, OGMA_REG_TOP_INTEN);
> +       ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR, scb_irq_temp);
> +
> +       ret = ogma_hw_configure_to_normal(priv);
> +       if (ret) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "%s: normal fail %d\n", __func__, ret);
> +               goto err3b;
> +       }
> +
> +       netif_napi_add(priv->net_device, &priv->napi, ogma_netdev_napi_poll,
> +                      napi_weight);
> +
> +       net_device->netdev_ops = &ogma_netdev_ops;
> +       net_device->ethtool_ops = &ogma_ethtool_ops;
> +       net_device->features = NETIF_F_SG | NETIF_F_IP_CSUM |
> +                              NETIF_F_IPV6_CSUM | NETIF_F_TSO |
> +                              NETIF_F_TSO6 | NETIF_F_GSO |
> +                              NETIF_F_HIGHDMA | NETIF_F_RXCSUM;
> +       priv->net_device->hw_features = priv->net_device->features;
> +
> +       priv->rx_cksum_offload_flag = 1;
> +       spin_lock_init(&priv->tx_queue_lock);
> +
> +       err = ogma_mii_register(priv);
> +       if (err) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "mii bus registration failed %d\n", err);
> +               goto err3c;
> +       }
> +
> +       err = register_netdev(priv->net_device);
> +       if (err) {
> +               netif_err(priv, probe, priv->net_device,
> +                         "register_netdev() failed\n");
> +               goto err4;
> +       }
> +
> +       ogma_write_reg(priv, OGMA_REG_TOP_INTEN_SET,
> +                      OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
> +
> +       netif_info(priv, probe, priv->net_device,
> +                  "%s initialized\n", priv->net_device->name);
> +
> +       pm_runtime_mark_last_busy(&pdev->dev);
> +       pm_runtime_put_autosuspend(&pdev->dev);
> +
> +       return 0;
> +
> +err4:
> +       ogma_mii_register(priv);
> +err3c:
> +       free_netdev(priv->net_device);
> +err3b:
> +       ogma_write_reg(priv, OGMA_REG_TOP_INTEN_SET, scb_irq_temp);
> +       ogma_terminate(priv);
> +err3:
> +       pm_runtime_put_sync_suspend(&pdev->dev);
> +       pm_runtime_disable(&pdev->dev);
> +       while (priv->clock_count > 0) {
> +               priv->clock_count--;
> +               clk_put(priv->clk[priv->clock_count]);
> +       }
> +
> +       free_irq(priv->net_device->irq, priv);
> +err2:
> +       iounmap(priv->ioaddr);
> +err1:
> +       kfree(priv);
> +
> +       dev_err(&pdev->dev, "init failed\n");
> +
> +       return ret;
> +}
> +
> +static int ogma_remove(struct platform_device *pdev)
> +{
> +       struct ogma_priv *priv = platform_get_drvdata(pdev);
> +       u32 timeout = 1000000;
> +
> +       pm_runtime_get_sync(&pdev->dev);
> +
> +       ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR,
> +                      OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
> +       BUG_ON(ogma_hw_configure_to_taiki(priv));
> +
> +       phy_write(priv->phydev, 0, phy_read(priv->phydev, 0) | (1 << 15));
> +       while (--timeout && (phy_read(priv->phydev, 0)) & (1 << 15))
> +               ;

If you need to reset the PHY, call genphy_soft_reset() as it will make
sure it waits long enough for the PHY to be in reset.
-- 
Florian
