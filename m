From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
Date: Thu, 8 Oct 2009 13:20:29 -0400
Message-ID: <20091008172029.GB23928@hmsreliant.think-freely.org>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <4ACD3AC8.608@gmail.com> <20091008135435.GA23928@hmsreliant.think-freely.org> <4ACDFB1C.4090107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56437 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758907AbZJHRVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 13:21:10 -0400
Content-Disposition: inline
In-Reply-To: <4ACDFB1C.4090107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 08, 2009 at 04:45:48PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> >>> +	if (check_drops) {
> >>> +		skb =3D skb_recv_datagram(sk, flags|MSG_PEEK,
> >>> +				flags & MSG_DONTWAIT, &err);
> >> 	Ouch, this is too expensive, please find another way :)
> >>
> >>> +		if (skb) {
> >>> +			gap =3D skb->dropcount;
> >>> +			consume_skb(skb);
> >>> +		}
> >>> +	}
> >>> +
> > I'm not sure that I see the expense here, and what expense there is=
, I don't see
> > how it avoidable.  In order to do this reporting at the socket leve=
l, we need to
> > look at the skb at the head of the receive queue.  But we need to d=
o so in a way
> > thats consistent with the flags being passed in (i.e. if this is a =
blocking
> > socket, we need to block here until something is available to read)=
=2E  Then its
> > just an atomic_inc on skb->users, followed by a dec in the consume_=
skb.  I could
> > implement the logic for DONTWAIT myself, and skip the atomic_inc/de=
c, but I'm
> > not sure thats much of a savings.  If you have another thought, I'm=
 certainly
> > open to it.
>=20
> The expense is a lot of atomic ops. You forgot the lock, so thats fou=
r atomic ops.
>=20
> You can do all this with no extra atomics.
>=20
> All you need is some function with (struct msghdr *msg, struct sock *=
sk, struct sk_buff *skb)
> triplet.
>=20
> hint : sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struc=
t sk_buff *skb)
>=20
> Could be renamed to something else if you want...
>=20
> sock_recv_ts_or_drops() or whatever
Ok, but that will require moving the flag that we're triggering this on=
 down
into the sock structure, and not doing the check up in __sock_recvmsg, =
but I
suppose thats fine.  Ok, I'll repost soon.  Thanks!
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
