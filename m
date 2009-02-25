From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Wed, 25 Feb 2009 06:54:19 -0500
Message-ID: <20090225115419.GA16150@hmsreliant.think-freely.org>
References: <20090206165736.295ec007@extreme> <20090207174931.GA10247@localhost.localdomain> <20090209102134.GA8492@gondor.apana.org.au> <20090224.234840.93952093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, shemminger@vyatta.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37140 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761551AbZBYLyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 06:54:38 -0500
Content-Disposition: inline
In-Reply-To: <20090224.234840.93952093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 11:48:40PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 9 Feb 2009 21:21:34 +1100
> 
> > On Sat, Feb 07, 2009 at 12:49:32PM -0500, Neil Horman wrote:
> > >
> > > Well, as I mentioned, its totally incomplete.  I only posted it, so that you
> > > could see an exemplar of how I wanted to use tracepoints to dynamically
> > > intercept various in kernel events so that I could gather drop notifications. Of
> > > course several other tracepoints will be needed to capture other classes of drop
> > > (IPv6 stats, arp queue overflows, qdisc drops, etc).
> > 
> > FWIW it sounds pretty reasonable to me.  Although I'm still unsure
> > on what impact all these trace points will have on the maintainence
> > of our source code.
> 
> It occurs to me that this kind of event tracking is more about
> a negated test rather than a straight one.
> 
> It makes no sense to annotate all of the abnormal drop cases,
> there are tons of those.
> 
> Rather it's easier to consolidate the normal cases.
> 
> Here's an idea that doesn't use tracepoints (I really don't like
> them, to be honest):
> 
> 1) Isolate the normal packet freeing contexts, have them call
>    kfree_skb_clean() or something like that.
> 
> 2) What remains are the abnormal drop cases.  They still call
>    plain kfree_skb() which records __builtin_return_address(0)
>    and builds a hash table of counts call sites.
> 
> Then you just dump the table via some user visible interface.
> 

I had actually started down this road for awhile, and liked it for its low
maintenence overhead (as you mentioned, less to annotate), but I balked at it
after a bit, mostly for its increased ambiguity.  By catching the drop where the
packet is freed, we lose information about the exact point at which we decided
to drop it.  As such, users of said dumped table loose (or potentially lose) the
ability to correlate the saved stack pointer with an exact point in the code
where a corresponding statistic was incremented, as well as the correlation to a
specific point in the code (they just get the calling function program counter
rather than file, funciton and line number).

Is the loss of that information worth the additional ease of maintenece? I'm not
sure.  It was my feeling that, while the number of drop points was large, it was
a fairly stable set, and by embedding the tracepoints in the macros for stat
drops, new points are still likely to get picked up transparently (the remaining
points in the queueing disciplines are outliers there).  But the above idea is
functional as well.  If the consensus is that recording where we actually free
the skb is preferable to where we note that we're going to drop (i.e. the
various points at which we increment one of our statistics counters), then I'm
happy to make that conversion.

Regards
Neil

