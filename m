From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] usb-net/pegasus: fix pegasus carrier detection
Date: Tue, 24 Apr 2007 16:24:46 -0400
Message-ID: <1177446286.18030.13.camel@localhost.localdomain>
References: <1177424406.13684.5.camel@localhost.localdomain>
	 <462E3508.1030703@garzik.org> <20070424170429.GA13668@kroah.com>
	 <58298.85.91.128.158.1177436881.squirrel@nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: petkan@nucleusys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49245 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368AbXDXUVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 16:21:03 -0400
In-Reply-To: <58298.85.91.128.158.1177436881.squirrel@nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-04-24 at 20:48 +0300, petkan@nucleusys.com wrote:
> > On Tue, Apr 24, 2007 at 12:49:12PM -0400, Jeff Garzik wrote:
> >>  Long term, Greg seemed OK with moving the net drivers from
> >> drivers/usb/net
> >>  to drivers/usb/net, in line with the current policy of placing net
> >> drivers
> >>  in drivers/net/*, bus agnostic.  After that move, sending to netdev and
> >> me
> >>  (as you did here) would be the preferred avenue.
> >
> > Speaking of which, do you want me to do this in the 2.6.22-rc1
> > timeframe?  Usually big code moves like this are good to do right after
> > rc1 comes out as the major churn is usually completed then.
> 
> Sorry to interfere, but could you guys wait until tomorrow before applying
> the patch to your respective GIT trees?  I'd like to check if the code is
> doing the right thing and avoid patch reversal.

Original problem was that the patch I referenced in the commit message
from Jan 6 2006 switched the return value semantics from
read_mii_word().  Before the patch, read_mii_word returned 1 on success,
0 on error.  After the patch, it returns the generally accepted 0 on
success and !0 on error.

That causes set_carrier() to return immediately rather than fiddle with
netif_carrier_*.  When the Jan 6 2006 patch went in changing the return
values, set_carrier() was not updated for the new return values.
Nothing else in the code cares about read_mii_word()'s return value
except set_carrier().

But when the card is brought up and no cable is plugged in,
intr_callback() gets called repeatedly, which itself repeatedly calls
netif_carrier_on() due to the NO_CARRIER check.  The comment there about
"NO_CARRIER kicks in on TX failure" seems accurate, because even with no
cable plugged in, and therefore no packets getting transmitted, the
NO_CARRIER check is never true on the Belkin part.  Therefore,
netif_carrier_on() is always called as a result of the failure of d[0] &
NO_CARRIER, turning carrier back on even if there is no cable plugged
in.  This bulldozes over the MII carrier_check routine too.

I don't think the intr_callback() code should ever turn the carrier
_on_, because there's that 2*HZ MII carrier check which can certainly
handle the carrier on/off stuff.

LINK_STATUS appears valid on the Belkin part too, so we can add that as
a reverse-quirk and use LINK_STATUS on parts where it works.  If you
think that the NO_CARRIER check should be in _addition_ to the
LINK_STATUS check, that's fine with me, provided that the NO_CARRIER
check only turns carrier off.

Dan


