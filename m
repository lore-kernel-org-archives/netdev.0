From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v2 net-next 3/4] mlx4: xdp: Reserve headroom for
 receiving packet when XDP prog is active
Date: Tue, 6 Dec 2016 14:25:02 -0800
Message-ID: <20161206222502.GA47523@kafai-mba.local>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com>
 <1480821446-4122277-4-git-send-email-kafai@fb.com>
 <CALzJLG9Um8ng5JdQihJQ8Y0m+zuTiwnhCZBOqw-WKvLsb0=VCg@mail.gmail.com>
 <20161205195519.GA29784@kafai-mba.local>
 <CALzJLG8-dZAvio7035CM4bFtzGanaLNWA=pExZfBJ6n9-K9ntQ@mail.gmail.com>
 <20161206182718.GA16682@kafai-mba.local>
 <CALzJLG_+1fAv=i2uRF7cd_GZh2v66Pry=HusHmh6a_Nfq78CHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        "Jesper Dangaard Brouer" <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "Tariq Toukan" <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58617 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751308AbcLFW0O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 17:26:14 -0500
Content-Disposition: inline
In-Reply-To: <CALzJLG_+1fAv=i2uRF7cd_GZh2v66Pry=HusHmh6a_Nfq78CHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 11:40:19PM +0200, Saeed Mahameed wrote:
> On Tue, Dec 6, 2016 at 8:27 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> > On Tue, Dec 06, 2016 at 06:50:47PM +0200, Saeed Mahameed wrote:
> >> On Mon, Dec 5, 2016 at 9:55 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> >> > On Mon, Dec 05, 2016 at 02:54:06AM +0200, Saeed Mahameed wrote:
> >> >> On Sun, Dec 4, 2016 at 5:17 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> >> >> > Reserve XDP_PACKET_HEADROOM and honor bpf_xdp_adjust_head()
> >> >> > when XDP prog is active.  This patch only affects the code
> >> >> > path when XDP is active.
> >> >> >
> >> >> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> >> >> > ---
> >> >>
> >> >> Hi Martin, Sorry for the late review, i have some comments below
> >> >>
> >> >> >  drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 17 +++++++++++++++--
> >> >> >  drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 23 +++++++++++++++++------
> >> >> >  drivers/net/ethernet/mellanox/mlx4/en_tx.c     |  9 +++++----
> >> >> >  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  3 ++-
> >> >> >  4 files changed, 39 insertions(+), 13 deletions(-)
> >> >> >
> >> >> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >> >> > index 311c14153b8b..094a13b52cf6 100644
> >> >> > --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >> >> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >> >> > @@ -51,7 +51,8 @@
> >> >> >  #include "mlx4_en.h"
> >> >> >  #include "en_port.h"
> >> >> >
> >> >> > -#define MLX4_EN_MAX_XDP_MTU ((int)(PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN)))
> >> >> > +#define MLX4_EN_MAX_XDP_MTU ((int)(PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) - \
> >> >> > +                                  XDP_PACKET_HEADROOM))
> >> >> >
> >> >> >  int mlx4_en_setup_tc(struct net_device *dev, u8 up)
> >> >> >  {
> >> >> > @@ -1551,6 +1552,7 @@ int mlx4_en_start_port(struct net_device *dev)
> >> >> >         struct mlx4_en_tx_ring *tx_ring;
> >> >> >         int rx_index = 0;
> >> >> >         int err = 0;
> >> >> > +       int mtu;
> >> >> >         int i, t;
> >> >> >         int j;
> >> >> >         u8 mc_list[16] = {0};
> >> >> > @@ -1684,8 +1686,12 @@ int mlx4_en_start_port(struct net_device *dev)
> >> >> >         }
> >> >> >
> >> >> >         /* Configure port */
> >> >> > +       mtu = priv->rx_skb_size + ETH_FCS_LEN;
> >> >> > +       if (priv->tx_ring_num[TX_XDP])
> >> >> > +               mtu += XDP_PACKET_HEADROOM;
> >> >> > +
> >> >>
> >> >> Why would the physical MTU care for the headroom you preserve for XDP prog?
> >> >> This is the wire MTU, it shouldn't be changed, please keep it as
> >> >> before, any preservation you make in packets buffers are needed only
> >> >> for FWD case or modify case (HW or wire should not care about them).
> >> >
> >> > Thanks for your feedback!
> >>
> >> Just doing my job :))
> >>
> >> >
> >> > FWD:
> >> > packet received from a port
> >> > => process by a XDP prog
> >> > => XDP_TX out to the same port.
> >> >
> >> > For example, if the received packet has 1500 payload and the XDP prog
> >> > encapsulates it in an IPv6 header (+40 bytes).  After testing, it cannot
> >> > be sent out due to the HW/wire MTU is 1500.
> >> >
> >> > Even the wire MTU info was passed to the XDP prog, there is not much a
> >> > XDP prog could do here other than dropping it.
> >> >
> >> > Hence, this patch gives guarantee to the XDP prog such that
> >> > it can always send out what it has received + XDP_PACKET_HEADROOM.
> >> >
> >>
> >> Still i am not convinced ! this is against common sense,
> >> this means that the XDP prog can send packets larger than the  MTU
> >> seen on netdev!
> >>
> >> anyway if a packet with the size (MTU + XDP_PACKET_HEADROOM) was sent
> >> from XDP ring and HW allowed it to exit somehow (with the code you
> >> provided :)), most likely it will be dropped
> >> at the other end.
> > The MTU of our receiver side is larger than 1500.
> >
> > If the otherside could not handle >1500, we could lower the box running
> > XDP prog to 1460.
> >
>
> This is exactly the user confusion we are trying to avoid.
>
> Genuinely lowering the other side or dropping packets in XDP program
> that are not eligible for edit&FWD (packets > MTU - required headroom
> )  will create the same effect. why don't you use this approach ?
>
> dropping "large" packets in XDP seems the best solution.
Within the DC, yes we have absolute control on what to expect and we can even
lower the other end easily if it is needed.  However, it may not be the case
for machines sitting at some exotic location.

After this thread, I think this bit may require more thoughts/discussions.
I will drop it now and revisit later since it is not user ABI related.

For now, lets check and drop at the driver side since the driver has the MTU
info.

>
> > Just ensure we are on the same page.  The rx MTU stays the same (1500)
> > because the rx_desc's byte_count is not raised by XDP_PACKET_HEADROOM.
> >
>
> Yea it is clear,
>
> One more reason not to do this: now packets that were dropped due to
> "large MTU" HW drop cause, will now pass the HW check but will fail on
> RX error (RX buffers are smaller than the wire MTU sized packet) this
> counts as an error in both mlx5/4 which is not acceptable.
>
> >>
> >> I still think XDP prog should not be allowed to FW packets larger than
> >> the MTU seen on the netdev and you shouldn't modify the wire MTU just
> >> for this case.
> >>
> >> >>
> >> >> >         err = mlx4_SET_PORT_general(mdev->dev, priv->port,
> >> >> > -                                   priv->rx_skb_size + ETH_FCS_LEN,
> >> >> > +                                   mtu,
> >> >> >                                     priv->prof->tx_pause,
> >> >> >                                     priv->prof->tx_ppp,
> >> >> >                                     priv->prof->rx_pause,
> >> >> > @@ -2255,6 +2261,13 @@ static bool mlx4_en_check_xdp_mtu(struct net_device *dev, int mtu)
> >> >> >  {
> >> >> >         struct mlx4_en_priv *priv = netdev_priv(dev);
> >> >> >
> >> >> > +       if (mtu + XDP_PACKET_HEADROOM > priv->max_mtu) {
> >> >> > +               en_err(priv,
> >> >> > +                      "Device max mtu:%d does not allow %d bytes reserved headroom for XDP prog\n",
> >> >> > +                      priv->max_mtu, XDP_PACKET_HEADROOM);
> >> >> > +               return false;
> >> >> > +       }
> >> >> > +
> >> >> >         if (mtu > MLX4_EN_MAX_XDP_MTU) {
> >> >> >                 en_err(priv, "mtu:%d > max:%d when XDP prog is attached\n",
> >> >> >                        mtu, MLX4_EN_MAX_XDP_MTU);
> >> >> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >> >> > index 23e9d04d1ef4..324771ac929e 100644
> >> >> > --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >> >> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> >> >> > @@ -96,7 +96,6 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
> >> >> >         struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
> >> >> >         const struct mlx4_en_frag_info *frag_info;
> >> >> >         struct page *page;
> >> >> > -       dma_addr_t dma;
> >> >> >         int i;
> >> >> >
> >> >> >         for (i = 0; i < priv->num_frags; i++) {
> >> >> > @@ -115,9 +114,10 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
> >> >> >
> >> >> >         for (i = 0; i < priv->num_frags; i++) {
> >> >> >                 frags[i] = ring_alloc[i];
> >> >> > -               dma = ring_alloc[i].dma + ring_alloc[i].page_offset;
> >> >> > +               frags[i].page_offset += priv->frag_info[i].rx_headroom;
> >> >>
> >> >> I don't see any need for headroom on frag_info other that frag0 (which
> >> >> where the packet starts).
> >> >> What is the meaning of a headroom of a frag in a middle of a packet ?
> >> >>
> >> >> if you agree with me then, you can use XDP_PACKET_HEADROOM as is where
> >> >> needed (i.e frag0 page offset) and remove
> >> >> "priv->frag_info[i].rx_headroom"
> >> >>
> >> >> ...
> >> >>
> >> >> After going through the code a little bit i see that this code is
> >> >> shared between XDP and common path, and you didn't want to add boolean
> >> >> conditions.
> >> >>
> >> >> Ok i see what you did here.
> >> >>
> >> >> Maybe we can pass headroom as a function parameter and split frag0
> >> >> handling from the rest ?
> >> >> If it is too much then i am ok with the code as it is,
> >> > Right, this patch does the boolean check (XDP active or not) early on
> >> > in mlx4_en_calc_rx_buf() (i.e. out of the fast path) and store
> >> > the result in priv->frag_info[0].rx_headroom.
> >> >
> >> > Just want to ensure I understand your comment correctly.
> >> > You prefer not to store the boolean test result in frag_info[0].rx_headroom
> >> > since it is redundant to !!priv->tx_ring_num[TX_XDP] and rx_headroom is also
> >> > confusing for frag[1-3].
> >> >
> >> > Instead, do the XDP [in]active test before calling mlx4_en_alloc_frags()
> >> > and then only adjust frags[0].page_offset by +XDP_PACKET_HEADROOM if is needed.
> >> > It could be done either by passing an extra argument to mlx4_en_alloc_frags()
> >> > or completely separate mlx4_en_alloc_frags().  I am fine with this also.
> >> >
> >>
> >> Correct, but if this change will add extra checks to the data path
> >> then I am ok with the current code.
> > Right, the check has to be done somewhere in the data path.
> > Lets stay with the current approach then.
> >
> >>
> >> >
> >> >>
> >> >> > +               rx_desc->data[i].addr = cpu_to_be64(frags[i].dma +
> >> >> > +                                                   frags[i].page_offset);
> >> >> >                 ring_alloc[i] = page_alloc[i];
> >> >> > -               rx_desc->data[i].addr = cpu_to_be64(dma);
> >> >> >         }
> >> >> >
> >> >> >         return 0;
> >> >> > @@ -250,7 +250,8 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
> >> >> >
> >> >> >         if (ring->page_cache.index > 0) {
> >> >> >                 frags[0] = ring->page_cache.buf[--ring->page_cache.index];
> >> >> > -               rx_desc->data[0].addr = cpu_to_be64(frags[0].dma);
> >> >> > +               rx_desc->data[0].addr = cpu_to_be64(frags[0].dma +
> >> >> > +                                                   frags[0].page_offset);
> >> >> >                 return 0;
> >> >> >         }
> >> >> >
> >> >> > @@ -889,6 +890,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >> >> >                 if (xdp_prog) {
> >> >> >                         struct xdp_buff xdp;
> >> >> >                         dma_addr_t dma;
> >> >> > +                       void *pg_addr, *orig_data;
> >> >> >                         u32 act;
> >> >> >
> >> >> >                         dma = be64_to_cpu(rx_desc->data[0].addr);
> >> >> > @@ -896,11 +898,18 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >> >> >                                                 priv->frag_info[0].frag_size,
> >> >> >                                                 DMA_FROM_DEVICE);
> >> >> >
> >> >> > -                       xdp.data = page_address(frags[0].page) +
> >> >> > -                                                       frags[0].page_offset;
> >> >> > +                       pg_addr = page_address(frags[0].page);
> >> >> > +                       orig_data = pg_addr + frags[0].page_offset;
> >> >> > +                       xdp.data = orig_data;
> >> >> >                         xdp.data_end = xdp.data + length;
> >> >> >
> >> >> >                         act = bpf_prog_run_xdp(xdp_prog, &xdp);
> >> >> > +
> >> >> > +                       if (xdp.data != orig_data) {
> >> >> > +                               length = xdp.data_end - xdp.data;
> >> >> > +                               frags[0].page_offset = xdp.data - pg_addr;
> >> >> > +                       }
> >> >> > +
> >> >> >
> >> >>
> >> >> is this needed only for XDP FWD case ?
> >> > No. It is also for PASS.
> >> >
> >>
> >> I see.
> >>
> >> >> is this the only way to detect that the user modified the packet
> >> >> headers (comparing pointers, before and after) ?
> >> > Yes
> >> >
> >> >>
> >> >> if the answer is yes, it should be faster to unconditionally reset
> >> >> packet offset and lenght on XDP_FWD :
> >> >> case XDP_FWD:
> >> >>    length = xdp.data_end - xdp.data;
> >> >>    frags[0].page_offset = xdp.data - pg_addr;
> >> >>
> >> >>
> >> >> >                         switch (act) {
> >> >> >                         case XDP_PASS:
> >> >> >                                 break;
> >> >> > @@ -1180,6 +1189,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
> >> >> >                  */
> >> >> >                 priv->frag_info[0].frag_stride = PAGE_SIZE;
> >> >> >                 priv->frag_info[0].dma_dir = PCI_DMA_BIDIRECTIONAL;
> >> >> > +               priv->frag_info[0].rx_headroom = XDP_PACKET_HEADROOM;
> >> >> >                 i = 1;
> >> >> >         } else {
> >> >> >                 int buf_size = 0;
> >> >> > @@ -1194,6 +1204,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
> >> >> >                                 ALIGN(priv->frag_info[i].frag_size,
> >> >> >                                       SMP_CACHE_BYTES);
> >> >> >                         priv->frag_info[i].dma_dir = PCI_DMA_FROMDEVICE;
> >> >> > +                       priv->frag_info[i].rx_headroom = 0;
> >> >>
> >> >> IMHO, redundant. as you see here frag0 and other frags handling are
> >> >> separated, maybe we can do the same in mlx4_en_alloc_frags.
> >> >>
> >> >> >                         buf_size += priv->frag_info[i].frag_size;
> >> >> >                         i++;
> >> >> >                 }
> >> >> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> >> >> > index 4b597dca5c52..9e5f38cefe5f 100644
> >> >> > --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> >> >> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> >> >> > @@ -354,7 +354,7 @@ u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
> >> >> >         struct mlx4_en_rx_alloc frame = {
> >> >> >                 .page = tx_info->page,
> >> >> >                 .dma = tx_info->map0_dma,
> >> >> > -               .page_offset = 0,
> >> >> > +               .page_offset = XDP_PACKET_HEADROOM,
> >> >> >                 .page_size = PAGE_SIZE,
> >> >> >         };
> >> >> >
> >> >> > @@ -1132,7 +1132,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
> >> >> >         tx_info->page = frame->page;
> >> >> >         frame->page = NULL;
> >> >> >         tx_info->map0_dma = dma;
> >> >> > -       tx_info->map0_byte_count = length;
> >> >> > +       tx_info->map0_byte_count = length + frame->page_offset;
> >> >>
> >> >> Didn't you already take care of lenght by the following code:
> >> >>                        if (xdp.data != orig_data) {
> >> >>                                length = xdp.data_end - xdp.data;
> >> >>                                frags[0].page_offset = xdp.data - pg_addr;
> >> >>                         }
> >> >>
> >> > Before this patch, length always assumes the data starts at the beginning
> >> > of the page and dma is the start of the page.  Hence, adding
> >> > framg->page_offset back to the length here.
> >> >
> >> > However, if I read the codes correctly, I think the map0_byte_count (before or
> >> > after this patch) does not matter since it is only used in dma_unmap_page() and
> >> > PAGE_SIZE is always used in dma_unmap_page() for this code patch.  Hence, I think
> >> > we can just set map0_byte_count to PAGE_SIZE here.
> >> >
> >>
> >> Right, in mlx4_alloc_pages we always map with PAGE_SIZE <<  order
> >>  dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE << order,
> >>   frag_info->dma_dir);
> >> for XDP order is always 0, so you can safely set it to PAGE_SIZE.
> >>
> >> >> and here  frame->page_offset is not really page offset, it can only be
> >> >> XDP_PACKET_HEADROOM.
> >> > Note that the XDP prog can call bpf_xdp_adjust_head() to add a header.
> >> > The XDP prog can extend up to XDP_PACKET_HEADROOM (256) bytes but it
> >> > can also (and usually) only add 40 bytes IPv6 header and then XDP_TX it out.
> >> >
> >>
> >> I see.
> >>
> >> >>
> >> >> >         tx_info->nr_txbb = nr_txbb;
> >> >> >         tx_info->nr_bytes = max_t(unsigned int, length, ETH_ZLEN);
> >> >> >         tx_info->data_offset = (void *)data - (void *)tx_desc;
> >> >> > @@ -1141,9 +1141,10 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
> >> >> >         tx_info->linear = 1;
> >> >> >         tx_info->inl = 0;
> >> >> >
> >> >> > -       dma_sync_single_for_device(priv->ddev, dma, length, PCI_DMA_TODEVICE);
> >> >> > +       dma_sync_single_range_for_device(priv->ddev, dma, frame->page_offset,
> >> >> > +                                        length, PCI_DMA_TODEVICE);
> >> >> >
> >> >> > -       data->addr = cpu_to_be64(dma);
> >> >> > +       data->addr = cpu_to_be64(dma + frame->page_offset);
> >> >> >         data->lkey = ring->mr_key;
> >> >> >         dma_wmb();
> >> >> >         data->byte_count = cpu_to_be32(length);
> >> >> > diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> >> >> > index 20a936428f4a..ba1c6cd0cc79 100644
> >> >> > --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> >> >> > +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> >> >> > @@ -475,7 +475,8 @@ struct mlx4_en_frag_info {
> >> >> >         u16 frag_prefix_size;
> >> >> >         u32 frag_stride;
> >> >> >         enum dma_data_direction dma_dir;
> >> >> > -       int order;
> >> >> > +       u16 order;
> >> >> > +       u16 rx_headroom;
> >> >> >  };
> >> >> >
> >> >> >  #ifdef CONFIG_MLX4_EN_DCB
> >> >> > --
> >> >> > 2.5.1
> >> >> >
