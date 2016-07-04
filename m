From: Michal Soltys <soltys@ziu.info>
Subject: Re: [PATCH -next] hfsc: reduce hfsc_sched to 14 cachelines
Date: Mon, 4 Jul 2016 19:57:35 +0200
Message-ID: <5d033586-2338-f2b5-fb51-3396a3aad9f2@ziu.info>
References: <1467642140-19156-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:43693 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbcGDR5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 13:57:45 -0400
In-Reply-To: <1467642140-19156-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-07-04 16:22, Florian Westphal wrote:
> hfsc_sched is huge (size: 920, cachelines: 15), but we can get it to 14
> cachelines by placing level after filter_cnt (covering 4 byte hole) and
> reducing period/nactive/flags to u32 (period is just a counter,
> incremented when class becomes active -- 2**32 is plenty for this
> purpose, also, long is only 32bit wide on 32bit platforms anyway).
> 
> cl_vtperiod is exported to userspace via tc_hfsc_stats, but its period
> member is already u32, so no precision is lost there either.
> 

It should be fine, even if it overflowed (which theoretically isn't that
hard: 1500 mtu, 1gbit interface, 900mbit transfer (meaning some process
throttling itself to 900mbit, not hfsc upperlimiting it) => ~16 hours to
overflow or ITOW 75000 period changes/s) - what really matters (in
init_vf()) is if the period is different.

For the record, I have 2 patches that will trim some stuff further.
Unfortunately I have another 2 that will near surely put it back at
[hopefully only] 16 (if they get accepted that is).

But there're some other candidates that might help (some not that tiny
functions defined as inline that are called in more than 1 place). E.g.
update_cfmin() is called from 3 places.
