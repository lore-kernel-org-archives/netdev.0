From: "Simon Barber" <simon@devicescape.com>
Subject: RE: 3945 driver using d80211
Date: Wed, 9 Aug 2006 14:41:37 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F015EFAE3@dhost002-46.dex002.intermedia.net>
References: <C86180A8C204554D8A3323D8F6B0A29F015EFADB@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Mohamed Abbas" <mabbas@linux.intel.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:14185 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751160AbWHIVli convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 17:41:38 -0400
Content-class: urn:content-classes:message
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F015EFADB@dhost002-46.dex002.intermedia.net>
To: "Simon Barber" <simon@devicescape.com>,
	"Dan Williams" <dcbw@redhat.com>,
	"Michael Wu" <flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One thing driving many silicon vendors away from putting the MLME in the
card - is that in order to support the advanced wireless features of MS
Vista you have to leave the MLME to the host! (this is to enable Vista's
advanced wireless features - like simultaneous client/ad-hoc mode). This
is forcing more and more vendors to do things the right way.

Simon
 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Simon Barber
Sent: Wednesday, August 09, 2006 2:33 PM
To: Dan Williams; Michael Wu
Cc: Johannes Berg; Mohamed Abbas; netdev@vger.kernel.org
Subject: RE: 3945 driver using d80211

There are many different functions in a complete 802.11 implementation -
and different implementations put these functions in different places.
In general, I would consider the primary difference between a "full-mac"
card and others to be the location of the MLME function. All full-mac
cards perform the MLME in the card. They typically also do the
conversion of data frames between 802.3 and 802.11 format in the card as
well, and the inter-BSS transitions are handled in the card too.

This key difference make it very unlikely that full-mac cards will
implement various advanced 802.11 features - such as WDS, virtual APs,
multiple clients, simultaneous client/AP modes etc etc. (Of course, by
adding a large number of APIs all this can theoretically be achieved -
it's just a lot more work this way).

Because the full-mac cards have functions in the card that other cards
do not the API for these cards will necessarily be quite different from
the API for non-full-mac cards. Typically the full mac cards will only
ever expose a single 802.3 interface - and hence they may not need to
have an 802.11 master interface at all. They will require a user space
API that includes control of MLME functions - because the MLME is in the
card. A non full-mac card does not require this user space API - with
the MLME built in to hostapd since year dot, and in new versions of
wpa_supplicant there is little need for the kernel to have a MLME API
from user space - unless you are using a full-mac card. This is a great
thing - goodbye to much of the awkward parts of the legacy kernel
wireless APIs.

In short - full-mac and non full-mac cards have very different kernel
and API requirements. I'd be very careful in looking at how much their
kernel support should be fully merged.

It would be very interesting to do a taxonomy of the different cards,
and look at where different functions are performed.

One question for intel - will intel ever release a firmware for the
2100/2200 that makes the card into a non-full-mac card? (This would make
unified support so much easier, as well as giving the cards much more
capability and flexability.)

Simon


-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Dan Williams
Sent: Wednesday, August 09, 2006 12:23 PM
To: Michael Wu
Cc: Johannes Berg; Mohamed Abbas; netdev@vger.kernel.org
Subject: Re: 3945 driver using d80211

On Wed, 2006-08-09 at 09:47 -0700, Michael Wu wrote:
> On Wednesday 09 August 2006 00:57, Johannes Berg wrote:
> > Please not, for now. We need someone pushing for fullmac features in

> > d80211, we need those anyway for embedded systems that can't afford 
> > running all of it on the main CPU. While obviously Intel would 
> > benefit from doing this since a lot more d80211 features would come 
> > available, the greater good would be having a main-stream card that 
> > someone cares about and helps making d80211 full-mac capable.
> >
> It's not that hard to generate probe, authentication, and association 
> frames, and it isn't done frequently enough to stress any embedded 
> system that can run linux. Doing this would let 3945 take advantage of

> all the d80211 features, so why not?
> 
> What level of fullmac support are we talking about? True fullmac cards

> (as I define them) do not need to use d80211. WE19 is all they need, 
> to add
> WPA/WPA2 support. The IPW cards have a particularly unique split 
> between firmware and host 802.11 duties which I haven't seen in any 
> other cards. They aren't quite fullmac enough to interface with WE 
> directly, yet they only need probe response handling to complete the 
> picture. What other half-fullmac, half-softmac card besides the other 
> IPW cards splits card/host 802.11 duties along those lines? What other

> splits between card and host are out there? I would be very reluctant 
> to make changes to the 802.11 stack to support "fullmac" without
evidence that other drivers need the change.

The atmel driver is somewhat of a hybrid.  For fullmac cards like airo,
you just set the connection info up, let the card go, and you get back a
link event.  But the atmel driver controls authentication and
association stuff; that's not done in firmware.  Look at:

send_authentication_request()
send_association_request()
atmel_transmit_management_frame()
atmel_management_frame()
authenticate()
associate()

The driver has an auth/assoc state machine, receives management frames,
and sends out the next appropriate management frame based on the current
state.  I think this is the reverse of ipw2100, where the firmware
handles assoc/auth but not much else, but it's still less fullmac than
airo, and more fullmac than softmac.

Dan


-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
