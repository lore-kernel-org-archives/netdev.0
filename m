From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: igb driver can cause cache invalidation of non-owned memory?
Date: Mon, 10 Oct 2016 11:52:06 +0300
Message-ID: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Chris Healy <cphealy@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi


DMA mapping scheme introduced in commit cbc8e55f6fda ('igb: Map entire
page and sync half instead of mapping and unmapping half pages') back in
2012, and used up to now, can probably cause breakage of unrelated code
on archs with non-coherent caches.

With this scheme, page used for Rx is completely dma_map()ed at
allocation time, split into two buffers, and individual buffer is
sync_to_cpu()ed AND PASSED TO NETWORK STACK via skb_add_rx_frag() -
while driver driver still uses other buffer. Later, when driver decides
to no longer use this page, it will dma_unmap() it completely - which on
archs with non-coherent caches means cache invalidation. This cache
invalidation will include area that is already passed elsewhere. If
external code has performed any writes to that area and writes still are
in cache only, cache invalidation will cause writes to be lost.


I'm not sure if this breakage is indeed possible. I did not face it,
just found while checking how things work.

Code in question is in kernel already for 4 years. However, since (1)
igb is mostly used on x86 where caches are coherent, and (2) Rx buffers
are normally not written to, it could stay unnoticed all that time.

Could somebody please comment on this?


Nikita Yushchenko
