From: Dan Williams <dcbw@redhat.com>
Subject: Re: SIOCSIWESSID + SIOCSIWAP behaviour
Date: Mon, 15 May 2006 10:19:49 -0400
Message-ID: <1147702789.2193.33.camel@localhost.localdomain>
References: <4467BD47.5040000@gentoo.org>
	 <1147663779.2204.27.camel@localhost.localdomain>
	 <20060515131656.GC9673@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Jean Tourrilhes <jt@hpl.hp.com>,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57815 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964947AbWEOOXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 10:23:52 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060515131656.GC9673@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-15 at 06:16 -0700, Jouni Malinen wrote:
> On Sun, May 14, 2006 at 11:29:38PM -0400, Dan Williams wrote:
> > On Mon, 2006-05-15 at 00:29 +0100, Daniel Drake wrote:
> > > When SIWESSID happens, softmac drops association/authentication with the 
> > > current network and then starts a scan for the requested SSID. When 
> > > found, softmac authenticates and associates to that network.
> 
> I don't think there is requirement for doing a new scan here if recent
> scan results are available.

Yeah, thought that was understood.  No reason to do another scan if you
just did one in the driver 5 seconds ago.

> > > When SIWAP happens, softmac drops association/authentication with the 
> > > current network and then starts a scan for the requested BSSID. When 
> > > found, softmac authenticates and associates to that network.
> 
> Same here. Neither of these commands should drop IEEE 802.11
> authentication. I would say that neither should drop association either
> until a new association is available or it is clear that current
> configuration does not allow association to be created. First case would

I assume that by "or it is clear that the current configuration does not
allow association to be created" means that the driver cannot find an AP
matching both the ESSID and the BSSID the user set, right?  If so, then
quite correct, the driver shouldn't disassociate until it's certain that
the current user-specified configuration (ie, any combination of ESSID
and BSSID set) does not apply to any known access points in the scan
list.

It's perfectly legal to send a new SIWAP event with a different BSSID if
the driver simply associates with a new access point in the same ESSID
too.  In this case, the driver does _not_ need to send a blank SIWAP
disassoc event to userspace, since it's staying within the same ESSID.

I think at this point I'm still still assuming that APs with the same
ESSID are on the same network by default.  Although that's not entirely
valid, especially in the realm of consumer gear (multiple 'linksys' APs
on the same channel even, each with different upstream connection), in
this case the user space application will have to know to lock the BSSID
of the card/driver to the one it wants.  That's a user space issue, not
a driver issue.  Driver's shouldn't be too smart about this stuff
without providing standard overrides.

> configuration does not allow association to be created. First case would
> just report a new association (no disassociation reported) and second
> case would report disassociation to user space.

If no association has been completed yet before the user sets SIWESSID
or SIWAP, then of course no disassociation event needs to get sent to
userspace because there's been no association from which to
disassociate.

I believe the following sequence is correct:

boot
user app issues SIWESSID 'foo'
driver finds associates/authenticates to 'foo'
  (if not available, it Just Does Nothing)
  (if available, sends SIWAP of '<whatever foo is>' to userspace)
user app issues SIWAP '12:34:56:78:91:23'
driver sends SIWAP of 00:00:00:00:00:00 (disassoc) to userspace
driver finds and associates with '12:34:56:78:91:23'
  (if not available, it Just Does Nothing)
  (if available, sends SIWAP of '12:34:56:78:91:23' to userspace)

Similarly, I believe the following is correct:

boot
user app issues SIWESSID 'foo'
driver searches for 'foo' but does not find it
  (if driver does background scanning and finds 'foo', it may associate)
  (if driver does not do background scanning, must wait until user
     app requests a scan, and if 'foo' is in results, may associate)
user app issues SIWAP '12:34:56:78:91:23'
  (no SIWAP driver disassoc event needed because no association exists)
driver finds and associates with '12:34:56:78:91:23'
  (if not available, it Just Does Nothing)
  (if available, sends SIWAP of '12:34:56:78:91:23' to userspace)

Dan


