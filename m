From: Florian Westphal <fw@strlen.de>
Subject: Re: Quick Blind TCP Connection Spoofing with SYN Cookies
Date: Fri, 16 Aug 2013 11:21:47 +0200
Message-ID: <20130816092147.GA5154@breakpoint.cc>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakob Lell <jakob@jakoblell.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60788 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754444Ab3HPJWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 05:22:22 -0400
Content-Disposition: inline
In-Reply-To: <20130815235743.GA25665@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:
> > The simplification of TCP Connection Spoofing described here is an
> > inherent problem of TCP SYN Cookies and so there won't be a simple
> > patch which just solves the issue and makes the Spoofing Attack as
> > hard as it is without SYN Cookies. It is only possible to gradually
> > increase the required effort for successfully spoofing a connection
> > e.g. by only accepting the last two instead of four counter values
> > (which will lead to a 60-120s 
> 
> If the counter is slowed down 4 times, accepting only two
> values should result in similar behaviour as we have today.
> 
> Can anyone think of a reason this should not be done?

I was also working on patches that mitigate this (not ready yet),
lets compare notes.

There are two problems.

1) current scheme is dangerous with HZ=1000 on 32
   bit platforms due to jiffies overflow, it needs to be fixed.

Else, cookies can be re-used exactly after 49 day period.

I did straighforward replacement first to not change current timer:

Use getnstimeofday(), take "second" value, shift result by 6 (64-second
granular timer).

If you have time to work on it, I would appreciate if you could take
care of this.

> Additionally, I believe we should reduce the number of possible MSS
> values. I think 3 values should be enough - not supporting jumbo
> frames and wasting a few bytes on sub-optimal MSS around 1400
> bytes should be acceptable when a system is under a DoS attack.

Agreed.  I had a (untested patch) that just kicks out the unlikely
values.  I used 536, 1200, 1440, 1460 for ipv4, and 536, 1220, 1460,
8940 for ipv6.  I think this would be sufficient to keep decent
connectivity for legitimate clients.

We could add an alternate fallback table with more exotic values
and use a bit in the tcp timestamp to indicate use of fallback table
however since that only workswhen ts are used I would not do this unless
there is evidence that this is useful.

As for the cookie lifetime: I agree it should be reduced, allowing
delta for more than one minute seems way too long given that we never
retransmit lost syn/ack.

A conservative change would be to reject delta <= 2, with 64 second
timer.

Cheers,
Florian
