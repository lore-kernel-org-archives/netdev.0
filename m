From: "tgraf@suug.ch" <tgraf@suug.ch>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 11:57:49 +0000
Message-ID: <20150317115749.GJ17829@casper.infradead.org>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48462 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977AbbCQL5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 07:57:51 -0400
Content-Disposition: inline
In-Reply-To: <20150317112726.GC11671@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/15 at 10:27pm, Herbert Xu wrote:
> On Tue, Mar 17, 2015 at 11:22:03AM +0000, tgraf@suug.ch wrote:
> >
> > Not sure I understand the downside of a bucket length based grow
> > decision with optional forced rehashing plus synchroneous table
> > realloc if we hit a 2nd watermark as you proposed earlier. Shouldn't
> > we consider deterministic lookup and insert behaviour more important
> > than overall table utilization? Given the rehashing, the grow decision
> > should not be attackable.
> 
> Do you really want to double the table size when 0.1% of the buckets
> have a chain length > 4 but still < 16?

If we constantly hit that bucket because we are handling just a few
TCP flows it would be worth to double the size & rehash to avoid the
additional cache misses of the linked list.

Although a limit of 4 would be too high. Ideally we should resize and
rehash when we add the 2nd entry to a bucket to stay < 100% utilization.
It seems likely though that we'll always have a bucket with >=2
entries so we would end up constantly doubling and rehashing. This is
the only thing that speaks for a table wide nelems counters in my
opinion.

Another option would be to continue resizing & rehashing as long as we
have at least one bucket with >= 4 entries but allow a table size
dependant limit of (length > 1 && length < 4) buckets. This may be
overengineered again though ;-)
