From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] usb-net/pegasus: fix pegasus carrier detection
Date: Wed, 25 Apr 2007 12:03:10 -0400
Message-ID: <1177516990.3612.2.camel@localhost.localdomain>
References: <1177424406.13684.5.camel@localhost.localdomain>
	 <462E3508.1030703@garzik.org> <20070424170429.GA13668@kroah.com>
	 <58298.85.91.128.158.1177436881.squirrel@nucleusys.com>
	 <1177446286.18030.13.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704251648050.16498@bender.nucleusys.com>
	 <1177513723.3612.0.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704251808210.16498@bender.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161865AbXDYP70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 11:59:26 -0400
In-Reply-To: <Pine.LNX.4.64.0704251808210.16498@bender.nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-25 at 18:09 +0300, Petko Manolov wrote:
> On Wed, 25 Apr 2007, Dan Williams wrote:
> 
> > On Wed, 2007-04-25 at 17:58 +0300, Petko Manolov wrote:
> >> In general i agree with the reasoning below.  However, isn't it better to
> >> remove the code that sets carrier on/off in intr_callback()?
> >
> > I'm fine with this; whatever makes carrier status work makes me happy :)
> 
> Great.  Are you going to submit the new patch or this hard labor will lay 
> on my shoulders? :)

Well, it looked like you already had one; but if you'd like I'll whip up
a new one.

Dan

> 
>  		Petko
> 
> 
> 
> >> There's a reliable way of getting the link status by reading the MII.
> >> After correct checking of the return value from read_mii_word(),
> >> set_carrier() is what is good enough.  If 2 seconds is too long of an
> >> interval we could reduce it to 1 second or, if needed, less.
> >>
> >> I'd like to avoid adding additional flags per device as it will take
> >> forever to collect information about their "correct" behavior and update
> >> pegasus.h.  In short i think this part of your patch should be enough:
> >>
> >> ---
> >>
> >> @@ -847,10 +848,16 @@ static void intr_callback(struct urb *urb)
> >>  		 * d[0].NO_CARRIER kicks in only with failed TX.
> >>  		 * ... so monitoring with MII may be safest.
> >>  		 */
> >> -		if (d[0] & NO_CARRIER)
> >> -			netif_carrier_off(net);
> >> -		else
> >> -			netif_carrier_on(net);
> >> -
> >>  		/* bytes 3-4 == rx_lostpkt, reg 2E/2F */
> >>  		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
> >> @@ -950,7 +957,7 @@ static void set_carrier(struct net_device *net)
> >>  	pegasus_t *pegasus = netdev_priv(net);
> >>  	u16 tmp;
> >>
> >> -	if (!read_mii_word(pegasus, pegasus->phy, MII_BMSR, &tmp))
> >> +	if (read_mii_word(pegasus, pegasus->phy, MII_BMSR, &tmp))
> >>  		return;
> >>
> >> ---
> >>
> >>
> >> cheers,
> >> Petko
> >>
> >>
> >> On Tue, 24 Apr 2007, Dan Williams wrote:
> >>
> >>> On Tue, 2007-04-24 at 20:48 +0300, petkan@nucleusys.com wrote:
> >>>>> On Tue, Apr 24, 2007 at 12:49:12PM -0400, Jeff Garzik wrote:
> >>>>>>  Long term, Greg seemed OK with moving the net drivers from
> >>>>>> drivers/usb/net
> >>>>>>  to drivers/usb/net, in line with the current policy of placing net
> >>>>>> drivers
> >>>>>>  in drivers/net/*, bus agnostic.  After that move, sending to netdev and
> >>>>>> me
> >>>>>>  (as you did here) would be the preferred avenue.
> >>>>>
> >>>>> Speaking of which, do you want me to do this in the 2.6.22-rc1
> >>>>> timeframe?  Usually big code moves like this are good to do right after
> >>>>> rc1 comes out as the major churn is usually completed then.
> >>>>
> >>>> Sorry to interfere, but could you guys wait until tomorrow before applying
> >>>> the patch to your respective GIT trees?  I'd like to check if the code is
> >>>> doing the right thing and avoid patch reversal.
> >>>
> >>> Original problem was that the patch I referenced in the commit message
> >>> from Jan 6 2006 switched the return value semantics from
> >>> read_mii_word().  Before the patch, read_mii_word returned 1 on success,
> >>> 0 on error.  After the patch, it returns the generally accepted 0 on
> >>> success and !0 on error.
> >>>
> >>> That causes set_carrier() to return immediately rather than fiddle with
> >>> netif_carrier_*.  When the Jan 6 2006 patch went in changing the return
> >>> values, set_carrier() was not updated for the new return values.
> >>> Nothing else in the code cares about read_mii_word()'s return value
> >>> except set_carrier().
> >>>
> >>> But when the card is brought up and no cable is plugged in,
> >>> intr_callback() gets called repeatedly, which itself repeatedly calls
> >>> netif_carrier_on() due to the NO_CARRIER check.  The comment there about
> >>> "NO_CARRIER kicks in on TX failure" seems accurate, because even with no
> >>> cable plugged in, and therefore no packets getting transmitted, the
> >>> NO_CARRIER check is never true on the Belkin part.  Therefore,
> >>> netif_carrier_on() is always called as a result of the failure of d[0] &
> >>> NO_CARRIER, turning carrier back on even if there is no cable plugged
> >>> in.  This bulldozes over the MII carrier_check routine too.
> >>>
> >>> I don't think the intr_callback() code should ever turn the carrier
> >>> _on_, because there's that 2*HZ MII carrier check which can certainly
> >>> handle the carrier on/off stuff.
> >>>
> >>> LINK_STATUS appears valid on the Belkin part too, so we can add that as
> >>> a reverse-quirk and use LINK_STATUS on parts where it works.  If you
> >>> think that the NO_CARRIER check should be in _addition_ to the
> >>> LINK_STATUS check, that's fine with me, provided that the NO_CARRIER
> >>> check only turns carrier off.
> >>>
> >>> Dan
> >>>
> >>>
> >>>
> >
> >

