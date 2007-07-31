From: Pavel Machek <pavel@ucw.cz>
Subject: Re: ATA over ethernet swapping
Date: Wed, 1 Aug 2007 00:27:42 +0200
Message-ID: <20070731222742.GR2087@elf.ucw.cz>
References: <20070731135831.GA4604@elf.ucw.cz> <20070731150324.GE3206@coraid.com> <20070731152924.GM2087@elf.ucw.cz> <20070731162140.GI3206@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel list <linux-kernel@vger.kernel.org>, ak@suse.de,
	Netdev list <netdev@vger.kernel.org>
To: "Ed L. Cashin" <ecashin@coraid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:35701 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762346AbXGaW2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 18:28:21 -0400
Content-Disposition: inline
In-Reply-To: <20070731162140.GI3206@coraid.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> ...
> > Is the protocol documented somewhere? aoe.txt only points at
> > HOWTO... aha, protocol is linked from wikipedia.
> > http://www.coraid.com/documents/AoEr10.txt ... perhaps that should be
> > linked from aoe.txt, too?
> 
> Perhaps.  Most people reading the aoe.txt file won't need to refer to
> the protocol itself, though.

Some of your users are developers, too :-). Should I generate a patch?

> > Hmm, aoe protocol is really trivial. Perhaps netpoll/netconsole
> > infrastructure could be used to create driver good enough for
> > swapping? (Ok, it would not neccessarily perform too well, but... we'd
> > simply wait for the reply synchronously. It should be pretty simple).
> 
> I think that in general you still need a way to receive write
> confirmations without allocating memory, and the driver can't provide
> that mechanism.  The problem is that when memory is scarce, writes of
> dirty data must be able to complete, but because memory is scarce,
> there might not be enough to receive and process packets write-reponse
> packets, and the driver has no way of affecting the situation.  That's
> why I think a callback could work: The network layer could allow
> storage drivers to register a callback that recognizes write
> responses.

Hmm, ok, it is not as simple as I thought. include/linux/netpoll.h
already includes mechanism to notify interested parties really soon,
but drivers still call dev_alloc_skb() before that.

> Usually the callback would not be used, but if free pages became so
> scarce that network receives could not take place in a normal fashion,
> the (zero or few) registered callbacks would be used to quickly
> determine whether each packet was a write response.  The distinction
> is important, because write responses can result in the freeing of
> pages.

Hmm, adding GFP_GIVE_ME_EMERGENCY_POOLS to dev_alloc_skb(), then doing

...

int netif_rx(struct sk_buff *skb)
{
	struct softnet_data *queue;
	unsigned long flags;

	/* if netpoll wants it, pretend we never saw it */
	if (netpoll_rx(skb))
		return NET_RX_DROP;

	if (memory_is_still_very_low())
		return NET_RX_DROP;

...should do the trick. Would something like that be acceptable to
network people?
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
