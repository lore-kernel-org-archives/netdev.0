From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH RFC] mlx4: RX prefetch loop
Date: Tue, 12 Jul 2016 09:46:26 -0700
Message-ID: <CAKgT0Ud8wrz8jRe5JzaiycZmO3fxNhPudRiv7up4ZWFfYWfj4A@mail.gmail.com>
References: <20160708172024.4a849b7a@redhat.com> <20160708160135.27507.77711.stgit@firesoul>
 <20160711130922.636ee4e6@redhat.com> <20160711230509.GA45195@ast-mbp.thefacebook.com>
 <20160712144521.4244e8ab@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Netdev <netdev@vger.kernel.org>, kafai@fb.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	john fastabend <john.fastabend@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	rana.shahot@gmail.com, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>, as754m@att.com,
	Saeed Mahameed <saeedm@mellanox.com>, amira@mellanox.com,
	tzahio@mellanox.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:35224 "EHLO
	mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049AbcGLQq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 12:46:28 -0400
Received: by mail-it0-f50.google.com with SMTP id u186so92245750ita.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 09:46:28 -0700 (PDT)
In-Reply-To: <20160712144521.4244e8ab@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 5:45 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Mon, 11 Jul 2016 16:05:11 -0700
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>
>> On Mon, Jul 11, 2016 at 01:09:22PM +0200, Jesper Dangaard Brouer wrote:
>> > > - /* Process all completed CQEs */
>> > > + /* Extract and prefetch completed CQEs */
>> > >   while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
>> > >               cq->mcq.cons_index & cq->size)) {
>> > > +         void *data;
>> > >
>> > >           frags = ring->rx_info + (index << priv->log_rx_info);
>> > >           rx_desc = ring->buf + (index << ring->log_stride);
>> > > +         prefetch(rx_desc);
>> > >
>> > >           /*
>> > >            * make sure we read the CQE after we read the ownership bit
>> > >            */
>> > >           dma_rmb();
>> > >
>> > > +         cqe_array[cqe_idx++] = cqe;
>> > > +
>> > > +         /* Base error handling here, free handled in next loop */
>> > > +         if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
>> > > +                      MLX4_CQE_OPCODE_ERROR))
>> > > +                 goto skip;
>> > > +
>> > > +         data = page_address(frags[0].page) + frags[0].page_offset;
>> > > +         prefetch(data);
>>
>> that's probably not correct in all cases, since doing prefetch on the address
>> that is going to be evicted soon may hurt performance.
>> We need to dma_sync_single_for_cpu() before doing a prefetch or
>> somehow figure out that dma_sync is a nop, so we can omit it altogether
>> and do whatever prefetches we like.
>
> Sure, DMA can be synced first (actually already played with this).

Yes, but the point I think that Alexei is kind of indirectly getting
at is that you are doing all your tests on x86 architecture are you
not?  The x86 stuff is a very different beast from architectures like
ARM which have a very different architecture when it comes to how they
handle the memory organization of the system.  In the case of x86 the
only time dma_sync is not a nop is if you force swiotlb to be enabled
at which point the whole performance argument is kind of pointless
anyway.

>> Also unconditionally doing batch of 8 may also hurt depending on what
>> is happening either with the stack, bpf afterwards or even cpu version.
>
> See this as software DDIO, if the unlikely case that data will get
> evicted, it will still exist in L2 or L3 cache (like DDIO). Notice,
> only 1024 bytes are getting prefetched here.

I disagree.  DDIO only pushes received frames into the L3 cache.  What
you are potentially doing is flooding the L2 cache.  The difference in
size between the L3 and L2 caches is very significant.  L3 cache size
is in the MB range while the L2 cache is only 256KB or so for Xeon
processors and such.  In addition DDIO is really meant for an
architecture that has a fairly large cache region to spare and it it
limits itself to that cache region, the approach taken in this code
could potentially prefetch a fairly significant chunk of memory.

>> Doing single prefetch of Nth packet is probably ok most of the time,
>> but asking cpu to prefetch 8 packets at once is unnecessary especially
>> since single prefetch gives the same performance.
>
> No, unconditionally prefetch of the Nth packet, will be wrong most of
> the time, for real work loads, as Eric Dumazet already pointed out.
>
> This patch does NOT unconditionally prefetch 8 packets.  Prefetching
> _only_ happens when it is known that packets are ready in the RX ring.
> We know this prefetch data will be used/touched, within the NAPI cycle.
> Even if the processing of the packet flush L1 cache, then it will be in
> L2 or L3 (like DDIO).

I think the point you are missing here Jesper is that the packet isn't
what will be flushed out of L1.  It will be all the data that had been
fetched before that.  So for example the L1 cache can only hold 32K,
and the way it is setup if you fetch the first 64 bytes of 8 pages you
will have evicted everything that was in that cache set will be
flushed out to L2.

Also it might be worth while to see what instruction is being used for
the prefetch.  Last I knew for read prefetches it was prefetchnta on
x86 which would only pull the data into the L1 cache as a
"non-temporal" store.  If I am not mistaken I think you run the risk
of having the data prefetched evicted back out and bypassing the L2
and L3 caches unless it is modified.  That was kind of the point of
the prefetchnta as it really meant to be a read-only prefetch and
meant to avoid polluting the L2 and L3 caches.

- Alex
