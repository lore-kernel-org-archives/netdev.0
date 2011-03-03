From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC LOL OMG] pfifo_lat: qdisc that limits dequeueing based on
 estimated link latency
Date: Thu, 03 Mar 2011 13:51:15 +0100
Message-ID: <1299156675.2983.65.camel@edumazet-laptop>
References: <20110228132341.194975v6ojrudl18@hayate.sektori.org>
	 <1299102850-2883-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bloat-devel@lists.bufferbloat.net
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59569 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019Ab1CCMvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 07:51:21 -0500
Received: by bwz15 with SMTP id 15so1103156bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 04:51:20 -0800 (PST)
In-Reply-To: <1299102850-2883-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 16:54 -0500, John W. Linville a =C3=A9c=
rit :
> This is a qdisc based on the existing pfifo_fast code.  The differenc=
e
> is that this qdisc limits the dequeue rate based on estimates of how
> many packets can be in-flight at a given time while maintaining a tar=
get
> link latency.
>=20
> This work is based on the eBDP documented in Section IV of "Buffer
> Sizing for 802.11 Based Networks" by Tianji Li, et al.
>=20
> 	http://www.hamilton.ie/tianji_li/buffersizing.pdf
>=20
> This implementation timestamps an skb as it dequeues it, then
> computes the service time when the frame is freed by the driver.
> An exponentially weighted moving average of per fragment service time=
s
> is used to restrict queueing delays in hopes of achieving a target
> fragment transmission latency.  The skb->deconstructor mechanism is
> abused in order to obtain packet service time estimates.
>=20
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> I took a whack at reimplementing my eBDP patch at the qdisc level.
> Unfortunately, it doesn't seem to work very well and I'm at a loss
> as to why... :-( Comments welcome -- maybe I'm doing something really
> stupid in the math and just can't see it.
>=20
> The skb->deconstructor abuse includes adding a union member in the sk=
b
> to record the qdisc->handle on the way out so that it can be used for
> accounting in the deconstructor -- thanks to Neil Horman for the
> suggestion!
>=20
> The reason I think this is an idea worth exploring is that existing
> qdisc code doesn't seem to account for the fact that the devices coul=
d
> be doing a lot of queueing behind them.  Even Jussi's recent
> sch_fifo_ewma post doesn't seem to take into account how long the dev=
ice
> holds-on to packets, which limits his ability to fight latency.
>=20
> Anyway, all comments appreciated!
>=20
> =20

Well, many issues in your patch.

skb destructor cannot be used like that (think about locking, and
various context where drivers actually free skbs (from interrupt, from
softirq, or even _before_ sending data on wire).

qdisc_lookup(skb->dev, skb->qdhandle) for example is only safe if run
with RTNL held. Its not meant to be used in fast path at all, but
management code only.

Being able to have a feedback on when a skb is freed (with a
notification of being delivered or dropped) is a recurring idea, so we
might design a stackable infrastructure.



