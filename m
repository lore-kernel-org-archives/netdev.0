From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf program
Date: Mon, 11 Jul 2016 14:48:17 +0300
Message-ID: <CALzJLG846VMsOWuAvT=6Kcdu_p+ixUX=tTyV-DgAEXYpXszBgw@mail.gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-5-git-send-email-bblanco@plumgrid.com> <CALzJLG8+LzX_sELAC-TVszeWXZFbCKVJ+rJnDT50fqN5PodEAA@mail.gmail.com>
 <57d2eb82-1992-b6fb-0727-b3b0d8983765@gmail.com> <20160710160540.GB6657@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:36725 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166AbcGKLsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 07:48:42 -0400
Received: by mail-yw0-f194.google.com with SMTP id y188so8764763ywf.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 04:48:42 -0700 (PDT)
In-Reply-To: <20160710160540.GB6657@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2016 at 7:05 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> On Sun, Jul 10, 2016 at 06:25:40PM +0300, Tariq Toukan wrote:
>>
>> On 09/07/2016 10:58 PM, Saeed Mahameed wrote:
>> >On Fri, Jul 8, 2016 at 5:15 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
>> >>+               /* A bpf program gets first chance to drop the packet. It may
>> >>+                * read bytes but not past the end of the frag.
>> >>+                */
>> >>+               if (prog) {
>> >>+                       struct xdp_buff xdp;
>> >>+                       dma_addr_t dma;
>> >>+                       u32 act;
>> >>+
>> >>+                       dma = be64_to_cpu(rx_desc->data[0].addr);
>> >>+                       dma_sync_single_for_cpu(priv->ddev, dma,
>> >>+                                               priv->frag_info[0].frag_size,
>> >>+                                               DMA_FROM_DEVICE);
>> >In case of XDP_PASS we will dma_sync again in the normal path, this
>> >can be improved by doing the dma_sync as soon as we can and once and
>> >for all, regardless of the path the packet is going to take
>> >(XDP_DROP/mlx4_en_complete_rx_desc/mlx4_en_rx_skb).
>> I agree with Saeed, dma_sync is a heavy operation that is now done
>> twice for all packets with XDP_PASS.
>> We should try our best to avoid performance degradation in the flow
>> of unfiltered packets.
> Makes sense, do folks here see a way to do this cleanly?

yes, we need something like:

+static inline void
+mlx4_en_sync_dma(struct mlx4_en_priv *priv,
+                struct mlx4_en_rx_desc *rx_desc,
+                int length)
+{
+       dma_addr_t dma;
+
+       /* Sync dma addresses from HW descriptor */
+       for (nr = 0; nr < priv->num_frags; nr++) {
+               struct mlx4_en_frag_info *frag_info = &priv->frag_info[nr];
+
+               if (length <= frag_info->frag_prefix_size)
+                       break;
+
+               dma = be64_to_cpu(rx_desc->data[nr].addr);
+               dma_sync_single_for_cpu(priv->ddev, dma, frag_info->frag_size,
+                                       DMA_FROM_DEVICE);
+       }
+}


@@ -790,6 +808,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
struct mlx4_en_cq *cq, int bud
                        goto next;
                }

+               length = be32_to_cpu(cqe->byte_cnt);
+               length -= ring->fcs_del;
+
+               mlx4_en_sync_dma(priv,rx_desc, length);
                 /* data is available continue processing the packet */

and make sure to remove all explicit dma_sync_single_for_cpu calls.
