From: Roland Dreier <roland@topspin.com>
Subject: Re: LLTX and netif_stop_queue
Date: Sat, 18 Dec 2004 07:35:49 -0800
Message-ID: <528y7vobze.fsf@topspin.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041217214432.07b7b21e.davem@davemloft.net> (David S.
	Miller's message of "Fri, 17 Dec 2004 21:44:32 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    David> I understand the bug, but we're not going to fix it this
    David> way.  This is a crucial invariant that we need to check for
    David> because it indicates a pretty serious state error except in
    David> this bug case you've discovered.

OK, that's fair enough.  I was pretty bummed myself when I realized
hard_start_xmit was getting called even after I stopped the queue.
Thanks for confirming my analysis.

    David> Perhaps one way to fix this is to add a pointer to a
    David> spinlock to the netdev struct, and have hold that the upper
    David> level grab that when NETIF_F_LLTX when doing queue state
    David> checks.  Actually, that could end up being racy too.

I may be missing something, but it seems to me that we get all of the
benefits of LLTX by just documenting that device drivers can use the
xmit_lock member of struct net_device to synchronize other parts of
the driver against hard_start_xmit.  I guess the driver also should
set xmit_lock_owner to -1 after it acquires xmit_lock.

This would mean that NETIF_F_LLTX can go away, and LLTX drivers would
just replace their use of their own private tx_lock with xmit_lock
(except in hard_start_xmit, where the upper layer already holds xmit_lock).

By the way, am I correct in thinking that the use of xmit_lock_owner
in qdisc_restart() is racy?

    if (!spin_trylock(&dev->xmit_lock)) {
    /* get the lock */

                                            if (!spin_trylock(&dev->xmit_lock)) {
                                            /* fail */
                                                if (dev->xmit_lock_owner == smp_processor_id()) {
                                                /* test the wrong value */

    /* set the value too late */
    dev->xmit_lock_owner = smp_processor_id();

I don't see a simple way to fix this unfortunately.

Thanks,
  Roland
