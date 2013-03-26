From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Tue, 26 Mar 2013 10:48:36 +0100
Message-ID: <20130326104836.1379592f@griffin>
References: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
	<20130321.172017.1499060411785395307.davem@davemloft.net>
	<20130323175915.GA3036@netboy.at.omicron.at>
	<20130325170855.0194ce13@griffin>
	<20130325185120.GB3100@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757306Ab3CZJsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 05:48:46 -0400
In-Reply-To: <20130325185120.GB3100@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Mar 2013 19:51:20 +0100, Richard Cochran wrote:
> While that might work for the PTP ioctls, it won't for the main
> clock_gettime/settime/adjtime call. As you wrote below, these take a
> dynamic clockid_t (which comes from a file descriptor), and so each
> device needs its own, unique file system node.

They need an unique file descriptor, not an unique file. There's nothing
preventing you from opening the same file multiple times, using each
obtained file descriptor to access a different PHC. Sure, there is
currently no place to store a per-fd data in posix-clock implementation
but that could be added.

> For better or worse, we are stuck with char devs, unless we want to
> redo the clock_xyz API. I certainly don't want to. We can have over a
> million PTP clocks on a single major number. That should be enough.
> 
> IIRC, it is possible to grow the range of minor numbers
> incrementally. Perhaps you could take a look at that?

That was what I was originally thinking about. But I don't like it much
- the overhead will increase significantly with increasing number of
devices, as the chrdev allocations for a given major are kept in a
linked list which has to be completely traversed on each allocation.
We'd also need to replace the ptp_clocks_map with a different data
structure (e.g. a linked list of bitmaps if we allocate minors in
chunks to alleviate the chrdev allocation overhead), not helping the
overhead.

Please correct me if I misunderstood something.

Thanks for the ideas,

 Jiri

-- 
Jiri Benc
