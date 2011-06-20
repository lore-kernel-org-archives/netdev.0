From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] mv643xx_eth: fix race in trasmit path.
Date: Mon, 20 Jun 2011 18:31:57 +0200
Message-ID: <1308587517.29160.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <cover.1308555865.git.richard.cochran@omicron.at>
	 <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
	 <1308578878.32446.31.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, stable@kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33596 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493Ab1FTOcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 10:32:02 -0400
Received: by wyb38 with SMTP id 38so1697205wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 07:32:01 -0700 (PDT)
In-Reply-To: <1308578878.32446.31.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 16:07 +0200, Maxime Bizon a =C3=A9crit :
> On Mon, 2011-06-20 at 09:48 +0200, Richard Cochran wrote:
>=20
> Hi Richard,
>=20
> > Because the socket buffer is freed in the completion interrupt, it =
is not
> > safe to access it after submitting it to the hardware.
>=20
> I don't see why.
>=20
> skb is freed from txq_reclaim() which grabs the tx queue lock before,
> (hence the lockless __skb_queue_xxx() in both functions)
>=20
> What am I missing ?

You are right, this driver still takes tx queue lock in its TX
completion path.

txq_reclaim() can currently run for a very long time, blocking other
cpus to make progress if blocked on tx queue lock.

So consider this patch as a cleanup :

Its better to make all drivers behave the same way

1) Either increment tx stats in their start_xmit(), and making sure the=
y
dont access skb->len too late.

2) increment tx stats in their TX completion path.

Then we can work on making TX completion path not taking tx queue lock
in its fast path.


