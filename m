From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] socket sk_sndmsg_page waste
Date: Tue, 06 Dec 2011 17:15:17 +0100
Message-ID: <1323188117.2448.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323154416.2467.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61026 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab1LFQPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 11:15:22 -0500
Received: by mail-ee0-f46.google.com with SMTP id q14so3053121eea.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 08:15:21 -0800 (PST)
In-Reply-To: <1323154416.2467.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 d=C3=A9cembre 2011 =C3=A0 07:53 +0100, Eric Dumazet a =C3=A9=
crit :
> TCP can steer one page of memory per socket to cook outgoing frames.
>=20
> This means a machine handling long living sockets can consume a lot o=
f
> ram.
>=20
> 1.000.000 tcp sockets : up to 4GB of allocated memory, if some writes
> had been done on these sockets.
>=20
> It would make sense to use a per thread page as a pool, instead of a =
per
> socket pool, and remove sk_sndmsg_page/off fields.
>=20
> Problem with this strategy is impact outside of net tree, and a cost =
at
> thread creation/destruction.
>=20
> [ But this could be used in fs/pipe.c or fs/splice.c code..., so that
> small writes() dont allocate a full page but try to reuse the "per
> task_struct" page ]
>=20
>=20

Another idea would be to use a percpu variable, to get proper NUMA
affinity as well, and no extra cost at thread create/delete time.

Only 'problem' is we can sleep (pagefault) in
skb_copy_to_page_nocache(), so special care must be taken (disabling
preemption wont prevent another thread on same cpu can use the same
page)
