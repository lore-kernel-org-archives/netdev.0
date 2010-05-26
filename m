From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Wed, 26 May 2010 07:18:35 +0200
Message-ID: <1274851115.25136.7.camel@edumazet-laptop>
References: <20100525115813.GA28063@kryten>
	 <1274801229.5020.80.camel@edumazet-laptop>  <20100526031943.GA28295@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:39333 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab0EZFSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 01:18:43 -0400
Received: by wwb13 with SMTP id 13so34622wwb.19
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 22:18:41 -0700 (PDT)
In-Reply-To: <20100526031943.GA28295@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 mai 2010 =C3=A0 13:19 +1000, Anton Blanchard a =C3=A9cri=
t :
> Hi,
>=20
> > > Which is:
> > >=20
> > >         WARN_ON(sk->sk_forward_alloc);
> > >=20
> >=20
> > Yes, the infamous one :)
> >=20
> > Is it reproductible ? What kind of workload is it ?
> > What is the NIC involved ?
>=20
> It was running sysbench against a postgresql database over localhost.=
 In
> each case I checked, sk_forward_alloc was less than one page.

ok. I am a bit surprised postgresql uses UDP

>=20
> I notice we update sk_forward_alloc in sk_mem_charge and sk_mem_uncha=
rge.
> Since it isn't an atomic variable I went looking for a lock somewhere=
 in
> the call chain (first thought was the socket lock). I couldn't find
> anything, but I could easily be missing something.
>=20

UDP path uses socket lock indeed to protect sk_forward_alloc non atomic
updates.

Check skb_free_datagram_locked() for example : sk_mem_reclaim_partial()
is called inside the lock_sock_bh/unlock_sock_bh protected section, and
*after* the uncharge done by skb_orphan(). This function was changed
recently, so maybe your platform hit some bug somewhere.

In receive path, we hold the socket lock while calling
sock_queue_rcv_skb()



