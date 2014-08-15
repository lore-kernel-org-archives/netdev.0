From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Fri, 15 Aug 2014 13:37:10 +0200
Message-ID: <1408102630.8789.6.camel@localhost>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
	 <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408064641.867439.152913861.09367C24@webmail.messagingengine.com>
	 <F5AD4339-AD85-4023-9FAF-543E99661D75@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:54692 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750743AbaHOLhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 07:37:13 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway1.nyi.internal (Postfix) with ESMTP id A8E412CB3B
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 07:37:12 -0400 (EDT)
In-Reply-To: <F5AD4339-AD85-4023-9FAF-543E99661D75@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Do, 2014-08-14 at 21:54 -0700, Guy Harris wrote:
> On Aug 14, 2014, at 6:04 PM, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> > On Fri, Aug 15, 2014, at 02:54, Eric Dumazet wrote:
> >> On Fri, 2014-08-15 at 02:43 +0200, Hannes Frederic Sowa wrote:
> >> 
> >>> Someone could use GRO to create packet trains to hide from intrustion
> >>> detection systems, which maybe are the main user of TPACKET_V3. I don't
> >>> think this is a good idea.
> >> 
> >> Presumably these tools already use a large enough bloc_size, and not a
> >> 4KB one ;)
> >> 
> >> Even without GRO, a jumbo frame (9K) can trigger the bug.
> > 
> > Sure, but if I would have written such a tool without knowledge of GRO I
> > would have queried at least the MTU. ;)
> 
> ...and then queried the maximum size of the headers that precede the link-layer payload.

But those are mostly constant, no?

> Except that you *can't* do that, and it can be variable-length without an obvious maximum (think 802.11 in monitor mode, where you have radiotap headers).  This causes much pain for libpcap when using TPACKET_V1 and TPACKET_V2, forcing it to allocate huge blocks when smaller ones might be sufficient.
> > If an IDS allocates block_sizes below the MTU there is not much we can
> > do.
> 
> If an IDS uses libpcap, it will get libpcap's behavior, which, for TPACKET_V3 is, roughly
> 
> 	req.tp_frame_size = MAXIMUM_SNAPLEN;
> 	req.tp_frame_nr = handle->opt.buffer_size/req.tp_frame_size;
> 
> 	/* compute the minumum block size that will handle this frame. 
> 	 * The block has to be page size aligned. 
> 	 * The max block size allowed by the kernel is arch-dependent and 
> 	 * it's not explicitly checked here. */
> 	req.tp_block_size = getpagesize();
> 	while (req.tp_block_size < req.tp_frame_size) 
> 		req.tp_block_size <<= 1;
> 
> 	frames_per_block = req.tp_block_size/req.tp_frame_size;
> 
> 	req.tp_block_nr = req.tp_frame_nr / frames_per_block;
> 
> 	/* req.tp_frame_nr is requested to match frames_per_block*req.tp_block_nr */
> 	req.tp_frame_nr = req.tp_block_nr * frames_per_block;
> 
> (the last two C statements are actually part of a loop, where it'll reduce req.tp_frame_nr if it gets told "I don't have enough room for that big a ring").
> 
> MAXIMUM_SNAPLEN is 65535 in older versions of libpcap and 262144 in newer versions; it's the maximum frame size.
> 
> handle->opt.buffer_size is the buffer size requested by the application; it defaults to 2 MiB.
> 
> That calculation, with the default values for the latest version of libpcap, ends up with:
> 
> 	req.tp_frame_size = 262144;
> 	req.tp_frame_nr = /* 2097152/262144 */ 8;
> 
> 	/* compute the minumum block size that will handle this frame. 
> 	 * The block has to be page size aligned. 
> 	 * The max block size allowed by the kernel is arch-dependent and 
> 	 * it's not explicitly checked here. */
> 	req.tp_block_size = 4096;	/* IA-32 and x86-64, and probably many others */
> 	while (req.tp_block_size < req.tp_frame_size) 
> 		req.tp_block_size <<= 1;
> 	/* ends up with req.tp_block_size = 262144 */
> 
> 	frames_per_block = /* 262144/262144 */ 1;
> 
> 	req.tp_block_nr = /* 8 / 1 */ 8;
> 
> 	/* req.tp_frame_nr is requested to match frames_per_block*req.tp_block_nr */
> 	req.tp_frame_nr = /* 8 * 1 / 8;
> 
> which I think means "8 256 KiB blocks".
> 
> > But up to the MTU we should let GRO behave transparently and here we
> > violate this. There are also interfaces which extremely large MTUs but
> > at least they report the MTU size correctly to user space.
> 
> Reporting the MTU to user space is insufficient for libpcap; it needs to know the *maximum packet size*, which includes link-layer headers (which I guess it could compute based on the ARPHRD_ for the interface, although for 802.11 that may be subject to change, e.g. the maximum link-layer header length grew when the QoS stuff was added) *and* metadata headers (such as radiotap, for which there really is no generic maximum length other than the 65535 byte limit imposed by the header length field being 16 bits, but a given driver can presumably return its maximum).
> 
> It also doesn't help with segmentation/reassembly offloading, where the MTU is decoupled from the maximum packet size.

Thanks, that answered the question above. Still, I think that the most
commonly use-cases would get covered by querying the MTU. libpcap needs
to be much more general and so must pay more attention.

Also, IMHO GRO is something special and does not fit that model very
well. But I am also fine with clamping. If people complain, we can
revisit that topic.

Thanks,
Hannes
