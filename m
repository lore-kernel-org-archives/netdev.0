From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Tue, 26 Sep 2017 21:13:42 +0200
Message-ID: <20170926211342.0c8e72b0@redhat.com>
References: <cover.1506297988.git.daniel@iogearbox.net>
        <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46226 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935538AbdIZTNu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 15:13:50 -0400
In-Reply-To: <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Sep 2017 02:25:51 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> This work enables generic transfer of metadata from XDP into skb. The
> basic idea is that we can make use of the fact that the resulting skb
> must be linear and already comes with a larger headroom for supporting
> bpf_xdp_adjust_head(), which mangles xdp->data. Here, we base our work
> on a similar principle and introduce a small helper bpf_xdp_adjust_meta()
> for adjusting a new pointer called xdp->data_meta. Thus, the packet has
> a flexible and programmable room for meta data, followed by the actual
> packet data. struct xdp_buff is therefore laid out that we first point
> to data_hard_start, then data_meta directly prepended to data followed
> by data_end marking the end of packet. bpf_xdp_adjust_head() takes into
> account whether we have meta data already prepended and if so, memmove()s
> this along with the given offset provided there's enough room.
> 
> [...] The scratch space at the head
> of the packet can be multiple of 4 byte up to 32 byte large. Drivers not
> yet supporting xdp->data_meta can simply be set up with xdp->data_meta
> as xdp->data + 1 as bpf_xdp_adjust_meta() will detect this and bail out,
> such that the subsequent match against xdp->data for later access is
> guaranteed to fail.

So, xdp->meta_data is placed just before the packet xdp->data starts.

I'm currently implementing a cpumap type, that transfers raw XDP frames
to another CPU, and the SKB is allocated on the remote CPU.  (It
actually works extremely well).  

For transferring info I need, I'm currently using xdp->data_hard_start
(the top/start of the xdp page).  Which should be compatible with your
approach, right?

The info I need:

 struct xdp_pkt {
	void *data;
	u16 len;
	u16 headroom;
	struct net_device *dev_rx;
 };

When I enqueue the xdp packet I do the following:

 int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
	struct net_device *dev_rx)
 {
	struct xdp_pkt *xdp_pkt;
	int headroom;

	/* Convert xdp_buff to xdp_pkt */
	headroom = xdp->data - xdp->data_hard_start;
	if (headroom < sizeof(*xdp_pkt))
		return -EOVERFLOW;
	xdp_pkt = xdp->data_hard_start;
	xdp_pkt->data = xdp->data;
	xdp_pkt->len  = xdp->data_end - xdp->data;
	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);

	/* Info needed when constructing SKB on remote CPU */
	xdp_pkt->dev_rx = dev_rx;

	bq_enqueue(rcpu, xdp_pkt);
	return 0;
 }

On the remote CPU dequeueing the packet, I'm doing the following.  As
you can see I'm still lacking some meta-data, that would be nice to
also transfer.  Could I use your infrastructure for that?

 static struct sk_buff *cpu_map_build_skb(struct bpf_cpu_map_entry *rcpu,
					  struct xdp_pkt *xdp_pkt)
 {
	unsigned int truesize;
	void *pkt_data_start;
	struct sk_buff *skb;

	/* TODO: rcpu could provide truesize, it's static per RX-ring */
	truesize = 2048;

	// pkt_data_start = xdp_pkt + sizeof(*xdp_pkt);
	pkt_data_start = xdp_pkt->data - xdp_pkt->headroom;

	/* Need to adjust "truesize" for skb_shared_info to get proper
	 * placed, to take into account that xdp_pkt is using part of
	 * headroom
	 */
	skb = build_skb(pkt_data_start, truesize - sizeof(*xdp_pkt));
	if (!skb)
		return NULL;

	skb_reserve(skb, xdp_pkt->headroom);
	__skb_put(skb, xdp_pkt->len);

	// skb_record_rx_queue(skb, rx_ring->queue_index);
	skb->protocol = eth_type_trans(skb, xdp_pkt->dev_rx);

	// How much does csum matter? 
 //	skb->ip_summed = CHECKSUM_UNNECESSARY; // Try to fake it...

	// Does setting skb_set_hash()) matter?
 //	__skb_set_hash(skb, 42, true, false); // Say it is software
 //	__skb_set_hash(skb, 42, false, true); // Say it is hardware

	// Do we lack setting rx_queue... it doesn't seem to matter
 //	skb_record_rx_queue(skb, 0);

	return skb;
 }

(I'll send out some patches soonish, hopefully tomorrow... to show in
more details what I'm doing)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
