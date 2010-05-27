From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Thu, 27 May 2010 06:18:46 +0200
Message-ID: <1274933926.2542.26.camel@edumazet-laptop>
References: <20100525115813.GA28063@kryten>
	 <1274801229.5020.80.camel@edumazet-laptop> <20100526031943.GA28295@kryten>
	 <20100526.005634.48509140.davem@davemloft.net>
	 <1274868776.2672.96.camel@edumazet-laptop>  <20100527035617.GB28295@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52062 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724Ab0E0ESv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 00:18:51 -0400
Received: by wyb29 with SMTP id 29so3822221wyb.19
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 21:18:50 -0700 (PDT)
In-Reply-To: <20100527035617.GB28295@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 mai 2010 =C3=A0 13:56 +1000, Anton Blanchard a =C3=A9crit :
> Hi Eric,
>=20
> > You are 100% right David, maybe we should add a test when changing
> > sk_forward_alloc to test if socket is locked (lockdep only test), b=
ut
> > that's for 2.6.36 :)
>=20
> Thanks for the patch, unfortunately I can still hit the WARN_ON. I'm =
somewhat
> confused by the two stage locking in the socket lock (ie sk_lock.sloc=
k and
> sk_lock.owned).
>=20
> What state should the socket lock be in for serialising updates of
> sk_forward_alloc? In some cases we appear to update it with sk_lock.s=
lock =3D
> unlocked, sk_lock.owned =3D 1:
>=20
> NIP [c0000000005b4ad0] .sock_queue_rcv_skb
> LR [c0000000005b4acc] .sock_queue_rcv_skb
> Call Trace:
> [c0000000005f9fcc] .ip_queue_rcv_skb
> [c00000000061d604] .__udp_queue_rcv_skb
> [c0000000005b1a38] .release_sock
> [c0000000006205f0] .udp_sendmsg
> [c0000000006290d4] .inet_sendmsg
> [c0000000005abfb4] .sock_sendmsg
> [c0000000005ae9dc] .SyS_sendto
> [c0000000005ab6c0] .SyS_send
>=20
> And other times we update it with sk_lock.slock =3D locked, sk_lock.o=
wned =3D 0:
>=20
> NIP [c0000000005b2b6c] .sock_rfree
> LR [c0000000005b2b68] .sock_rfree
> Call Trace:
> [c0000000005bca10] .skb_free_datagram_locked
> [c00000000061fe88] .udp_recvmsg
> [c0000000006285e8] .inet_recvmsg
> [c0000000005abe0c] .sock_recvmsg
> [c0000000005ae358] .SyS_recvfrom
>=20
> I see we sometimes take sk_lock.slock then check the owned field, but=
 we
> aren't doing that all the time.
>=20

Old rule was :

A Process context was using=20
lock + test_and_set_or_sleep + unlock (sk_lock.slock =3D unlocked,
sk_lock.owned =3D 1)

softirq handler was using :
(sk_lock.slock =3D locked, sk_lock.owned =3D0)

I added a shortcut, but it seems wrong as is

Process context :

lock only (sk_lock.slock =3D locked, sk_lock.owned =3D ???)

So I should add a test on owned. If set (by another thread), we should =
take the slow path.

Thanks !


