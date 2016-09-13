From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v3 2/3] e1000: add initial XDP
 support
Date: Tue, 13 Sep 2016 09:56:35 -0700
Message-ID: <20160913165343.GB36394@ast-mbp.thefacebook.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
 <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
 <CAKgT0UfzRehm_YNi2k5uyvdW_52mPSO3cEGfr6EtA+5ONM+cLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        u9012063@gmail.com, Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36616 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755062AbcIMQ4k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 12:56:40 -0400
Received: by mail-pf0-f196.google.com with SMTP id n24so37909pfb.3
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 09:56:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAKgT0UfzRehm_YNi2k5uyvdW_52mPSO3cEGfr6EtA+5ONM+cLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 08:42:41PM -0700, Alexander Duyck wrote:
> On Mon, Sep 12, 2016 at 3:13 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
> > From: Alexei Starovoitov <ast@fb.com>
> >
> > This patch adds initial support for XDP on e1000 driver. Note e1000
> > driver does not support page recycling in general which could be
> > added as a further improvement. However XDP_DROP case will recycle.
> > XDP_TX and XDP_PASS do not support recycling.
> >
> > e1000 only supports a single tx queue at this time so the queue
> > is shared between xdp program and Linux stack. It is possible for
> > an XDP program to starve the stack in this model.
> >
> > The XDP program will drop packets on XDP_TX errors. This can occur
> > when the tx descriptors are exhausted. This behavior is the same
> > for both shared queue models like e1000 and dedicated tx queue
> > models used in multiqueue devices. However if both the stack and
> > XDP are transmitting packets it is perhaps more likely to occur in
> > the shared queue model. Further refinement to the XDP model may be
> > possible in the future.
> >
> > I tested this patch running e1000 in a VM using KVM over a tap
> > device.
> >
> > CC: William Tu <u9012063@gmail.com>
> > Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > ---
> >  drivers/net/ethernet/intel/e1000/e1000.h      |    2
> >  drivers/net/ethernet/intel/e1000/e1000_main.c |  176 +++++++++++++++++++++++++
> >  2 files changed, 175 insertions(+), 3 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
> > index d7bdea7..5cf8a0a 100644
> > --- a/drivers/net/ethernet/intel/e1000/e1000.h
> > +++ b/drivers/net/ethernet/intel/e1000/e1000.h
> > @@ -150,6 +150,7 @@ struct e1000_adapter;
> >   */
> >  struct e1000_tx_buffer {
> >         struct sk_buff *skb;
> > +       struct page *page;
> >         dma_addr_t dma;
> >         unsigned long time_stamp;
> >         u16 length;
> 
> I'm not really a huge fan of adding yet another member to this
> structure.  Each e1000_tx_buffer is already pretty big at 40 bytes,
> pushing it to 48 just means we lose that much more memory.  If nothing
> else we may wan to look at doing something like creating a union
> between the skb, page, and an unsigned long.  Then you could use the
> lowest bit of the address as a flag indicating if this is a skb or a
> page.

that exactly what we did for mlx4_en_tx_info, since it's a real nic
where performance matters. For e1k I didn't want to complicate
the logic for no reason, since I don't see how 8 extra bytes matter here.
we will take a look if union is easy to do though.

> > @@ -279,6 +280,7 @@ struct e1000_adapter {
> >                              struct e1000_rx_ring *rx_ring,
> >                              int cleaned_count);
> >         struct e1000_rx_ring *rx_ring;      /* One per active queue */
> > +       struct bpf_prog *prog;
> >         struct napi_struct napi;
> >
> >         int num_tx_queues;
> > diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > index 62a7f8d..232b927 100644
> > --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> > +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > @@ -32,6 +32,7 @@
> >  #include <linux/prefetch.h>
> >  #include <linux/bitops.h>
> >  #include <linux/if_vlan.h>
> > +#include <linux/bpf.h>
> >
> >  char e1000_driver_name[] = "e1000";
> >  static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
> > @@ -842,6 +843,44 @@ static int e1000_set_features(struct net_device *netdev,
> >         return 0;
> >  }
> >
> > +static int e1000_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
> > +{
> > +       struct e1000_adapter *adapter = netdev_priv(netdev);
> > +       struct bpf_prog *old_prog;
> > +
> > +       old_prog = xchg(&adapter->prog, prog);
> > +       if (old_prog) {
> > +               synchronize_net();
> > +               bpf_prog_put(old_prog);
> > +       }
> > +
> > +       if (netif_running(netdev))
> > +               e1000_reinit_locked(adapter);
> > +       else
> > +               e1000_reset(adapter);
> 
> What is the point of the reset?  If the interface isn't running is
> there anything in the hardware you actually need to cleanup?

The above is inspired by e1000_set_features().
I'm assuming it was done there for a reason and same applies here.

> > +       return 0;
> > +}
> > +
> > +static bool e1000_xdp_attached(struct net_device *dev)
> > +{
> > +       struct e1000_adapter *priv = netdev_priv(dev);
> > +
> > +       return !!priv->prog;
> > +}
> > +
> > +static int e1000_xdp(struct net_device *dev, struct netdev_xdp *xdp)
> > +{
> > +       switch (xdp->command) {
> > +       case XDP_SETUP_PROG:
> > +               return e1000_xdp_set(dev, xdp->prog);
> > +       case XDP_QUERY_PROG:
> > +               xdp->prog_attached = e1000_xdp_attached(dev);
> > +               return 0;
> > +       default:
> > +               return -EINVAL;
> > +       }
> > +}
> > +
> >  static const struct net_device_ops e1000_netdev_ops = {
> >         .ndo_open               = e1000_open,
> >         .ndo_stop               = e1000_close,
> > @@ -860,6 +899,7 @@ static const struct net_device_ops e1000_netdev_ops = {
> >  #endif
> >         .ndo_fix_features       = e1000_fix_features,
> >         .ndo_set_features       = e1000_set_features,
> > +       .ndo_xdp                = e1000_xdp,
> >  };
> >
> >  /**
> > @@ -1276,6 +1316,9 @@ static void e1000_remove(struct pci_dev *pdev)
> >         e1000_down_and_stop(adapter);
> >         e1000_release_manageability(adapter);
> >
> > +       if (adapter->prog)
> > +               bpf_prog_put(adapter->prog);
> > +
> >         unregister_netdev(netdev);
> >
> >         e1000_phy_hw_reset(hw);
> > @@ -1859,7 +1902,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
> >         struct e1000_hw *hw = &adapter->hw;
> >         u32 rdlen, rctl, rxcsum;
> >
> > -       if (adapter->netdev->mtu > ETH_DATA_LEN) {
> > +       if (adapter->netdev->mtu > ETH_DATA_LEN || adapter->prog) {
> >                 rdlen = adapter->rx_ring[0].count *
> >                         sizeof(struct e1000_rx_desc);
> >                 adapter->clean_rx = e1000_clean_jumbo_rx_irq;
> 
> If you are really serious about using the page based Rx path we should
> probably fix the fact that you take a pretty significant hit on
> performance penalty for turning this mode on.

Not sure I follow. KVM tests show that xdp_drop/tx is faster even with
full page alloc and no page recycling.
xdp is only operational in page-per-packet mode which dictates the above approach.

> > @@ -1973,6 +2016,11 @@ e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
> >                 dev_kfree_skb_any(buffer_info->skb);
> >                 buffer_info->skb = NULL;
> >         }
> > +       if (buffer_info->page) {
> > +               put_page(buffer_info->page);
> > +               buffer_info->page = NULL;
> > +       }
> > +
> >         buffer_info->time_stamp = 0;
> >         /* buffer_info must be completely set up in the transmit path */
> >  }
> > @@ -3298,6 +3346,69 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
> >         return NETDEV_TX_OK;
> >  }
> >
> > +static void e1000_tx_map_rxpage(struct e1000_tx_ring *tx_ring,
> > +                               struct e1000_rx_buffer *rx_buffer_info,
> > +                               unsigned int len)
> > +{
> > +       struct e1000_tx_buffer *buffer_info;
> > +       unsigned int i = tx_ring->next_to_use;
> > +
> > +       buffer_info = &tx_ring->buffer_info[i];
> > +
> > +       buffer_info->length = len;
> > +       buffer_info->time_stamp = jiffies;
> > +       buffer_info->mapped_as_page = false;
> > +       buffer_info->dma = rx_buffer_info->dma;
> > +       buffer_info->next_to_watch = i;
> > +       buffer_info->page = rx_buffer_info->rxbuf.page;
> > +
> > +       tx_ring->buffer_info[i].skb = NULL;
> > +       tx_ring->buffer_info[i].segs = 1;
> > +       tx_ring->buffer_info[i].bytecount = len;
> > +       tx_ring->buffer_info[i].next_to_watch = i;
> > +
> > +       rx_buffer_info->rxbuf.page = NULL;
> > +}
> > +
> > +static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
> > +                                u32 len,
> > +                                struct net_device *netdev,
> > +                                struct e1000_adapter *adapter)
> > +{
> > +       struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
> > +       struct e1000_hw *hw = &adapter->hw;
> > +       struct e1000_tx_ring *tx_ring;
> > +
> > +       if (len > E1000_MAX_DATA_PER_TXD)
> > +               return;
> > +
> > +       /* e1000 only support a single txq at the moment so the queue is being
> > +        * shared with stack. To support this requires locking to ensure the
> > +        * stack and XDP are not running at the same time. Devices with
> > +        * multiple queues should allocate a separate queue space.
> > +        */
> > +       HARD_TX_LOCK(netdev, txq, smp_processor_id());
> > +
> > +       tx_ring = adapter->tx_ring;
> > +
> > +       if (E1000_DESC_UNUSED(tx_ring) < 2) {
> > +               HARD_TX_UNLOCK(netdev, txq);
> > +               return;
> > +       }
> > +
> > +       if (netif_xmit_frozen_or_stopped(txq))
> > +               return;
> > +
> > +       e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
> > +       netdev_sent_queue(netdev, len);
> > +       e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
> > +
> > +       writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
> > +       mmiowb();
> > +
> > +       HARD_TX_UNLOCK(netdev, txq);
> > +}
> > +
> >  #define NUM_REGS 38 /* 1 based count */
> >  static void e1000_regdump(struct e1000_adapter *adapter)
> >  {
> > @@ -4139,6 +4250,19 @@ static struct sk_buff *e1000_alloc_rx_skb(struct e1000_adapter *adapter,
> >         return skb;
> >  }
> >
> > +static inline int e1000_call_bpf(struct bpf_prog *prog, void *data,
> > +                                unsigned int length)
> > +{
> > +       struct xdp_buff xdp;
> > +       int ret;
> > +
> > +       xdp.data = data;
> > +       xdp.data_end = data + length;
> > +       ret = BPF_PROG_RUN(prog, (void *)&xdp);
> > +
> > +       return ret;
> > +}
> > +
> >  /**
> >   * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
> >   * @adapter: board private structure
> > @@ -4157,12 +4281,15 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
> >         struct pci_dev *pdev = adapter->pdev;
> >         struct e1000_rx_desc *rx_desc, *next_rxd;
> >         struct e1000_rx_buffer *buffer_info, *next_buffer;
> > +       struct bpf_prog *prog;
> >         u32 length;
> >         unsigned int i;
> >         int cleaned_count = 0;
> >         bool cleaned = false;
> >         unsigned int total_rx_bytes = 0, total_rx_packets = 0;
> >
> > +       rcu_read_lock(); /* rcu lock needed here to protect xdp programs */
> > +       prog = READ_ONCE(adapter->prog);
> >         i = rx_ring->next_to_clean;
> >         rx_desc = E1000_RX_DESC(*rx_ring, i);
> >         buffer_info = &rx_ring->buffer_info[i];
> > @@ -4188,12 +4315,54 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
> >
> >                 cleaned = true;
> >                 cleaned_count++;
> > +               length = le16_to_cpu(rx_desc->length);
> > +
> > +               if (prog) {
> > +                       struct page *p = buffer_info->rxbuf.page;
> > +                       dma_addr_t dma = buffer_info->dma;
> > +                       int act;
> > +
> > +                       if (unlikely(!(status & E1000_RXD_STAT_EOP))) {
> > +                               /* attached bpf disallows larger than page
> > +                                * packets, so this is hw error or corruption
> > +                                */
> > +                               pr_info_once("%s buggy !eop\n", netdev->name);
> > +                               break;
> > +                       }
> > +                       if (unlikely(rx_ring->rx_skb_top)) {
> > +                               pr_info_once("%s ring resizing bug\n",
> > +                                            netdev->name);
> > +                               break;
> > +                       }
> > +                       dma_sync_single_for_cpu(&pdev->dev, dma,
> > +                                               length, DMA_FROM_DEVICE);
> > +                       act = e1000_call_bpf(prog, page_address(p), length);
> > +                       switch (act) {
> > +                       case XDP_PASS:
> > +                               break;
> > +                       case XDP_TX:
> > +                               dma_sync_single_for_device(&pdev->dev,
> > +                                                          dma,
> > +                                                          length,
> > +                                                          DMA_TO_DEVICE);
> > +                               e1000_xmit_raw_frame(buffer_info, length,
> > +                                                    netdev, adapter);
> 
> Implementing a new xmit path and clean-up routines for just this is
> going to be a pain.  I'd say if we are going to do something like this
> then maybe we should look at coming up with a new ndo for the xmit and
> maybe push more of this into some sort of inline hook.  Duplicating
> this code in every driver is going to be really expensive.

we will have a common xdp routines when more drivers implement it.
I would expect several pieces fo mlx4/mlx5 can be made common.
ndo approach won't work here, since stack doesn't call into this part.
The xdp logic stays within the driver and dma/page things are driver specific too.
It's pretty much like trying to make common struct between e1000_tx_buffer
and mlx4_en_tx_info. Which is quite difficult.

> Also I just noticed there is no break statement from the xmit code
> above to the drop that below.  I'd think you could overwrite the frame
> data in a case where the Rx exceeds the Tx due to things like flow
> control generating back pressure.

you mean pause frames on TX side?
Aren't 'if (E1000_DESC_UNUSED(tx_ring) < 2) {' enough in e1000_xmit_raw_frame() ?

Thanks for the review!
