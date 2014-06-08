From: Andy Green <andy.green@linaro.org>
Subject: Re: [PATCH] net-next: ethernet driver: Fujist OGMA
Date: Mon, 9 Jun 2014 06:58:22 +0800
Message-ID: <CAAfg0W7A_ghwQJPc6-DqFW-Ft8ktboLu84uRFuRPexrTNWrDxg@mail.gmail.com>
References: <20140608020913.17601.6638.stgit@localhost.localdomain>
	<20140608221941.GA28334@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:38285 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbaFHW6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 18:58:23 -0400
Received: by mail-qg0-f54.google.com with SMTP id q108so8048180qgd.41
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 15:58:22 -0700 (PDT)
In-Reply-To: <20140608221941.GA28334@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 June 2014 06:19, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Andy Green <andy.green@linaro.org> :
> [...]
>
> Partial review below. The driver needs more.

Thanks a lot for the comments, I will start working on them.

The 'strange' things you're seeing were normal for the original driver
sources, I cleaned almost all of it out but after a while if
checkpatch is okay with it, it's difficult to avoid becoming
"snowblind".

>> diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma.h b/drivers/net/ethernet/fujitsu/ogma/ogma.h
>> new file mode 100644
>> index 0000000..126e458
>> --- /dev/null
>> +++ b/drivers/net/ethernet/fujitsu/ogma/ogma.h
> [...]
>> +struct ogma_priv {
>> +     u32 core_enabled_flag:1;
>> +     u32 gmac_rx_running_flag:1;
>> +     u32 gmac_tx_running_flag:1;
>> +     u32 gmac_mode_valid_flag:1;
>> +     u32 normal_desc_ring_valid:1;
>> +     void *base_addr;
>
> Add __iomem annotation.

OK

> Please rename it (ioaddr, whatever). It looks like net_device.base_addr

OK

> [...]
>> +static inline void ogma_write_reg(struct ogma_priv *priv, u32 reg_addr,
>> +                                 u32 value)
>> +{
>> +     writel(value, (priv->base_addr) + (reg_addr << 2));
>
> Excess parenthesis. The driver contains quite some of those.

OK will go through it again.

>> +}
>> +
>> +static inline u32 ogma_read_reg(struct ogma_priv *priv, u32 reg_addr)
>> +{
>> +     return readl(priv->base_addr + (reg_addr << 2));
>> +}
>> +
>> +static inline void pfdep_set_pkt_buf_type(void *skb, bool recv_buf_flag)
>> +{
>> +     struct sk_buff *skb_p = (struct sk_buff *)skb;
>> +     (*((bool *) skb_p->cb)) = recv_buf_flag;
>
> Missing empty line.

OK

> [...]
>> +extern const struct net_device_ops ogma_netdev_ops;
>> +extern const struct ethtool_ops ogma_ethtool_ops;
>> +
>> +int ogma_start_gmac(struct ogma_priv *priv, bool rx_flag, bool tx_flag);
>> +int ogma_stop_gmac(struct ogma_priv *priv, bool rx_flag, bool tx_flag);
>> +int ogma_set_gmac_mode(struct ogma_priv *priv,
>> +                    const struct ogma_gmac_mode *mode);
>> +void ogma_set_phy_reg(struct ogma_priv *priv, u8 phy_addr, u8 reg_addr,
>> +                   u16 value);
>> +u16 ogma_get_phy_reg(struct ogma_priv *priv, u8 phy_addr, u8 reg_addr);
>> +int ogma_start_desc_ring(struct ogma_priv *priv, unsigned int id);
>> +int ogma_stop_desc_ring(struct ogma_priv *priv, unsigned int id);
>> +u16 ogma_get_rx_num(struct ogma_priv *priv, unsigned int id);
>> +u16 ogma_get_tx_avail_num(struct ogma_priv *priv, unsigned int id);
>> +int ogma_clean_tx_desc_ring(struct ogma_priv *priv, unsigned int id);
>> +int ogma_clean_rx_desc_ring(struct ogma_priv *priv, unsigned int id);
>> +int ogma_set_tx_pkt_data(struct ogma_priv *priv, unsigned int id,
>> +     const struct ogma_tx_pkt_ctrl *tx_ctrl, u8 scat_num,
>> +             const struct ogma_frag_info *scat, struct sk_buff *skb);
>> +int ogma_get_rx_pkt_data(struct ogma_priv *priv, unsigned int id,
>> +     struct ogma_rx_pkt_info *rx_pkt_info_p, struct ogma_frag_info *frag,
>> +                                             u16 *len, struct sk_buff **skb);
>> +int ogma_ring_irq_enable(struct ogma_priv *priv,
>> +                           unsigned int id, u32 irq_factor);
>> +int ogma_ring_irq_disable(struct ogma_priv *priv,
>> +                            unsigned int id, u32 irq_factor);
>> +int ogma_set_irq_coalesce_param(struct ogma_priv *priv, unsigned int id,
>> +             u16 int_pktcnt, bool int_tmr_unit_ms_flag, u16 int_tmr_cnt);
>> +
>> +int ogma_alloc_desc_ring(struct ogma_priv *priv, unsigned int id);
>> +void ogma_free_desc_ring(struct ogma_priv *priv, struct ogma_desc_ring *desc);
>> +int ogma_setup_rx_desc_ring(struct ogma_priv *priv,
>> +                                             struct ogma_desc_ring *desc);
>> +int ogma_netdev_napi_poll(struct napi_struct *napi_p, int budget);
>
> Excess public scope ?


>> diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c b/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
>> new file mode 100644
>> index 0000000..f11a834
>> --- /dev/null
>> +++ b/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
> [...]
>> +static void desc_lock(struct ogma_desc_ring *desc, bool *ctx)
>> +{
>> +     if (in_softirq()) {
>> +             *ctx = 1;       /* Mark that bh is already disabled. */
>> +             spin_lock(&desc->spinlock_desc);
>> +     } else {
>> +             *ctx = 0;
>> +             spin_lock_bh(&desc->spinlock_desc);
>> +     }
>> +}
>
> Device drivers should not need this kind of locking.
>
> Let's see:
> - ogma_ring_irq_enable
>   Only called from the xmit handler, whence in locally disabled bh context.
>
> - ogma_start_desc_ring
>   Only called through ogma_netdev_ops.ndo_open, thus in bh enabled context.
>   One may ask if open() _really_ needs this lock anyway as it can delay
>   both napi processing and tx queueing.
>
> - ogma_stop_desc_ring
>   It's called in more places than ogma_start_desc_ring but it should
>   work the same (disable NAPI in close, wait for quiescence, etc.).
>
> - ogma_get_rx_num
>   Called from NAPI context. No need to disable bh.
>
> - ogma_get_tx_avail_num
>   Called from NAPI context or xmit handler. No need to disable bh.
>
> - ogma_clean_tx_desc_ring
>   Called from NAPI, xmit or ogma_netdev_ops.ndo_open. The latter can
>   control the formers. Should be a plain spinlock.
>
> - ogma_clean_rx_desc_ring
>   Only called through ogma_netdev_ops.ndo_open. See above.
>
> - ogma_set_tx_pkt_data
>   Only called from the xmit handler, whence in locally disabled bh context.
>
> - ogma_get_rx_pkt_data
>   Only called from NAPI context. No need to disable bh.
>
> Executive summary: desc_lock should go away.

It's very helpful thanks.

I'll look at devolving it into one or the other spinlock calls in each
instance and eliminate the funky wrapper.

>> +int ogma_ring_irq_enable(struct ogma_priv *priv, unsigned int id,
>> +                                                             u32 irq_factor)
>> +{
>> +     int ret = 0;
>> +     struct ogma_desc_ring *desc = &priv->desc_ring[id];
>> +     bool ctx;
>
> Please use inverted xmas tree style for variable declaration.

OK will do.

>> +
>> +     desc_lock(desc, &ctx);
>> +
>> +     if (!desc->running_flag) {
>> +             dev_err(priv->dev, "desc ring not running\n");
>> +             ret = -ENODEV;
>> +             goto bail;
>> +     }
>> +
>> +     ogma_write_reg(priv, ads_irq_set[id], irq_factor);
>> +
>> +bail:
>> +     desc_unlock(desc, &ctx);
>> +
>> +     return ret;
>> +}
>> +
>> +int ogma_ring_irq_disable(struct ogma_priv *priv,
>> +                            unsigned int id, u32 irq_factor)
>
> int ogma_ring_irq_disable(struct ogma_priv *priv, unsigned int id,
>                           u32 irq_factor)

OK

>> +{
>> +     ogma_write_reg(priv, desc_ring_irq_inten_clr_reg_addr[id], irq_factor);
>> +
>> +     return 0;
>
> Why does it return anything ? It should be void.

Yes.

>> +}
>> +
>> +static int alloc_pkt_buf(struct device *dev, u16 len, void **addr_p,
>> +                             phys_addr_t *phys, struct sk_buff **pskb)
>> +{
>> +     struct sk_buff *skb = dev_alloc_skb(len + 2);
>> +     if (!skb)
>> +             return -ENOMEM;
>> +
>> +     /* Reserve leading 2 bytes to make IP header word-aligned. */
>> +     skb_reserve(skb, 2);
>
> netdev_alloc_skb_ip_align
>
>> +
>> +     *phys = dma_map_single(dev, skb->data, (size_t) len, DMA_FROM_DEVICE);
>> +     if (!*phys) {
>> +             dev_kfree_skb(skb);
>> +
>> +             return -ENOMEM;
>> +     }
>> +
>> +     *addr_p = (void *)skb->data;
>> +     *pskb = skb;
>> +
>> +     /* Mark that this is a receiving buffer. */
>> +     pfdep_set_pkt_buf_type(skb, 1);
>
> The comment underlines a poor naming.

Yes, it's a refugee of the original style, will fix.

>> +
>> +     return 0;
>> +}
>> +
>> +void kfree_pkt_buf(struct device *dev, u16 len, void *addr,
>> +     phys_addr_t phys_addr, bool last_flag, struct sk_buff *skb)
>> +{
>> +     dma_unmap_single(dev, phys_addr, (size_t) len,
>> +                      (pfdep_is_recv_pkt_buf(skb) ?
>> +                       DMA_FROM_DEVICE : DMA_TO_DEVICE));
>
> Excess parenthesis.

OK

>> +
>> +     if (last_flag)
>> +             dev_kfree_skb(skb);
>> +}
>> +
>> +int ogma_alloc_desc_ring(struct ogma_priv *priv, unsigned int id)
>> +{
>> +     int ret = 0;
>> +     struct ogma_desc_ring *desc = &priv->desc_ring[id];
>> +     struct ogma_desc_param *param = &priv->desc_ring[id].param;
>> +     u8 rx_desc_entry_len = 0;
>> +
>> +     if ((priv->param.desc_param[id].valid_flag) &&
>> +         ((priv->param.desc_param[id].entry_num < OGMA_DESC_MIN) ||
>> +          (priv->param.desc_param[id].entry_num > OGMA_DESC_MAX))) {
>
> A local variable for &priv->param.desc_param[id] would not hurt.

OK

> [...]
>> +     desc->ring_vaddr = dma_alloc_coherent(NULL,
>> +             desc->len * param->entry_num, &desc->deschys_addr, GFP_KERNEL);
>
> Indent should line things up with the first character after the parenthesis.

Okay but that can get messy quick if the opening parenthesis is far to
the right.

>> +     if (!desc->ring_vaddr) {
>> +             ret = -ENOMEM;
>> +             dev_err(priv->dev, "%s: failed to alloc\n", __func__);
>> +             goto err;
>> +     }
>> +
>> +     memset(desc->ring_vaddr, 0, (u32) desc->len * param->entry_num);
>> +     desc->frag = kmalloc(sizeof(struct ogma_frag_info) * param->entry_num,
>> +                                                             GFP_NOWAIT);
>
> Indent.
>
>> +     if (!desc->frag) {
>> +             ret = -ENOMEM;
>> +             dev_err(priv->dev, "%s: failed to alloc\n", __func__);
>> +             goto err;
>> +     }
>> +
>> +     memset(desc->frag, 0, sizeof(struct ogma_frag_info) * param->entry_num);
>> +     desc->priv = kmalloc(sizeof(struct sk_buff *) * param->entry_num,
>> +                                                             GFP_NOWAIT);
>
> Indent.
>
>> +     if (!desc->priv) {
>> +             ret = -ENOMEM;
>> +             dev_err(priv->dev, "%s: failed to alloc priv\n", __func__);
>> +             goto err;
>> +     }
>> +
>> +     memset(desc->priv, 0, sizeof(struct sk_buff *) * param->entry_num);
>> +
>> +     return 0;
>> +
>> +err:
>> +     ogma_free_desc_ring(priv, desc);
>> +
>> +     return ret;
>> +}
>> +
>> +void ogma_uninit_pkt_desc_ring(struct ogma_priv *priv,
>> +                            struct ogma_desc_ring *desc)
>> +{
>> +     u16 idx;
>> +     u32 tmp;
>> +     bool last_flag;
>> +     int count = desc->param.entry_num;
>> +
>> +     for (idx = 0; idx < count; idx++) {
>> +             if (!desc->frag[idx].addr)
>> +                     continue;
>> +
>> +             tmp = *((u32 *)((void *)desc->ring_vaddr + (desc->len * idx)));
>> +             last_flag = (tmp >> 8) & 1;
>> +             kfree_pkt_buf(priv->dev, desc->frag[idx].len,
>> +                     desc->frag[idx].addr, desc->frag[idx].phys_addr,
>> +                           last_flag, desc->priv[idx]);
>
> Broken indent. The driver contains a lot of those. :o(

checkpatch is okay with them.  I'll see what happens with --strict.

> Please add a local variable for desc->frag[idx].
>
> [...]
>> +static void ogma_set_rx_desc_entry(struct ogma_priv *priv,
>> +     struct ogma_desc_ring *desc, u16 idx, const struct ogma_frag_info *frag,
>> +                                                  struct sk_buff *skb)
>> +{
>> +     struct ogma_rx_desc_entry rx_desc_entry;
>> +
>> +     ogma_check_desc_own_sanity(desc, idx, 0);
>> +
>> +     memset(&rx_desc_entry, 0, sizeof(rx_desc_entry));
>> +
>> +     rx_desc_entry.attr = (1 << OGMA_RX_PKT_DESC_RING_OWN_FIELD) |
>> +                          (1 << OGMA_RX_PKT_DESC_RING_FS_FIELD) |
>> +                          (1 << OGMA_RX_PKT_DESC_RING_LS_FIELD);
>> +
>> +     rx_desc_entry.data_buf_addr = frag->phys_addr;
>> +     rx_desc_entry.buf_len_info = frag->len;
>> +
>> +     if (idx == (desc->param.entry_num - 1))
>> +             rx_desc_entry.attr |= (0x1U << OGMA_RX_PKT_DESC_RING_LD_FIELD);
>> +
>> +     memcpy(((void *)((void *)desc->ring_vaddr + desc->len * idx + 4)),
>> +             (void *)((void *)&rx_desc_entry + 4), desc->len - 4);
>
> Scary void * fetish.

Yes.

> [...]
>> diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c b/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
>> new file mode 100644
>> index 0000000..2f69a29
>> --- /dev/null
>> +++ b/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
> [...]
>> +const struct net_device_ops ogma_netdev_ops = {
>> +     .ndo_open = ogma_netdev_open,
>> +     .ndo_stop = ogma_netdev_stop,
>> +     .ndo_start_xmit = ogma_netdev_start_xmit,
>> +     .ndo_set_features = ogma_netdev_set_features,
>> +     .ndo_get_stats = ogma_netdev_get_stats,
>> +     .ndo_change_mtu = ogma_netdev_change_mtu,
>> +     .ndo_set_mac_address = ogma_netdev_set_macaddr,
>> +     .ndo_validate_addr = eth_validate_addr,
>> +};
>
> Please use tabs before "=" to line things up.

OK.

>> diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
>> new file mode 100644
>> index 0000000..176d746
>> --- /dev/null
>> +++ b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
> [...]
>> +int ogma_configure_normal_mode(struct ogma_priv *priv,
>> +                            const struct ogma_normal_mode_hwconf
>> +                            *normal_mode_hwconf_p)
>> +{
> [...]
>> +     timeout = WAIT_FW_RDY_TIMEOUT;
>> +     while (timeout-- && (ogma_read_reg(priv,
>> +                                        desc_ads
>> +                                        [OGMA_RING_NRM_RX])
>> +                          & (0x1UL << OGMA_REG_DESC_RING_CONFIG_CFG_UP)))
>
> :o(

OK.

> [...]
>> +static int ogma_probe(struct platform_device *pdev)
>> +{
> [...]
>> +     res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> +     if (!res) {
>> +             dev_err(&pdev->dev, "Missing base resource\n");
>> +             goto bail1;
>> +     }
>> +
>> +     priv->base_addr = ioremap_nocache(res->start,
>> +                                             res->end - res->start + 1);
>> +     if (!priv->base_addr) {
>> +             dev_err(&pdev->dev, "ioremap_nocache() failed\n");
>> +             err = -EINVAL;
>> +             goto bail1;
>
> bail1, bail2, bail3 and friends are not sane label names.

OK.

> I haven't found any __le{8, 16, 32} nor cpu_to_xyz in the driver. I would
> had expected some in the descriptors.

Yes... the IP's only implemented in LE mode ARM to date.

For this IP the descriptors have programmable Endian-ness, we force it
to LE right now.  So this can be solved only by dynamically setting
the endianness I think.

Thanks again for the comments, I will start working through them now
and send a v2 in a few days leaving time for any more comments.

-Andy

> --
> Ueimor
