From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 10:19:34 -0400
Message-ID: <1159453174.2642.8.camel@localhost.localdomain>
References: <200609271726.34305.mb@bu3sch.de>
	 <200609271950.47430.mb@bu3sch.de> <451B4AF6.3090203@lwfinger.net>
	 <200609281455.53763.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60545 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1161140AbWI1OSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 10:18:03 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609281455.53763.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 14:55 +0200, Michael Buesch wrote:
> On Thursday 28 September 2006 06:09, Larry Finger wrote:
> > Michael Buesch wrote:
> > > On Wednesday 27 September 2006 18:18, Larry Finger wrote:
> > >> Michael Buesch wrote:
> > >>> This fixes some race conditions in the WirelessExtension
> > >>> handling and association handling code.
> > >>>
> > >>> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> > >>>
> > >>> ---
> > >> This patch doesn't apply.
> > > 
> > > Oh, linville merged stuff on the 25th. That's the day I updated
> > > my tree to do this patch. But seems like I did it just before
> > > the merge.
> > > Who could suspect that linville merges something. :D
> > > *me runs away*
> > > 
> > > Anyway. Here's an updated patch.
> > 
> > NACK this version. It applied correctly, but introduced a new problem. My device occasionally gets 
> > deauthentication messages from my AP.Preciously, it would do a scan or two, and then reauthenticate. 
> > After your patch was applied, it never stops scanning.
> 
> Oh, well... It's impossible to completely fix softmac race issues.
> I am _not_ going to rewrite huge parts of softmac to get locking
> working. If you want this to be fixed, please hack up a solution by
> yourself. I'm really not going to do more work on softmac. This
> has various reasons. 1) I cannot reproduce all these bugs I'm hunting
> 2) Time is spent better at d80211 or other projects.
> 
> But to debug the problem:
> Why do you get deauth messages? Broken AP?
> I'd say that it's _correct_ behaviour to stop working
> after getting a deauth ;). wpa_supplicant is responsible to re-auth.

I'd buy that argument.  When the driver gets the deauth message,
shouldn't it be sending an IWAP 00:00:00:00:00:00 wireless event to
userspace?  That would cause a tool like wpa_supplicant (or NM) to
attempt reauth/reassoc anyway, based on their own policy.

"Stations may send Disassociation or Deauthentication frames in response
to traffic when the sender has not properly joined the network." (802.11
Wireless Networks)

What's the value of the Reason Code received in the deauth frame?  That
will give a clue as to why the AP is rejecting you:

0   Reserved; unused
1   Unspecified
2   Prior authentication is not valid
3   Station has left the basic service area or extended service area
        and is deauthenticated
4   Inactivity timer expired and station was disassociated
5   Disassociated due to insufficient resources at the access point
6   Incorrect frame type or subtype received from unauthenticated station
7   Incorrect frame type or subtype received from unassociated station
8   Station has left the basic service area or extended service area and is
       disassociated
9   Association or reassociation requested before authentication is complete
10  Reserved; unused

> Why doesn't it re-auth? Or does it do and it just doesn't work as
> expected?

It would be interesting to know what state the driver's state machine is
in when it gets this message.  Does the driver think it's authenticated?
Does the AP think the same thing?

Dan

