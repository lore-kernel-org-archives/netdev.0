From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: d80211-drivers pull request (week-48)
Date: Wed, 13 Dec 2006 00:39:55 +0100
Message-ID: <20061212233955.GB8487@p15091797.pureserver.info>
References: <200612110101.58710.flamingice@sourmilk.net> <457E00D4.7010201@gentoo.org> <200612112120.58157.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:59700 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932582AbWLMALY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 19:11:24 -0500
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200612112120.58157.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-12-11 21:20 Michael Wu wrote:

> On Monday 11 December 2006 20:07, Daniel Drake wrote:
> > Michael Wu wrote:
> > >       zd1211rw-d80211: Use ieee80211_tx_status
> >
> > I've thought some more about this and I'm not so sure that this is the
> > right approach.
> >
> > Can't devicescape be taught that the ZD1211 handles retries in hardware
> > and the stack doesn't need to worry about it?
> >
> All 802.11 devices have to be able to handle retries in hardware to do random 
> backoff properly. Still, the stack wants to know what happened.
> 
> > I think I remember reading that devicescape uses failed transmission
> > rate in the rate adjustment calculations. Even without this racy ack
> > system we can still achieve that - the device tells us every time it
> > retries a transmit, and then it sends a special interrupt at the end
> > saying that all retries failed.
> >
> Yes, but it also uses successful transmissions in rate adjustment.
> 
> I don't think this race is such a big deal. It will only happen when someone 
> is really trying to mess with the link, and would cause the rate control to 
> jump to the highest speed. However, if someone is really trying to mess with 
> the link this way, the stability of the link is in trouble anyways. Wait for 
> stations to send frames, and send an ack for every unicast frame - everyone 
> will get confused. To actually mess with this code, the attacker would have 
> to transmit acks nearly continuously as it can't tell exactly when is a good 
> time to screw things up, and the driver recovers as soon as the queue is 
> emptied. Someone transmitting all the time is a problem for all wireless 
> cards. :)

Just two observations:

1) The retry-failed-interrupt message contains the destination
   MAC address of the transmitted message. 
2) We could get easily two acks for the same transmission.
3) We could get ACKs or retry-failed-interrupts for packets, for
   which no status has been requested by the upper layers.

I suggest that the skbs as buffer for the URB transmissions. Check
ACK/NAK for all packets, but still prepare the status only for
packets, which requested it. We could add a timeout value to each
packet to make sure, that we don't ACK or NAK packets, which have
been overdue.

-- 
Uli Kunitz
