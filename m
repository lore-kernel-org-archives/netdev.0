From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 0/4] net: mitigating kmem_cache slowpath for network stack
 in NAPI context
Date: Fri, 23 Oct 2015 14:46:01 +0200
Message-ID: <20151023124451.17364.14594.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115AbbJWMqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 08:46:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It have been a long road. Back in July 2014 I realized that network
stack were hitting the kmem_cache/SLUB slowpath when freeing SKBs, but
had no solution.  In Dec 2014 I had implemented a solution called
qmempool[1], that showed it was possible to improve this, but got
rejected due to being a cache on top of kmem_cache.  In July 2015
improvements to kmem_cache were proposed, and recently Oct 2015 my
kmem_cache (SLAB+SLUB) patches for bulk alloc and free have been
accepted into the AKPM quilt tree.

This patchset is the first real use-case kmem_cache bulk alloc and free.
And is joint work with Alexander Duyck while still at Red Hat.

Using bulk free to avoid the SLUB slowpath shows the full potential.
In this patchset it is realized in NAPI/softirq context.  1. During
DMA TX completion bulk free is optimal and does not introduce any
added latency. 2. bulk free of SKBs delay free'ed due to IRQ context
in net_tx_action softirq completion queue.

Using bulk alloc is showing minor improvements for SLUB(+0.9%), but a
very slight slowdown for SLAB(-0.1%).

[1] http://thread.gmane.org/gmane.linux.network/342347/focus=126138


This patchset is based on net-next (commit 26440c835), BUT I've
applied several patches from AKPMs MM-tree.

Cherrypick some commits from MMOTM tree on branch/tag mmotm-2015-10-06-16-30
from git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
(Below commit IDs are obviously not stable)

Pickup my own MM-changes:
 b0aa3e95ce82 ("slub: mark the dangling ifdef #else of CONFIG_SLUB_DEBUG")
 114a2b37847c ("slab: implement bulking for SLAB allocator")
 606397476e8b ("slub: support for bulk free with SLUB freelists")
 ee29cd6a570c ("slub: optimize bulk slowpath free by detached freelist")
 491c6e0ca89d ("slub-optimize-bulk-slowpath-free-by-detached-freelist-fix")

Pickup slab.h changes:
 d9a47e0b776b ("compiler.h: add support for function attribute assume_aligned")
 1c3a5c789b4f ("slab.h: sprinkle __assume_aligned attributes")

Wanted Kirill A. Shutemov's changes as they change virt_to_head_page(),
had to apply patches manually from http://ozlabs.org/~akpm/mmotm/
(stamp-2015-10-20-16-33) as AKPM made several small fixes.

---

Jesper Dangaard Brouer (4):
      net: bulk free infrastructure for NAPI context, use napi_consume_skb
      net: bulk free SKBs that were delay free'ed due to IRQ context
      ixgbe: bulk free SKBs during TX completion cleanup cycle
      net: bulk alloc and reuse of SKBs in NAPI context


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +
 include/linux/skbuff.h                        |    4 +
 net/core/dev.c                                |    9 ++
 net/core/skbuff.c                             |  122 +++++++++++++++++++++++--
 4 files changed, 127 insertions(+), 14 deletions(-)

--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
