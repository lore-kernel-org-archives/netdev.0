From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Sat, 8 Oct 2011 12:35:05 +0200
Message-ID: <20111008103503.GA2148@netboy.at.omicron.at>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
 <20111007.133356.489094996618032061.davem@davemloft.net>
 <20111008075719.GA2284@netboy.at.omicron.at>
 <1318061808.3991.12.camel@jlt3.sipsolutions.net>
 <1318064238.5276.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59337 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab1JHKfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 06:35:09 -0400
Received: by bkbzt4 with SMTP id zt4so5959416bkb.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 03:35:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318064238.5276.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 08, 2011 at 10:57:18AM +0200, Eric Dumazet wrote:
> Le samedi 08 octobre 2011 =E0 10:16 +0200, Johannes Berg a =E9crit :
>=20
> > I'm not terribly familiar with struct sock. Looking at it, I'm a bi=
t
> > confused by skb_orphan() -- it doesn't put the sock reference. So a=
re
> > sockets not refcounted for skbs in this way? They seem to use
> > sock_wfree() which does a bit more than this it seems, and I don't =
see
> > it using sk_refcnt anywhere so I'm a bit confused now.

Me, too.

> Check following commit changelog to get some information on this.

Thanks, Eric, that does help explain.

>     We use this sock_hold()/sock_put() so that sock freeing
>     is delayed until all tx packets are completed.
>    =20
>     As we also update sk_wmem_alloc, we could offset sk_wmem_alloc
>     by one unit at init time, until sk_free() is called.
>     Once sk_free() is called, we atomic_dec_and_test(sk_wmem_alloc)
>     to decrement initial offset and atomicaly check if any packets
>     are in flight.
>    =20
>     skb_set_owner_w() doesnt call sock_hold() anymore

So, if I understand, then I can solve my particular problem by doing:

* skb_clone_tx_timestamp
	clone =3D skb_clone(skb, GFP_ATOMIC);
	skb_set_owner_w(clone, sk)
// instead of
//	clone->sk =3D sk;
	phydev->drv->txtstamp(phydev, clone, type);

* skb_complete_tx_timestamp
	serr->ee.ee_errno =3D ENOMSG;
	serr->ee.ee_origin =3D SO_EE_ORIGIN_TIMESTAMPING;
// just remove this:
//	skb->sk =3D NULL;
	err =3D sock_queue_err_skb(sk, skb);

The only problem(?) I see is that it violates the rules from sock.h,
quoted below. The cloned tx skb destined for the error queue would be
budgeted to sk_wmem_alloc while wait for the time stamp. But maybe we
can allow this?

from sock.h:
/*
 * Socket reference counting postulates.
 *
 * * Each user of socket SHOULD hold a reference count.
 * * Each access point to socket (an hash table bucket, reference from =
a list,
 *   running timer, skb in flight MUST hold a reference count.
                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                   /
BTW, no longer true.

 * * Packets, delivered from outside (from network or from another proc=
ess)
 *   and enqueued on receive/error queues SHOULD NOT grab reference cou=
nt,
 *   when they sit in queue. ~~~~~~~~~~~~~~~~~~~~~~~

Want to break/bend this rule.

Thanks,
Richard
