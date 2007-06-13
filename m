From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] Re: [2.6.21.1] soft lockup when removing netconsole module
Date: Wed, 13 Jun 2007 11:25:37 +0200
Message-ID: <20070613092537.GA2432@ff.dom.local>
References: <20070526154011.GB3735@vanheusden.com> <20070529005628.f7f3abc6.akpm@linux-foundation.org> <20070612110233.GA3281@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Folkert van Heusden <folkert@vanheusden.com>,
	linux-kernel@vger.kernel.org,
	Jason Wessel <jason.wessel@windriver.com>,
	Thomas Gleixner <tglx@linutronix.de>, stable@kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:33841 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754088AbXFMJR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 05:17:59 -0400
Content-Disposition: inline
In-Reply-To: <20070612110233.GA3281@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 01:02:33PM +0200, Jarek Poplawski wrote:
...
> Of course such a problem should preferably be fixed by somebody who
> knows the code (alas I don't know netconsole), to be sure all needed
> cancels are still done after this change. I hope Jason's patch is
> right but I'm a little surprised I can't see netdev in cc (I'll try
> to fix this).

So, I've had a look into netpoll and, unfortunately, I don't
think this patch is right... 

> > From: Jason Wessel <jason.wessel@windriver.com>
> > 
> > Do not call cancel_rearming_delayed_work() if there is no
> > pending work.
> > 
> > Signed-off-by: Jason Wessel <jason.wessel@windriver.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  net/core/netpoll.c |    6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff -puN net/core/netpoll.c~a net/core/netpoll.c
> > --- a/net/core/netpoll.c~a
> > +++ a/net/core/netpoll.c
> > @@ -784,8 +784,10 @@ void netpoll_cleanup(struct netpoll *np)
> >  			if (atomic_dec_and_test(&npinfo->refcnt)) {
> >  				skb_queue_purge(&npinfo->arp_tx);
> >  				skb_queue_purge(&npinfo->txq);
> > -				cancel_rearming_delayed_work(&npinfo->tx_work);
> > -				flush_scheduled_work();
> > +				if (delayed_work_pending(&npinfo->tx_work)) {
> > +					cancel_rearming_delayed_work(&npinfo->tx_work);
> > +					flush_scheduled_work();
> > +				}
> >  
> >  				kfree(npinfo);
> >  			}
> > _

There are such possibilities:

1. After positive delayed_work_pending(&npinfo->tx_work) test
some work is queued, but there is no guarantee that when running
it'll rearm again, so cancel_rearming_delayed_work can loop again;

2. After negative delayed_work_pending(&npinfo->tx_work) test
a work is just running, eg. waiting on netif_tx_lock, while
kfree(npinfo) is done here (oops?!).

I've found an additional problem here with or without this patch:
after deleting a timer in cancel_rearming_delayed_work() there could
stay a last skb queued in npinfo->txq, and after kfree(npinfo)
we have small memory leak. If I'm right here similar fix is needed
in the current netpoll code: additional npinfo->txq purging only
or maybe the whole cancel_rearming_ changed like this.

I've tried to eliminate these problems in attached below patch
proposal. I'm not sure it's all right: as I've written earlier I
don't know netconsole enough, but it's probably a little better
than above solution.

I've some doubts yet (I didn't have time to check this all):

1. I hope this other schedule_delayed_work() from netpoll_send_skb()
is not possible when netpoll_cleanup() runs - if I'm wrong additional
check of npinfo->refcnt should be done there;
2. I also hope npinfo->refcnt before scheduling should be enough here
- if not - another possibility is adding some locking eg.:
netif_tx_lock before cancel for synchronization.

Of course it would be very nice if somebody could test or verify
this patch more.

Regards,
Jarek P.


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.21-/net/core/netpoll.c 2.6.21/net/core/netpoll.c
--- 2.6.21-/net/core/netpoll.c	2007-04-26 15:08:32.000000000 +0200
+++ 2.6.21/net/core/netpoll.c	2007-06-12 21:05:23.000000000 +0200
@@ -73,7 +73,8 @@ static void queue_process(struct work_st
 			netif_tx_unlock(dev);
 			local_irq_restore(flags);
 
-			schedule_delayed_work(&npinfo->tx_work, HZ/10);
+			if (atomic_read(&npinfo->refcnt))
+				schedule_delayed_work(&npinfo->tx_work, HZ/10);
 			return;
 		}
 		netif_tx_unlock(dev);
@@ -780,9 +781,15 @@ void netpoll_cleanup(struct netpoll *np)
 			if (atomic_dec_and_test(&npinfo->refcnt)) {
 				skb_queue_purge(&npinfo->arp_tx);
 				skb_queue_purge(&npinfo->txq);
-				cancel_rearming_delayed_work(&npinfo->tx_work);
+				cancel_delayed_work(&npinfo->tx_work);
 				flush_scheduled_work();
 
+				/* clean after last, unfinished work */
+				if (!skb_queue_empty(&npinfo->txq)) {
+					struct sk_buff *skb;
+					skb = __skb_dequeue(&npinfo->txq);
+					kfree_skb(skb);
+				}
 				kfree(npinfo);
 			}
 		}
