From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Tue, 12 Jan 2010 07:50:59 +0000
Message-ID: <20100112075059.GA6628@ff.dom.local>
References: <4B4B2FBD.5090007@ring3k.org> <20100111084504.7adb5a1e@nehalam> <20100111220753.GC3139@del.dom.local> <20100111.161419.138918787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, mikem@ring3k.org, flyboy@gmail.com,
	rjw@sisk.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:43906 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab0ALHvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 02:51:08 -0500
Received: by ey-out-2122.google.com with SMTP id 4so866503eyf.5
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 23:51:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100111.161419.138918787.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2010 at 04:14:19PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 11 Jan 2010 23:07:54 +0100
> 
> > I don't agree: you both try to make this check more specific.
> > Actually, since this problem is quite tricky, I wondered about
> > making it more genaral and visible for other maintainers by
> > adding something like netif_wake_queue_present() with the
> > check and some comment.
> 
> This detracts from the real problem.
> 
> The issue is that we have a code path bringing a device down, which
> uses helper routines which are meant to be executed when the device is
> up and functioning normally.
> 
> That's the bug.
> 
> No other driver does silly things like call helper routines which wake
> the TX queue when taking the chip down.
> 
> Fix that, not the immediate symptoms.  Write a routine that
> unconditionally clears the TX queue, frees the packets, etc. and
> has none of the wake logic.
> 
> That's what most other driver do, and those that don't should be
> fixed similarly.

As I wrote it's tricky and could be hard to track even if you "heard"
about it, e.g. Mike moves netif_wake_queue() to another place in his
last proposal, but it still can run after netif_device_detach() until 
napi_synchronize() in sky2_down().

I think, I can see similar problems e.g. in gianfar or netxen, where
napi_disable() is done after netif_device_detach(), especially in
suspend procedures (there might be less severe (than oops) effects
yet). IMHO, it all looks simply error prone (sometime you have to
know a driver well to track all possible paths to say it's really
safe).

In the meantime users are endangered with known oopses or at least
suspend problems, while we know the reasons, can fix it (even
temporarily) with one-liners, but wait for the right fixes. (Btw,
such fixes might require a significant rewrite, risking inserting
new bugs, so I doubt they are "right" for -stable.) Anyway, I'm
OK with this (I hope what should be done will be done, and I
don't have sky2 ;-)

Cheers,
Jarek P.
