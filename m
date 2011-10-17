From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Mon, 17 Oct 2011 09:02:54 +0200
Message-ID: <1318834974.2500.61.camel@edumazet-laptop>
References: <4E98B3B4.20406@hp.com>
	 <20111014.191845.232827637484150228.davem@davemloft.net>
	 <1318661682.2525.41.camel@edumazet-laptop>
	 <20111016.205329.560591300167306483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:51962 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab1JQHDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 03:03:01 -0400
Received: by wwn22 with SMTP id 22so3075125wwn.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 00:03:00 -0700 (PDT)
In-Reply-To: <20111016.205329.560591300167306483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 16 octobre 2011 =C3=A0 20:53 -0400, David Miller a =C3=A9cr=
it :

> So perhaps the best solution is to divorce truesize from such driver
> and device details?  If there is one calculation, then TCP need only
> be concerned with one case.
>=20
> Look at how confusing and useless tcp_adv_win_scale ends up being for
> this problem.
>=20
> Therefore I'll make the mostly-serious propsal that truesize be
> something like "initial_real_total_data + sizeof(metadata)"
>=20
> So if a device receives a 512 byte packet, it's:
>=20
> 	512 + sizeof(metadata)
>=20

That would probably OOM in stress situation, with thousand of sockets.

> It still provides the necessary protection that truesize is meant to
> provide, yet sanitizes all of the receive and send buffer overhead
> handling.
>=20
> TCP should be absoultely, and completely, impervious to details like
> how buffering needs to be done for some random wireless card.  Just
> the mere fact that using a larger buffer in a driver ruins TCP
> performance indicates a serious design failure.
>=20

I dont think its a design failure. Its the same problem when computing
the TCP window given the rcvspace (memory we allow to be consumed for
the socket) based on the MSS : If the sender uses 1-bytes frames only,
then receiver hit the memory limit and performance drops.

Right now our tcp-window tuning really assumes too much : perfect MSS
skb using _exactly_ MSS + sizeof(metadata), while we already know that
real slab cost is higher :=20

  __roundup_pow_of_two(MSS + sizeof(struct skb_shared_info)) +
  SKB_DATA_ALIGN(sizeof(struct sk_buff))

and now with paged frag devices :

  PAGE_SIZE + SKB_DATA_ALIGN(sizeof(struct sk_buff))

We assume sender behaves correctly and drivers dont use 64KB pages to
store a single 72-bytes frame

I would say the first thing TCP stack must respect is the memory limits
that the admin set for it. Thats what skb->truesize is for.

# cat /proc/sys/net/ipv4/tcp_rmem
4096	87380	4127616

In this case, we allow up to 4Mbytes or receiver memory per session.
Not 20 or 30 Mbytes...

We must translate this to a TCP window, suitable for current hardware.
