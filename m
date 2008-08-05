From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [E1000-devel] [PATCH] catch up device stats when multicast
	>total frames
Date: Tue, 5 Aug 2008 12:53:23 -0400
Message-ID: <20080805165323.GD22123@hmsreliant.think-freely.org>
References: <20080805131610.GC22123@hmsreliant.think-freely.org> <36D9DB17C6DE9E40B059440DB8D95F5205C8FA8C@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4476 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760508AbYHEQxk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 12:53:40 -0400
Content-Disposition: inline
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5205C8FA8C@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 09:43:19AM -0700, Brandeburg, Jesse wrote:
> Neil Horman wrote:
> > On Tue, Aug 05, 2008 at 01:15:29PM +0100, Ben Hutchings wrote:
> >>> 	REcently observed a problem wherein, if a BMC or other IPMI
> device
> >>> is attached to a NIC, multicast frames can be consumed by the
> >>> aformentioned device without ever being seen by the driver.  Since
> >>> multicast frames are counted in the hardware and the total frame
> >>> counter is counted in the driver napi routine, 
> >> 
> >> I'd be surprised if the hardware does not also maintain a total frame
> >> counter.  If not, you can possibly calculate the total as good + bad
> >> packets, or unicast + multicast + broadcast + bad, or something like
> >> that. 
> > 
> > It does, however,  for whatever reason the drriver relies on a
> > software computed total packets counter rather than the hardware
> > based on (possibly for the same reason, in that it counts frames the
> 
> We changed the driver to do real time updates based on user feedback
> that updating the stats every two seconds was not fast enough.  It was
> the simplest solution at the time.
> 
Makes sense to me.

> >> This is a botch - it means the numbers can't be so obviously wrong,
> >> but doesn't make them correct. 
> >> 
> > I agree, but as it stands currently the numbers are obviously wrong,
> > and I don't see a way to make them undenyably correct.  We could use
> > the hardware counter instead, but then we would be counting frames
> > that various IPMI endpoints might consume, so that wouldn't be quite
> 
> There are counters at the end of the ethtool -S output called
>    tx_smbus: 0
>    rx_smbus: 0
>    dropped_smbus: 0
> 
> that are indicating when the SMBUS is active. (SMBUS is used to tx / rx
> BMC packets)  Those at least tell you when IPMI is active.
> 
I didn't see those, I'll need to look again. Still though, knowing this still
leaves us with the possibility that multicast packets > total_rx_packets (where
the former is counted in hw, while the latter is counted in sw). 

> > right.  We could fix up the sofware counter based on the hardware
> > counter, but that doesn't seem right either.  We could inspect the
> > packet in the driver, and do a software multicast frame counter, but
> > that would be a big performance hit.  So there is no great fix to
> > this problem. This at least makes the stats sane, doesn't impact
> > performance, and doesn't affect stats for which IPMI reception isn't
> > an issue.  
> 
> There doesn't seem to be much of a middle ground, you either count in
> real time or you update every two seconds.
> 
Agreed, theres no great solution here.


> > John, you stopped commenting in the origional bug report, do you have
> > any further thoughts on this as a fix to the issue at hand?
> 
> I guess this comes down to a question of "how big a problem is this" as
> we can really do it either way.  And in fact we had recently developed a
> patch that allowed ethtool to control the stats update frequency (the
> rate the hw counters are read)  I'm not sure, but reverting the change
> that removed the hardware byte counters, and adding this "stats
> frequency update" would kind of fix both issues.  The only reason I'm
> not fond of the real-time updates up until this point is the hot path
> cache misses.
> 
> Jesse
I can't really answer how big a problem this is.  What I can tell you is that it
was reported to me origionally as a net-snmp issue.  net-snmp was getting some
very odd counter values because it was computing unicast rx frames from a given
interface as unicast = total - multicast, as read from /proc/net/dev.  The
assumption here being that total >= multicast in that file.  Given the e1000
driver as it currently stands, thats not a safe assumption for net-snmp, nor any
other application using /proc/net/dev to make. Clearly an obvious solution here
is for applications to sanity check this input data, but that just begs the
question, what then?  If total < [some reasonable component of total], what do
we do?  I think making sure that we put up sane counters is a resonable
solution, but I'm certainly open to other solutions, or arguments for fixing
this elsewhere.

Regards
Neil


-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
