From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sock_def_readable() and friends RCU
 conversion
Date: Sat, 01 May 2010 10:03:31 +0200
Message-ID: <1272701011.2230.134.camel@edumazet-laptop>
References: <1272549408.4258.189.camel@bigi> <1272573383.3969.8.camel@bigi>
	 <1272574909.2209.150.camel@edumazet-laptop>
	 <20100430.163519.133415203.davem@davemloft.net>
	 <1272697367.2230.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, xiaosuo@gmail.com, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org, eilong@broadcom.com,
	bmb@athenacr.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36309 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358Ab0EAIDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 04:03:38 -0400
Received: by bwz19 with SMTP id 19so504660bwz.21
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 01:03:36 -0700 (PDT)
In-Reply-To: <1272697367.2230.106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 01 mai 2010 =C3=A0 09:02 +0200, Eric Dumazet a =C3=A9crit :
> Le vendredi 30 avril 2010 =C3=A0 16:35 -0700, David Miller a =C3=A9cr=
it :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 29 Apr 2010 23:01:49 +0200
> >=20
> > > [PATCH net-next-2.6] net: sock_def_readable() and friends RCU con=
version
> >=20
> > So what's the difference between call_rcu() freeing this little wai=
tqueue
> > struct and doing it for the entire socket?
> >=20
> > We'll still be doing an RCU call every socket destroy, and now we a=
lso have
> > a new memory allocation/free per connection.
> >=20
> > This has to show up in things like 'lat_connect' and friends, does =
it not?
>=20
> Before patch :
>=20
> lat_connect -N 10 127.0.0.1
> TCP/IP connection cost to 127.0.0.1: 27.8872 microseconds
>=20
> After :
>=20
> lat_connect -N 10 127.0.0.1
> TCP/IP connection cost to 127.0.0.1: 20.7681 microseconds
>=20
> Strange isnt it ?
>=20
> (special care should be taken with this bench, as it leave many socke=
ts
> in TIME_WAIT state, so to get consistent numbers we have to wait a wh=
ile
> before restarting it)


Oops, this was with the other patch (about dst no_refcounting in input
path), sorry.

With the "sock_def_readable() and friends RCU conversion" patch I got :

lat_connect -N 10 127.0.0.1
TCP/IP connection cost to 127.0.0.1: 27.6244 microseconds


Anyway, this lat_connect seems very unreliable (lot of variance)

with linux-2.6.31, ~33 us
with linux-2.6.33, ~30 us

David, I also need this RCU thing in order to be able to group all
wakeups at the end of net_rx_action().

Plan was to use RCU, so that I dont need to increase sk_refcnt when
queueing a "wakeup" (and decrease sk_refcnt a long time after)

Previous attempt was a bit hacky,
http://patchwork.ozlabs.org/patch/24179/

I expect 2010 one will be cleaner :)


