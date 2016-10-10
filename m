From: David Miller <davem@davemloft.net>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Mon, 10 Oct 2016 05:01:25 -0400 (EDT)
Message-ID: <20161010.050125.1981283393312167625.davem@davemloft.net>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        cphealy@gmail.com
To: nikita.yoush@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Mon, 10 Oct 2016 11:52:06 +0300

> With this scheme, page used for Rx is completely dma_map()ed at
> allocation time, split into two buffers, and individual buffer is
> sync_to_cpu()ed AND PASSED TO NETWORK STACK via skb_add_rx_frag() -
> while driver driver still uses other buffer. Later, when driver decides
> to no longer use this page, it will dma_unmap() it completely - which on
> archs with non-coherent caches means cache invalidation. This cache
> invalidation will include area that is already passed elsewhere.

This should happen only if the device wrote into that piece of the
memory which it absolutely should not.

When the dma sync occurs, no dirty data should be in the caches for
the portion of the page any more, and therefore nothing should be
written back unless the device illegally wrote to that part of the
page again.

If something is causing data to be written back even if the device
doesn't write into that area again, it's a bug.

And FWIW the swiommu code has this bug.  It should never (re-)copy
back into the mapped area after a sync unless the device wrote into
that area in the time between the sync and the unmap.
