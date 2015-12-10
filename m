From: Gilad Avidov <gavidov@codeaurora.org>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Wed, 9 Dec 2015 17:26:45 -0700
Message-ID: <20151209172645.5e6ab040@gavidov-lnx.qualcomm.com>
References: <1449529094-10922-1-git-send-email-gavidov@codeaurora.org>
	<CAOZdJXXQKMrOJpm3XJmX5ZULEoOZqS12u5FWKdcxfUm+LnGbww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, sdharia@codeaurora.org,
	linux-arm-msm@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	vikrams@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <CAOZdJXXQKMrOJpm3XJmX5ZULEoOZqS12u5FWKdcxfUm+LnGbww@mail.gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you Timur for the good review.

On Wed, 9 Dec 2015 14:09:27 -0600
Timur Tabi <timur@codeaurora.org> wrote:

> So first of all, thanks for posting this.  I know it's missing a bunch
> of stuff that's necessary for Qualcomm's Server chip, but it's a
> start.
> 
> Unfortunately, 6,000 lines is a lot to review at once.  Any chance you
> can break up the next version into smaller patches?

Agree its a lot to review, however:
1) This driver is the what left after I removed all unnecessary
features, thus it is already minimal.
I have removed features such as support for: server, ACPI, ethtool,
ptp/1588, etc.
2) This size seems comparable to first patches of existing Ethernet
drivers.

> 
> On Mon, Dec 7, 2015 at 4:58 PM, Gilad Avidov <gavidov@codeaurora.org>
> wrote:
> 
> > +               qcom,emac-gpio-mdc = <&msmgpio 123 0>;
> > +               qcom,emac-gpio-mdio = <&msmgpio 124 0>;
> 
> Is there any chance you can remove all references to "MSM" throughout
> the entire driver, since the EMAC exists on non-MSM parts?

msm appears only in this DT binding example. None in the code.
I will look into removing this instance too.

> 
> > +               qcom,emac-tstamp-en;
> > +               qcom,emac-ptp-frac-ns-adj = <125000000 1>;
> > +               phy-addr = <0>;
> > +       };
> > diff --git a/drivers/net/ethernet/qualcomm/Kconfig
> > b/drivers/net/ethernet/qualcomm/Kconfig index a76e380..ae9442d
> > 100644 --- a/drivers/net/ethernet/qualcomm/Kconfig
> > +++ b/drivers/net/ethernet/qualcomm/Kconfig
> > @@ -24,4 +24,11 @@ config QCA7000
> >           To compile this driver as a module, choose M here. The
> > module will be called qcaspi.
> >
> > +config QCOM_EMAC
> > +       tristate "MSM EMAC Gigabit Ethernet support"
> > +       default n
> 
> "default n" is redundant
> 
> > +       select CRC32
> > +       ---help---
> > +         This driver supports the Qualcomm EMAC Gigabit Ethernet
> > controller.
> 
> I think should be longer, perhaps by adding some more info about the
> controller itself?

ok.

> 
> > +
> >  endif # NET_VENDOR_QUALCOMM
> > diff --git a/drivers/net/ethernet/qualcomm/Makefile
> > b/drivers/net/ethernet/qualcomm/Makefile index 9da2d75..b14686e
> > 100644 --- a/drivers/net/ethernet/qualcomm/Makefile
> > +++ b/drivers/net/ethernet/qualcomm/Makefile
> > @@ -4,3 +4,5 @@
> >
> >  obj-$(CONFIG_QCA7000) += qcaspi.o
> >  qcaspi-objs := qca_spi.o qca_framing.o qca_7k.o qca_debug.o
> > +
> > +obj-$(CONFIG_QCOM_EMAC) += emac/
> > \ No newline at end of file
> 
> Please fix

ok.

> 
> > +/* RSS */
> > +static void emac_mac_rss_config(struct emac_adapter *adpt)
> > +{
> > +       int key_len_by_u32 = sizeof(adpt->rss_key) / sizeof(u32);
> > +       int idt_len_by_u32 = sizeof(adpt->rss_idt) / sizeof(u32);
> 
> Can you use ARRAY_SIZE here?

Agree.

> 
> > +       u32 rxq0;
> > +       int i;
> > +
> > +       /* Fill out hash function keys */
> > +       for (i = 0; i < key_len_by_u32; i++) {
> > +               u32 key, idx_base;
> > +
> > +               idx_base = (key_len_by_u32 - i) * 4;
> > +               key = ((adpt->rss_key[idx_base - 1])       |
> > +                      (adpt->rss_key[idx_base - 2] << 8)  |
> > +                      (adpt->rss_key[idx_base - 3] << 16) |
> > +                      (adpt->rss_key[idx_base - 4] << 24));
> > +               writel_relaxed(key, adpt->base + EMAC_RSS_KEY(i,
> > u32));
> > +       }
> > +
> > +       /* Fill out redirection table */
> > +       for (i = 0; i < idt_len_by_u32; i++)
> > +               writel_relaxed(adpt->rss_idt[i],
> > +                              adpt->base + EMAC_RSS_TBL(i, u32));
> > +
> > +       writel_relaxed(adpt->rss_base_cpu, adpt->base +
> > EMAC_BASE_CPU_NUMBER); +
> > +       rxq0 = readl_relaxed(adpt->base + EMAC_RXQ_CTRL_0);
> > +       if (adpt->rss_hstype & EMAC_RSS_HSTYP_IPV4_EN)
> > +               rxq0 |= RXQ0_RSS_HSTYP_IPV4_EN;
> > +       else
> > +               rxq0 &= ~RXQ0_RSS_HSTYP_IPV4_EN;
> > +
> > +       if (adpt->rss_hstype & EMAC_RSS_HSTYP_TCP4_EN)
> > +               rxq0 |= RXQ0_RSS_HSTYP_IPV4_TCP_EN;
> > +       else
> > +               rxq0 &= ~RXQ0_RSS_HSTYP_IPV4_TCP_EN;
> > +
> > +       if (adpt->rss_hstype & EMAC_RSS_HSTYP_IPV6_EN)
> > +               rxq0 |= RXQ0_RSS_HSTYP_IPV6_EN;
> > +       else
> > +               rxq0 &= ~RXQ0_RSS_HSTYP_IPV6_EN;
> > +
> > +       if (adpt->rss_hstype & EMAC_RSS_HSTYP_TCP6_EN)
> > +               rxq0 |= RXQ0_RSS_HSTYP_IPV6_TCP_EN;
> > +       else
> > +               rxq0 &= ~RXQ0_RSS_HSTYP_IPV6_TCP_EN;
> > +
> > +       rxq0 |= ((adpt->rss_idt_size << IDT_TABLE_SIZE_SHFT) &
> > +               IDT_TABLE_SIZE_BMSK);
> > +       rxq0 |= RSS_HASH_EN;
> > +
> > +       wmb(); /* ensure all parameters are written before enabling
> > RSS */ +
> > +       writel_relaxed(rxq0, adpt->base + EMAC_RXQ_CTRL_0);
> 
> Why not just use writel(), which already includes a wmb()
> 

ok.

> > +/* Power Management */
> > +void emac_mac_pm(struct emac_adapter *adpt, u32 speed, bool
> > wol_en, bool rx_en) +{
> > +       u32 dma_mas, mac;
> > +
> > +       dma_mas = readl_relaxed(adpt->base + EMAC_DMA_MAS_CTRL);
> > +       dma_mas &= ~LPW_CLK_SEL;
> > +       dma_mas |= LPW_STATE;
> > +
> > +       mac = readl_relaxed(adpt->base + EMAC_MAC_CTRL);
> > +       mac &= ~(FULLD | RXEN | TXEN);
> > +       mac = (mac & ~SPEED_BMSK) |
> > +         (((u32)emac_mac_speed_10_100 << SPEED_SHFT) & SPEED_BMSK);
> > +
> > +       if (wol_en) {
> > +               if (rx_en)
> > +                       mac |= (RXEN | BROAD_EN);
> 
> You don't need the parentheses.

ok.

> 
> > +/* Config descriptor rings */
> > +static void emac_mac_dma_rings_config(struct emac_adapter *adpt)
> > +{
> > +       if (adpt->timestamp_en)
> > +               emac_reg_update32(adpt->csr +
> > EMAC_EMAC_WRAPPER_CSR1,
> > +                                 0, ENABLE_RRD_TIMESTAMP);
> > +
> > +       /* TPD */
> 
> What does TPD stand for?

TPD: Transmit Packet Descriptor ring.
See definition of TPD, RFD and RRD at the top of emac-mac.h

> 
> > +       writel_relaxed(EMAC_DMA_ADDR_HI(adpt->tx_q[0].tpd.p_addr),
> > +                      adpt->base + EMAC_DESC_CTRL_1);
> > +       switch (adpt->tx_q_cnt) {
> > +       case 4:
> > +
> > writel_relaxed(EMAC_DMA_ADDR_LO(adpt->tx_q[3].tpd.p_addr),
> > +                              adpt->base +
> > EMAC_H3TPD_BASE_ADDR_LO);
> > +               /* fall through */
> > +       case 3:
> > +
> > writel_relaxed(EMAC_DMA_ADDR_LO(adpt->tx_q[2].tpd.p_addr),
> > +                              adpt->base +
> > EMAC_H2TPD_BASE_ADDR_LO);
> > +               /* fall through */
> > +       case 2:
> > +
> > writel_relaxed(EMAC_DMA_ADDR_LO(adpt->tx_q[1].tpd.p_addr),
> > +                              adpt->base +
> > EMAC_H1TPD_BASE_ADDR_LO);
> > +               /* fall through */
> > +       case 1:
> > +
> > writel_relaxed(EMAC_DMA_ADDR_LO(adpt->tx_q[0].tpd.p_addr),
> > +                              adpt->base + EMAC_DESC_CTRL_8);
> > +               break;
> > +       default:
> > +               netdev_err(adpt->netdev,
> > +                          "error: invalid number of TX queues
> > (%d)\n",
> > +                          adpt->tx_q_cnt);
> > +               return;
> > +       }
> 
> This is not time-critical code.  Why not just create a for-loop?
> 

the offsets are all different:
EMAC_H3TPD_BASE_ADDR_LO, EMAC_H2TPD_BASE_ADDR_LO,
EMAC_H1TPD_BASE_ADDR_LO, EMAC_DESC_CTRL_8

of course I can put the offset in an array, but I am not sure that it
will look better.

> > +/* Config transmit parameters */
> > +static void emac_mac_tx_config(struct emac_adapter *adpt)
> > +{
> > +       u16 tx_offload_thresh = EMAC_MAX_TX_OFFLOAD_THRESH;
> > +       u32 val;
> > +
> > +       writel_relaxed((tx_offload_thresh >> 3) &
> 
> Why is tx_offload_thresh a u16 if you're going to use writel anyway?
> Make it a u32.

agree.

> 
> > +void emac_mac_reset(struct emac_adapter *adpt)
> > +{
> > +       writel_relaxed(0, adpt->base + EMAC_INT_MASK);
> > +       writel_relaxed(DIS_INT, adpt->base + EMAC_INT_STATUS);
> > +
> > +       emac_mac_stop(adpt);
> > +
> > +       emac_reg_update32(adpt->base + EMAC_DMA_MAS_CTRL, 0,
> > SOFT_RST);
> > +       wmb(); /* ensure mac is fully reset */
> > +       usleep_range(100, 150);
> 
> Please add a comment explaiing why this delay is necessary.

ok.

> 
> > +void emac_mac_stop(struct emac_adapter *adpt)
> > +{
> > +       emac_reg_update32(adpt->base + EMAC_RXQ_CTRL_0, RXQ_EN, 0);
> > +       emac_reg_update32(adpt->base + EMAC_TXQ_CTRL_0, TXQ_EN, 0);
> > +       emac_reg_update32(adpt->base + EMAC_MAC_CTRL, (TXEN |
> > RXEN), 0);
> > +       wmb(); /* ensure mac is stopped before we proceed */
> > +       usleep_range(1000, 1050);
> 
> Same here.

ok.

> 
> > +/* set MAC address */
> > +void emac_mac_addr_clear(struct emac_adapter *adpt, u8 *addr)
> > +{
> > +       u32 sta;
> > +
> > +       /* for example: 00-A0-C6-11-22-33
> > +        * 0<-->C6112233, 1<-->00A0.
> > +        */
> 
> /*
>  * Multi-line comments
>  * look like this.
>  */
> 
> > +/* Free all descriptors of given transmit queue */
> > +static void emac_tx_q_descs_free(struct emac_adapter *adpt,
> > +                                struct emac_tx_queue *tx_q)
> > +{
> > +       unsigned long size;
> > +       u32 i;
> 
> Since 'i' is used as an index, it should be an unsized integer.  And
> 'size' should be a 'size_t'

ok.

> 
> > +static void emac_tx_q_descs_free_all(struct emac_adapter *adpt)
> > +{
> > +       u8 i;
> 
> 'int'.  Personally, I'd prefer "unsigned int", but 'int' is what you
> use elsewhere.
> 

Ill go with unsigned int.

> > +/* Free all descriptors of given receive queue */
> > +static void emac_rx_q_free_descs(struct emac_adapter *adpt,
> > +                                struct emac_rx_queue *rx_q)
> > +{
> > +       struct device *dev = adpt->netdev->dev.parent;
> > +       unsigned long size;
> > +       u32 i;
> 
> size_t size;
> int i;

will do.

> 
> > +/* Allocate TX descriptor ring for the given transmit queue */
> > +static int emac_tx_q_desc_alloc(struct emac_adapter *adpt,
> > +                               struct emac_tx_queue *tx_q)
> > +{
> > +       struct emac_ring_header *ring_header = &adpt->ring_header;
> > +       unsigned long size;
> 
> size_t

ok.

> 
> > +
> > +       size = sizeof(struct emac_buffer) * tx_q->tpd.count;
> > +       tx_q->tpd.tpbuff = kzalloc(size, GFP_KERNEL);
> > +       if (!tx_q->tpd.tpbuff)
> > +               return -ENOMEM;
> > +
> > +       tx_q->tpd.size = tx_q->tpd.count * (adpt->tpd_size * 4);
> > +       tx_q->tpd.p_addr = ring_header->p_addr + ring_header->used;
> > +       tx_q->tpd.v_addr = ring_header->v_addr + ring_header->used;
> > +       ring_header->used += ALIGN(tx_q->tpd.size, 8);
> > +       tx_q->tpd.produce_idx = 0;
> > +       tx_q->tpd.consume_idx = 0;
> > +       return 0;
> 
> blank line above "return".

ok.

> 
> > +}
> > +
> > +static int emac_tx_q_desc_alloc_all(struct emac_adapter *adpt)
> > +{
> > +       int retval = 0;
> > +       u8 i;
> 
> int i;

ok.

> 
> > +static void emac_rx_q_free_bufs_all(struct emac_adapter *adpt)
> > +{
> > +       u8 i;
> 
> int i;

ok.

> 
> > +/* Allocate RX descriptor rings for the given receive queue */
> > +static int emac_rx_descs_alloc(struct emac_adapter *adpt,
> > +                              struct emac_rx_queue *rx_q)
> > +{
> > +       struct emac_ring_header *ring_header = &adpt->ring_header;
> > +       unsigned long size;
> 
> size_t

ok.

> 
> > +static int emac_rx_descs_allocs_all(struct emac_adapter *adpt)
> > +{
> > +       int retval = 0;
> > +       u8 i;
> 
> int i;

ok.

> 
> > +
> > +       for (i = 0; i < adpt->rx_q_cnt; i++) {
> > +               retval = emac_rx_descs_alloc(adpt, &adpt->rx_q[i]);
> > +               if (retval)
> > +                       break;
> > +       }
> > +
> > +       if (retval) {
> > +               netdev_err(adpt->netdev, "error: Rx Queue %u alloc
> > failed\n",
> 
> %d

ok.

> 
> > +/* Produce new receive free descriptor */
> > +static bool emac_mac_rx_rfd_create(struct emac_adapter *adpt,
> > +                                  struct emac_rx_queue *rx_q,
> > +                                  union emac_rfd *rfd)
> > +{
> > +       u32 *hw_rfd = EMAC_RFD(rx_q, adpt->rfd_size,
> > +                              rx_q->rfd.produce_idx);
> > +
> > +       *(hw_rfd++) = rfd->word[0];
> > +       *hw_rfd = rfd->word[1];
> > +
> > +       if (++rx_q->rfd.produce_idx == rx_q->rfd.count)
> > +               rx_q->rfd.produce_idx = 0;
> > +
> > +       return true;
> 
> You never check the return value, so just make this a void function.
> 

Agree.

> > +}
> > +
> > +/* Fill up receive queue's RFD with preallocated receive buffers */
> > +static int emac_mac_rx_descs_refill(struct emac_adapter *adpt,
> > +                                   struct emac_rx_queue *rx_q)
> > +{
> > +       struct emac_buffer *curr_rxbuf;
> > +       struct emac_buffer *next_rxbuf;
> > +       union emac_rfd rfd;
> > +       struct sk_buff *skb;
> > +       void *skb_data = NULL;
> > +       u32 count = 0;
> 
> int count = 0;
> 
> The type should match the return value of the function.

Agree.

> 
> > +       u32 next_produce_idx;
> > +
> > +       next_produce_idx = rx_q->rfd.produce_idx;
> > +       if (++next_produce_idx == rx_q->rfd.count)
> > +               next_produce_idx = 0;
> > +       curr_rxbuf = GET_RFD_BUFFER(rx_q, rx_q->rfd.produce_idx);
> > +       next_rxbuf = GET_RFD_BUFFER(rx_q, next_produce_idx);
> > +
> > +       /* this always has a blank rx_buffer*/
> > +       while (!next_rxbuf->dma) {
> > +               skb = dev_alloc_skb(adpt->rxbuf_size +
> > NET_IP_ALIGN);
> > +               if (unlikely(!skb))
> > +                       break;
> 
> I don't think this is time-critical code, so don't use unlikely().

ok.

> 
> > +/* Consume next received packet descriptor */
> > +static bool emac_rx_process_rrd(struct emac_adapter *adpt,
> > +                               struct emac_rx_queue *rx_q,
> > +                               union emac_rrd *rrd)
> > +{
> > +       u32 *hw_rrd = EMAC_RRD(rx_q, adpt->rrd_size,
> > +                              rx_q->rrd.consume_idx);
> > +
> > +       /* If time stamping is enabled, it will be added in the
> > beginning of
> > +        * the hw rrd (hw_rrd). In sw rrd (rrd), 32bit words 4 & 5
> > are reserved
> > +        * for the time stamp; hence the conversion.
> > +        * Also, read the rrd word with update flag first; read
> > rest of rrd
> > +        * only if update flag is set.
> > +        */
> > +       if (adpt->timestamp_en)
> > +               rrd->word[3] = *(hw_rrd + 5);
> > +       else
> > +               rrd->word[3] = *(hw_rrd + 3);
> > +       rmb(); /* ensure hw receive returned descriptor timestamp
> > is read */ +
> > +       if (!rrd->genr.update)
> > +               return false;
> > +
> > +       if (adpt->timestamp_en) {
> > +               rrd->word[4] = *(hw_rrd++);
> > +               rrd->word[5] = *(hw_rrd++);
> > +       } else {
> > +               rrd->word[4] = 0;
> > +               rrd->word[5] = 0;
> > +       }
> > +
> > +       rrd->word[0] = *(hw_rrd++);
> > +       rrd->word[1] = *(hw_rrd++);
> > +       rrd->word[2] = *(hw_rrd++);
> > +       mb(); /* ensure descriptor is read */
> 
> Why do you use mb() here, but rmb() above?  The comment is the same.

I will change both to rmb()

> 
> > +static void emac_rx_rfd_clean(struct emac_rx_queue *rx_q,
> > +                             union emac_rrd *rrd)
> > +{
> > +       struct emac_buffer *rfbuf = rx_q->rfd.rfbuff;
> > +       u32 consume_idx = rrd->genr.si;
> > +       u16 i;
> 
> int i;

ok.

> 
> > +static inline bool emac_skb_cb_expired(struct sk_buff *skb)
> > +{
> > +       if (time_is_after_jiffies(EMAC_SKB_CB(skb)->jiffies +
> > +                                 msecs_to_jiffies(100)))
> > +               return false;
> > +       return true;
> 
> return time_is_before_jiffies(EMAC_SKB_CB(skb)->jiffies +
> msecs_to_jiffies(100));

Agree.

> 
> > +/* Process receive event */
> > +void emac_mac_rx_process(struct emac_adapter *adpt, struct
> > emac_rx_queue *rx_q,
> > +                        int *num_pkts, int max_pkts)
> > +{
> > +       struct net_device *netdev  = adpt->netdev;
> > +
> > +       union emac_rrd rrd;
> > +       struct emac_buffer *rfbuf;
> > +       struct sk_buff *skb;
> > +
> > +       u32 hw_consume_idx, num_consume_pkts;
> > +       u32 count = 0;
> 
> unsigned int count;

ok.

> 
> > +       u32 proc_idx;
> > +       u32 reg = readl_relaxed(adpt->base + rx_q->consume_reg);
> > +
> > +       hw_consume_idx = (reg & rx_q->consume_mask) >>
> > rx_q->consume_shft;
> > +       num_consume_pkts = (hw_consume_idx >=
> > rx_q->rrd.consume_idx) ?
> > +               (hw_consume_idx -  rx_q->rrd.consume_idx) :
> > +               (hw_consume_idx + rx_q->rrd.count -
> > rx_q->rrd.consume_idx); +
> > +       while (1) {
> > +               if (!num_consume_pkts)
> > +                       break;
> > +
> > +               if (!emac_rx_process_rrd(adpt, rx_q, &rrd))
> > +                       break;
> > +
> > +               if (likely(rrd.genr.nor == 1)) {
> > +                       /* good receive */
> > +                       rfbuf = GET_RFD_BUFFER(rx_q, rrd.genr.si);
> > +                       dma_unmap_single(adpt->netdev->dev.parent,
> > rfbuf->dma,
> > +                                        rfbuf->length,
> > DMA_FROM_DEVICE);
> > +                       rfbuf->dma = 0;
> > +                       skb = rfbuf->skb;
> > +               } else {
> > +                       netdev_err(adpt->netdev,
> > +                                  "error: multi-RFD not support
> > yet!\n");
> > +                       break;
> > +               }
> > +               emac_rx_rfd_clean(rx_q, &rrd);
> > +               num_consume_pkts--;
> > +               count++;
> > +
> > +               /* Due to a HW issue in L4 check sum detection
> > (UDP/TCP frags
> > +                * with DF set are marked as error), drop packets
> > based on the
> > +                * error mask rather than the summary bit (ignoring
> > L4F errors)
> > +                */
> > +               if (rrd.word[EMAC_RRD_STATS_DW_IDX] &
> > EMAC_RRD_ERROR) {
> > +                       netif_dbg(adpt, rx_status, adpt->netdev,
> > +                                 "Drop error packet[RRD:
> > 0x%x:0x%x:0x%x:0x%x]\n",
> > +                                 rrd.word[0], rrd.word[1],
> > +                                 rrd.word[2], rrd.word[3]);
> > +
> > +                       dev_kfree_skb(skb);
> > +                       continue;
> > +               }
> > +
> > +               skb_put(skb, rrd.genr.pkt_len - ETH_FCS_LEN);
> > +               skb->dev = netdev;
> > +               skb->protocol = eth_type_trans(skb, skb->dev);
> > +               if (netdev->features & NETIF_F_RXCSUM)
> > +                       skb->ip_summed = ((rrd.genr.l4f) ?
> > +                                         CHECKSUM_NONE :
> > CHECKSUM_UNNECESSARY);
> > +               else
> > +                       skb_checksum_none_assert(skb);
> > +
> > +               if (test_bit(EMAC_STATUS_TS_RX_EN, &adpt->status)) {
> > +                       struct skb_shared_hwtstamps *hwts =
> > skb_hwtstamps(skb); +
> > +                       hwts->hwtstamp = ktime_set(rrd.genr.ts_high,
> > +                                                  rrd.genr.ts_low);
> > +               }
> > +
> > +               emac_receive_skb(rx_q, skb, (u16)rrd.genr.cvlan_tag,
> > +                                (bool)rrd.genr.cvlan_flag);
> > +
> > +               netdev->last_rx = jiffies;
> > +               (*num_pkts)++;
> > +               if (*num_pkts >= max_pkts)
> > +                       break;
> > +       }
> 
> How about
> 
> do {
> ...
> } while (*num_pkts < max_pkts);

Agree.

> 
> > +/* Check if enough transmit descriptors are available */
> > +static bool emac_tx_has_enough_descs(struct emac_tx_queue *tx_q,
> > +                                    const struct sk_buff *skb)
> > +{
> > +       u32 num_required = 1;
> > +       u16 i;
> 
> int i;
> 
> Anyway, you got the idea.  I think sized integers should be used
> sparingly, and general counting and index variable should be unsized
> integers, preferably also unsigned.
> 

ok. I will change it throughout the driver.

> > +/* Fill up transmit descriptors with TSO and Checksum offload
> > information */ +static int emac_tso_csum(struct emac_adapter *adpt,
> > +                        struct emac_tx_queue *tx_q,
> > +                        struct sk_buff *skb,
> > +                        union emac_tpd *tpd)
> > +{
> > +       u8  hdr_len;
> > +       int retval;
> > +
> > +       if (skb_is_gso(skb)) {
> > +               if (skb_header_cloned(skb)) {
> > +                       retval = pskb_expand_head(skb, 0, 0,
> > GFP_ATOMIC);
> > +                       if (unlikely(retval))
> > +                               return retval;
> > +               }
> > +
> > +               if (skb->protocol == htons(ETH_P_IP)) {
> > +                       u32 pkt_len =
> > +                               ((unsigned char *)ip_hdr(skb) -
> > skb->data) +
> 
> Use void* for pointer math, instead of "unsigned char *".

pointer math on void* ?
what is the size of void ?

> 
> > +/* Transmit the packet using specified transmit queue */
> > +int emac_mac_tx_buf_send(struct emac_adapter *adpt, struct
> > emac_tx_queue *tx_q,
> > +                        struct sk_buff *skb)
> > +{
> > +       union emac_tpd tpd;
> > +       u32 prod_idx;
> > +
> > +       if (test_bit(EMAC_STATUS_DOWN, &adpt->status)) {
> > +               dev_kfree_skb_any(skb);
> > +               return NETDEV_TX_OK;
> > +       }
> > +
> > +       if (!emac_tx_has_enough_descs(tx_q, skb)) {
> > +               /* not enough descriptors, just stop queue */
> > +               netif_stop_queue(adpt->netdev);
> > +               return NETDEV_TX_BUSY;
> > +       }
> > +
> > +       memset(&tpd, 0, sizeof(tpd));
> > +
> > +       if (emac_tso_csum(adpt, tx_q, skb, &tpd) != 0) {
> > +               dev_kfree_skb_any(skb);
> > +               return NETDEV_TX_OK;
> > +       }
> > +
> > +       if (skb_vlan_tag_present(skb)) {
> > +               u16 vlan = skb_vlan_tag_get(skb);
> > +               u16 tag;
> > +
> > +               EMAC_VLAN_TO_TAG(vlan, tag);
> > +               tpd.genr.cvlan_tag = tag;
> 
> Can't you just do EMAC_VLAN_TO_TAG(vlan, tpd.genr.cvlan_tag);
> 
> 

Should have been the way you suggested.
However, per Felix's comment I will change the bit fields to bitwise
macros. This will force code slow similar to the original.

> 
> 
> 
> > diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.h
> > b/drivers/net/ethernet/qualcomm/emac/emac-mac.h new file mode 100644
> > index 0000000..a6761af
> > --- /dev/null
> > +++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.h
> > @@ -0,0 +1,341 @@
> > +/* Copyright (c) 2013-2015, The Linux Foundation. All rights
> > reserved.
> > + *
> > + * This program is free software; you can redistribute it and/or
> > modify
> > + * it under the terms of the GNU General Public License version 2
> > and
> > + * only version 2 as published by the Free Software Foundation.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + */
> > +
> > +/* EMAC DMA HW engine uses three rings:
> > + * Tx:
> > + *   TPD: Transmit Packet Descriptor ring.
> > + * Rx:
> > + *   RFD: Receive Free Descriptor ring.
> > + *     Ring of descriptors with empty buffers to be filled by Rx
> > HW.
> > + *   RRD: Receive Return Descriptor ring.
> > + *     Ring of descriptors with buffers filled with received data.
> > + */
> > +
> > +#ifndef _EMAC_HW_H_
> > +#define _EMAC_HW_H_
> > +
> > +/* EMAC_CSR register offsets */
> > +#define EMAC_EMAC_WRAPPER_CSR1
> > 0x000000 +#define
> > EMAC_EMAC_WRAPPER_CSR2                                0x000004
> > +#define EMAC_EMAC_WRAPPER_CSR3
> > 0x000008 +#define
> > EMAC_EMAC_WRAPPER_CSR5                                0x000010
> > +#define EMAC_EMAC_WRAPPER_TX_TS_LO
> > 0x000104 +#define
> > EMAC_EMAC_WRAPPER_TX_TS_HI                            0x000108
> > +#define EMAC_EMAC_WRAPPER_TX_TS_INX
> > 0x00010c
> 
> Can you move some of the macros into the .c files?  For example, I'm
> pretty sure that the EMAC_EMAC_WRAPPER_CSRx macros are used only in
> emac-sgmii.c.

I have moved all that made sense to .c files already. If I find
anything else that can be moved I will move it too.

For the case of EMAC_EMAC_WRAPPER_CSRx:
EMAC_EMAC_WRAPPER_CSR1 used in emac-mac.c
EMAC_EMAC_WRAPPER_CSR1 used in emac-mac.c and emac-sgmii.c
and
EMAC_EMAC_WRAPPER_TX_xxx used in emac-mac.c

Since they are all part of EMAC_CSR register space I think that it is
better to keep them togther.

> 
> Anyway, I'm stopping for now.  I'll post more later.

Thank you again. Looking forward for the rest of it.
Gilad

> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-arm-msm" in the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
