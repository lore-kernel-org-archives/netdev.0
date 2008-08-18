From: David Miller <davem@davemloft.net>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Sun, 17 Aug 2008 23:52:37 -0700 (PDT)
Message-ID: <20080817.235237.24119245.davem@davemloft.net>
References: <20080806.220911.91192536.davem@davemloft.net>
	<20080807100910.GA12391@ff.dom.local>
	<20080807143654.16955ngk5tnp5kzk@hayate.ip6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750885AbYHRGwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 02:52:37 -0400
In-Reply-To: <20080807143654.16955ngk5tnp5kzk@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Date: Thu, 07 Aug 2008 14:36:54 +0300

> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
> 
> > There is also some doubt about differences between ->enqueue() and
> > ->requeue() wrt. kfree_skb() and returning codes: maybe it would be
> > better (for uniformity) to add similar changes to requeues (and
> > dev_requeue_skb()) as well?
> >
> 
> I think requeue should be changed to return same as enqueue, netem even
> uses requeue as enqueue replacement for packet reordering. Maybe add
> new function qdisc_requeue_tree to handle freeing and masking flags and
> change outside uses of requeue to use it (qdisc_peek_len in hfsc,
> sch_atm_dequeue, dev_requeue_skb).

Yes, I in fact stumbled through this stuff while working on
the HTB/TBF ->enqueue() fixes.

It's not going to be easy to cure this completely and we'll
have to work in stages.

What I'll do tonight is first make a simple set of fixes,
like fixing these things to use the proper NET_XMIT_*
values instead of constant "0" and stuff like that.

Next I'll do the real ->requeue() return value audit.

As an aside I still think we really don't need ->requeue(),
once we pull a packet out of ->enqueue() it's out of the
packet scheduler's realm and we can definitely hold onto it
as the next packet to give to the device.  This netem code
is really an abuse of this ->requeue() callback.  It was
never meant to be used like that.

In fact, as I look at how TBF and NETEM want to use ->requeue() they
could just the same implement it using my suggested alternative for
->requeue() which is just an SKB list ala gso_list hung off of the
qdisc.

They all just want to "insert to front" when they call ->requeue(),
nothing more.

In the TBF case, it wants to defer the send to some time in the
future.  But that would work in my scheme as well as it would now.
TBF's ->enqueue() would return NULL yet stick the packet into
the qdisc->skb_list, the watchdog is schedules will run the queue
when it fires.

So, in short, the more I think about it the more I think we can
certainly kill off ->requeue() and all of it's resulting complexity.
