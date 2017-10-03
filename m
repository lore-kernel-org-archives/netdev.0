From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V3 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion
 and allocation
Date: Tue, 3 Oct 2017 08:58:43 +0200
Message-ID: <20171003085843.14d3491e@redhat.com>
References: <150696027949.24152.7507025809123255386.stgit@firesoul>
        <150696032966.24152.3096148163967111058.stgit@firesoul>
        <20171003010245.f3op4t56crbjc4ke@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47442 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750820AbdJCG64 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 02:58:56 -0400
In-Reply-To: <20171003010245.f3op4t56crbjc4ke@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Oct 2017 18:02:46 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Mon, Oct 02, 2017 at 06:05:29PM +0200, Jesper Dangaard Brouer wrote:
> > +		while ((xdp_pkt = __ptr_ring_consume(rcpu->queue))) {
> > +			struct sk_buff *skb;
> > +			int ret;
> > +
> > +			/* Allow busy polling again */
> > +			empty_cnt = 0;
> > +
> > +			skb = cpu_map_build_skb(rcpu, xdp_pkt);
> > +			if (!skb) {
> > +				page_frag_free(xdp_pkt);
> > +				continue;
> > +			}
> > +
> > +			/* Inject into network stack */
> > +			ret = netif_receive_skb(skb);
> > +			if (ret == NET_RX_DROP)
> > +				drops++;  
> 
> I thought the whole thing is an alternative to RPS,
> but netif_receive_skb_internal() will call into RPS logic.
> So the user has to make sure it disabled or they will
> conflict in some weird way?

In this patchset, cpumap and RPS are independent, and there is nothing
wrong with running RPS after cpumap have placed the SKB on a CPU.
Combining the two does seem a little weird.  Especially since cpumap
doesn't (yet) transfer the HW-rxhash, thus extra SW-rxhash work will be
done by RPS.

I like you ABI argument.  While combining RPS+cpumap is technically
possible, there isn't a good use-case for this.  Thus, we should not
open this possibility, as we would need to support this combination
forever.

> Or you're calling netif_receive_skb() to be able to call
> generic XDP on that cpu again ?

That should not (currently) be possible. AFAIK we (Daniel) choose to
not allow Native and Generic XDP to be loaded on the same net_device.
(With the same ABI argument as here)


> But that prog can do cpumap redirect again?
> sort-of recursive redirect? Is it really useful?
> May be call into __netif_receive_skb_core() directly?
> not sure.

I like the idea of calling  __netif_receive_skb_core() directly.  I'll
send a V4 (after running my different benchmarks).

> I'm asking all these questions to make sure we think through
> these implications before it becomes an abi.

I fully follow your ABI argument. Thank you for bringing this up!


Do notice, that I expect to change this code path (later), to support
GRO. But it would be beneficial to get the HW-rxhash working first, as
it will speedup the GRO "same_flow" check, and allow cpumap to
distribute packets better.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
