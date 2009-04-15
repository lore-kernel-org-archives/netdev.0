From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Lguest] [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 07:06:10 -0700
Message-ID: <m11vruovu5.fsf@fess.ebiederm.org>
References: <1239224319.17844.16.camel@zetabook> <49DDE91A.8060603@trash.net>
	<49DDF614.1060909@trash.net> <m1bpr6hqrm.fsf@fess.ebiederm.org>
	<49E47976.8020005@trash.net>
	<20090415083610.GA8579@gondor.apana.org.au>
	<20090415084717.GA8829@gondor.apana.org.au>
	<m18wm2rqy6.fsf@fess.ebiederm.org>
	<20090415132802.GA11408@gondor.apana.org.au>
	<m1skkaox8h.fsf@fess.ebiederm.org>
	<20090415134610.GA11683@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Matias Zabaljauregui <zabaljauregui@gmail.com>, odie@cs.aau.dk,
	Rusty Russell <rusty@rustcorp.com.au>, lguest@ozlabs.org,
	virtualization@lists.osdl.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47189 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbZDOOGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 10:06:17 -0400
In-Reply-To: <20090415134610.GA11683@gondor.apana.org.au> (Herbert Xu's message of "Wed\, 15 Apr 2009 21\:46\:10 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Wed, Apr 15, 2009 at 06:35:58AM -0700, Eric W. Biederman wrote:
>> 
>> Because as far as I can tell we would just leak that refcount.
>> 
>> The poll code does not appear to call back into any of the file
>> methods when it frees itself from the wait queue.
>
> OK my suggestion was stupid.
>
> But I still don't see how this race is possible at all.
>
> So process A has a tun fd open and is spinning in poll(2).  Now
> process B comes along and deletes that tun device.  Process A's
> fd should have a netdev reference that keeps the device and
> associated structures alive.
>
> Oh I see what's going on.  We're automatically detaching the
> device in uninit.  This is just wrong.  Just because process B
> deleted the netdev, process A should not be involutarily detached.
>
> Does anything actually rely on this behaviour?

Yes.

There is the boring rmmod case that has always existed.

There is more interesting case of moving your tap device
into another network namespace.

In which case there is the possibility of the network namespace
exiting and destroying all of the virtual network devices before
we close the file handle.

I implemented the rtnetlink methods so we can test the uninit
behavior without going through all sorts of hoops.

Eric
