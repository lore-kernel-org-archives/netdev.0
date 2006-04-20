From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: SIOCGIWSCAN wireless event behaviour
Date: Thu, 20 Apr 2006 09:43:54 -0700
Message-ID: <20060420164354.GA32409@bougret.hpl.hp.com>
References: <4447979F.4050603@gentoo.org> <1145543852.2654.11.camel@localhost.localdomain>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, softmac-dev@sipsolutions.net,
	netdev@vger.kernel.org, hostap@shmoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelbas02.cce.hp.com ([161.114.21.105]:9420 "EHLO
	ccerelbas02.cce.hp.com") by vger.kernel.org with ESMTP
	id S1751032AbWDTQoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 12:44:04 -0400
To: Dan Williams <dcbw@redhat.com>, Jouni Malinen <jkmaline@cc.hut.fi>
Content-Disposition: inline
In-Reply-To: <1145543852.2654.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 10:37:32AM -0400, Dan Williams wrote:
> On Thu, 2006-04-20 at 15:15 +0100, Daniel Drake wrote:
> > Hi Jean,
> > 
> > A query regarding wireless events: under which circumstances should a 
> > driver/stack send a SIOCGIWSCAN event to userspace?
> > 
> > Should it be sent whenever a driver has new scan results available, or 
> > only when the user requested a scan a short time beforehand (via 
> > SIOCSIWSCAN)?

	The original behaviour was that the event was sent only when a
user did request a scan. At that time, cards did not do background
scanning, so new scan results would be produced only as a result of a
user scan.
	After a short discussion we Dan, we agree that to change that,
the driver should send a scan whenever a new scan result is available,
regardless of how it happens (background scan or user scan). This
allow smart application to synchronise on background scans and avoid
them generating useless user scans. Minimising the number of user scan
is actually good.

> Similar situation:  when wpa_supplicant requests a scan, the driver
> scans and pushes the GIWSCAN at completion.  _Every_ process (like
> NetworkManager) listening for netlink WE messages gets the GIWSCAN event
> even though only wpa_supplicant requested the original scan.
> 
> So what I'm saying is that applications that process GIWSCAN netlink
> messages today should _already_ be able to handle random GIWSCAN events
> at any time even when they have not explicitly requested a scan with
> SIWSCAN.  The events are broadcast and the driver shouldn't really care
> which user app initiated any particular request.  Multiple apps can
> theoretically request scans at any time, though this isn't so good in
> practice.

	100% correct.

> > I ask this because softmac is sending the SIOCGIWSCAN event even when 
> > the user did not explicitly ask for it.
> 
> Given the above, I think this behavior is fine and even desirable.

	Yes.

> > I think the 'extra' SIOCGIWSCAN event may be confusing wpa_supplicant 
> > (but have not confirmed that yet).
> 
> If this is the case, wpa_supplicant should not be getting confused by
> GIWSCAN events happening at random times, and should be fixed.  However,
> in my experience with 0.4.8, this isn't a problem and wpa_supplicant
> handles random scan events correctly.  Not sure about the 0.5.x branch
> though.

	After we changed to behaviour of ipw, various users reported
that wpa_supplicant was confused. I particularly trust the report of
Bill Moss, who has been hacking ipw for a long time :

http://sourceforge.net/mailarchive/forum.php?thread_id=10091113&forum_id=38938

	Jouni was notified, but did not really answer to that bug report.
	Then, the ipw maintainers commited the following patch to ipw
that fix or workaround that issue :

http://marc.theaimsgroup.com/?l=linux-netdev&m=114492056522667&w=2

	I would still like Jouni to have a look at the issue to tell
us where the problem is. Two driver having issue is not coincidence. I
would hate driver starting to implement various workaround if the
problem is really in wpa_supplicant.

	Have fun...

	Jean
