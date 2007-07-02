From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] Re: [NETPOLL] netconsole: fix soft lockup when removing module
Date: Mon, 2 Jul 2007 09:52:26 +0200
Message-ID: <20070702075226.GB1639@ff.dom.local>
References: <20070701173558.GA207@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S\. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44791 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751895AbXGBHoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 03:44:06 -0400
Content-Disposition: inline
In-Reply-To: <20070701173558.GA207@tv-sign.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>From my recent patch:

> >    #1
> >    Until kernel ver. 2.6.21 (including) cancel_rearming_delayed_work()
> >    required a work function should always (unconditionally) rearm with
> >    delay > 0 - otherwise it would endlessly loop. This patch replaces
> >    this function with cancel_delayed_work(). Later kernel versions don't
> >    require this, so here it's only for uniformity.

But Oleg Nesterov <oleg@tv-sign.ru> found:

> But 2.6.22 doesn't need this change, why it was merged?
> 
> In fact, I suspect this change adds a race,
...

His description was right (thanks), so this patch reverts #1.

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.22-rc7-/net/core/netpoll.c 2.6.22-rc7/net/core/netpoll.c
--- 2.6.22-rc7-/net/core/netpoll.c	2007-07-02 09:03:27.000000000 +0200
+++ 2.6.22-rc7/net/core/netpoll.c	2007-07-02 09:32:34.000000000 +0200
@@ -72,8 +72,7 @@ static void queue_process(struct work_st
 			netif_tx_unlock(dev);
 			local_irq_restore(flags);
 
-			if (atomic_read(&npinfo->refcnt))
-				schedule_delayed_work(&npinfo->tx_work, HZ/10);
+			schedule_delayed_work(&npinfo->tx_work, HZ/10);
 			return;
 		}
 		netif_tx_unlock(dev);
@@ -786,7 +785,7 @@ void netpoll_cleanup(struct netpoll *np)
 			if (atomic_dec_and_test(&npinfo->refcnt)) {
 				skb_queue_purge(&npinfo->arp_tx);
 				skb_queue_purge(&npinfo->txq);
-				cancel_delayed_work(&npinfo->tx_work);
+				cancel_rearming_delayed_work(&npinfo->tx_work);
 				flush_scheduled_work();
 
 				/* clean after last, unfinished work */
