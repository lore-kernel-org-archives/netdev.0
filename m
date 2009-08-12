From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 1/2] mac802154: add a software MAC 802.15.4
 implementation
Date: Wed, 12 Aug 2009 17:06:05 +0400
Message-ID: <20090812130605.GA17169@doriath.ww600.siemens.net>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
 <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
 <1249914466.32614.13.camel@johannes.local>
 <20090811202304.GA6303@doriath.ww600.siemens.net>
 <1250023198.13529.69.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Sergey Lapin <slapin@ossfans.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:40774 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbZHLNGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 09:06:47 -0400
Content-Disposition: inline
In-Reply-To: <1250023198.13529.69.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2009 at 10:39:58PM +0200, Johannes Berg wrote:
> On Wed, 2009-08-12 at 00:23 +0400, Dmitry Eremin-Solenikov wrote:
> 
> > > That return value is strange.
> > 
> > The idea is that tx function can return info about errors during
> > transmit (busy channel, no ACK, etc).
> 
> Well, TX functions don't usually wait for anything so busy channel or no
> ack wouldn't be possible to return there but more like a TX status, and
> I think people are more used to NETDEV_TX_OK etc. return values. But
> it's your choice to make, obviously. If you want to return specific
> information like that though I would recommend making an enum so you get
> at least some type checking (and things like 'return -1' are more
> obviously wrong).

Currently we do all the work from special worker threads, so it's
possible for this callback to sleep. The error isn't yet propagated to
upper layers (there is a huge TODO there), anyway.

> 
> > > We've had no end to trouble with the master netdev, I suggest you look
> > > into the current mac80211 code and see if you can get rid of it.
> > 
> > What troubles w/ master netdev did you have had? I do still see the
> > master devices in mac80211. IIUC, it's planned to replace (from
> > management point of view) the mdev with wiphy instance, isn't it?
> 
> Mostly the userspace API was a mess, and you can't actually _do_
> anything with the master netdev. It also doesn't see all the frames,
> only outgoing. It's very strange.

We were using master netdevices for several purposes:
1) ip link add link mwpanX type wpan, so that we have out-of-box support
   for radio additions. That's really nice thing to have.

2) for SOCK_RAW implementation that can be used to send raw packets
   over-the-air/receive raw packets. I think we can use af_packet for
   this, but I'm still not sure about packet injection.

3) On the RX, we did send a clone of skb to the mdev and clones to slave
   interfaces, thus overcoming your last argument.

> The biggest problem is that it really clutters up the userspace API
> since you can't do any netdev things with it, it's just a placeholder.
> 
> In addition to that, you can't put anything into skb->cb, then push the
> frame to the master netdev, and expect things in skb->cb to still be
> there when the frame arrives at the master netdev. Not sure you do that
> (I hope not because that would be very buggy), but eventually you'll
> probably find that you do want that, etc.

Hmm. It works for us. Could you please tell me more about the problems
with skb->cb ?

> IMHO it's just better practise to not use it in situations like this
> where it can't be really used as a netdev.

We did use it as a netdev, however we can probably live without it.
I'll rethink this interface.

-- 
With best wishes
Dmitry

