From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ieee802154: sparse warnings: make symbols
 static
Date: Wed, 04 Jul 2012 15:45:27 +0200
Message-ID: <1341409527.2583.1986.camel@edumazet-glaptop>
References: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341209912-6030-2-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1341211072.5269.0.camel@edumazet-glaptop>
	 <1341211476.5269.2.camel@edumazet-glaptop>
	 <1341211751.5269.6.camel@edumazet-glaptop>
	 <CAJmB2rAdDvpGhEDzBQddJBi5fJ55McN8uJEzLQiF_froR4hxVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dbaryshkov@gmail.com
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58022 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987Ab2GDNpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 09:45:32 -0400
Received: by eaak11 with SMTP id k11so2911119eaa.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 06:45:31 -0700 (PDT)
In-Reply-To: <CAJmB2rAdDvpGhEDzBQddJBi5fJ55McN8uJEzLQiF_froR4hxVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-04 at 17:38 +0400, Alexander Smirnov wrote:

> Do I need to create 2 separate patches: one for revert and second to
> initialize spinlock correctly, or I can combine these changes in one
> patch?
> 

you can combine patch

> >
> > You should validate this code with LOCKDEP
> 
> Nothing was shown by LOCKDEP for 6lowpan. :-(
> 

Because path was not hit ( fragment expire )

You would have to simulate a drop or something to trigger the lockdep
splat, when lowpan_fragment_timer_expired() fires.

> I've selected the following options:
> 
> -*- Spinlock and rw-lock debugging: basic checks
> -*- Mutex debugging: basic checks
> -*- Lock debugging: detect incorrect freeing of live locks
> [*] Lock usage statistics
> [*] Lock dependency engine debugging
> 
> >
> > lowpan_dellink() does a spin_lock(&flist_lock);
> > while same lock can be taken by lowpan_fragment_timer_expired() from
> > timer irq, -> deadlock.
> 
> What would be the best way to solve this context mismatch? Can I do
> something like following:
> 1. create some 6lowpan internal workqueue
> 2. replace lowpan_fragment_timer_expired() body by queue_work() with
> current list_deleting routine
> 3. when 6lowpan is going to be deleted - I'll flush the queue and
> remove all the timers and respective fragments
> 

Just use the spin_lock_bh() variant to disable BH, so that timer doesnt
deadlock with you.
