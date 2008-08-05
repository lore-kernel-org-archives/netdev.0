From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: [PATCH] catch up device stats when multicast > total frames
Date: Tue, 5 Aug 2008 09:52:28 -0700
Message-ID: <4C5E6457CD7911469A07260381288C28078FB74B@orsmsx502.amr.corp.intel.com>
References: <20080805115018.GB22123@hmsreliant.think-freely.org>
 <20080805121527.GZ10471@solarflare.com>
 <20080805131610.GC22123@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: Neil Horman <nhorman@tuxdriver.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17075 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757875AbYHEQwf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 12:52:35 -0400
In-Reply-To: <20080805131610.GC22123@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The total packet count in the driver was done so that the count is always right even in between stats updates.  Believe it or not there are some people that think this is an important thing for some reason.  We don't understand that but agreed to do this to correct what they were seeing with the stats being updated every 2 seconds.

The problem that seems to be happening here is that the BMC is consuming frames that the driver never sees.  This I think is what is messing up the counts.  The problem we have is that we aren't sure if all the BMC's are doing the same thing.  We can't seem to find that information out.  So we end up with a fix like that that prevents the calculations from going negative.

I'm not sure what the right thing to do is.  I suggested in the past (in the BZ) that the total HW packet count be used for this calculation but Niel didn't like that for some reason, at least I think that's why it wasn't used.  I suggested that the HW counts be used when looking for these MC frame counts and not use the real time counts it should work correctly without regard to which BMC is being used.  It would always calculate correctly.  The calculation could come out of the update stats routine.

BTW, why did this move from the RH BZ to here?


Cheers,
John
-----------------------------------------------------------
167 days until the end of the error!
-----------------------------------------------------------
"Those who would give up essential Liberty, to purchase a little temporary Safety, deserve neither Liberty nor Safety.", Benjamin Franklin 1755

-----Original Message-----
From: Neil Horman [mailto:nhorman@tuxdriver.com]
Sent: Tuesday, August 05, 2008 6:16 AM
To: Ben Hutchings
Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Ronciak, John
Subject: Re: [PATCH] catch up device stats when multicast > total frames

On Tue, Aug 05, 2008 at 01:15:29PM +0100, Ben Hutchings wrote:
> Neil Horman wrote:
> > Hey-
> >     REcently observed a problem wherein, if a BMC or other IPMI device is
> > attached to a NIC, multicast frames can be consumed by the aformentioned device
> > without ever being seen by the driver.  Since multicast frames are counted in
> > the hardware and the total frame counter is counted in the driver napi routine,
>
> I'd be surprised if the hardware does not also maintain a total frame
> counter.  If not, you can possibly calculate the total as good + bad
> packets, or unicast + multicast + broadcast + bad, or something like that.
>

It does, however,  for whatever reason the drriver relies on a software
computed total packets counter rather than the hardware based on (possibly for
the same reason, in that it counts frames the driver never actually sees).  I
asked John R. in the origional bug report why e1000 might do this, and while
neither of us were sure, that seemed to be the consensus.

> [...]
> > --- a/drivers/net/e1000/e1000_main.c
> > +++ b/drivers/net/e1000/e1000_main.c
> > @@ -3761,6 +3761,8 @@ e1000_update_stats(struct e1000_adapter *adapter)
> >     /* Fill out the OS statistics structure */
> >     adapter->net_stats.multicast = adapter->stats.mprc;
> >     adapter->net_stats.collisions = adapter->stats.colc;
> > +   if (adapter->net_stats.rx_packets < adapter->net_stats.multicast)
> > +           adapter->net_stats.rx_packets = adapter->net_stats.multicast;
> >
> >     /* Rx Errors */
> >
> [...]
>
> This is a botch - it means the numbers can't be so obviously wrong, but
> doesn't make them correct.
>
I agree, but as it stands currently the numbers are obviously wrong, and I don't
see a way to make them undenyably correct.  We could use the hardware counter
instead, but then we would be counting frames that various IPMI endpoints might
consume, so that wouldn't be quite right.  We could fix up the sofware counter
based on the hardware counter, but that doesn't seem right either.  We could
inspect the packet in the driver, and do a software multicast frame counter, but
that would be a big performance hit.  So there is no great fix to this problem.
This at least makes the stats sane, doesn't impact performance, and doesn't
affect stats for which IPMI reception isn't an issue.

John, you stopped commenting in the origional bug report, do you have any
further thoughts on this as a fix to the issue at hand?

Neil


--
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
