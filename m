From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 12:43:08 -0500
Message-ID: <1169055788.2550.44.camel@localhost.localdomain>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932608AbXAQRrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 12:47:09 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1169047134.9175.49.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-17 at 15:18 +0000, Johannes Berg wrote:
> On Wed, 2007-01-17 at 10:01 -0500, Dan Williams wrote:
> 
> > The part is a mostly fullmac part that until now has been targetted at
> > the embedded market (PSP, N80 phone, etc).  That means that the driver
> > shouldn't be too large (airo is about 8000 kLOC without airo_cs) but for
> > some reason it still is; we're working on that.
> 
> I disagree that this is a fullmac part. You need to tell it to
> authenticate and then you need to tell it to associate. IPW is a
> fullmac, you tell it "use SSID xxx". Not this, you tell it "auth to
> BSSID aaa" and then "associate to BSSID aaa" etc.

I said "mostly" fullmac.  Sort of like ipw2100 (IIRC) is softmac but it
does all the association stuff in firmware.  It doesn't fit fullmac, but
it's a lot more fullmac than atheros.  There isn't any management frame
processing, it doesn't do any data frame processing.

The 8388 architecture is typical of a thick firmware architecture, where
the firmware handles all 802.11 MAC management tasks.  The host driver
downloads standard 802.3 frames to the firmware to be transmitted over
the link as 802.11 frames.

I thought these 2 things were essentially _the_ definition of fullmac,
please correct me if I'm wrong.

Perhaps I just don't understand how flexible d80211 has become; when we
last were talking about it 8 months ago, it appears that it could not
handle parts that did significant pieces of work in firmware, like the
8388 does.  Do we have the functionality in d80211 yet to handle pieces
that are a full mix of hybrid full/soft mac?

Essentially, the auth/assoc path is this (D=driver, F=firmware):

D: AUTHENTICATE (BSSID)
F: look up in scan table
F: handle all Open System or Shared Key auth frames and housekeeping
F: send success to driver
D: ASSOCIATE (BSSID)
F: handle association request and response frames and housekeeping

I fail to see how this is handholding.

If you want handholding, look at atmel.  That's a sort-of "fullmac" part
in which you have to do a lot of handholding in the driver, including
handle the authentication state machine and tell the firmware what step
to go through.  For example, from atmel.c:

static void send_authentication_request(struct atmel_private *priv, u16 system,
					u8 *challenge, int challenge_len)
{
...
	if (priv->wep_is_on && priv->CurrentAuthentTransactionSeqNum != 1)
		/* no WEP for authentication frames with TrSeqNo 1 */
                header.frame_ctl |=  cpu_to_le16(IEEE80211_FCTL_PROTECTED);

	auth.alg = cpu_to_le16(system);

	auth.status = 0;
	auth.trans_seq = cpu_to_le16(priv->CurrentAuthentTransactionSeqNum);
	priv->ExpectedAuthentTransactionSeqNum = priv->CurrentAuthentTransactionSeqNum+1;
	priv->CurrentAuthentTransactionSeqNum += 2;

	if (challenge_len != 0)	{
		auth.el_id = 16; /* challenge_text */
		auth.chall_text_len = challenge_len;
		memcpy(auth.chall_text, challenge, challenge_len);
		atmel_transmit_management_frame(priv, &header, (u8 *)&auth, 8 + challenge_len);
	} else {
		atmel_transmit_management_frame(priv, &header, (u8 *)&auth, 6);
	}
...
}

Now _THATS_ what I call handholding.  We don't have to do any of that
here.

> Besides the fact that I think this is a very dumb thing to do in new
> hardware due to IEEE 802.11w (protected management frames) being well
> underway which you can't handle at all that way, I also don't see how
> you can claim that this is fullmac when you need to tell it every step
> of the way.

The driver certainly doesn't need to tell it "every step of the way".
The driver sends two commands, there are two steps.  It does _NOT_ deal
with management frames, challenge/response of Shared Key (like atmel),
or even the details of open system.

After that, it just shoves 802.3 framed packets into the device from
wlan_tx.c and gets 802.3 framed packets out from wlan_rx.c.

> The way I see it, you're telling the firmware to send an auth frame and
> then you wait for the firmware to come back and tell you "yes I have
> received a response" instead of just sending the frame yourself and then
> waiting for the response frame. So the difference is that you need to do
> a bit less frame parsing in the driver-stack.

Not quite; the driver doesn't have to deal with the Open System
handshake or the Shared Key handshake.  Instead of Airo's 1-step
process, this is a simple 2-step process.  Look at wlan_join.c,
wlan_associate().  That's what happens; nothing more.

> I could drown you in technical comments on everything starting from the
> way commands are sent, via the fact that there are large chunks of dead
> code (#ifdef REASSOCIATION), down to the formatting of comments and
> other trivialities, but I'd rather address the larger issues first.

And here, you'd be completely correct.  I could go into a long list of
things that need to be cleaned up.  Those of us working on the driver
certainly have a lot of work to do, no questions asked.  But...

I think you may have gotten the wrong impression about the part due to
the cruft in the driver.  We'll clean that stuff out, like the
ENTER/LEAVE and a host of other junk.  But what we'd like is comments on
how to clean it up and what other people think should get re-arranged,
and maybe how it could be integrated with d80211 more.

For example:

1) What, if any of this, could actually fit into the d80211 stack, given
the mostly fullmac operations of this part?  Other considerations
include:
   - Device requires firmware support for > 1 interface (rt2x00 also
       doesn't support more than one non-monitor mode interface,
       so this isn't that much of a problem)
   - Scanning must be done in 3 channel groups so you don't
       overflow the firmware results buffer and truncate BSS data
   - All packets are 802.3 framed (firmware does all 802.11 framing)
   - Firmware handles all 802.11 management frame tasks
   - There are separate firmware commands to join or start an adhoc
       network

2) How could we take advantage the region stuff and 802.11d code in
d80211?  I was also under the impression that the region code and
regulatory domain stuff was nowhere near decided on.  I believe there
are full sessions on this at the LWS II this weekend.

3) Could you enumerate your issues with the command dispatching?  Right
now, many of the commands are blocking, which is suboptimal.  This is an
artifact of the embedded history of the part.  We need to eventually fix
that and make the upper layers not expect to block stuff like auth/assoc
and scanning.  What other stuff are you thinking of?

Thanks!
Dan


