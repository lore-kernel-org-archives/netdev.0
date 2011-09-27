From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: Always fire at least one linkwatch event
Date: Tue, 27 Sep 2011 15:34:13 -0400
Message-ID: <20110927193413.GA30020@hmsreliant.think-freely.org>
References: <1316634689-15083-1-git-send-email-nhorman@tuxdriver.com>
 <20110927.145943.1365764295978178226.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jfeeney@redhat.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38382 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913Ab1I0TeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:34:19 -0400
Content-Disposition: inline
In-Reply-To: <20110927.145943.1365764295978178226.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2011 at 02:59:43PM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 21 Sep 2011 15:51:29 -0400
> 
> > It was recently noted that the tg3 driver had a problem in that after boot a
> > kernel and if-upping the tg3 interface the sysfs operstate attribute continued
> > to read 'unkown'.  This was happening because tg3 assumes the default carrier
> > state (which is to say the __LINK_STATE_NOCARRIER bit is clear) is correct.
> > That said, when the device is if-upped, and the open path, calls
> > netif_carrier_on, the test_and_set_bit call in that function returns false
> > (since the bit was previously zero from its initial state).  This means that
> > netif_carrier_on call never generates a linkwatch event, and as a result
> > dev->operstate never gets recomputed.  This could be fixed by unconditionally
> > calling netif_carrier_off in the probe routine, to simply force a state change
> > on that bit, but that seems like a sub-par solution, given that many drivers may
> > have this error.  Instead it seems like it might be better to burn an extra bit
> > in the state field to indicate that the CARRIER bit is still in the initial
> > state and our first call to netif_carrier_[off|on] should always fire a
> > linkwatch event.
> 
> I'm finding this analysis hard to follow.
> 
> tg3_open() does netif_carrier_off(), and this will set the
> __LINK_STATE_NOCARRIER bit.
> 
Sorry, I should have explained further.  In the interests of full disclosure,
this was initially reported on a RHEL 2.6.32 kernel, where netif_carrier_off was
not called from tg3_open.  As a result, when tg3_carrier_on was called later in
the open path, the test_and_clear would return 0, since NOCARRIER was
initialized to 0, and we wouldn't fire a linkwatch event, which in turn meant
that operstate was never updated until a full ifup/down/up cycle was completed.

So tg3 actually works properly upstream, but the larger issue remains - Drivers
individually must set and clear the NOCARRIER flag in order to effectively prime
the linkwatch state machine, which seems to me haphazard and prone to recurring
bugs.  What I'm proposing here is a driver independent method of ensuring that
the first call to netif_carrier_off/on gets called regardless of initial state.
This prevents drivers from having to individually remember to call
netif_carrier_off at the start of an open routine, which visually makes more
sense to me, especially when they almost immediately call netif_carrier_on right
afterwards.

Hope that clarifies things somewhat.
Neil
