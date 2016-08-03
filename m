From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Date: Wed, 3 Aug 2016 10:45:13 -0700
Message-ID: <20160803174107.GA38399@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
 <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33255 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbcHCRqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 13:46:19 -0400
Received: by mail-pf0-f193.google.com with SMTP id i6so15043647pfe.0
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 10:46:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2016 at 09:35:20AM +0200, Eric Dumazet wrote:
> On Tue, 2016-07-19 at 12:16 -0700, Brenden Blanco wrote:
> > The mlx4 driver by default allocates order-3 pages for the ring to
> > consume in multiple fragments. When the device has an xdp program, this
> > behavior will prevent tx actions since the page must be re-mapped in
> > TODEVICE mode, which cannot be done if the page is still shared.
> > 
> > Start by making the allocator configurable based on whether xdp is
> > running, such that order-0 pages are always used and never shared.
> > 
> > Since this will stress the page allocator, add a simple page cache to
> > each rx ring. Pages in the cache are left dma-mapped, and in drop-only
> > stress tests the page allocator is eliminated from the perf report.
> > 
> > Note that setting an xdp program will now require the rings to be
> > reconfigured.
> 
> Again, this has nothing to do with XDP ?
> 
> Please submit a separate patch, switching this driver to order-0
> allocations.
> 
> I mentioned this order-3 vs order-0 issue earlier [1], and proposed to
> send a generic patch, but had been traveling lately, and currently in
> vacation.
> 
> order-3 pages are problematic when dealing with hostile traffic anyway,
> so we should exclusively use order-0 pages, and page recycling like
> Intel drivers.
> 
> http://lists.openwall.net/netdev/2016/04/11/88

Completely agree. These multi-page tricks work only for benchmarks and
not for production.
Eric,
if you can submit that patch for mlx4 that would be awesome.

I think we should default to order-0 for both mlx4 and mlx5.
Alternatively we're thinking to do a netlink or ethtool switch to
preserve old behavior, but frankly I don't see who needs this order-N
allocation schemes.
