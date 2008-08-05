From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [E1000-devel] [PATCH] catch up device stats when multicast >total frames
Date: Tue, 5 Aug 2008 09:43:19 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5205C8FA8C@orsmsx418.amr.corp.intel.com>
References: <20080805115018.GB22123@hmsreliant.think-freely.org><20080805121527.GZ10471@solarflare.com> <20080805131610.GC22123@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Neil Horman" <nhorman@tuxdriver.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:49664 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753185AbYHEQnW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 12:43:22 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080805131610.GC22123@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
> On Tue, Aug 05, 2008 at 01:15:29PM +0100, Ben Hutchings wrote:
>>> 	REcently observed a problem wherein, if a BMC or other IPMI
device
>>> is attached to a NIC, multicast frames can be consumed by the
>>> aformentioned device without ever being seen by the driver.  Since
>>> multicast frames are counted in the hardware and the total frame
>>> counter is counted in the driver napi routine, 
>> 
>> I'd be surprised if the hardware does not also maintain a total frame
>> counter.  If not, you can possibly calculate the total as good + bad
>> packets, or unicast + multicast + broadcast + bad, or something like
>> that. 
> 
> It does, however,  for whatever reason the drriver relies on a
> software computed total packets counter rather than the hardware
> based on (possibly for the same reason, in that it counts frames the

We changed the driver to do real time updates based on user feedback
that updating the stats every two seconds was not fast enough.  It was
the simplest solution at the time.

>> This is a botch - it means the numbers can't be so obviously wrong,
>> but doesn't make them correct. 
>> 
> I agree, but as it stands currently the numbers are obviously wrong,
> and I don't see a way to make them undenyably correct.  We could use
> the hardware counter instead, but then we would be counting frames
> that various IPMI endpoints might consume, so that wouldn't be quite

There are counters at the end of the ethtool -S output called
   tx_smbus: 0
   rx_smbus: 0
   dropped_smbus: 0

that are indicating when the SMBUS is active. (SMBUS is used to tx / rx
BMC packets)  Those at least tell you when IPMI is active.

> right.  We could fix up the sofware counter based on the hardware
> counter, but that doesn't seem right either.  We could inspect the
> packet in the driver, and do a software multicast frame counter, but
> that would be a big performance hit.  So there is no great fix to
> this problem. This at least makes the stats sane, doesn't impact
> performance, and doesn't affect stats for which IPMI reception isn't
> an issue.  

There doesn't seem to be much of a middle ground, you either count in
real time or you update every two seconds.

> John, you stopped commenting in the origional bug report, do you have
> any further thoughts on this as a fix to the issue at hand?

I guess this comes down to a question of "how big a problem is this" as
we can really do it either way.  And in fact we had recently developed a
patch that allowed ethtool to control the stats update frequency (the
rate the hw counters are read)  I'm not sure, but reverting the change
that removed the hardware byte counters, and adding this "stats
frequency update" would kind of fix both issues.  The only reason I'm
not fond of the real-time updates up until this point is the hot path
cache misses.

Jesse
