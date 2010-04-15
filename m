From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 06:14:06 +0200
Message-ID: <1271304846.16881.1881.camel@edumazet-laptop>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
	 <1271302133.16881.1814.camel@edumazet-laptop>
	 <1271302846.16881.1828.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:57385 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844Ab0DOEON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 00:14:13 -0400
Received: by bwz25 with SMTP id 25so998309bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 21:14:12 -0700 (PDT)
In-Reply-To: <1271302846.16881.1828.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 05:40 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 15 avril 2010 =C3=A0 05:28 +0200, Eric Dumazet a =C3=A9crit =
:
> > > =20
> > > +	per_cpu(netdev_rx_stat, cpu).dropped++;
> >=20
> > This is a bit expensive, and could be a queue->rx_stat.dropped++
> > if netdev_rx_stat is moved inside queue structure.
>=20
> Hmm, this is not really needed, this event is the slow path and shoul=
d
> almost never happen. This part of your fix is fine.
>=20
>=20
> -

Oh well, I revert this comment, we need a mutual exclusion between cpus
if we dont want to miss some increments, even in a slow path.

__get_cpu_var(netdev_rx_stat).field++; is safe because updated only by
this cpu.

Once you use per_cpu(netdev_rx_stat, cpu).field++; you need a
synchronization since this is not atomic.

so queue->dropped++ is safer and faster too (inside the rps_lock
section)


