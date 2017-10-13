From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V7 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion
 and allocation
Date: Fri, 13 Oct 2017 11:13:47 +0200
Message-ID: <20171013111347.1472fcfb@redhat.com>
References: <150781116384.9409.2491501775270038284.stgit@firesoul>
        <150781121989.9409.14542782810603037426.stgit@firesoul>
        <21efa4a5-1e2f-bbe9-c1d0-115843fb885b@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jakub.kicinski@netronome.com>,
        "Michael S. Tsirkin" <mst@redhat.com>, <pavel.odintsov@gmail.com>,
        Jason Wang <jasowang@redhat.com>, <mchan@broadcom.com>,
        John Fastabend <john.fastabend@gmail.com>,
        <peter.waskiewicz.jr@intel.com>, <ast@fiberby.dk>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43146 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757978AbdJMJN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 05:13:59 -0400
In-Reply-To: <21efa4a5-1e2f-bbe9-c1d0-115843fb885b@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Oct 2017 22:13:43 +0100
Edward Cree <ecree@solarflare.com> wrote:

> On 12/10/17 13:26, Jesper Dangaard Brouer wrote:
> > This patch makes cpumap functional, by adding SKB allocation and
> > invoking the network stack on the dequeuing CPU.
> >
> > For constructing the SKB on the remote CPU, the xdp_buff in converted
> > into a struct xdp_pkt, and it mapped into the top headroom of the
> > packet, to avoid allocating separate mem.  For now, struct xdp_pkt is
> > just a cpumap internal data structure, with info carried between
> > enqueue to dequeue.  
> 
> <snip>
> 
> > +struct sk_buff *cpu_map_build_skb(struct bpf_cpu_map_entry *rcpu,
> > +				  struct xdp_pkt *xdp_pkt)
> > +{
> > +	unsigned int frame_size;
> > +	void *pkt_data_start;
> > +	struct sk_buff *skb;
> > +
> > +	/* build_skb need to place skb_shared_info after SKB end, and
> > +	 * also want to know the memory "truesize".  Thus, need to
> > +	 * know the memory frame size backing xdp_buff.
> > +	 *
> > +	 * XDP was designed to have PAGE_SIZE frames, but this
> > +	 * assumption is not longer true with ixgbe and i40e.  It
> > +	 * would be preferred to set frame_size to 2048 or 4096
> > +	 * depending on the driver.
> > +	 *   frame_size = 2048;
> > +	 *   frame_len  = frame_size - sizeof(*xdp_pkt);
> > +	 *
> > +	 * Instead, with info avail, skb_shared_info in placed after
> > +	 * packet len.  This, unfortunately fakes the truesize.
> > +	 * Another disadvantage of this approach, the skb_shared_info
> > +	 * is not at a fixed memory location, with mixed length
> > +	 * packets, which is bad for cache-line hotness.
> > +	 */
> > +	frame_size = SKB_DATA_ALIGN(xdp_pkt->len) + xdp_pkt->headroom +
> > +		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> > +
> > +	pkt_data_start = xdp_pkt->data - xdp_pkt->headroom;
> > +	skb = build_skb(pkt_data_start, frame_size);
> > +	if (!skb)
> > +		return NULL;
> > +
> > +	skb_reserve(skb, xdp_pkt->headroom);
> > +	__skb_put(skb, xdp_pkt->len);
> > +	if (xdp_pkt->metasize)
> > +		skb_metadata_set(skb, xdp_pkt->metasize);
> > +
> > +	/* Essential SKB info: protocol and skb->dev */
> > +	skb->protocol = eth_type_trans(skb, xdp_pkt->dev_rx);
> > +
> > +	/* Optional SKB info, currently missing:
> > +	 * - HW checksum info		(skb->ip_summed)
> > +	 * - HW RX hash			(skb_set_hash)
> > +	 * - RX ring dev queue index	(skb_record_rx_queue)
> > +	 */  
> One possibility for dealing with these and related issues — also things
>  like the proper way to free an xdp_buff if SKB creation fails, which
>  might not be page_frag_free() for some drivers with unusual recycle ring
>  implementations — is to have a new ndo for 'receiving' an xdp_pkt from a
>  cpumap redirect.
> Since you're always receiving from the same driver that enqueued it, even
>  the structure of the metadata stored in the top of the packet page
>  doesn't have to be standardised; instead, each driver can put there just
>  whatever happens to be needed for its ndo_xdp_rx routine.  (Though there
>  would probably be standard enqueue and dequeue functions that the
>  'common-case' drivers could use.)
> In some cases, the driver could even just leave in the page the packet
>  prefix it got from the NIC, rather than reading it and then writing an
>  interpreted version back, thus minimising the number of packet-page
>  cachelines the 'bottom half' RX function has to touch (it would still
>  need to write in anything it got from the RX event, of course).
> It shouldn't be much work as many driver RX routines are already
>  structured this way — sfc, for instance, has a split into efx_rx_packet()
>  and __efx_rx_packet(), as a software pipeline for prefetching.

This is all talking about future work.  I'll be happy to discuss this
outside/after this patchset.  I see nothing blocking these ideas.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
