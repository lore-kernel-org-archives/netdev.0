From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 0/7] net: bulk alloc side and more bulk free
 drivers
Date: Fri, 4 Mar 2016 20:15:12 +0100
Message-ID: <20160304201512.6f66a3cd@redhat.com>
References: <20160304130054.32651.51776.stgit@firesoul>
	<20160304163641.GA52086@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	saeedm@mellanox.com, gerlitz.or@gmail.com, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755567AbcCDTPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 14:15:18 -0500
In-Reply-To: <20160304163641.GA52086@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Mar 2016 08:36:44 -0800
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Fri, Mar 04, 2016 at 02:01:14PM +0100, Jesper Dangaard Brouer wrote:
> > This patchset use the bulk ALLOC side of the kmem_cache bulk APIs, for
> > SKB allocations.  The bulk free side got enabled in merge commit
> > 3134b9f019f2 ("net: mitigating kmem_cache free slowpath").
> > 
> > The first two patches is a followup on the free-side, which enables
> > bulk-free in the drivers mlx4 and mlx5 (dev_kfree_skb -> napi_consume_skb).
> > 
> > Rest of patchset is focused on bulk alloc-side.  We start with a
> > conservative bulk alloc of 8 SKB, which all drivers using the
> > napi_alloc_skb() call will benefit from.  Then the API is extended to,
> > allow driver hinting on needed SKBs (only some drivers know this
> > size), and mlx5 driver is the first user of hinting.  
> 
> patches 1-5 look very good to me. Should help all cases afaik.
> As far as 6-7 about hints I have a question. Does this hint
> actually makes the difference? The fixed bulk alloc of 8 probably
> easier for the main slub, but when mlx5 starts doing 'work_done' as
> a hint there will be more 'random' bulking going on.
> Was wondering whether you have the perf numbers to back up 6/7

Yes, it makes a difference.  I did some performance numbers with
dropping in the mlx5 driver, plus the RX loop cache-miss avoidance.
With all my optimizations I reached 12Mpps, with this hint optimization
I could reach 13Mpps.  It sounds nice also percentage wise (8.3%), but
in nanosec this optimization "only" corresponds to 6.4 ns.  For real
workloads, we might see a higher "nanosec" improvement, as this invoke
kmem_cache_alloc_bulk() less times resulting in less icache-misses.
So, yes it makes a difference.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
