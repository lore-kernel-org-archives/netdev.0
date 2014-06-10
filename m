From: Andy Green <andy.green@linaro.org>
Subject: Re: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Tue, 10 Jun 2014 10:54:14 +0800
Message-ID: <CAAfg0W4btAePRrYX+oDO3tE6n7vOEZNWq8u=Xo22RUwXoxDu5w@mail.gmail.com>
References: <20140610010803.18695.88446.stgit@localhost.localdomain>
	<CAGVrzcYrXrsN+_2fA7LUWMFMxnVmv72JMDLyftVx68JS-X7FDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Patch Tracking <patches@linaro.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:56669 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407AbaFJCyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 22:54:16 -0400
Received: by mail-qa0-f44.google.com with SMTP id j7so8708078qaq.3
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 19:54:15 -0700 (PDT)
In-Reply-To: <CAGVrzcYrXrsN+_2fA7LUWMFMxnVmv72JMDLyftVx68JS-X7FDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 June 2014 10:14, Florian Fainelli <f.fainelli@gmail.com> wrote:

First thanks a lot for taking the time to write detailed information
on how to further improve the driver.

> 2014-06-09 18:08 GMT-07:00 Andy Green <andy.green@linaro.org>:
>> This driver adds support for "ogma", a Fujitsu Semiconductor Ltd IP Gigabit
>> Ethernet + PHY IP used in a variety of their ARM-based ASICs.
>>
>> We are preparing to upstream the main platform support for these chips
>> which is currently waiting for mailbox driver in v6 now and waiting for
>> a final ACK
>>
>> https://lkml.org/lkml/2014/5/15/49
>>
>> This driver was originally written by guys inside Fujitsu as an abstracted
>> "you can build this for Windows as well" type code, I've removed all that,
>> modernized various things, added runtime_pm, and ported it to work with
>> Device Tree, using only the bindings already mentioned in
>>
>> ./Documentation/devicetree/bindings/net/ethernet.txt
>
> Even though this is the case, which is good, you still need to provide
> a Device Tree bindings that documents how a Device Tree node for this
> specific hardware is supposed to look like.

OK

>> There are only two checkpatch complaints, both about documentation for the
>> DT name missing.  But we will document vendor "fujitsu" in the main mach
>> support patches and it seems normal to just use the unified ethernet binding
>> with no documentation for this subsystem (we don't add any new DT bindings).
>>
>> The patch is based on net-next fff1f59b1773fcb from today, and the unchanged
>> patch has been tested on real hardware on an integration tree based on 3.15-rc8
>>
>> Any comments about how to further improve and align it with current best-
>> practice for upstream Ethernet drivers are appreciated.
>>
>> Changes since v1:
>>
>>  - Followed comments from Francois Romieu about style issues and eliminate
>> spinlock wrappers
>>
>>  - Remove remaining excess ()
>>  - Pass checkpatch --strict now
>>  - Use netdev_alloc_skb_ip_align as suggested
>>  - Set hardware endian support according to cpu endianess
>>  - change error handling targets from "bailX" to "errX"
>>
>> Signed-off-by: Andy Green <andy.green@linaro.org>
>> ---
>
> [snip]
>
>> +static int alloc_pkt_buf(struct ogma_priv *priv, u16 len, void **addr_p,
>> +                        phys_addr_t *phys, struct sk_buff **pskb)
>> +{
>> +       struct sk_buff *skb = netdev_alloc_skb_ip_align(priv->net_device, len);
>> +
>> +       if (!skb)
>> +               return -ENOMEM;
>> +
>> +       *phys = dma_map_single(priv->dev, skb->data, len, DMA_FROM_DEVICE);
>> +       if (!*phys) {
>> +               dev_kfree_skb(skb);
>> +
>> +               return -ENOMEM;
>> +       }
>
> Missing dma_mapping_error() check here, enabling DMA-API debugging
> would flag that too.

OK.

>> +
>> +       *addr_p = skb->data;
>> +       *pskb = skb;
>> +
>> +       ogma_mark_skb_type(skb, OGMA_RING_NRM_RX);
>> +
>> +       return 0;
>> +}
>> +
>> +static void kfree_pkt_buf(struct device *dev, struct ogma_frag_info *frag,
>> +                         bool last_flag, struct sk_buff *skb)
>> +{
>> +       dma_unmap_single(dev, frag->phys_addr, frag->len,
>> +                        skb_is_rx(skb) ? DMA_FROM_DEVICE : DMA_TO_DEVICE);
>
> I would really go for separate functions, rather than having a single
> one that handles RX or TX.

OK

>> +       desc->ring_vaddr = dma_alloc_coherent(NULL,
>
> Please retain a struct device pointer in your driver private context
> and use it here. Without a struct device pointer you won't get the
> per-device DMA mask, which might be different, neither will you get
> the per-device DMA operations (if they exist).

Yes I do have the struct device * in priv, I will use it here.

>> +                                             desc->len * param->entries,
>> +                                             &desc->deschys_addr, GFP_KERNEL);
>> +       if (!desc->ring_vaddr) {
>> +               ret = -ENOMEM;
>> +               dev_err(priv->dev, "%s: failed to alloc\n", __func__);
>> +               goto err;
>> +       }
>> +
>> +       memset(desc->ring_vaddr, 0, (u32) desc->len * param->entries);
>> +       desc->frag = kmalloc(sizeof(*desc->frag) * param->entries,
>> +                            GFP_NOWAIT);
>
> Is not GFP_KERNEL suitable here? If not, cannot you move the
> allocation to a code-path that is allowed to sleep. e.g the ndo_open()
> function for instance?

The original author used GFP_NOWAIT everywhere, I'll try to understand
the rationale and change to GFP_KERNEL if it's not needed.

>> +       if (!desc->frag) {
>> +               ret = -ENOMEM;
>> +               dev_err(priv->dev, "%s: failed to alloc\n", __func__);
>> +               goto err;
>> +       }
>> +
>> +       memset(desc->frag, 0, sizeof(struct ogma_frag_info) * param->entries);
>
> kzalloc() does a kmalloc() + memset().
>
>> +       desc->priv = kmalloc(sizeof(struct sk_buff *) * param->entries,
>> +                            GFP_NOWAIT);
>
> Same here.
>
>> +       if (!desc->priv) {
>> +               ret = -ENOMEM;
>> +               dev_err(priv->dev, "%s: failed to alloc priv\n", __func__);
>> +               goto err;
>> +       }
>> +
>> +       memset(desc->priv, 0, sizeof(struct sk_buff *) * param->entries);
>
> Same here, use kzalloc().

OK thanks.

>> +
>> +       return 0;
>> +
>> +err:
>> +       ogma_free_desc_ring(priv, desc);
>> +
>> +       return ret;
>> +}
>
> [snip]
>
>> +static u32 ogma_clk_type(u32 gmac_hz)
>> +{
>> +       if (gmac_hz < 35 * OGMA_CLK_MHZ)
>> +               return OGMA_GMAC_GAR_REG_CR_25_35_MHZ;
>> +
>> +       if (gmac_hz < 60 * OGMA_CLK_MHZ)
>> +               return OGMA_GMAC_GAR_REG_CR_35_60_MHZ;
>> +
>> +       if (gmac_hz < 100 * OGMA_CLK_MHZ)
>> +               return OGMA_GMAC_GAR_REG_CR_60_100_MHZ;
>> +
>> +       if (gmac_hz < 150 * OGMA_CLK_MHZ)
>> +               return OGMA_GMAC_GAR_REG_CR_100_150_MHZ;
>> +
>> +       if (gmac_hz < 250 * OGMA_CLK_MHZ)
>> +               return OGMA_GMAC_GAR_REG_CR_150_250_MHZ;
>> +
>> +       return OGMA_GMAC_GAR_REG_CR_250_300_MHZ;
>> +}
>
> Does not that belong in the clk API with clk_get_rate()?

I don't think so, it's not setting the clock generator but configuring
the MAC IP according to the range of clocks it is provided from the
clock generator.

If it moved to clk API, the clk API would have to know about how many
of these networking IPs and where they are etc.

>> +
>> +void ogma_mac_write(struct ogma_priv *priv, u32 addr, u32 value)
>> +{
>> +       ogma_write_reg(priv, MAC_REG_DATA, value);
>> +       ogma_write_reg(priv, MAC_REG_CMD, addr | OGMA_GMAC_CMD_ST_WRITE);
>> +
>> +       while (ogma_read_reg(priv, MAC_REG_CMD) & OGMA_GMAC_CMD_ST_BUSY)
>> +               ;
>
> You should add a timeout guard here.

OK.

>> +}
>> +
>> +u32 ogma_mac_read(struct ogma_priv *priv, u32 addr)
>> +{
>> +       ogma_write_reg(priv, MAC_REG_CMD, addr | OGMA_GMAC_CMD_ST_READ);
>> +       while (ogma_read_reg(priv, MAC_REG_CMD) & OGMA_GMAC_CMD_ST_BUSY)
>> +               ;
>
> Same here

OK.

>> +       return ogma_read_reg(priv, MAC_REG_DATA);
>> +}
>> +
>> +int ogma_start_gmac(struct ogma_priv *priv, bool rx_flag, bool tx_flag)
>> +{
>> +       u32 value;
>> +
>> +       BUG_ON(!priv->gmac_mode_valid_flag);
>> +
>> +       if (!rx_flag && !tx_flag)
>> +               return 0;
>> +
>> +       if (priv->gmac_rx_running_flag && priv->gmac_tx_running_flag)
>> +               return 0;
>> +
>> +       if (rx_flag && priv->gmac_rx_running_flag && !tx_flag)
>> +               return 0;
>> +
>> +       if (tx_flag && priv->gmac_tx_running_flag && !rx_flag)
>> +               return 0;
>> +
>> +       if (!priv->gmac_rx_running_flag && !priv->gmac_tx_running_flag) {
>> +               if (priv->gmac_mode.link_speed == OGMA_PHY_LINK_SPEED_1G)
>> +                       ogma_mac_write(priv, GMAC_REG_MCR, 0);
>> +               else
>> +                       ogma_mac_write(priv, GMAC_REG_MCR, OGMA_GMAC_MCR_PS);
>> +
>> +               ogma_mac_write(priv, GMAC_REG_BMR, OGMA_GMAC_BMR_REG_RESET);
>> +
>> +               /* Wait soft reset */
>> +               usleep_range(1000, 5000);
>> +
>> +               if (ogma_mac_read(priv, GMAC_REG_BMR) & OGMA_GMAC_BMR_REG_SWR)
>> +                       return -EAGAIN;
>> +
>> +               ogma_write_reg(priv, MAC_REG_DESC_SOFT_RST, 1);
>> +               while (ogma_read_reg(priv, MAC_REG_DESC_SOFT_RST) & 1)
>> +                       ;
>
> And here
>
>> +
>> +               ogma_write_reg(priv, MAC_REG_DESC_INIT, 1);
>> +               while (ogma_read_reg(priv, MAC_REG_DESC_INIT) & 1)
>> +                       ;
>
> And here

OK.

>> +
>> +               ogma_mac_write(priv, GMAC_REG_BMR, OGMA_GMAC_BMR_REG_COMMON);
>> +               ogma_mac_write(priv, GMAC_REG_RDLAR, priv->rdlar_pa);
>> +               ogma_mac_write(priv, GMAC_REG_TDLAR, priv->tdlar_pa);
>> +               ogma_mac_write(priv, GMAC_REG_MFFR, 0x80000001);
>> +
>> +               value = (priv->gmac_mode.half_duplex_flag ?
>> +                        OGMA_GMAC_MCR_REG_HALF_DUPLEX_COMMON :
>> +                        OGMA_GMAC_MCR_REG_FULL_DUPLEX_COMMON);
>> +
>> +               if (priv->gmac_mode.link_speed != OGMA_PHY_LINK_SPEED_1G)
>> +                       value |= OGMA_GMAC_MCR_PS;
>> +
>> +               if ((priv->param.gmac_config.phy_if != OGMA_PHY_IF_GMII) &&
>> +                   (priv->gmac_mode.link_speed == OGMA_PHY_LINK_SPEED_100M))
>> +                       value |= OGMA_GMAC_MCR_REG_FES;
>> +
>> +               value |= OGMA_GMAC_MCR_REG_CST | OGMA_GMAC_MCR_REG_JE;
>> +               ogma_mac_write(priv, GMAC_REG_MCR, value);
>> +
>> +               if (priv->gmac_mode.flow_ctrl_enable_flag) {
>> +                       ogma_write_reg(priv, MAC_REG_FLOW_TH,
>> +                                      (priv->gmac_mode.flow_stop_th << 16) |
>> +                                      priv->gmac_mode.flow_start_th);
>> +                       ogma_mac_write(priv, GMAC_REG_FCR,
>> +                                      (priv->gmac_mode.pause_time << 16) |
>> +                                      OGMA_GMAC_FCR_REG_RFE |
>> +                                      OGMA_GMAC_FCR_REG_TFE);
>> +               }
>> +       }
>> +
>> +       if ((rx_flag && !priv->gmac_rx_running_flag) ||
>> +           (tx_flag && !priv->gmac_tx_running_flag)) {
>> +               value = ogma_mac_read(priv, GMAC_REG_OMR);
>> +
>> +               if (rx_flag && (!priv->gmac_rx_running_flag)) {
>> +                       value |= OGMA_GMAC_OMR_REG_SR;
>> +                       priv->gmac_rx_running_flag = 1;
>> +               }
>> +               if (tx_flag && (!priv->gmac_tx_running_flag)) {
>> +                       value |= OGMA_GMAC_OMR_REG_ST;
>> +                       priv->gmac_tx_running_flag = 1;
>> +               }
>> +
>> +               ogma_mac_write(priv, GMAC_REG_OMR, value);
>> +       }
>
> This is close to impossible to read, there are way too many flags
> variable. Please find a way to use the PHY library along with
> netif_running() checks to simplify that.

Alright, I will look at how to do.

>> +
>> +       return 0;
>> +}
>> +
>> +int ogma_stop_gmac(struct ogma_priv *priv, bool rx_flag, bool tx_flag)
>> +{
>> +       u32 value;
>> +
>> +       if (!rx_flag && !tx_flag)
>> +               return 0;
>> +
>> +       if ((rx_flag && priv->gmac_rx_running_flag) ||
>> +           (tx_flag && priv->gmac_tx_running_flag)) {
>> +               value = ogma_mac_read(priv, GMAC_REG_OMR);
>> +
>> +               if (rx_flag && priv->gmac_rx_running_flag) {
>> +                       value &= (~OGMA_GMAC_OMR_REG_SR);
>> +                       priv->gmac_rx_running_flag = 0;
>> +               }
>> +               if (tx_flag && priv->gmac_tx_running_flag) {
>> +                       value &= (~OGMA_GMAC_OMR_REG_ST);
>> +                       priv->gmac_tx_running_flag = 0;
>> +               }
>> +
>> +               ogma_mac_write(priv, GMAC_REG_OMR, value);
>> +       }
>> +
>> +       return 0;
>> +}
>> +
>> +int ogma_set_gmac_mode(struct ogma_priv *priv,
>> +                      const struct ogma_gmac_mode *mode)
>> +{
>> +       if (priv->gmac_rx_running_flag || priv->gmac_tx_running_flag)
>> +               return -EBUSY;
>> +
>> +       if (mode->link_speed != OGMA_PHY_LINK_SPEED_1G &&
>> +           mode->link_speed != OGMA_PHY_LINK_SPEED_100M &&
>> +           mode->link_speed != OGMA_PHY_LINK_SPEED_10M) {
>> +               dev_err(priv->dev, "%s: bad link speed\n", __func__);
>> +               return -ENODATA;
>> +       }
>> +
>> +       if (mode->link_speed == OGMA_PHY_LINK_SPEED_1G &&
>> +           mode->half_duplex_flag) {
>> +               dev_err(priv->dev, "%s: 1G + half duplex\n", __func__);
>> +               return -ENODATA;
>> +       }
>
> This is not *usually* supported by most link partners, but it is still
> valid to have 1Gbits/half duplex, just handle it like any other mode.

I'll ask inside Fujitsu if there's some issue with that.  The logic to
reject it was explicit in the original driver.

>> +
>> +       if (mode->half_duplex_flag && mode->flow_ctrl_enable_flag) {
>> +               dev_err(priv->dev, "%s: half duplex + flow\n", __func__);
>> +               return -ENODATA;
>> +       }
>> +
>> +       if (mode->flow_ctrl_enable_flag) {
>> +               if (!mode->flow_start_th ||
>> +                   mode->flow_start_th > OGMA_FLOW_START_TH_MAX)
>> +                       return -ENODATA;
>> +
>> +               if (mode->flow_stop_th < mode->flow_start_th ||
>> +                   mode->flow_stop_th > OGMA_FLOW_STOP_TH_MAX)
>> +                       return -ENODATA;
>> +
>> +               if (mode->pause_time < OGMA_FLOW_PAUSE_TIME_MIN)
>> +                       return -ENODATA;
>
> These should be using the ethtool coalescing parameters. -ENODATA is
> not a valid return error code, -EINVAL at the very least or
> -EOPNOTSUPP.

OK.  It ended up ENODATA because the original driver had its own
abstracted error codes, and while blah_INVALID mapped to -EINVAL this
was a different code originally.  Will fix.

>> +       }
>> +
>> +       memcpy(&priv->gmac_mode, mode, sizeof(struct ogma_gmac_mode));
>> +       priv->gmac_mode_valid_flag = 1;
>> +
>> +       return 0;
>> +}
>> +
>> +void ogma_set_phy_reg(struct ogma_priv *priv, u8 phy_addr, u8 reg, u16 value)
>> +{
>> +       BUG_ON(phy_addr >= 32 || reg >= 32);
>> +
>> +       ogma_mac_write(priv, GMAC_REG_GDR, value);
>> +       ogma_mac_write(priv, GMAC_REG_GAR,
>> +                      phy_addr << OGMA_GMAC_GAR_REG_SHIFT_PA |
>> +                      reg << OGMA_GMAC_GAR_REG_SHIFT_GR |
>> +                      ogma_clk_type(priv->gmac_hz) << GMAC_REG_SHIFT_CR_GAR |
>> +                      OGMA_GMAC_GAR_REG_GW | OGMA_GMAC_GAR_REG_GB);
>> +
>> +       while (ogma_mac_read(priv, GMAC_REG_GAR) & OGMA_GMAC_GAR_REG_GB)
>> +               ;
>
> Missing timeout. And please implement those calls to conform to the
> PHY library. reg should be an unsigned 16-bits quantity.

OK.

>> +}
>> +
>> +u16 ogma_get_phy_reg(struct ogma_priv *priv, u8 phy_addr, u8 reg_addr)
>> +{
>> +       BUG_ON(phy_addr >= 32 || reg_addr >= 32);
>> +
>> +       ogma_mac_write(priv, GMAC_REG_GAR, OGMA_GMAC_GAR_REG_GB |
>> +                      phy_addr << OGMA_GMAC_GAR_REG_SHIFT_PA |
>> +                      reg_addr << OGMA_GMAC_GAR_REG_SHIFT_GR |
>> +                      ogma_clk_type(priv->gmac_hz) << GMAC_REG_SHIFT_CR_GAR);
>> +
>> +       while (ogma_mac_read(priv, GMAC_REG_GAR) & OGMA_GMAC_GAR_REG_GB)
>> +               ;
>
> Missing timeout here and same problem as before.
>
> [snip]
>
>> +int ogma_netdev_napi_poll(struct napi_struct *napi_p, int budget)
>> +{
>> +       struct ogma_ndev *ndev = container_of(napi_p, struct ogma_ndev, napi);
>> +       struct net_device *net_device = ndev->net_device;
>> +       int ret, i = 0, tx_queue_status, rx_num;
>
> You should rename i to "work_done" or "rx_pkt_processed" or anything
> that allows from a quick inspection what this variable is about.

OK.

>> +       struct ogma_rx_pkt_info rx_pkt_info;
>> +       struct ogma_frag_info frag;
>> +       struct sk_buff *skb;
>> +       u16 len;
>> +
>> +       for (i = 0, rx_num = 0; i < budget; i++, rx_num--) {
>> +               if (!rx_num) {
>> +                       rx_num = ogma_get_rx_num(ndev->priv,
>> +                                                OGMA_RING_NRM_RX);
>> +                       if (!rx_num)
>> +                               break;
>> +               }
>> +
>> +               ret = ogma_get_rx_pkt_data(ndev->priv, OGMA_RING_NRM_RX,
>> +                                          &rx_pkt_info, &frag, &len, &skb);
>> +               if (ret == -ENOMEM) {
>> +                       dev_err(ndev->priv->dev, "%s: rx fail %d",
>> +                               __func__, ret);
>> +                       net_device->stats.rx_dropped++;
>> +                       continue;
>> +               }
>
> The hardware does not tell you whether the packet is oversized, or if
> there any errors? That looks a little unusual.

I will ask inside Fujitsu.  This was the approach of the original
driver but I agree it sounds like something is missing.

> Use netdev_err() here instead. Or even better netif_err() with
> rx_status, this comment applies to the entire driver BTW.

OK.  It's another legacy from the original error approach I'll audit
all the -E* uses in the driver for it.

>> +
>> +               dma_unmap_single(ndev->dev_p, frag.phys_addr, frag.len,
>> +                                DMA_FROM_DEVICE);
>> +
>> +               skb_put(skb, len);
>> +               skb->protocol = eth_type_trans(skb, ndev->net_device);
>> +               skb->dev = ndev->net_device;
>
> skb->dev is already assigned by eth_type_trans().

OK

>> +
>> +               if (ndev->rx_cksum_offload_flag &&
>> +                   rx_pkt_info.rx_cksum_result == OGMA_RX_CKSUM_RESULT_OK)
>> +                       skb->ip_summed = CHECKSUM_UNNECESSARY;
>> +               else
>> +                       skb->ip_summed = CHECKSUM_NONE;
>
> This is already the case, no need to assign to CHECKSUM_NONE.

OK

>> +
>> +               napi_gro_receive(napi_p, skb);
>> +
>> +               net_device->stats.rx_packets++;
>> +               net_device->stats.rx_bytes += len;
>> +       }
>> +
>> +       ogma_ring_irq_clr(ndev->priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
>> +
>> +       ogma_clean_tx_desc_ring(ndev->priv, OGMA_RING_NRM_TX);
>> +       spin_lock(&ndev->tx_queue_lock);
>> +       tx_queue_status = netif_queue_stopped(ndev->net_device);
>> +       spin_unlock(&ndev->tx_queue_lock);
>> +
>> +       if (tx_queue_status &&
>> +           ogma_get_tx_avail_num(ndev->priv, OGMA_RING_NRM_TX) >=
>> +                                               OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX)
>> +               netif_wake_queue(ndev->net_device);
>> +
>> +       if (i == budget)
>> +               return budget;
>> +
>> +       napi_complete(napi_p);
>> +       ogma_write_reg(ndev->priv, OGMA_REG_TOP_INTEN_SET,
>> +                      OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
>
> You should separate the TX reclaim into its own function and do that
> before you process RX since this is usually a very fast operation.

OK

>> +
>> +       return i;
>> +}
>> +
>> +static void ogma_netdev_stop_sub(struct ogma_ndev *ndev, bool gmac_stop_flag)
>> +{
>> +       struct net_device *net_device = ndev->net_device;
>> +
>> +       pr_debug("%s\n", __func__);
>> +
>> +       if (ndev->phy_handler_kthread_p != NULL) {
>> +               kthread_stop(ndev->phy_handler_kthread_p);
>> +               ndev->phy_handler_kthread_p = NULL;
>> +       }
>
> What is this? The PHY library already provides a link state machine
> that should be more than sufficient.

It's a thread doing a 500ms periodic poll of PHY status.  If the PHY
library can replace it then great.

>> +
>> +       ndev->prev_link_status_flag = 0;
>> +       ndev->prev_auto_nego_complete_flag = 0;
>> +
>> +       netif_stop_queue(net_device);
>> +
>> +       if (gmac_stop_flag)
>> +               ogma_stop_gmac(ndev->priv, 1, 1);
>> +
>> +       ogma_stop_desc_ring(ndev->priv, OGMA_RING_NRM_RX);
>> +       ogma_stop_desc_ring(ndev->priv, OGMA_RING_NRM_TX);
>> +
>> +       napi_disable(&ndev->napi);
> [snip]
>
>> +static netdev_tx_t ogma_netdev_start_xmit(struct sk_buff *skb,
>> +                                         struct net_device *net_device)
>> +{
>> +       struct ogma_ndev *ndev = netdev_priv(net_device);
>> +       struct ogma_priv *priv = ndev->priv;
>> +       struct ogma_tx_pkt_ctrl tx_ctrl;
>> +       struct ogma_frag_info *scat;
>> +       u16 pend_tx, tso_seg_len;
>> +       skb_frag_t *frag;
>> +       u8 scat_num;
>> +       int ret, i;
>> +
>> +       memset(&tx_ctrl, 0, sizeof(struct ogma_tx_pkt_ctrl));
>> +
>> +       ogma_ring_irq_clr(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
>> +
>> +       ogma_clean_tx_desc_ring(priv, OGMA_RING_NRM_TX);
>
> TX reclaim should be done in your NAPI context, not before you start
> transmitting, otherwise you will just slow down packet transmission.

OK.

>> +       BUG_ON(skb_shinfo(skb)->nr_frags >= OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX);
>> +       scat_num = skb_shinfo(skb)->nr_frags + 1;
>> +
>> +       scat = kzalloc(scat_num * sizeof(*scat), GFP_NOWAIT);
>> +       if (!scat)
>> +               return NETDEV_TX_BUSY;
>> +
>> +       if (skb->ip_summed == CHECKSUM_PARTIAL) {
>> +               if (skb->protocol == htons(ETH_P_IP))
>> +                       ip_hdr(skb)->check = 0;
>> +               tx_ctrl.cksum_offload_flag = 1;
>> +       }
>> +
>> +       tso_seg_len = 0;
>> +
>> +       if (skb_is_gso(skb)) {
>> +               tso_seg_len = skb_shinfo(skb)->gso_size;
>> +
>> +               BUG_ON(skb->ip_summed != CHECKSUM_PARTIAL);
>> +               BUG_ON(!tso_seg_len);
>> +               BUG_ON(tso_seg_len > (priv->param.use_jumbo_pkt_flag ?
>> +                           OGMA_TCP_JUMBO_SEG_LEN_MAX : OGMA_TCP_SEG_LEN_MAX));
>> +
>> +               if (tso_seg_len < OGMA_TCP_SEG_LEN_MIN) {
>> +                       tso_seg_len = OGMA_TCP_SEG_LEN_MIN;
>> +
>> +                       if (skb->data_len < OGMA_TCP_SEG_LEN_MIN)
>> +                               tso_seg_len = 0;
>> +               }
>> +       }
>> +
>> +       if (tso_seg_len > 0) {
>> +               if (skb->protocol == htons(ETH_P_IP)) {
>> +                       BUG_ON(!(skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4));
>> +
>> +                       ip_hdr(skb)->tot_len = 0;
>> +                       tcp_hdr(skb)->check =
>> +                               ~tcp_v4_check(0, ip_hdr(skb)->saddr,
>> +                                             ip_hdr(skb)->daddr, 0);
>> +               } else {
>> +                       BUG_ON(!(skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6));
>> +                       ipv6_hdr(skb)->payload_len = 0;
>> +                       tcp_hdr(skb)->check =
>> +                               ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
>> +                                                &ipv6_hdr(skb)->daddr,
>> +                                                0, IPPROTO_TCP, 0);
>> +               }
>> +        if (dma_mapping_error(jrdev, ctx->sh_desc_enc_dma)) {
                dev_err(jrdev, "unable to map shared descriptor\n");
                return -ENOMEM;
        }
>> +               tx_ctrl.tcp_seg_offload_flag = 1;
>> +               tx_ctrl.tcp_seg_len = tso_seg_len;
>> +       }
>> +
>> +       scat[0].phys_addr = dma_map_single(ndev->dev_p, skb->data,
>> +                                       skb_headlen(skb), DMA_TO_DEVICE);
>
> Missing dma_mapping_error() here.

OK

>> +       scat[0].addr = skb->data;
>> +       scat[0].len = skb_headlen(skb);
>> +
>> +       for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>> +               frag = &skb_shinfo(skb)->frags[i];
>> +               scat[i + 1].phys_addr = skb_frag_dma_map(ndev->dev_p, frag, 0,
>> +                               skb_frag_size(frag), DMA_TO_DEVICE);
>> +               scat[i + 1].addr = skb_frag_address(frag);
>> +               scat[i + 1].len = frag->size;
>> +       }
>> +
>> +       tx_ctrl.target_desc_ring_id = OGMA_RING_GMAC;
>> +       ogma_mark_skb_type(skb, OGMA_RING_NRM_TX);
>> +
>> +       ret = ogma_set_tx_pkt_data(priv, OGMA_RING_NRM_TX, &tx_ctrl, scat_num,
>> +                                  scat, skb);
>> +
>> +       if (ret) {
>> +               dev_err(priv->dev, "set tx pkt failed %d.", ret);
>> +               for (i = 0; i < scat_num; i++)
>> +                       dma_unmap_single(ndev->dev_p, scat[i].phys_addr,
>> +                                        scat[i].len, DMA_TO_DEVICE);
>> +               kfree(scat);
>> +               net_device->stats.tx_dropped++;
>> +
>> +               return NETDEV_TX_BUSY;
>
> NETDEV_TX_BUSY should only be used when you run out of descriptors,
> which you should check before. Here most likely you would run out of
> memory/DMA mappings, so NETDEV_TX_OK should be returned.

OK

>> +       }
>> +
>> +       kfree(scat);
>> +
>> +       net_device->stats.tx_packets++;
>> +       net_device->stats.tx_bytes += skb->len;
>
> Do not increment statistics here, you queued packets, but there is no
> guarantee at this point that your transmission has actually completed.
> This should be done in your TX reclaim/clean function instead.

OK

>> +
>> +       spin_lock(&ndev->tx_queue_lock);
>> +       pend_tx = ogma_get_tx_avail_num(ndev->priv, OGMA_RING_NRM_TX);
>
> Would not a smp_rmb() be sufficient here if the sole purpose of the
> spin_lock() is to get a consistent view of pend_tx.

OK

>> +
>> +       if (pend_tx < OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX) {
>> +               ogma_ring_irq_enable(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
>> +               netif_stop_queue(net_device);
>> +               goto err;
>> +       }
>> +       if (pend_tx <= ndev->tx_empty_irq_activation_threshold) {
>> +               ogma_ring_irq_enable(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
>> +               goto err;
>> +       }
>> +       ogma_ring_irq_disable(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
>> +
>> +err:
>> +       spin_unlock(&ndev->tx_queue_lock);
>> +
>> +       return NETDEV_TX_OK;
>> +}
>> +
>> +static struct net_device_stats *ogma_netdev_get_stats(struct net_device
>> +                                                     *net_device)
>> +{
>> +       return &net_device->stats;
>> +}
>> +
>> +static void ogma_ethtool_get_drvinfo(struct net_device *net_device,
>> +                                    struct ethtool_drvinfo *drvinfo)
>> +{
>
> Please return something useful here.

OK

>> +}
>> +
>> +static int ogma_netdev_change_mtu(struct net_device *net_device, int new_mtu)
>> +{
>> +       struct ogma_ndev *ndev = netdev_priv(net_device);
>> +
>> +       if (!ndev->priv->param.use_jumbo_pkt_flag)
>> +               return eth_change_mtu(net_device, new_mtu);
>> +
>> +       if ((new_mtu < 68) || (new_mtu > 9000))
>> +               return -EINVAL;
>> +
>> +       net_device->mtu = new_mtu;
>> +
>> +       return 0;
>> +}
>> +
>> +static int ogma_netdev_set_features(struct net_device *net_device,
>> +                                   netdev_features_t features)
>> +{
>> +       struct ogma_ndev *ndev = netdev_priv(net_device);
>> +
>> +       ndev->rx_cksum_offload_flag = !!(features & NETIF_F_RXCSUM);
>
> This does not look correct. At the very least you should check against
> ndev->wanted_features which is what user-space requested we
> enable/disable.

I see... will do.

>> +
>> +       return 0;
>> +}
>> +
>> +static void ogma_netdev_get_phy_link_status(struct ogma_ndev *ndev,
>> +                                           unsigned int *link_status,
>> +                                           unsigned int *autoneg_done,
>> +                                           unsigned int *link_down,
>> +                                           unsigned int *link_speed,
>> +                                           unsigned int *half_duplex)
>> +{
>> +       struct ogma_priv *priv = ndev->priv;
>> +       u16 sr, u;
>> +
>> +       *link_down = 0;
>> +       *link_speed = OGMA_PHY_LINK_SPEED_10M;
>> +       *half_duplex = 0;
>
> This is duplicating the PHY library, please consider implementing an
> adjust_link() callback instead of open-coding this

I think studying how this phy library is used by other drivers will
probably impact a lot of things....

>> +
>> +       sr = ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_SR);
>> +
>> +       if (!(sr & OGMA_PHY_SR_REG_LINK)) {
>> +               *link_down = 1;
>> +               sr = ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_SR);
>> +       }
>> +
>> +       *link_status = !!(sr & OGMA_PHY_SR_REG_LINK);
>> +       *autoneg_done = !!(sr & OGMA_PHY_SR_REG_AN_C);
>> +
>> +       if (!*link_status || !*autoneg_done)
>> +               return;
>> +
>> +       if ((ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_MSC) &
>> +                                       OGMA_PHY_MSC_REG_1000BASE_FULL) &&
>> +                       (ogma_get_phy_reg(priv, priv->phyads,
>> +                                       OGMA_PHY_REG_ADDR_1000BASE_SR) &
>> +                                               OGMA_PHY_1000BASE_REG_FULL)) {
>> +               *link_speed = OGMA_PHY_LINK_SPEED_1G;
>> +               return;
>> +       }
>> +
>> +       u = ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_ANA) &
>> +           ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_ANLPA);
>> +
>> +       if (u & OGMA_PHY_ANLPA_REG_TXF) {
>> +               *link_speed = OGMA_PHY_LINK_SPEED_100M;
>> +               return;
>> +       }
>> +       if (u & OGMA_PHY_ANLPA_REG_TXD) {
>> +               *link_speed = OGMA_PHY_LINK_SPEED_100M;
>> +               *half_duplex = 1;
>> +               return;
>> +       }
>> +       if (u & OGMA_PHY_ANLPA_REG_TF) {
>> +               *link_speed = OGMA_PHY_LINK_SPEED_10M;
>> +               return;
>> +       }
>> +
>> +       *link_speed = OGMA_PHY_LINK_SPEED_10M;
>> +       *half_duplex = 1;
>> +}
>> +
>> +static int ogma_netdev_configure_mac(struct ogma_ndev *ndev,
>> +                                    int link_speed, int half_duplex_flag)
>> +{
>> +       struct ogma_gmac_mode mode;
>> +       int ret;
>> +
>> +       memcpy(&mode, &ndev->priv->gmac_mode, sizeof(mode));
>> +
>> +       mode.link_speed = link_speed;
>> +       mode.half_duplex_flag = half_duplex_flag;
>> +
>> +       ret = ogma_stop_gmac(ndev->priv, true, true);
>> +       if (ret)
>> +               return ret;
>> +
>> +       ret = ogma_set_gmac_mode(ndev->priv, &mode);
>> +       if (ret)
>> +               return ret;
>> +
>> +       return ogma_start_gmac(ndev->priv, true, true);
>> +}
>> +
>> +static void net_device_phy_poll(struct ogma_ndev *ndev)
>> +{
>> +       unsigned int link_status_flag, auto_nego_complete_flag,
>> +               latched_link_down_flag, link_speed, half_duplex;
>> +       int ret;
>> +
>> +       if (!(ndev->net_device->flags & IFF_UP))
>> +               return;
>
> This is netif_running(), and as said before, this duplicates the link
> state machine, please get rid of this.
>
>> +
>> +       ogma_netdev_get_phy_link_status(ndev, &link_status_flag,
>> +                                       &auto_nego_complete_flag,
>> +                                       &latched_link_down_flag,
>> +                                       &link_speed, &half_duplex);
>> +
>> +       if ((!latched_link_down_flag) &&
>> +           (link_status_flag == ndev->prev_link_status_flag) &&
>> +           (auto_nego_complete_flag == ndev->prev_auto_nego_complete_flag))
>> +               return;
>> +
>> +       /* Configure GMAC if link is up and auto negotiation is complete */
>> +       if (link_status_flag && auto_nego_complete_flag) {
>> +               ret = ogma_netdev_configure_mac(ndev, link_speed, half_duplex);
>> +               if (ret) {
>> +                       dev_err(ndev->priv->dev, "%s: fail conf mac", __func__);
>> +                       link_status_flag = 0;
>> +                       auto_nego_complete_flag = 0;
>> +               }
>> +       }
>> +
>> +       if (ndev->prev_link_status_flag != link_status_flag) {
>> +               if (link_status_flag) {
>> +                       netif_carrier_on(ndev->net_device);
>> +                       netif_start_queue(ndev->net_device);
>> +               } else {
>> +                       netif_stop_queue(ndev->net_device);
>> +                       netif_carrier_off(ndev->net_device);
>> +               }
>> +       }
>> +
>> +       /* Update saved PHY status */
>> +       ndev->prev_link_status_flag = link_status_flag;
>> +       ndev->prev_auto_nego_complete_flag = auto_nego_complete_flag;
>> +}
>> +
>> +static int netdev_phy_handler(void *argp)
>> +{
>> +       struct ogma_ndev *ndev = (struct ogma_ndev *)argp;
>> +
>> +       while (!kthread_should_stop()) {
>> +               rtnl_lock();
>> +               net_device_phy_poll(ndev);
>> +               rtnl_unlock();
>> +               schedule_timeout_interruptible(500 * HZ / 1000);
>> +       }
>> +
>> +       return 0;
>> +}
>> +
>> +static int ogma_netdev_open_sub(struct ogma_ndev *ndev)
>> +{
>> +       struct ogma_priv *priv = ndev->priv;
>> +       int ret;
>> +
>> +       napi_enable(&ndev->napi);
>> +
>> +       ret = ogma_start_desc_ring(priv, OGMA_RING_NRM_RX);
>> +       if (ret) {
>> +               dev_err(priv->dev, "%s: start rx desc fail\n", __func__);
>> +               ret = -EINVAL;
>> +               goto disable_napi;
>> +       }
>> +
>> +       ret = ogma_set_irq_coalesce_param(priv, OGMA_RING_NRM_RX,
>> +                                         ndev->rxint_pktcnt, 0,
>> +                                         ndev->rxint_tmr_cnt_us);
>> +       if (ret) {
>> +               dev_err(priv->dev, "%s: set irq fail\n", __func__);
>> +               ret = -EINVAL;
>> +               goto stop_desc_ring_nrm_rx;
>> +       }
>> +
>> +       ret = ogma_start_desc_ring(priv, OGMA_RING_NRM_TX);
>> +       if (ret) {
>> +               dev_err(priv->dev, "%s: start tx desc fail\n", __func__);
>> +               ret = -EINVAL;
>> +               goto stop_desc_ring_nrm_rx;
>> +       }
>> +
>> +       /* We adaptively control tx_empty IRQ */
>> +       ogma_ring_irq_disable(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
>> +
>> +       ndev->phy_handler_kthread_p = kthread_run(netdev_phy_handler,
>> +                                       (void *)ndev, "netdev_phy_handler");
>> +       if (IS_ERR(ndev->phy_handler_kthread_p)) {
>> +               ret = PTR_ERR(ndev->phy_handler_kthread_p);
>> +               ndev->phy_handler_kthread_p = NULL;
>> +               goto stop_queue;
>> +       }
>> +
>> +       return 0;
>> +
>> +stop_queue:
>> +
>> +       ogma_stop_desc_ring(ndev->priv, OGMA_RING_NRM_TX);
>> +
>> +stop_desc_ring_nrm_rx:
>> +       ogma_stop_desc_ring(ndev->priv, OGMA_RING_NRM_RX);
>> +
>> +disable_napi:
>> +       napi_disable(&ndev->napi);
>> +
>> +       return ret;
>> +}
>> +
>> +static int ogma_netdev_open(struct net_device *net_device)
>> +{
>> +       struct ogma_ndev *ndev = netdev_priv(net_device);
>> +       int ret;
>> +
>> +       pr_debug("%s\n", __func__);
>> +       pm_runtime_get_sync(ndev->priv->dev);
>> +
>> +       ret = ogma_clean_rx_desc_ring(ndev->priv, OGMA_RING_NRM_RX);
>> +       if (ret) {
>> +               dev_err(ndev->priv->dev, "%s: clean rx desc fail\n", __func__);
>> +               goto err;
>> +       }
>> +
>> +       ret = ogma_clean_tx_desc_ring(ndev->priv, OGMA_RING_NRM_TX);
>> +       if (ret) {
>> +               dev_err(ndev->priv->dev, "%s: clean tx desc fail\n", __func__);
>> +               goto err;
>> +       }
>> +
>> +       ogma_ring_irq_clr(ndev->priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
>> +
>> +       ret = ogma_netdev_open_sub(ndev);
>> +       if (ret) {
>> +               dev_err(ndev->priv->dev, "ogma_netdev_open_sub() failed\n");
>> +               goto err;
>> +       }
>
> Where is your transmit queue enabled? You should call
> netif_queue_start() somewhere.

OK.

>> +
>> +       return ret;
>> +
>> +err:
>> +       pm_runtime_put_sync(ndev->priv->dev);
>> +
>> +       return ret;
>> +}
>> +
>> +const struct net_device_ops ogma_netdev_ops = {
>> +       .ndo_open               = ogma_netdev_open,
>> +       .ndo_stop               = ogma_netdev_stop,
>> +       .ndo_start_xmit         = ogma_netdev_start_xmit,
>> +       .ndo_set_features       = ogma_netdev_set_features,
>> +       .ndo_get_stats          = ogma_netdev_get_stats,
>> +       .ndo_change_mtu         = ogma_netdev_change_mtu,
>> +       .ndo_set_mac_address    = ogma_netdev_set_macaddr,
>> +       .ndo_validate_addr      = eth_validate_addr,
>> +};
>> +
>> +const struct ethtool_ops ogma_ethtool_ops = {
>> +       .get_drvinfo            = ogma_ethtool_get_drvinfo,
>> +};
>> diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
>> new file mode 100755
>> index 0000000..dd5ebf3
>> --- /dev/null
>> +++ b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
>> @@ -0,0 +1,729 @@
>> +/**
>> + * ogma_driver.c
>> + *
>> + *  Copyright (C) 2013-2014 Fujitsu Semiconductor Limited.
>> + *  Copyright (C) 2014 Linaro Ltd  Andy Green <andy.green@linaro.org>
>> + *  All rights reserved.
>> + *
>> + *  This program is free software; you can redistribute it and/or
>> + *  modify it under the terms of the GNU General Public License
>> + *  as published by the Free Software Foundation; either version 2
>> + *  of the License, or (at your option) any later version.
>> + */
>> +
>> +#include <linux/version.h>
>> +#include <linux/moduleparam.h>
>> +#include <linux/device.h>
>> +#include <linux/string.h>
>> +#include <linux/random.h>
>> +#include <linux/pci.h>
>> +#include <linux/ctype.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/types.h>
>> +#include <linux/bitops.h>
>> +#include <linux/dma-mapping.h>
>> +#include <linux/module.h>
>> +#include <linux/sizes.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/clk.h>
>> +#include <linux/of.h>
>> +#include <linux/of_device.h>
>> +#include <linux/io.h>
>> +#include <linux/pm_runtime.h>
>> +#include <linux/kthread.h>
>> +
>> +#include "ogma.h"
>> +
>> +#define OGMA_F_NETSEC_VER_MAJOR_NUM(x) (x & 0xffff0000)
>> +
>> +static const u32 desc_ads[OGMA_RING_MAX + 1] = {
>> +       OGMA_REG_NRM_TX_CONFIG,
>> +       OGMA_REG_NRM_RX_CONFIG,
>> +       0,
>> +       0
>> +};
>> +
>> +static const u32 ogma_desc_start_reg_addr[OGMA_RING_MAX + 1] = {
>> +       OGMA_REG_NRM_TX_DESC_START,
>> +       OGMA_REG_NRM_RX_DESC_START,
>> +       OGMA_REG_RESERVED_RX_DESC_START,
>> +       OGMA_REG_RESERVED_TX_DESC_START
>> +};
>> +
>> +static unsigned short tx_desc_num = 128;
>> +static unsigned short rx_desc_num = 128;
>> +static int napi_weight = 64;
>> +unsigned short pause_time = 256;
>> +
>> +#define WAIT_FW_RDY_TIMEOUT 50
>> +
>> +static u32 ogma_calc_pkt_ctrl_reg_param(const struct ogma_pkt_ctrlaram
>> +                                       *pkt_ctrlaram_p)
>> +{
>> +       u32 param = OGMA_PKT_CTRL_REG_MODE_NRM;
>> +
>> +       if (pkt_ctrlaram_p->log_chksum_er_flag)
>> +               param |= OGMA_PKT_CTRL_REG_LOG_CHKSUM_ER;
>> +
>> +       if (pkt_ctrlaram_p->log_hd_imcomplete_flag)
>> +               param |= OGMA_PKT_CTRL_REG_LOG_HD_INCOMPLETE;
>> +
>> +       if (pkt_ctrlaram_p->log_hd_er_flag)
>> +               param |= OGMA_PKT_CTRL_REG_LOG_HD_ER;
>> +
>> +       return param;
>> +}
>> +
>> +int ogma_configure_normal_mode(struct ogma_priv *priv,
>> +                              const struct ogma_normal
>> +                              *normal_p)
>> +{
>> +       int ret = 0;
>> +       int timeout;
>> +       u32 value;
>> +
>> +       if (!priv || !normal_p)
>> +               return -EINVAL;
>> +
>> +       memcpy((void *)&priv->normal,
>> +              (const void *)normal_p,
>> +              sizeof(struct ogma_normal));
>> +
>> +       /* save scb set value  */
>> +       priv->scb_set_normal_tx_phys_addr = ogma_read_reg(priv,
>> +                       ogma_desc_start_reg_addr[OGMA_RING_NRM_TX]);
>> +
>> +       /* set desc_start addr */
>> +       ogma_write_reg(priv,
>> +                      ogma_desc_start_reg_addr[OGMA_RING_NRM_RX],
>> +                      priv->desc_ring[OGMA_RING_NRM_RX].deschys_addr);
>> +
>> +       ogma_write_reg(priv,
>> +                      ogma_desc_start_reg_addr[OGMA_RING_NRM_TX],
>> +                      priv->desc_ring[OGMA_RING_NRM_TX].deschys_addr);
>> +
>> +       /* set normal tx desc ring config */
>> +       value = priv->normal.tx_tmr_mode_flag << OGMA_REG_DESC_TMR_MODE |
>> +               priv->normal.tx_little_endian_flag << OGMA_REG_DESC_ENDIAN |
>> +               1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
>> +               1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
>> +       ogma_write_reg(priv, desc_ads[OGMA_RING_NRM_TX], value);
>> +
>> +       value = priv->normal.rx_tmr_mode_flag << OGMA_REG_DESC_TMR_MODE |
>> +               priv->normal.rx_little_endian_flag << OGMA_REG_DESC_ENDIAN |
>> +               1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
>> +               1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
>> +       ogma_write_reg(priv, desc_ads[OGMA_RING_NRM_RX], value);
>> +
>> +       timeout = WAIT_FW_RDY_TIMEOUT;
>> +       while (timeout-- && (ogma_read_reg(priv, desc_ads[OGMA_RING_NRM_TX]) &
>> +                                      (1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP)))
>> +               usleep_range(1000, 2000);
>> +
>> +       if (timeout < 0)
>> +               return -ETIME;
>> +
>> +       timeout = WAIT_FW_RDY_TIMEOUT;
>> +       while (timeout-- && (ogma_read_reg(priv, desc_ads[OGMA_RING_NRM_RX]) &
>> +                                      (1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP)))
>> +               usleep_range(1000, 2000);
>> +
>> +       if (timeout < 0)
>> +               return -ETIME;
>> +
>> +       priv->normal_desc_ring_valid = 1;
>> +
>> +       return ret;
>> +}
>> +
>> +int ogma_change_mode_to_normal(struct ogma_priv *priv)
>> +{
>> +       int ret = 0;
>> +       u32 value;
>> +
>> +       if (!priv->normal_desc_ring_valid)
>> +               return -EINVAL;
>> +
>> +       priv->scb_pkt_ctrl_reg = ogma_read_reg(priv, OGMA_REG_PKT_CTRL);
>> +
>> +       value = ogma_calc_pkt_ctrl_reg_param(&priv->normal. pkt_ctrlaram);
>> +
>> +       if (priv->normal.use_jumbo_pkt_flag)
>> +               value |= OGMA_PKT_CTRL_REG_EN_JUMBO;
>> +
>> +       value |= OGMA_PKT_CTRL_REG_MODE_NRM;
>> +
>> +       /* change to normal mode */
>> +       ogma_write_reg(priv, OGMA_REG_DMA_MH_CTRL,
>> +                      OGMA_DMA_MH_CTRL_REG_MODE_TRANS);
>> +
>> +       ogma_write_reg(priv, OGMA_REG_PKT_CTRL, value);
>> +
>> +       priv->normal_desc_ring_valid = 0;
>> +
>> +       return ret;
>> +}
>> +
>> +int ogma_change_mode_to_taiki(struct ogma_priv *priv)
>> +{
>> +       int ret = 0;
>> +       u32 value;
>> +
>> +       ogma_write_reg(priv, ogma_desc_start_reg_addr[OGMA_RING_NRM_TX],
>> +                      priv->scb_set_normal_tx_phys_addr);
>> +
>> +       value = 1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
>> +               1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
>> +
>> +       ogma_write_reg(priv, desc_ads[OGMA_RING_NRM_TX], value);
>> +
>> +       while (ogma_read_reg(priv, desc_ads[OGMA_RING_NRM_TX]) &
>> +                                       (1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP))
>> +               ;
>> +
>> +       ogma_write_reg(priv, OGMA_REG_DMA_MH_CTRL,
>> +                      OGMA_DMA_MH_CTRL_REG_MODE_TRANS);
>> +
>> +       ogma_write_reg(priv, OGMA_REG_PKT_CTRL, priv->scb_pkt_ctrl_reg);
>> +
>> +       return ret;
>> +}
>> +
>> +int ogma_clear_modechange_irq(struct ogma_priv *priv, u32 value)
>> +{
>> +       ogma_write_reg(priv, OGMA_REG_MODE_TRANS_COMP_STATUS,
>> +                      (value & (OGMA_MODE_TRANS_COMP_IRQ_N2T |
>> +                                OGMA_MODE_TRANS_COMP_IRQ_T2N)));
>> +
>> +       return 0;
>> +}
>> +
>> +static int ogma_hw_configure_to_normal(struct ogma_priv *priv)
>> +{
>> +       struct ogma_normal normal = { 0 };
>> +       int err;
>> +
>> +       normal.use_jumbo_pkt_flag = true;
>> +
>> +       /* set descriptor endianess according to CPU endianess */
>> +       normal.tx_little_endian_flag = cpu_to_le32(1) == 1;
>> +       normal.rx_little_endian_flag = cpu_to_le32(1) == 1;
>> +
>> +       err = ogma_configure_normal_mode(priv, &normal);
>> +       if (err) {
>> +               dev_err(priv->dev, "%s: normal conf fail\n", __func__);
>> +               return err;
>> +       }
>> +       err = ogma_change_mode_to_normal(priv);
>> +       if (err) {
>> +               dev_err(priv->dev, "%s: normal set fail\n", __func__);
>> +               return err;
>> +       }
>> +       /* Wait Change mode Complete */
>> +       usleep_range(2000, 10000);
>> +
>> +       return err;
>> +}
>> +
>> +static int ogma_hw_configure_to_taiki(struct ogma_priv *priv)
>> +{
>> +       int ret;
>> +
>> +       ret = ogma_change_mode_to_taiki(priv);
>> +       if (ret) {
>> +               dev_err(priv->dev, "%s: taiki set fail\n", __func__);
>> +               return ret;
>> +       }
>> +
>> +       /* Wait Change mode to Taiki Complete */
>> +       usleep_range(2000, 10000);
>
> Cannot this timeout be inside ogma_change_mode_to_taiki()?

Yes.

> [snip]
>
>> +
>> +static int ogma_probe(struct platform_device *pdev)
>> +{
>> +       struct device_node *phy_np;
>> +       struct ogma_priv *priv;
>> +       struct ogma_ndev *ndev;
>> +       struct resource *res;
>> +       u32 scb_irq_temp;
>> +       const char *cp;
>> +       const u32 *p;
>> +       u32 hw_ver;
>> +       int err, i;
>> +       int ret;
>> +       int len;
>> +
>> +       priv = kzalloc(sizeof(*priv), GFP_KERNEL);
>> +       if (!priv)
>> +               return -ENOMEM;
>
> This is not necessary, just call alloc_etherdev() with sizeof(*priv)
> for it to allocate your private context.

OK.

>> +
>> +       platform_set_drvdata(pdev, priv);
>> +
>> +       priv->dev = &pdev->dev;
>> +       priv->clock_count = 0;
>> +
>> +       p = of_get_property(pdev->dev.of_node, "local-mac-address", &len);
>> +       if (!p || len != (ETH_ALEN * sizeof(int))) {
>> +               dev_err(&pdev->dev, "Missing Mac Address\n");
>> +               goto err1;
>> +       }
>> +       for (i = 0; i < ETH_ALEN; i++)
>> +               priv->mac[i] = be32_to_cpu(p[i]);
>
> of_get_mac_address() does that already

Oh... OK thanks.

> [snip]
>
>> +
>> +       priv->dummy_virt = dma_alloc_coherent(NULL, OGMA_DUMMY_DESC_ENTRY_LEN,
>> +                                                &priv->dummy_phys, GFP_KERNEL);
>
> You should use the struct device pointer from &pdev->dev, such that
> you respect the DMA mask that your device might need, as well as any
> custom per-device DMA-API operations that could exist.

Got it thanks.

> [snip]
>
>> +       p = of_get_property(phy_np, "reg", NULL);
>> +       if (p) {
>> +               priv->phyads = be32_to_cpu(*p);
>> +       } else {
>> +               dev_err(&pdev->dev, "Missing phy address in DT\n");
>> +               goto err3b;
>> +       }
>> +
>> +       priv->gmac_mode.link_speed = OGMA_PHY_LINK_SPEED_1G;
>> +       p = of_get_property(pdev->dev.of_node, "max-speed", NULL);
>> +       if (p) {
>> +               switch (be32_to_cpu(*p)) {
>> +               case 1000:
>> +                       priv->gmac_mode.link_speed = OGMA_PHY_LINK_SPEED_1G;
>> +                       break;
>> +               case 100:
>> +                       priv->gmac_mode.link_speed = OGMA_PHY_LINK_SPEED_100M;
>> +                       break;
>> +               case 10:
>> +                       priv->gmac_mode.link_speed = OGMA_PHY_LINK_SPEED_10M;
>> +                       break;
>> +               default:
>> +                       dev_err(&pdev->dev,
>> +                               "link-speed should be 1000, 100 or 10\n");
>> +                       goto err4;
>> +               }
>> +       }
>
> Once again, the PHY library does that if you register a MDIO bus for
> your Ethernet MAC as you should.
>
>> +       scb_irq_temp = ogma_read_reg(priv, OGMA_REG_TOP_INTEN);
>> +       ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR, scb_irq_temp);
>> +
>> +       ret = ogma_hw_configure_to_normal(priv);
>> +       if (ret) {
>> +               dev_err(&pdev->dev, "%s: normal cfg fail %d", __func__, ret);
>> +               goto err3b;
>> +       }
>> +
>> +       priv->net_device = alloc_netdev(sizeof(*ndev), "eth%d", ether_setup);
>
> alloc_etherdev() does that.

OK

>> +       if (!priv->net_device)
>> +               goto err3b;
>> +
>> +       ndev = netdev_priv(priv->net_device);
>> +       ndev->dev_p = &pdev->dev;
>> +       ndev->phy_handler_kthread_p = NULL;
>> +       SET_NETDEV_DEV(priv->net_device, &pdev->dev);
>> +
>> +       memcpy(priv->net_device->dev_addr, priv->mac, 6);
>
> checkpatch.pl should warn you about this and advise using
> ether_copy_addr() instead.

Didn't see any warning... will do.

>> +
>> +       netif_napi_add(priv->net_device, &ndev->napi, ogma_netdev_napi_poll,
>> +                      napi_weight);
>> +
>> +       priv->net_device->netdev_ops = &ogma_netdev_ops;
>> +       priv->net_device->ethtool_ops = &ogma_ethtool_ops;
>> +       priv->net_device->features = NETIF_F_SG | NETIF_F_IP_CSUM |
>> +                                    NETIF_F_IPV6_CSUM | NETIF_F_TSO |
>> +                                    NETIF_F_TSO6 | NETIF_F_GSO |
>> +                                    NETIF_F_HIGHDMA | NETIF_F_RXCSUM;
>> +       priv->net_device->hw_features = priv->net_device->features;
>> +
>> +       ndev->priv = priv;
>> +       ndev->net_device = priv->net_device;
>> +       ndev->rx_cksum_offload_flag = 1;
>> +       spin_lock_init(&ndev->tx_queue_lock);
>> +       ndev->tx_desc_num = tx_desc_num;
>> +       ndev->rx_desc_num = rx_desc_num;
>> +       ndev->rxint_tmr_cnt_us = 0;
>> +       ndev->rxint_pktcnt = 1;
>> +       ndev->tx_empty_irq_activation_threshold = tx_desc_num - 2;
>> +       ndev->prev_link_status_flag = 0;
>> +       ndev->prev_auto_nego_complete_flag = 0;
>> +
>> +       err = register_netdev(priv->net_device);
>> +       if (err) {
>> +               dev_err(priv->dev, "register_netdev() failed");
>> +               goto err3c;
>> +       }
>> +
>> +       if (err) {
>> +               dev_err(&pdev->dev, "ogma_netdev_init() failed\n");
>> +               ogma_terminate(priv);
>> +               goto err4;
>> +       }
>> +       priv->net_device->irq = priv->irq;
>
> This looks potentially racy, at the very moment register_netdev() is
> called, any kernel thread or user-space program can call ndo_open(),
> so you need to assign this member before. register_netdev() really
> should be the last thing you do before returning from your probe()
> function.

OK.

>> +
>> +       ogma_write_reg(priv, OGMA_REG_TOP_INTEN_SET, OGMA_TOP_IRQ_REG_NRM_TX |
>> +                                                    OGMA_TOP_IRQ_REG_NRM_RX);
>
> This should be done in your ndo_open() function, not here.

OK

> [snip]
>
>> +
>> +       ogma_set_phy_reg(priv, priv->phyads, 0,
>> +                        ogma_get_phy_reg(priv, priv->phyads, 0) | (1 << 15));
>> +       while ((ogma_get_phy_reg(priv, priv->phyads, 0)) & (1 << 15))
>> +               ;
>
> You want a timeout here to make sure we catch when things go wrong,
> and this deserves a comment explaining what it does.

OK it sounds like a general "timeout / safe spin" function is needed
to mop all this up.

> [snip]
>
>> +
>> +static int __init ogma_module_init(void)
>> +{
>> +       return platform_driver_register(&ogma_driver);
>> +}
>> +
>> +static void __exit ogma_module_exit(void)
>> +{
>> +       platform_driver_unregister(&ogma_driver);
>> +}
>> +
>> +module_init(ogma_module_init);
>> +module_exit(ogma_module_exit);
>
> module_platform_driver() to reduce the boilerplate.

OK.

Thanks again for taking the time.  I guess I will be busy for a while
implementing these changes ^^

-Andy

> --
> Florian
