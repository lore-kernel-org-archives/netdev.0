From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neighbour table overflow errors. leaking neighbours I think
Date: Sat, 14 Jan 2012 08:48:29 +0100
Message-ID: <1326527309.5287.9.camel@edumazet-laptop>
References: <CAKedQg_qWUgXzsTrQJ0NGoxzKHaQvAnZ2pztzAXVHbq9H4gLRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Bruce Jones <brucerjones@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57373 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab2ANHse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 02:48:34 -0500
Received: by wgbds12 with SMTP id ds12so3825000wgb.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 23:48:33 -0800 (PST)
In-Reply-To: <CAKedQg_qWUgXzsTrQJ0NGoxzKHaQvAnZ2pztzAXVHbq9H4gLRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 13 janvier 2012 =C3=A0 17:29 -0700, Bruce Jones a =C3=A9cri=
t :
> I am seeing neighbour table overflow messages so I began exploring
> neighbour structure reference counts to try and understand the issue
> and see why they are not being reclaimed by the garbage collector.
> I'm pretty new to the kernel so have just been sprinkling printks
> around to try to understand how this all works.
>=20
> The box is running 2.6.32.50.  I know that is old, but the current
> code for 3.2.1 looks like it is doing basically the same thing.
>=20
> I am running a test that is blasting the box with lots of bogus tcp
> packets.  This results in calls to tcp_v4_send_reset().  That then
> calls ip_send_reply() which calls ip_route_output_key() which causes =
a
> new neighbour entry to be allocated.  Then back in ip_send_reply(),
> ip_append_data() is called.  I find that this call is failing and
> returning ENOBUFS.   The return value from ip_append_data() is not
> checked in ip_send_reply() so nothing is cleaned up.  I see that othe=
r
> calls to ip_append_data() do check the return value and call some
> cleanup function.  Those cleanup functions do things like release skb=
,
> dsts, etc.  I image I might be leaking those things too, though I hav=
e
> only looked at nieghbours.  My question is should there be a similar
> function to clean up if ip_append_data fails() in ip_send_reply() or
> is there a reason that that particular call doesn't check for errors
> when the others do?
>=20

ip_send_reply() does the necessary route cleanup.

I see no leak there.


void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
                   const struct ip_reply_arg *arg, unsigned int len)
{
=2E..
        rt =3D ip_route_output_key(sock_net(sk), &fl4);
        if (IS_ERR(rt))
                return;
	bh_lock_sock(sk);

	...
	ip_append_data(sk, &fl4, ip_reply_glue_bits, arg->iov->iov_base,
			len, 0,
                       &ipc, &rt, MSG_DONTWAIT);
	...

	bh_unlock_sock(sk);

	ip_rt_put(rt); // HERE
}


What is your network configuration ?  (ip ro)

I suspect your are attached to a /16 network and you forgot to increase
neigh limits.

# grep . /proc/sys/net/ipv4/neigh/default/gc_thresh*
/proc/sys/net/ipv4/neigh/default/gc_thresh1:128
/proc/sys/net/ipv4/neigh/default/gc_thresh2:512
/proc/sys/net/ipv4/neigh/default/gc_thresh3:1024
