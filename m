From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Thu, 27 Nov 2008 11:07:07 +0100
Message-ID: <1227780427.16263.468.camel@ecld0pohly>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
	 <492E3AAE.3000709@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Oliver Hartkopp <oliver@hartkopp.net>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23769 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843AbYK0KHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 05:07:11 -0500
In-Reply-To: <492E3AAE.3000709@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-27 at 06:14 +0000, Oliver Hartkopp wrote:
> Patrick Ohly wrote:
> > This patch series was discussed before on linux-netdev ("hardware
> > time stamping + igb example implementation").
> (..)
> 
> > This patch now adds a 8 byte field unconditionally.
> 
> This looks really better to me :-)

Good, so we are making progress :-)

> I still have two questions of understanding regarding these (offset) 
> transformations that make it still difficult:
> 
> 1. As no one has an insight of how the specific hardware generates the 
> hw time stamp anyway, why can't you put the already transformed values 
> into the hw timestamp field?

It certainly would be sufficient for PTP with the "assisted" PTP mode of
synchronizing system time. But my understanding is that Octavian and
possibly others want to have access to the raw, unmodified hardware time
stamps. Octavian, perhaps you can confirm/elaborate what your use case
is?

I should point out that currently the "raw" hardware time stamp is
already "cooked" a bit in the sense that the new field is spec'ed to
contain nanoseconds, not some opaque 64 bit blob. This is intentional
because even though the time when the clock started to run is unknown,
at least deltas can be calculated. The expectation is that this delta is
close to world and system time, with some inaccuracies caused by using
different crystals to drive the underlying hardware and thus varying
frequencies.

The "two-way" PTP mode could use these values to synchronize NIC clocks
(using a yet to be defined ioctl call which speeds up or slows down NIC
clocks, like adjtimex does for system time) and system time on top of
that NIC time. At the NIC level synchronization is going to be more
accurate than at the system level because it removes the NIC/system time
comparison from the equation. I believe this is similar to what Octavian
wants to do.

> 2. From what i've read in the discussion, i understood that the hardware 
> clock and the system clock skew. Assuming both to be strong 
> monotonic(?), is there a linear skew observable from your testing 
> experiences?

The clock drift changes over time, so on a big scale the skew is not
linear. For short periods (minute range) it is reasonable to assume that
the drift is constant, so a linear interpolation works reasonably well.
For your proposal that means that the user application needs to reread
the sysfs file at least once in a while, without really knowing how
often that should be.

[sysfs entry which exposes skew for interface]
> So if you would check this sysfs entry two or more times, you would get 
> an impression about the hw time stamp behaviour of your hardware by 
> simply calculating the linear (timedepended) offset based on several 
> 'skew-sample-points', right?

This would work, but it exposes internal mechanisms (skew measurement)
to user space. If a driver developer has a better method that is more
suitable for his hardware (perhaps something non-linear or based on more
frequent skew measurements), then the application doesn't benefit from
it.

To summarize, I see the following options at this time:

1  only store transformed time stamp...
1a ... without mapping back to raw hardware time stamp
   (advantage: simple implementation,
   kernel itself can compare hardware time stamps from different NICs;
   disadvantage: not suitable for some use cases)
1b ... with backward mapping at socket level (advantage: user space has
   full access to whatever it needs; disadvantage: backward
   transformation most likely inexact, correct way of accessing network
   device from socket unknown)
1c ... with extra user space API for transformation (advantage: 
   side-steps the implementation issues in the kernel; disadvantage:
   biggger user space API, exposes internals)

2  only store raw time stamp...
2a ... without transformation (disadvantage: not good enough for PTP)
2b ... with transformation to system time at socket level (advantage:
   no information lost due to transformation; disadvantage: same
   implementation issues as 1b)
2c ... with extra user space API for transformation (similar to 1c)

3  store both raw and transformed time stamps in skb (advantage: no
   extra APIs (in kernel or to user space) necessary for transformation,
   disadvantage: 16 additional bytes instead of just 8)

4  a compile-time configuration option which chooses between 1a (only
   store transformed time, should be the default) and 3 (store both)

My personal preference is, in this order: 3, 4, 2b (current patch,
but needs clean way to find network device), 1a.

Any other opinions?

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

