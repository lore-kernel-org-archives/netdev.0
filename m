From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Mon, 23 Jul 2012 17:59:44 +0200
Message-ID: <1343059184.2626.11027.camel@edumazet-glaptop>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	 <1343020585.2626.10054.camel@edumazet-glaptop>
	 <CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42341 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304Ab2GWP7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 11:59:49 -0400
Received: by bkwj10 with SMTP id j10so5450953bkw.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 08:59:48 -0700 (PDT)
In-Reply-To: <CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-23 at 11:25 -0400, Kevin Groeneveld wrote:

> I am curious if you can elaborate on what is racy about the patch, I
> am still trying to learn.  I assumed (possibly incorrectly) that
> because I was using percpu variables that the stats updates didn't
> need any extra synchronization as any concurrent updates would be on
> different cpus.
> 

ppp paths (xmit versus receive) are reentrant.

Therefore several cpus might do the
u64_stats_update_begin(&stats->syncp) at the same moment : one increment
could be lost forever, making all readers looping forever in
u64_stats_fetch_begin_bh()

include/linux/u64_stats_sync.h

* 3) Write side must ensure mutual exclusion or one seqcount update could
 *    be lost, thus blocking readers forever.
 *    If this synchronization point is not a mutex, but a spinlock or
 *    spinlock_bh() or disable_bh() :


> > I really doubt ppp is performance sensitive, it so doesnt need percpu
> > counter.
> >
> > If you really want 64bits stats on ppp, use proper synchronization
> > around u64 counters (but shared ones)
> 
> I will work on an updated patch without the percpu variables.  I
> didn't really think about servers with many cpus and many ppp sessions
> when I created the patch, I was mainly thinking about my Linksys
> router and other simple clients.  Many of the other network drivers
> use percpu variables for their stats so I just followed along.

Because there is one loopback device only, not thousands ;)

> 
> Would proper synchronization in this case just be wrapping the updates
> in a spin_lock/spin_unlock?

Would be fine (if the proper BH safe variant is used), or you could also
use atomic64_t.
