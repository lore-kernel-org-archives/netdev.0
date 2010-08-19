From: Zach Brown <zach.brown-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: ipoib neighbour free race?
Date: Thu, 19 Aug 2010 12:10:45 -0700
Message-ID: <20100819191045.GA5811@takashi.pdx.zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi gang,

We're chasing a bug that we can hit when we pull IB cables with
CONFIG_DEBUG_PAGE_ALLOC enabled.   It appears as though the to_ipoib_neigh() in
ipoib_neigh_free() under ipoib_mcast_free() is referencing a freed neighbour
struct.

The invariant here, as far as I can tell, is that cleanup_neigh is always
called as neighbours leave the hash.  We should never reference a freed
neighbour from the ipoib_neigh teardown path because ipoib_neigh_cleanup()
should free the ipoib_neigh before the neighbour drops its hash ref and can be
freed.

But I wonder if we can get a race during shutdown where ipoib_neigh_cleanup()
is called before the send path sees a neighbour and associates it with an
ipoib_neigh.  In that case we'd never get the neigh_cleanup() call to free the
ipoib_neigh before the neighbour.  Later teardown of the ipoib_neigh, say from
ipoib_mcast_free(), could try to clear the ipoib_neigh pointer in the freed
neighbour.

neigh_forced_gc() and neigh_periodic_work() are careful to only remove
neighbours from the table if their refcount is 1.  But neigh_flush_dev() can
remove neighbours, and call neigh_cleanup(), while others are referencing it.

My question, then, is whether or not neigh_flush_dev() race with the ipoib send
paths?  If so, it seems that we could hit this race.

It's been a long time (maybe a decade?!) since I worked with the networking
paths, so maybe I'm missing serialization that prevents this.

- z
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
