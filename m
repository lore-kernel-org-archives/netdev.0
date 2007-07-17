From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Tue, 17 Jul 2007 14:04:36 +0200
Message-ID: <20070717120436.GC2049@ff.dom.local>
References: <20070712104641.GB1708@ff.dom.local> <1184240842.3477.110.camel@ranko-fc2.spidernet.net> <46961970.7080209@trash.net> <1184262525.3477.135.camel@ranko-fc2.spidernet.net> <20070713121733.GB3282@ff.dom.local> <1184329602.16732.16.camel@ranko-fc2.spidernet.net> <20070713134231.GC3282@ff.dom.local> <20070716070032.GA1871@ff.dom.local> <469B6CA4.9030205@trash.net> <1184607905.18564.50.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ranko Zivojnovic <ranko@spidernet.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:48952 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754814AbXGQLzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 07:55:42 -0400
Content-Disposition: inline
In-Reply-To: <1184607905.18564.50.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2007 at 08:45:05PM +0300, Ranko Zivojnovic wrote:
...
> [NET] gen_estimator deadlock fix
> 
> -Fixes ABBA deadlock noted by Patrick McHardy <kaber@trash.net>:
> 
> > There is at least one ABBA deadlock, est_timer() does:
> > read_lock(&est_lock)
> > spin_lock(e->stats_lock) (which is dev->queue_lock)
> >
> > and qdisc_destroy calls htb_destroy under dev->queue_lock, which
> > calls htb_destroy_class, then gen_kill_estimator and this
> > write_locks est_lock.
> 
> To fix the ABBA deadlock the rate estimators are now kept on an rcu list.
> 
> -The est_lock changes the use from protecting the list to protecting
> the update to the 'bstat' pointer in order to avoid NULL dereferencing.

This patch looks fine, but while checking for this lock I've found
another strange thing: for actions tcfc_stats_lock is used here, which
is equivalent to tcfc_lock; so, in gen_kill_estimator we get this lock
sometimes after dev->queue_lock; this order is also possible during
tc_classify if actions are used; on the other hand act_mirred calls
dev_queue_xmit under this lock, so dev->queue_lock is taken in another
order. I hope it's with different devs, and there is no real deadlock
possible, but this all is a bit queer...

I don't know actions enough, but it seems, if it's possible that they
are always run only from tc_classify, with dev->queue_lock, maybe it
would be simpler to use this lock for actions' stats with
gen_estimator too. And if gen_kill_estimator is sometimes run with
dev->queue_lock, maybe doing this always would make this locking
really understandable and less prone for such inversions (plus
est_lock could be forgotten)?

Regards,
Jarek P.
