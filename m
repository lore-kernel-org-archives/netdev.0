From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Thu, 17 Jul 2008 15:03:35 +0200
Message-ID: <487F4327.1000107@trash.net>
References: <20080717.051726.226040470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080717.051726.226040470.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> This allows less strict control of access to the qdisc attached to a
> netdev_queue.  It is even allowed to enqueue into a qdisc which is
> in the process of being destroyed.  The RCU handler will toss out
> those packets.
> 
> We will need this to handle sharing of a qdisc amongst multiple
> TX queues.  In such a setup the lock has to be shared, so will
> be inside of the qdisc itself.  At which point the netdev_queue
> lock cannot be used to hard synchronize access to the ->qdisc
> pointer.
> 
> One operation we have to keep inside of qdisc_destroy() is the list
> deletion.  It is the only piece of state visible after the RCU quiesce
> period, so we have to undo it early and under the appropriate locking.
> 
> The operations in the RCU handler do not need any looking because the
> qdisc tree is no longer visible to anything at that point.

Still working my way through the patches, but this one caught my
eye (we had this before and it caused quite a few problems).

One of the problems is that only the uppermost qdisc is destroyed
immediately, child qdiscs are still visible on qdisc_list and are
removed without any locking from the RCU callback. There are also
visibility issues for classifiers and actions deeper down in the
hierarchy.

The previous way to work around this was quite ugly. qdisc_destroy()
walked the entire hierarchy to unlink inner classes immediately
from the qdisc_list (commit 85670cc1f changed it to what we do now).
That fixed visibility issues for everything visible only through
qdiscs (child qdiscs and classifiers). Actions are also visible
globally, so this might still be a problem, not sure though since
they don't refer to their parent (haven't thought about it much yet).

Another problem we had earlier with this was that qdiscs previously
assumed changes (destruction) would only happen in process context
and thus didn't disable BHs when taking a read_lock for walking the
hierarchy (deadlocking with write_lock in BH context). This seems to
be handled correctly in your tree by always disabling BHs.

The remaining problem is data that was previously only used and
modified under the RTNL (u32_list is one example). Modifications
during destruction now need protection against concurrent use in
process context.

I still need to get a better understanding of how things work now,
so I won't suggest a fix until then :)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
