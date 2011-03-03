From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inetpeer with create==0
Date: Thu, 03 Mar 2011 07:51:47 +0100
Message-ID: <1299135107.2456.7.camel@edumazet-laptop>
References: <20110302.204545.193730647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42715 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab1CCGvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 01:51:52 -0500
Received: by fxm17 with SMTP id 17so803513fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 22:51:51 -0800 (PST)
In-Reply-To: <20110302.204545.193730647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 20:45 -0800, David Miller a =C3=A9crit =
:
> Eric, I was profiling the non-routing-cache case and something that s=
tuck
> out is the case of calling inet_getpeer() with create=3D=3D0.
>=20
> If an entry is not found, we have to redo the lookup under a spinlock
> to make certain that a concurrent writer rebalancing the tree does
> not "hide" an existing entry from us.
>=20
> This makes the case of a create=3D=3D0 lookup for a not-present entry
> really expensive.  It is on the order of 600 cpu cycles on my
> Niagara2.
>=20

Well, your test assumes all data is already on cpu caches ?

I'll take a look, but my reasoning was that the real cost in DDOS
situation is to bring data into caches. With a 20 depth, cache misses
costs are the problem.

The second lookup was basically free.

> I added a hack to not do the relookup under the lock when create=3D=3D=
0
> and it now costs less than 300 cycles.
>=20

Hmm... I'm curious you send this hack to me ;)

> This is now a pretty common operation with the way we handle COW'd
> metrics, so I think it's definitely worth optimizing.
>=20
> I looked at the generic radix tree implementation, and it supports
> full RCU lookups in parallel with insert/delete.  It handles the race
> case without the relookup under lock because it creates fixed paths
> to "slots" where nodes live using shifts and masks.  So if a path
> to a slot ever existed, it will always exist.
>=20
> Take a look at lib/radix-tree.c and include/linux/radix-tree.h if
> you are curious.
>=20
> I think we should do something similar for inetpeer.  Currently we
> cannot just use the existing generic radix-tree code because it only
> supports indexes as large as "unsigned long" and we need to handle
> 128-bit ipv6 addresses.


