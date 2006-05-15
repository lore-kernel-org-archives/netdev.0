From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: SIOCSIWESSID + SIOCSIWAP behaviour
Date: Mon, 15 May 2006 13:28:13 -0700
Message-ID: <20060515202813.GA7400@bougret.hpl.hp.com>
References: <4467BD47.5040000@gentoo.org> <1147663779.2204.27.camel@localhost.localdomain>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, Jouni Malinen <jkmaline@cc.hut.fi>,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelbas04.cce.hp.com ([161.114.21.107]:43468 "EHLO
	ccerelbas04.cce.hp.com") by vger.kernel.org with ESMTP
	id S1750813AbWEOU2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 16:28:23 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1147663779.2204.27.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 14, 2006 at 11:29:38PM -0400, Dan Williams wrote:
> On Mon, 2006-05-15 at 00:29 +0100, Daniel Drake wrote:
> > Hi Jean,

	Hi,

	Nice discussion you got going here ;-)

> > I'd just like to check my understanding (and softmacs implementation) 
> > of SIWESSID and SIWAP behaviour, for managed mode.
> > 
> > When SIWESSID happens, softmac drops association/authentication with the 
> > current network and then starts a scan for the requested SSID. When 
> > found, softmac authenticates and associates to that network.
> > 
> > When SIWAP happens, softmac drops association/authentication with the 
> > current network and then starts a scan for the requested BSSID. When 
> > found, softmac authenticates and associates to that network.
> 
> I'll chime in too... My understanding of WE is that your understanding
> of WE is correct.

	Yes.
	There is one case where you don't need to reassociate : if you
already have the correct ESSID or BSSID. This mostly happens when you
set the ESSID to any or the BSSID to off or any.
	Also, Jouni is correct that you don't need to scan if your
scan results are fresh enough.

>  But if the user has already set the SSID and _then_
> sets the BSSID, the driver must attempt to associate with an AP that has
> _both_ those properties.  Setting one doesn't cancel the other out
> (Jean, correct if I'm wrong here?)

	Correct.

>  AFAIK, you can actually set any old
> BSSID you like on the access point, so there's no guarantee that the
> BSSID any access point advertises is unique.  Furthermore I believe you
> can have one AP with one BSSID server more than one ESSID.  Higher-end
> Cisco/3Com/etc products allow this.

	I believe the BSSID has to be unique. HP APs can also offer
multiple ESSID for the same BSSID, but they do so using different
BSSID. If you look at the 802.11 spec, I can't see how two different
virtual cells can have the same BSSID, because the BSSID is the only
thing that identify the cell (the ESSID is not in each packet).

> > Is it correct that SIWAP can legally select *any* AP? (As opposed to 
> > only being for selecting a specific AP *on the ESS* indicated by a past 
> > or future SIWESSID call)
> 
> Correct.  The user may SIWAP _any_ BSSID at all, not necessarily related
> to the SSID.  However, if the user just set an ESSID with SIWESSID, I'm
> fairly sure that ESSID must be honored as well.

	The main configuration is SIWESSID, that's the only config
that is required by the standard. WIWAP is only a secondary
configuration, that is optional and not supported in all drivers. The
ESSID set should always be respected.
	If an ESSID is set, SIWAP should only look within APs having
this ESSID, and not use a different ESSID. Only if the ESSID is set to
'any' should the card really pick any AP regardless of ESSID.
	Personally, I think that SIWAP is too tricky to use properly
for most users, so we should encourage them to not use it.

> > No matter how I think of it, this strikes me as a hard interface to 
> > implement. Because association isn't an atomic operation, it is tricky 
> > to get the sequencing right, e.g. if the user does SIWESSID to start 
> > association, and then SIWAP to select a different AP before the original 
> > association has completed.
> 
> Hmm, what problems does this have?  It's not really any different than
> if the user issues two SIWESSID calls in short sequence, so you have to
> handle the start assoc->disassoc->start assoc sequence anyway...

	I agree that it make things messy in the driver. I also agree
that the user can do stupid things with iwconfig, and therefore there
is no real difference.
	There is still a performance issue. Having to cancel and
restart associations waste CPU cycles. One way to deal with that would
be to improve the "commit" strategy of the Wireless API. Basically,
every time you do a set, you schedule or reschedule the "commit" ioctl
to happen in a few dozen ms. This way, you could bundle all the
settting of apps such as wpa_supplicant with only a single
commit. This is similar to the way the routing API works.
	But, you won't get away that end-users can do stupid stuff
with iwconfig.

> Dan

	Have fun...

	Jean
