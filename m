From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v3 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Wed, 23 Apr 2014 17:46:01 -0700
Message-ID: <CAKh23FkZoWJk9L3VhvWmGqQfyjvSg=QJ9sRKzw4tr88DwQQ3zg@mail.gmail.com>
References: <1397702368-4846-1-git-send-email-isubramanian@apm.com>
	<1397702368-4846-5-git-send-email-isubramanian@apm.com>
	<1397704613.14062.13.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"jcm@redhat.com" <jcm@redhat.com>, patches <patches@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og107.obsmtp.com ([64.18.0.184]:46236 "HELO
	exprod5og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751269AbaDXAqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 20:46:05 -0400
Received: by mail-la0-f49.google.com with SMTP id ec20so1122200lab.36
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 17:46:01 -0700 (PDT)
In-Reply-To: <1397704613.14062.13.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2014 at 8:16 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2014-04-16 at 19:39 -0700, Iyappan Subramanian wrote:
>> This patch adds network driver for APM X-Gene SoC ethernet.
> []
>> diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
> []
>> @@ -0,0 +1,10 @@
>> +config NET_XGENE
>> +     tristate "APM X-Gene SoC Ethernet Driver"
>> +     select PHYLIB
>> +     default y
>
> default y?
>
> Shouldn't this need a depends on too?

I will remove the "default" entry.

>
>> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>
>> +static void xgene_enet_ring_set_type(u32 *ring_cfg, u8 is_bufpool)
>> +{
>
> bool is_bufpool?
>

Great suggestion.  I will replace with bool and try to use bool where
ever possible.

>> +static void xgene_enet_set_ring_id(struct xgene_enet_desc_ring *ring)
>> +{
>> +     u32 ring_id_val;
>> +     u32 ring_id_buf;
>> +     u8 is_bufpool = IS_FP(ring->id);
>
> bool?
>
>> +
>> +     ring_id_val = ring->id & GENMASK(9, 0);
>> +     ring_id_val |= (1 << 31) & GENMASK(31, 31);
>
> Setting a single bit and masking with the same
> bit looks silly.

I will use BIT macro in these circumstances.

>
>> +
>> +     ring_id_buf = (ring->num << 9) & GENMASK(18, 9);
>> +     ring_id_buf |= ((u32) is_bufpool << 20) & GENMASK(20, 20);
>
> And here.
>
>> +     ring_id_buf |= (1U << 21) & GENMASK(21, 21);
>
> This too.
>
> []
>
>> +static void xgene_enet_rd_mcx_stats(struct xgene_enet_pdata *pdata,
>> +                                 u32 rd_addr, u32 *rd_data)
>> +{
> []
>> +     if (!ret)
>> +             netdev_err(pdata->ndev, "MCX stats read failed, addr: %04x",
>> +                        rd_addr);
>
> Missing newline

I will add newline to the print statements.

>
>> +/* Start Statistics related functions */
>> +static void xgene_gmac_get_rx_stats(struct xgene_enet_pdata *pdata,
>> +                                 struct xgene_enet_rx_stats *rx_stat)
>> +{
>> +     xgene_enet_rd_mcx_stats(pdata, RBYT_ADDR, &rx_stat->rx_byte_count);
>> +     xgene_enet_rd_mcx_stats(pdata, RPKT_ADDR, &rx_stat->rx_packet_count);
>> +     xgene_enet_rd_mcx_stats(pdata, RDRP_ADDR, &rx_stat->rx_drop_pkt_count);
>> +     xgene_enet_rd_mcx_stats(pdata, RFCS_ADDR, &rx_stat->rx_fcs_err_count);
>> +     xgene_enet_rd_mcx_stats(pdata, RFLR_ADDR,
>> +                             &rx_stat->rx_frm_len_err_pkt_count);
>> +     xgene_enet_rd_mcx_stats(pdata, RALN_ADDR,
>> +                             &rx_stat->rx_alignment_err_pkt_count);
>> +     xgene_enet_rd_mcx_stats(pdata, ROVR_ADDR,
>> +                             &rx_stat->rx_oversize_pkt_count);
>> +     xgene_enet_rd_mcx_stats(pdata, RUND_ADDR,
>> +                             &rx_stat->rx_undersize_pkt_count);
>> +
>> +     rx_stat->rx_byte_count &= RX_BYTE_CNTR_MASK;
>> +     rx_stat->rx_packet_count &= RX_PKT_CNTR_MASK;
>> +     rx_stat->rx_drop_pkt_count &= RX_DROPPED_PKT_CNTR_MASK;
>> +     rx_stat->rx_fcs_err_count &= RX_FCS_ERROR_CNTR_MASK;
>> +     rx_stat->rx_frm_len_err_pkt_count &= RX_LEN_ERR_CNTR_MASK;
>> +     rx_stat->rx_alignment_err_pkt_count &= RX_ALIGN_ERR_CNTR_MASK;
>> +     rx_stat->rx_oversize_pkt_count &= RX_OVRSIZE_PKT_CNTR_MASK;
>> +     rx_stat->rx_undersize_pkt_count &= RX_UNDRSIZE_PKT_CNTR_MASK;
>> +}
>> +
>> +static void xgene_gmac_get_tx_stats(struct xgene_enet_pdata *pdata,
>> +                                 struct xgene_enet_tx_stats *tx_stats)
>> +{
>> +     xgene_enet_rd_mcx_stats(pdata, TBYT_ADDR, &tx_stats->tx_byte_count);
>> +     xgene_enet_rd_mcx_stats(pdata, TPKT_ADDR, &tx_stats->tx_pkt_count);
>> +     xgene_enet_rd_mcx_stats(pdata, TDRP_ADDR, &tx_stats->tx_drop_frm_count);
>> +     xgene_enet_rd_mcx_stats(pdata, TFCS_ADDR,
>> +                             &tx_stats->tx_fcs_err_frm_count);
>> +     xgene_enet_rd_mcx_stats(pdata, TUND_ADDR,
>> +                             &tx_stats->tx_undersize_frm_count);
>> +
>> +     tx_stats->tx_byte_count &= TX_BYTE_CNTR_MASK;
>> +     tx_stats->tx_pkt_count &= TX_PKT_CNTR_MASK;
>> +     tx_stats->tx_drop_frm_count &= TX_DROP_FRAME_CNTR_MASK;
>> +     tx_stats->tx_fcs_err_frm_count &= TX_FCS_ERROR_CNTR_MASK;
>> +     tx_stats->tx_undersize_frm_count &= TX_UNDSIZE_FRAME_CNTR_MASK;
>> +}
>
> Pity about the masks
>
>
>> +#define RX_BYTE_CNTR_MASK            0x7fffffff
>> +#define RX_PKT_CNTR_MASK             0x7fffffff
>> +#define RX_FCS_ERROR_CNTR_MASK               0x0000ffff
>> +#define RX_ALIGN_ERR_CNTR_MASK               0x0000ffff
>> +#define RX_LEN_ERR_CNTR_MASK         0x0000ffff
>> +#define RX_UNDRSIZE_PKT_CNTR_MASK    0x0000ffff
>> +#define RX_OVRSIZE_PKT_CNTR_MASK     0x0000ffff
>> +#define RX_DROPPED_PKT_CNTR_MASK     0x0000ffff
>> +#define TX_BYTE_CNTR_MASK            0x7fffffff
>> +#define TX_PKT_CNTR_MASK             0x7fffffff
>> +#define TX_DROP_FRAME_CNTR_MASK              0x0000ffff
>> +#define TX_FCS_ERROR_CNTR_MASK               0x00000fff
>> +#define TX_UNDSIZE_FRAME_CNTR_MASK   0x00000fff
>
> Any of these going to possibly overrun their
> counter size between polls?

No.  These counters are not expected to overrun between polls and I
will remove them.

>
> []
>> +static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
>> +                     struct net_device *ndev, u32 ring_num,
>> +                     enum xgene_enet_ring_cfgsize cfgsize, u32 ring_id)
>> +{
>> +     struct xgene_enet_desc_ring *ring;
>> +     struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>> +     struct device *dev = &pdata->pdev->dev;
>> +     u32 size;
>> +
>> +     ring = devm_kzalloc(dev, sizeof(struct xgene_enet_desc_ring),
>> +                         GFP_KERNEL);
>> +     if (!ring) {
>> +             netdev_err(ndev, "Could not allocate ring\n");
>
> Unnecessary OOM.  alloc errors get a generic OOM and dump_stack()

I will remove the print message.

>
>
>> +static struct net_device_stats *xgene_enet_stats(struct net_device *ndev)
>> +{
>> +     struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>> +     struct net_device_stats *nst = &pdata->nstats;
>> +     struct xgene_enet_detailed_stats detailed_stats;
>> +     struct xgene_enet_rx_stats *rx_stats;
>> +     struct xgene_enet_tx_stats *tx_stats;
>> +     u32 pkt_bytes, crc_bytes = 4;
>> +
>> +     memset(&detailed_stats, 0, sizeof(struct xgene_enet_detailed_stats));
>> +
>> +     rx_stats = &detailed_stats.rx_stats;
>> +     tx_stats = &detailed_stats.tx_stats;
>> +
>> +     local_irq_disable();
>> +     xgene_gmac_get_detailed_stats(pdata, &detailed_stats);
>> +
>> +     pkt_bytes = rx_stats->rx_byte_count;
>> +     pkt_bytes -= rx_stats->rx_packet_count * crc_bytes;
>> +     nst->rx_packets += rx_stats->rx_packet_count;
>> +     nst->rx_bytes += pkt_bytes;
>> +
>> +     pkt_bytes = tx_stats->tx_byte_count;
>> +     pkt_bytes -= tx_stats->tx_pkt_count * crc_bytes;
>> +     nst->tx_packets += tx_stats->tx_pkt_count;
>> +     nst->tx_bytes += pkt_bytes;
>> +
>> +     nst->rx_dropped += rx_stats->rx_drop_pkt_count;
>> +     nst->tx_dropped += tx_stats->tx_drop_frm_count;
>> +
>> +     nst->rx_crc_errors += rx_stats->rx_fcs_err_count;
>> +     nst->rx_length_errors += rx_stats->rx_frm_len_err_pkt_count;
>> +     nst->rx_frame_errors += rx_stats->rx_alignment_err_pkt_count;
>> +     nst->rx_over_errors += rx_stats->rx_oversize_pkt_count;
>> +
>> +     nst->rx_errors += rx_stats->rx_fcs_err_count
>> +         + rx_stats->rx_frm_len_err_pkt_count
>> +         + rx_stats->rx_oversize_pkt_count
>> +         + rx_stats->rx_undersize_pkt_count;
>> +
>> +     nst->tx_errors += tx_stats->tx_fcs_err_frm_count +
>> +         tx_stats->tx_undersize_frm_count;
>> +
>> +     local_irq_enable();
>> +
>> +     return nst;
>> +}
>
>
