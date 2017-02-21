From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next] liquidio: improve UDP TX performance
Date: Tue, 21 Feb 2017 15:27:54 -0800
Message-ID: <CALx6S35HE=8bwXMy7U=+kOSaP1fBmRjPUKn1neW6O=h38P0K2A@mail.gmail.com>
References: <20170221210907.GA8045@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36721 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752803AbdBUX14 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 18:27:56 -0500
Received: by mail-qk0-f195.google.com with SMTP id r90so1799831qki.3
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 15:27:55 -0800 (PST)
In-Reply-To: <20170221210907.GA8045@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 1:09 PM, Felix Manlunas
<felix.manlunas@cavium.com> wrote:
> From: VSR Burru <veerasenareddy.burru@cavium.com>
>
> Improve UDP TX performance by:
> * reducing the ring size from 2K to 512

It looks like liquidio supports BQL. Is that not effective here?

Thanks,
Tom

> * replacing the numerous streaming DMA allocations for info buffers and
>   gather lists with one large consistent DMA allocation per ring
>
> Netperf benchmark numbers before and after patch:
>
> PF UDP TX
> +--------+--------+------------+------------+---------+
> |        |        |  Before    |  After     |         |
> | Number |        |  Patch     |  Patch     |         |
> |  of    | Packet | Throughput | Throughput | Percent |
> | Flows  |  Size  |  (Gbps)    |  (Gbps)    | Change  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   0.52     |   0.93     |  +78.9  |
> |   1    |  1024  |   1.62     |   2.84     |  +75.3  |
> |        |  1518  |   2.44     |   4.21     |  +72.5  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   0.45     |   1.59     | +253.3  |
> |   4    |  1024  |   1.34     |   5.48     | +308.9  |
> |        |  1518  |   2.27     |   8.31     | +266.1  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   0.40     |   1.61     | +302.5  |
> |   8    |  1024  |   1.64     |   4.24     | +158.5  |
> |        |  1518  |   2.87     |   6.52     | +127.2  |
> +--------+--------+------------+------------+---------+
>
>
> VF UDP TX
> +--------+--------+------------+------------+---------+
> |        |        |  Before    |  After     |         |
> | Number |        |  Patch     |  Patch     |         |
> |  of    | Packet | Throughput | Throughput | Percent |
> | Flows  |  Size  |  (Gbps)    |  (Gbps)    | Change  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   1.28     |   1.49     |  +16.4  |
> |   1    |  1024  |   4.44     |   4.39     |   -1.1  |
> |        |  1518  |   6.08     |   6.51     |   +7.1  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   2.35     |   2.35     |    0.0  |
> |   4    |  1024  |   6.41     |   8.07     |  +25.9  |
> |        |  1518  |   9.56     |   9.54     |   -0.2  |
> +--------+--------+------------+------------+---------+
> |        |   360  |   3.41     |   3.65     |   +7.0  |
> |   8    |  1024  |   9.35     |   9.34     |   -0.1  |
> |        |  1518  |   9.56     |   9.57     |   +0.1  |
> +--------+--------+------------+------------+---------+
>
> Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> ---
> Patch Changlog:
>  v2: Add before and after benchmark numbers to the patch explanation.
>
>  drivers/net/ethernet/cavium/liquidio/lio_main.c    | 110 ++++++++++-----------
>  drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 104 ++++++++++---------
>  .../net/ethernet/cavium/liquidio/octeon_config.h   |   6 +-
>  drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  17 +---
>  drivers/net/ethernet/cavium/liquidio/octeon_droq.h |   4 +-
>  drivers/net/ethernet/cavium/liquidio/octeon_main.h |  42 --------
>  .../net/ethernet/cavium/liquidio/octeon_network.h  |  43 +++++---
>  7 files changed, 144 insertions(+), 182 deletions(-)
>
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
> index be9c0e3..92f46b1 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
> @@ -152,7 +152,7 @@ struct octnic_gather {
>          */
>         struct octeon_sg_entry *sg;
>
> -       u64 sg_dma_ptr;
> +       dma_addr_t sg_dma_ptr;
>  };
>
>  struct handshake {
> @@ -734,6 +734,9 @@ static void delete_glists(struct lio *lio)
>         struct octnic_gather *g;
>         int i;
>
> +       kfree(lio->glist_lock);
> +       lio->glist_lock = NULL;
> +
>         if (!lio->glist)
>                 return;
>
> @@ -741,23 +744,26 @@ static void delete_glists(struct lio *lio)
>                 do {
>                         g = (struct octnic_gather *)
>                                 list_delete_head(&lio->glist[i]);
> -                       if (g) {
> -                               if (g->sg) {
> -                                       dma_unmap_single(&lio->oct_dev->
> -                                                        pci_dev->dev,
> -                                                        g->sg_dma_ptr,
> -                                                        g->sg_size,
> -                                                        DMA_TO_DEVICE);
> -                                       kfree((void *)((unsigned long)g->sg -
> -                                                      g->adjust));
> -                               }
> +                       if (g)
>                                 kfree(g);
> -                       }
>                 } while (g);
> +
> +               if (lio->glists_virt_base && lio->glists_virt_base[i]) {
> +                       lio_dma_free(lio->oct_dev,
> +                                    lio->glist_entry_size * lio->tx_qsize,
> +                                    lio->glists_virt_base[i],
> +                                    lio->glists_dma_base[i]);
> +               }
>         }
>
> -       kfree((void *)lio->glist);
> -       kfree((void *)lio->glist_lock);
> +       kfree(lio->glists_virt_base);
> +       lio->glists_virt_base = NULL;
> +
> +       kfree(lio->glists_dma_base);
> +       lio->glists_dma_base = NULL;
> +
> +       kfree(lio->glist);
> +       lio->glist = NULL;
>  }
>
>  /**
> @@ -772,13 +778,30 @@ static int setup_glists(struct octeon_device *oct, struct lio *lio, int num_iqs)
>         lio->glist_lock = kcalloc(num_iqs, sizeof(*lio->glist_lock),
>                                   GFP_KERNEL);
>         if (!lio->glist_lock)
> -               return 1;
> +               return -ENOMEM;
>
>         lio->glist = kcalloc(num_iqs, sizeof(*lio->glist),
>                              GFP_KERNEL);
>         if (!lio->glist) {
> -               kfree((void *)lio->glist_lock);
> -               return 1;
> +               kfree(lio->glist_lock);
> +               lio->glist_lock = NULL;
> +               return -ENOMEM;
> +       }
> +
> +       lio->glist_entry_size =
> +               ROUNDUP8((ROUNDUP4(OCTNIC_MAX_SG) >> 2) * OCT_SG_ENTRY_SIZE);
> +
> +       /* allocate memory to store virtual and dma base address of
> +        * per glist consistent memory
> +        */
> +       lio->glists_virt_base = kcalloc(num_iqs, sizeof(*lio->glists_virt_base),
> +                                       GFP_KERNEL);
> +       lio->glists_dma_base = kcalloc(num_iqs, sizeof(*lio->glists_dma_base),
> +                                      GFP_KERNEL);
> +
> +       if (!lio->glists_virt_base || !lio->glists_dma_base) {
> +               delete_glists(lio);
> +               return -ENOMEM;
>         }
>
>         for (i = 0; i < num_iqs; i++) {
> @@ -788,6 +811,16 @@ static int setup_glists(struct octeon_device *oct, struct lio *lio, int num_iqs)
>
>                 INIT_LIST_HEAD(&lio->glist[i]);
>
> +               lio->glists_virt_base[i] =
> +                       lio_dma_alloc(oct,
> +                                     lio->glist_entry_size * lio->tx_qsize,
> +                                     &lio->glists_dma_base[i]);
> +
> +               if (!lio->glists_virt_base[i]) {
> +                       delete_glists(lio);
> +                       return -ENOMEM;
> +               }
> +
>                 for (j = 0; j < lio->tx_qsize; j++) {
>                         g = kzalloc_node(sizeof(*g), GFP_KERNEL,
>                                          numa_node);
> @@ -796,43 +829,18 @@ static int setup_glists(struct octeon_device *oct, struct lio *lio, int num_iqs)
>                         if (!g)
>                                 break;
>
> -                       g->sg_size = ((ROUNDUP4(OCTNIC_MAX_SG) >> 2) *
> -                                     OCT_SG_ENTRY_SIZE);
> +                       g->sg = lio->glists_virt_base[i] +
> +                               (j * lio->glist_entry_size);
>
> -                       g->sg = kmalloc_node(g->sg_size + 8,
> -                                            GFP_KERNEL, numa_node);
> -                       if (!g->sg)
> -                               g->sg = kmalloc(g->sg_size + 8, GFP_KERNEL);
> -                       if (!g->sg) {
> -                               kfree(g);
> -                               break;
> -                       }
> -
> -                       /* The gather component should be aligned on 64-bit
> -                        * boundary
> -                        */
> -                       if (((unsigned long)g->sg) & 7) {
> -                               g->adjust = 8 - (((unsigned long)g->sg) & 7);
> -                               g->sg = (struct octeon_sg_entry *)
> -                                       ((unsigned long)g->sg + g->adjust);
> -                       }
> -                       g->sg_dma_ptr = dma_map_single(&oct->pci_dev->dev,
> -                                                      g->sg, g->sg_size,
> -                                                      DMA_TO_DEVICE);
> -                       if (dma_mapping_error(&oct->pci_dev->dev,
> -                                             g->sg_dma_ptr)) {
> -                               kfree((void *)((unsigned long)g->sg -
> -                                              g->adjust));
> -                               kfree(g);
> -                               break;
> -                       }
> +                       g->sg_dma_ptr = lio->glists_dma_base[i] +
> +                                       (j * lio->glist_entry_size);
>
>                         list_add_tail(&g->list, &lio->glist[i]);
>                 }
>
>                 if (j != lio->tx_qsize) {
>                         delete_glists(lio);
> -                       return 1;
> +                       return -ENOMEM;
>                 }
>         }
>
> @@ -1885,9 +1893,6 @@ static void free_netsgbuf(void *buf)
>                 i++;
>         }
>
> -       dma_sync_single_for_cpu(&lio->oct_dev->pci_dev->dev,
> -                               g->sg_dma_ptr, g->sg_size, DMA_TO_DEVICE);
> -
>         iq = skb_iq(lio, skb);
>         spin_lock(&lio->glist_lock[iq]);
>         list_add_tail(&g->list, &lio->glist[iq]);
> @@ -1933,9 +1938,6 @@ static void free_netsgbuf_with_resp(void *buf)
>                 i++;
>         }
>
> -       dma_sync_single_for_cpu(&lio->oct_dev->pci_dev->dev,
> -                               g->sg_dma_ptr, g->sg_size, DMA_TO_DEVICE);
> -
>         iq = skb_iq(lio, skb);
>
>         spin_lock(&lio->glist_lock[iq]);
> @@ -3273,8 +3275,6 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
>                         i++;
>                 }
>
> -               dma_sync_single_for_device(&oct->pci_dev->dev, g->sg_dma_ptr,
> -                                          g->sg_size, DMA_TO_DEVICE);
>                 dptr = g->sg_dma_ptr;
>
>                 if (OCTEON_CN23XX_PF(oct))
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> index 9d5e035..7b83be4 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> @@ -108,6 +108,8 @@ struct octnic_gather {
>          * received from the IP layer.
>          */
>         struct octeon_sg_entry *sg;
> +
> +       dma_addr_t sg_dma_ptr;
>  };
>
>  struct octeon_device_priv {
> @@ -490,6 +492,9 @@ static void delete_glists(struct lio *lio)
>         struct octnic_gather *g;
>         int i;
>
> +       kfree(lio->glist_lock);
> +       lio->glist_lock = NULL;
> +
>         if (!lio->glist)
>                 return;
>
> @@ -497,17 +502,26 @@ static void delete_glists(struct lio *lio)
>                 do {
>                         g = (struct octnic_gather *)
>                             list_delete_head(&lio->glist[i]);
> -                       if (g) {
> -                               if (g->sg)
> -                                       kfree((void *)((unsigned long)g->sg -
> -                                                       g->adjust));
> +                       if (g)
>                                 kfree(g);
> -                       }
>                 } while (g);
> +
> +               if (lio->glists_virt_base && lio->glists_virt_base[i]) {
> +                       lio_dma_free(lio->oct_dev,
> +                                    lio->glist_entry_size * lio->tx_qsize,
> +                                    lio->glists_virt_base[i],
> +                                    lio->glists_dma_base[i]);
> +               }
>         }
>
> +       kfree(lio->glists_virt_base);
> +       lio->glists_virt_base = NULL;
> +
> +       kfree(lio->glists_dma_base);
> +       lio->glists_dma_base = NULL;
> +
>         kfree(lio->glist);
> -       kfree(lio->glist_lock);
> +       lio->glist = NULL;
>  }
>
>  /**
> @@ -522,13 +536,30 @@ static int setup_glists(struct lio *lio, int num_iqs)
>         lio->glist_lock =
>             kzalloc(sizeof(*lio->glist_lock) * num_iqs, GFP_KERNEL);
>         if (!lio->glist_lock)
> -               return 1;
> +               return -ENOMEM;
>
>         lio->glist =
>             kzalloc(sizeof(*lio->glist) * num_iqs, GFP_KERNEL);
>         if (!lio->glist) {
>                 kfree(lio->glist_lock);
> -               return 1;
> +               lio->glist_lock = NULL;
> +               return -ENOMEM;
> +       }
> +
> +       lio->glist_entry_size =
> +               ROUNDUP8((ROUNDUP4(OCTNIC_MAX_SG) >> 2) * OCT_SG_ENTRY_SIZE);
> +
> +       /* allocate memory to store virtual and dma base address of
> +        * per glist consistent memory
> +        */
> +       lio->glists_virt_base = kcalloc(num_iqs, sizeof(*lio->glists_virt_base),
> +                                       GFP_KERNEL);
> +       lio->glists_dma_base = kcalloc(num_iqs, sizeof(*lio->glists_dma_base),
> +                                      GFP_KERNEL);
> +
> +       if (!lio->glists_virt_base || !lio->glists_dma_base) {
> +               delete_glists(lio);
> +               return -ENOMEM;
>         }
>
>         for (i = 0; i < num_iqs; i++) {
> @@ -536,34 +567,33 @@ static int setup_glists(struct lio *lio, int num_iqs)
>
>                 INIT_LIST_HEAD(&lio->glist[i]);
>
> +               lio->glists_virt_base[i] =
> +                       lio_dma_alloc(lio->oct_dev,
> +                                     lio->glist_entry_size * lio->tx_qsize,
> +                                     &lio->glists_dma_base[i]);
> +
> +               if (!lio->glists_virt_base[i]) {
> +                       delete_glists(lio);
> +                       return -ENOMEM;
> +               }
> +
>                 for (j = 0; j < lio->tx_qsize; j++) {
>                         g = kzalloc(sizeof(*g), GFP_KERNEL);
>                         if (!g)
>                                 break;
>
> -                       g->sg_size = ((ROUNDUP4(OCTNIC_MAX_SG) >> 2) *
> -                                     OCT_SG_ENTRY_SIZE);
> +                       g->sg = lio->glists_virt_base[i] +
> +                               (j * lio->glist_entry_size);
>
> -                       g->sg = kmalloc(g->sg_size + 8, GFP_KERNEL);
> -                       if (!g->sg) {
> -                               kfree(g);
> -                               break;
> -                       }
> +                       g->sg_dma_ptr = lio->glists_dma_base[i] +
> +                                       (j * lio->glist_entry_size);
>
> -                       /* The gather component should be aligned on 64-bit
> -                        * boundary
> -                        */
> -                       if (((unsigned long)g->sg) & 7) {
> -                               g->adjust = 8 - (((unsigned long)g->sg) & 7);
> -                               g->sg = (struct octeon_sg_entry *)
> -                                       ((unsigned long)g->sg + g->adjust);
> -                       }
>                         list_add_tail(&g->list, &lio->glist[i]);
>                 }
>
>                 if (j != lio->tx_qsize) {
>                         delete_glists(lio);
> -                       return 1;
> +                       return -ENOMEM;
>                 }
>         }
>
> @@ -1324,10 +1354,6 @@ static void free_netsgbuf(void *buf)
>                 i++;
>         }
>
> -       dma_unmap_single(&lio->oct_dev->pci_dev->dev,
> -                        finfo->dptr, g->sg_size,
> -                        DMA_TO_DEVICE);
> -
>         iq = skb_iq(lio, skb);
>
>         spin_lock(&lio->glist_lock[iq]);
> @@ -1374,10 +1400,6 @@ static void free_netsgbuf_with_resp(void *buf)
>                 i++;
>         }
>
> -       dma_unmap_single(&lio->oct_dev->pci_dev->dev,
> -                        finfo->dptr, g->sg_size,
> -                        DMA_TO_DEVICE);
> -
>         iq = skb_iq(lio, skb);
>
>         spin_lock(&lio->glist_lock[iq]);
> @@ -2382,23 +2404,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
>                         i++;
>                 }
>
> -               dptr = dma_map_single(&oct->pci_dev->dev,
> -                                     g->sg, g->sg_size,
> -                                     DMA_TO_DEVICE);
> -               if (dma_mapping_error(&oct->pci_dev->dev, dptr)) {
> -                       dev_err(&oct->pci_dev->dev, "%s DMA mapping error 4\n",
> -                               __func__);
> -                       dma_unmap_single(&oct->pci_dev->dev, g->sg[0].ptr[0],
> -                                        skb->len - skb->data_len,
> -                                        DMA_TO_DEVICE);
> -                       for (j = 1; j <= frags; j++) {
> -                               frag = &skb_shinfo(skb)->frags[j - 1];
> -                               dma_unmap_page(&oct->pci_dev->dev,
> -                                              g->sg[j >> 2].ptr[j & 3],
> -                                              frag->size, DMA_TO_DEVICE);
> -                       }
> -                       return NETDEV_TX_BUSY;
> -               }
> +               dptr = g->sg_dma_ptr;
>
>                 ndata.cmd.cmd3.dptr = dptr;
>                 finfo->dptr = dptr;
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
> index b3dc2e9..d29ebc5 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
> @@ -71,17 +71,17 @@
>  #define   CN23XX_MAX_RINGS_PER_VF          8
>
>  #define   CN23XX_MAX_INPUT_QUEUES      CN23XX_MAX_RINGS_PER_PF
> -#define   CN23XX_MAX_IQ_DESCRIPTORS    2048
> +#define   CN23XX_MAX_IQ_DESCRIPTORS    512
>  #define   CN23XX_DB_MIN                 1
>  #define   CN23XX_DB_MAX                 8
>  #define   CN23XX_DB_TIMEOUT             1
>
>  #define   CN23XX_MAX_OUTPUT_QUEUES     CN23XX_MAX_RINGS_PER_PF
> -#define   CN23XX_MAX_OQ_DESCRIPTORS    2048
> +#define   CN23XX_MAX_OQ_DESCRIPTORS    512
>  #define   CN23XX_OQ_BUF_SIZE           1536
>  #define   CN23XX_OQ_PKTSPER_INTR       128
>  /*#define CAVIUM_ONLY_CN23XX_RX_PERF*/
> -#define   CN23XX_OQ_REFIL_THRESHOLD    128
> +#define   CN23XX_OQ_REFIL_THRESHOLD    16
>
>  #define   CN23XX_OQ_INTR_PKT           64
>  #define   CN23XX_OQ_INTR_TIME          100
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
> index 0be87d1..79f8094 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
> @@ -155,11 +155,6 @@ octeon_droq_destroy_ring_buffers(struct octeon_device *oct,
>                         recv_buffer_destroy(droq->recv_buf_list[i].buffer,
>                                             pg_info);
>
> -               if (droq->desc_ring && droq->desc_ring[i].info_ptr)
> -                       lio_unmap_ring_info(oct->pci_dev,
> -                                           (u64)droq->
> -                                           desc_ring[i].info_ptr,
> -                                           OCT_DROQ_INFO_SIZE);
>                 droq->recv_buf_list[i].buffer = NULL;
>         }
>
> @@ -211,10 +206,7 @@ int octeon_delete_droq(struct octeon_device *oct, u32 q_no)
>         vfree(droq->recv_buf_list);
>
>         if (droq->info_base_addr)
> -               cnnic_free_aligned_dma(oct->pci_dev, droq->info_list,
> -                                      droq->info_alloc_size,
> -                                      droq->info_base_addr,
> -                                      droq->info_list_dma);
> +               lio_free_info_buffer(oct, droq);
>
>         if (droq->desc_ring)
>                 lio_dma_free(oct, (droq->max_count * OCT_DROQ_DESC_SIZE),
> @@ -294,12 +286,7 @@ int octeon_init_droq(struct octeon_device *oct,
>         dev_dbg(&oct->pci_dev->dev, "droq[%d]: num_desc: %d\n", q_no,
>                 droq->max_count);
>
> -       droq->info_list =
> -               cnnic_numa_alloc_aligned_dma((droq->max_count *
> -                                             OCT_DROQ_INFO_SIZE),
> -                                            &droq->info_alloc_size,
> -                                            &droq->info_base_addr,
> -                                            numa_node);
> +       droq->info_list = lio_alloc_info_buffer(oct, droq);
>         if (!droq->info_list) {
>                 dev_err(&oct->pci_dev->dev, "Cannot allocate memory for info list.\n");
>                 lio_dma_free(oct, (droq->max_count * OCT_DROQ_DESC_SIZE),
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
> index e620740..6982c0a 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
> @@ -325,10 +325,10 @@ struct octeon_droq {
>         size_t desc_ring_dma;
>
>         /** Info ptr list are allocated at this virtual address. */
> -       size_t info_base_addr;
> +       void *info_base_addr;
>
>         /** DMA mapped address of the info list */
> -       size_t info_list_dma;
> +       dma_addr_t info_list_dma;
>
>         /** Allocated size of info list. */
>         u32 info_alloc_size;
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
> index 8cd3891..b3183c9 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
> @@ -138,48 +138,6 @@ static inline int octeon_map_pci_barx(struct octeon_device *oct,
>         return 1;
>  }
>
> -static inline void *
> -cnnic_numa_alloc_aligned_dma(u32 size,
> -                            u32 *alloc_size,
> -                            size_t *orig_ptr,
> -                            int numa_node)
> -{
> -       int retries = 0;
> -       void *ptr = NULL;
> -
> -#define OCTEON_MAX_ALLOC_RETRIES     1
> -       do {
> -               struct page *page = NULL;
> -
> -               page = alloc_pages_node(numa_node,
> -                                       GFP_KERNEL,
> -                                       get_order(size));
> -               if (!page)
> -                       page = alloc_pages(GFP_KERNEL,
> -                                          get_order(size));
> -               ptr = (void *)page_address(page);
> -               if ((unsigned long)ptr & 0x07) {
> -                       __free_pages(page, get_order(size));
> -                       ptr = NULL;
> -                       /* Increment the size required if the first
> -                        * attempt failed.
> -                        */
> -                       if (!retries)
> -                               size += 7;
> -               }
> -               retries++;
> -       } while ((retries <= OCTEON_MAX_ALLOC_RETRIES) && !ptr);
> -
> -       *alloc_size = size;
> -       *orig_ptr = (unsigned long)ptr;
> -       if ((unsigned long)ptr & 0x07)
> -               ptr = (void *)(((unsigned long)ptr + 7) & ~(7UL));
> -       return ptr;
> -}
> -
> -#define cnnic_free_aligned_dma(pci_dev, ptr, size, orig_ptr, dma_addr) \
> -               free_pages(orig_ptr, get_order(size))
> -
>  static inline int
>  sleep_cond(wait_queue_head_t *wait_queue, int *condition)
>  {
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
> index 6bb8941..eef2a1e 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
> @@ -62,6 +62,9 @@ struct lio {
>
>         /** Array of gather component linked lists */
>         struct list_head *glist;
> +       void **glists_virt_base;
> +       dma_addr_t *glists_dma_base;
> +       u32 glist_entry_size;
>
>         /** Pointer to the NIC properties for the Octeon device this network
>          *  interface is associated with.
> @@ -344,6 +347,29 @@ static inline void tx_buffer_free(void *buffer)
>  #define lio_dma_free(oct, size, virt_addr, dma_addr) \
>         dma_free_coherent(&(oct)->pci_dev->dev, size, virt_addr, dma_addr)
>
> +static inline void *
> +lio_alloc_info_buffer(struct octeon_device *oct,
> +                     struct octeon_droq *droq)
> +{
> +       void *virt_ptr;
> +
> +       virt_ptr = lio_dma_alloc(oct, (droq->max_count * OCT_DROQ_INFO_SIZE),
> +                                &droq->info_list_dma);
> +       if (virt_ptr) {
> +               droq->info_alloc_size = droq->max_count * OCT_DROQ_INFO_SIZE;
> +               droq->info_base_addr = virt_ptr;
> +       }
> +
> +       return virt_ptr;
> +}
> +
> +static inline void lio_free_info_buffer(struct octeon_device *oct,
> +                                       struct octeon_droq *droq)
> +{
> +       lio_dma_free(oct, droq->info_alloc_size, droq->info_base_addr,
> +                    droq->info_list_dma);
> +}
> +
>  static inline
>  void *get_rbd(struct sk_buff *skb)
>  {
> @@ -359,22 +385,7 @@ void *get_rbd(struct sk_buff *skb)
>  static inline u64
>  lio_map_ring_info(struct octeon_droq *droq, u32 i)
>  {
> -       dma_addr_t dma_addr;
> -       struct octeon_device *oct = droq->oct_dev;
> -
> -       dma_addr = dma_map_single(&oct->pci_dev->dev, &droq->info_list[i],
> -                                 OCT_DROQ_INFO_SIZE, DMA_FROM_DEVICE);
> -
> -       WARN_ON(dma_mapping_error(&oct->pci_dev->dev, dma_addr));
> -
> -       return (u64)dma_addr;
> -}
> -
> -static inline void
> -lio_unmap_ring_info(struct pci_dev *pci_dev,
> -                   u64 info_ptr, u32 size)
> -{
> -       dma_unmap_single(&pci_dev->dev, info_ptr, size, DMA_FROM_DEVICE);
> +       return droq->info_list_dma + (i * sizeof(struct octeon_droq_info));
>  }
>
>  static inline u64
