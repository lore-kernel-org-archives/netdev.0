From: "'tgraf@suug.ch'" <tgraf@suug.ch>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 12:40:12 +0000
Message-ID: <20150317124012.GH11089@casper.infradead.org>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
 <20150317122033.GA12612@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48652 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbbCQMkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 08:40:14 -0400
Content-Disposition: inline
In-Reply-To: <20150317122033.GA12612@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/15 at 11:20pm, Herbert Xu wrote:
> On Tue, Mar 17, 2015 at 12:13:42PM +0000, David Laight wrote:
> > From: Thomas Graf 
> > > Sent: 17 March 2015 11:58
> > ...
> > > > Do you really want to double the table size when 0.1% of the buckets
> > > > have a chain length > 4 but still < 16?
> > > 
> > > If we constantly hit that bucket because we are handling just a few
> > > TCP flows it would be worth to double the size & rehash to avoid the
> > > additional cache misses of the linked list.
> > > 
> > > Although a limit of 4 would be too high. Ideally we should resize and
> > > rehash when we add the 2nd entry to a bucket to stay < 100% utilization.
> > > It seems likely though that we'll always have a bucket with >=2
> > > entries so we would end up constantly doubling and rehashing. This is
> > > the only thing that speaks for a table wide nelems counters in my
> > > opinion.
> > 
> > I think you are seriously overestimating the 'efficiency' of the hash function.
> > And not doing the 'birthday paradox' maths at all.
> 
> Agreed.  Thomas, an easy test to do is to pump the integers from
> 0 to 65535 into jhash, then mask it with 65535 and run sort |
> uniq -c | sort -n on it, I think you'll see what we're talking
> about.

I'm not claiming perfect hash functions and this is exactly why I
think average utilization is not an optimal growth criteria because
it gives very limited view into the actual chain lengths.

What you describe above is a 100% utilization scenario. Initially
we talked about 0.1% utilization and whether to resize & rehash if a
single chain has length > 4. My answer is: yes we should resize &
rehash or at least rehash in that case.

My point here is that a chain length of 4 may be a serious
performance bottleneck already and that it might be worth to try
and detect bad hashing distribution and attempt to fix it at an
earlier stage while ruling out the possibility of endless rehashes.
