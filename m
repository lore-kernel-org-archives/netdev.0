From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Thu, 07 Apr 2016 08:18:29 -0700
Message-ID: <1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	lsf-pc@lists.linux-foundation.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35128 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756157AbcDGPSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 11:18:32 -0400
Received: by mail-pa0-f42.google.com with SMTP id td3so56703608pab.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 08:18:31 -0700 (PDT)
In-Reply-To: <20160407161715.52635cac@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-07 at 16:17 +0200, Jesper Dangaard Brouer wrote:
> (Topic proposal for MM-summit)
>=20
> Network Interface Cards (NIC) drivers, and increasing speeds stress
> the page-allocator (and DMA APIs).  A number of driver specific
> open-coded approaches exists that work-around these bottlenecks in th=
e
> page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
> allocating larger pages and handing-out page "fragments".
>=20
> I'm proposing a generic page-pool recycle facility, that can cover th=
e
> driver use-cases, increase performance and open up for zero-copy RX.
>=20
>=20
> The basic performance problem is that pages (containing packets at RX=
)
> are cycled through the page allocator (freed at TX DMA completion
> time).  While a system in a steady state, could avoid calling the pag=
e
> allocator, when having a pool of pages equal to the size of the RX
> ring plus the number of outstanding frames in the TX ring (waiting fo=
r
> DMA completion).


We certainly used this at Google for quite a while.

The thing is : in steady state, the number of pages being 'in tx queues=
'
is lower than number of pages that were allocated for RX queues.

The page allocator is hardly hit, once you have big enough RX ring
buffers. (Nothing fancy, simply the default number of slots)

The 'hard coded=C2=B4 code is quite small actually

if (page_count(page) !=3D 1) {
    free the page and allocate another one,=20
    since we are not the exclusive owner.
    Prefer __GFP_COLD pages btw.
}
page_ref_inc(page);

Problem of a 'pool' is that it matches a router workload, not host one.

With existing code, new pages are automatically allocated on demand, if
say previous pages are still used by skb stored in sockets receive
queues and consumers are slow to react to the presence of this data.

But in most cases (steady state), the refcount on the page is released
by the application reading the data before the driver cycled through th=
e
RX ring buffer and drivers only increments the page count.

I also played with grouping pages into the same 2MB pages, but got mixe=
d
results.
