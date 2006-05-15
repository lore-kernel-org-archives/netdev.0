From: Dan Williams <dcbw@redhat.com>
Subject: Re: SIOCSIWESSID + SIOCSIWAP behaviour
Date: Sun, 14 May 2006 23:29:38 -0400
Message-ID: <1147663779.2204.27.camel@localhost.localdomain>
References: <4467BD47.5040000@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@hpl.hp.com>, netdev@vger.kernel.org,
	softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59618 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751022AbWEODe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 May 2006 23:34:26 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4467BD47.5040000@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-15 at 00:29 +0100, Daniel Drake wrote:
> Hi Jean,
> 
> I'd just like to check my understanding (and softmacs implementation) 
> of SIWESSID and SIWAP behaviour, for managed mode.
> 
> When SIWESSID happens, softmac drops association/authentication with the 
> current network and then starts a scan for the requested SSID. When 
> found, softmac authenticates and associates to that network.
> 
> When SIWAP happens, softmac drops association/authentication with the 
> current network and then starts a scan for the requested BSSID. When 
> found, softmac authenticates and associates to that network.

I'll chime in too... My understanding of WE is that your understanding
of WE is correct.  But if the user has already set the SSID and _then_
sets the BSSID, the driver must attempt to associate with an AP that has
_both_ those properties.  Setting one doesn't cancel the other out
(Jean, correct if I'm wrong here?)  AFAIK, you can actually set any old
BSSID you like on the access point, so there's no guarantee that the
BSSID any access point advertises is unique.  Furthermore I believe you
can have one AP with one BSSID server more than one ESSID.  Higher-end
Cisco/3Com/etc products allow this.

> Is it correct that both of these immediately trigger 
> deauthenication+deassocation then authentication+assocation?

Correct.

> Is it correct that SIWAP can legally select *any* AP? (As opposed to 
> only being for selecting a specific AP *on the ESS* indicated by a past 
> or future SIWESSID call)

Correct.  The user may SIWAP _any_ BSSID at all, not necessarily related
to the SSID.  However, if the user just set an ESSID with SIWESSID, I'm
fairly sure that ESSID must be honored as well.

> Right now, wpa_supplicant does SIWESSID and SIWAP in quick succession, 
> which causes softmac to associate twice, and that quickly confuses things.

(I don't really understand why wpa_supplicant uses SIWAP when a BSSID
isn't specified in the config file, but...)

How does that confuse things?  My understanding of most of the other
non-softmac drivers is that the SIWESSID sets the required SSID, then
the SIWAP sets the required BSSID, and that only if that ESSID is _also_
a member of the BSSID, then the association is permitted to happen.  The
options are cumulative.  If the user happens to set an ESSID and then a
BSSID that doesn't actually contain that ESSID, user==stupid and the
card can't do anything.

One may reset/unlock the ESSID to "any" by setting the "flags" member of
0 in the IWESSID request.  The user can also reset/unlock the BSSID to
any by setting the BSSID in the request to all 0x00 or all 0xFF.

If a user app gets confused by disassociation events to userspace, the
app needs to get fixed.

> No matter how I think of it, this strikes me as a hard interface to 
> implement. Because association isn't an atomic operation, it is tricky 
> to get the sequencing right, e.g. if the user does SIWESSID to start 
> association, and then SIWAP to select a different AP before the original 
> association has completed.

Hmm, what problems does this have?  It's not really any different than
if the user issues two SIWESSID calls in short sequence, so you have to
handle the start assoc->disassoc->start assoc sequence anyway...

Dan


