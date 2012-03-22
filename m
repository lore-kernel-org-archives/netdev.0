From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Thu, 22 Mar 2012 21:59:01 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580DB022@ORSMSX105.amr.corp.intel.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
 <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321160817.GB1941@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580DA6CC@ORSMSX105.amr.corp.intel.com>
 <20120322070900.GD2182@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: chetan loke <loke.chetan@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14461 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031206Ab2CVV7C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 17:59:02 -0400
In-Reply-To: <20120322070900.GD2182@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, March 22, 2012 12:09 AM
> To: Keller, Jacob E
> Cc: chetan loke; netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net;
> Kirsher, Jeffrey T; Ronciak, John; john.stultz@linaro.org; tglx@linutronix.de
> Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
> timecompare method
> 
> On Wed, Mar 21, 2012 at 05:06:09PM +0000, Keller, Jacob E wrote:
> >
> > I agree with Chetan. I think it would be best to make sure the correct
> > form of locking is done, as we are providing an interface to the user.
> > Using a seqlock would allow for preventing the ioctls from blocking
> > the hardware timestamp code.
> 
> Okay, you can improve the time stamping path in the driver to avoid contending
> with callers to clock_gettime. But that will not help the hundreds of
> clock_gettime callers from contending with each other.
>

Seqlocks don't block when reading. The way they work is with a sequence number. When a reader wants to perform a read, it atomically records the sequence number. Then it performs the operation it wants (which can't have *any* side effects. It needs to be read only on the data). After finishing, it checks to see if the sequence number has increased. If so, it repeats the process until the sequence number stays the same.

Writers work like normal spin locks but increase a sequence number whenever they start work.

This means that readers don't block at all, and as long as the readers don't conflict with each other, there is no contention or writer starvation. It is possible for readers to 'live' lock, due to a large number of write operations. However, the lock is designed for few-writers, many readers. Which is what we have.

> > It's a fairly simple change for the gettime function (the most likely
> > culprit to be hammered) by changing it to use timecounter_cyc2time
> > function instead of timecounter_read. (as long as timecounter_read is
> > called at least every 1/2 the system time overflow, which it should be
> > due to the work task.)
> >
> > With that change, then the section use a seqlock (along with the
> > section for checking hardware timestamps). Other places would do the
> > full write lock.
> 
> So, you think that clock_gettime should not read the card's time registers?
> 
You can have it read the register value directly and use timecounter_cyc2time to convert that value into ns since the epoch. This works because you are already using timecounter_read during the worktask which should be running at least as often as half the counter wraparound time. Timecounter_read has a side effect of updating the last-read value in the timecounter structure. Timecounter_cyc2time does not. The MAC timestamps will be correct as long as the timecounter_read is updated at most half a wrap-around time before the systime is calculated.

This means that gettime, and tx/rx hwtstamp functions would be read operations, while settime, adjtime, cyclecounter_update and (if igb needs it?) the function which adjusts for link speed would be writes. Since these operations only occur occasionally (relative to tx/rx hwtstamp and gettime) we have a many readers/few writers scenario.

I can show you the changes on the ixgbe driver.

> Richard
> 
