From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Tue, 26 Mar 2013 19:44:33 +0100
Message-ID: <20130326184433.GA2494@netboy.at.omicron.at>
References: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
 <20130321.172017.1499060411785395307.davem@davemloft.net>
 <20130323175915.GA3036@netboy.at.omicron.at>
 <20130325170855.0194ce13@griffin>
 <20130325185120.GB3100@netboy.at.omicron.at>
 <20130326104836.1379592f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:45914 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754685Ab3CZSoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 14:44:46 -0400
Received: by mail-ee0-f54.google.com with SMTP id e51so262304eek.27
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 11:44:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130326104836.1379592f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 10:48:36AM +0100, Jiri Benc wrote:
> On Mon, 25 Mar 2013 19:51:20 +0100, Richard Cochran wrote:
> > While that might work for the PTP ioctls, it won't for the main
> > clock_gettime/settime/adjtime call. As you wrote below, these take a
> > dynamic clockid_t (which comes from a file descriptor), and so each
> > device needs its own, unique file system node.
> 
> They need an unique file descriptor, not an unique file. There's nothing
> preventing you from opening the same file multiple times, using each
> obtained file descriptor to access a different PHC. Sure, there is
> currently no place to store a per-fd data in posix-clock implementation
> but that could be added.

Assume you have multiple clocks in the system. You open /dev/ptp, and
you get a FD to be passed to clock_gettime. But *which* clock's time
should be read?

(An extra ioctl to choose the active clock seems a bit gross to me.)

> > For better or worse, we are stuck with char devs, unless we want to
> > redo the clock_xyz API. I certainly don't want to. We can have over a
> > million PTP clocks on a single major number. That should be enough.
> > 
> > IIRC, it is possible to grow the range of minor numbers
> > incrementally. Perhaps you could take a look at that?
> 
> That was what I was originally thinking about. But I don't like it much
> - the overhead will increase significantly with increasing number of
> devices, as the chrdev allocations for a given major are kept in a
> linked list which has to be completely traversed on each allocation.
> We'd also need to replace the ptp_clocks_map with a different data
> structure (e.g. a linked list of bitmaps if we allocate minors in
> chunks to alleviate the chrdev allocation overhead), not helping the
> overhead.

How about using idr and then, at each clock registration, just
increase the range of minors to include the new number?

I wouldn't worry about the overhead at allocation time. It is one time
only, during device registration, and so is not performance critical.

Thanks,
Richard
