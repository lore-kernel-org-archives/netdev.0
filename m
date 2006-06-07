From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH] pcnet32 driver NAPI support
Date: Wed, 7 Jun 2006 14:52:36 -0700
Message-ID: <20060607215236.GA13380@us.ibm.com>
References: <20060607165225.GB7859@csclub.uwaterloo.ca> <20060607182040.GA12748@us.ibm.com> <20060607193456.GN7857@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:51383 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932429AbWFGVwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 17:52:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k57LqWTp012964
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 17:52:33 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k57LqSj6125468
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 17:52:32 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k57LqSOS006082
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 17:52:28 -0400
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Content-Disposition: inline
In-Reply-To: <20060607193456.GN7857@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006 at 03:34:56PM -0400, Lennart Sorensen wrote:
> On Wed, Jun 07, 2006 at 11:20:40AM -0700, Don Fry wrote:
> 
> > Some areas of concern that you may have addressed already, I have not
> > scanned your changes yet, are what happens if the ring size is changed
> > without bringing down the interface (via ethtool), or if the loopback
> > test is run in a similar fashion, or a tx timeout occurs.
> 
> The same thing as if it was done before enabling napi.  From a few
> messages I have seen, it doesn't work right now, and it won't work any
> better with my changes.  I have never tried changing the ring size on
> the fly, so I don't know.

Today without your NAPI changes the device can be up and operational,
and change the ring size without hanging or causing a panic or causing
problems with the driver.  The same can be said for running the loopback
test, or when a tx timeout occurs.

It does not look like the same can be said for your NAPI changes, yet.
Try changing the ring size a dozen times during a receive storm and see
what happens.

> 
> It appears that the port is stopped before the ring size change is done,
> although I can't really tell how it handles things if the queue is not
> empty when it stops the port.  Does it try to handle anything left in
> the ring first or does it just toss those packets? (That I would
> consider wrong).
> 
> > The lp->lock MUST be held whenever accessing the csr or bcr registers as
> > this is a multi-step process, and has been the source of problems in the
> > past.  Even on UP systems.
> 
> Hmm, I just followed what appeared to be in pcnet32_rx and how tulip and
> a few other drivers had done their napi conversions.  It certainly works
> for me the way I did it.  Haven't seen any lockups yet.  I do see that I
> am not holding the lock when I acknowledge IRQs in pcnet32_poll, which
> pcnet32_rx doesn't need to worry about since it is called from the
> interrupt handler which already holds the lock.  That should be fixed
> then.

Yes, that is the minimum that needs to be changed.
There have been a lot of changes made to the driver, by myself included,
that seem to work just fine, but later the timing changes and you lose
the race, resulting in problems.  Changing one part of the driver
without understanding the whole thing is very risky.

> 
> So I can do:
>         // Clear RX interrupts
>         spin_lock(&lp->lock);
>         lp->a.write_csr (ioaddr, 0, 0x1400);
>         spin_unlock(&lp->lock);
> That part seems simple enough to protect.
> 
> Is this safe without holding the lock?
>     } while(lp->a.read_csr (ioaddr, 0) & 0x1400);

No, see below.

> Not sure how to wrap a lock around that one without holding the lock for
> way too long.
> 
> perhaps:
>         spin_lock(&lp->lock);
> 	state=lp->a.read_csr (ioaddr, 0) & 0x1400;
>         spin_unlock(&lp->lock);
>     } while(state);
> Does that seem more reasonable?

The lock must be held during ANY read or write to a csr or bcr.

The problem is that accessing a csr/bcr takes two steps.  One is to
write the address register indicating which register to read or write,
and second, read or write the register.  The problem is that without the
lock, entity A writes to the rap to access register X, then before it
can access that register entity B writes the rap to access register Y,
At that point entity A will read, or worse write, the contents of the
wrong register.

This problem is even worse when reading/writing a PHY register because
it entails writing bcr 33 and reading/writing bcr 34, without being
interrupted by something that might change bcr 33.  Not likely, but not
something that can be ignored.  It may not happen often, but it will
happen eventually.

> 
> Len Sorensen

-- 
Don Fry
brazilnut@us.ibm.com
