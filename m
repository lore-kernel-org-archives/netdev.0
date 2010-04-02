From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 09:29:53 +0200
Message-ID: <1270193393.1936.52.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
	 <j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:34246 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932234Ab0DBH35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 03:29:57 -0400
Received: by bwz1 with SMTP id 1so1338345bwz.21
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 00:29:56 -0700 (PDT)
In-Reply-To: <j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 avril 2010 =C3=A0 13:04 +0800, Changli Gao a =C3=A9crit =
:

> for sending packets, how about letting sender compute the rxhash of
> the packets from the other side if the rxhash of socket hasn't been
> set yet. I is better for client applications.
>=20



> For router and bridge, the current RPS can work well, but not for
> server or client applications. So I propose a new socket option to ge=
t
> the rps cpu of the packets received on a socket. It may be like this:
>=20


Your claim of RPS being not good for applications is wrong, our test
results show an improvement as is. Maybe your applications dont scale,
because of bad habits, or collidings heuristics, I dont know.

> int cpu;
> getsockopt(sock, SOL_SOCKET, SO_RPSCPU, &cpu, sizeof(cpu));
>=20
> As Tom's patch did, rxhash is recorded in socket. When the call above
> is made, rps_map is looked up to find the RPSCPU for that hash. Once
> we get the cpu of the current connection, for a TCP server, it can
> dispatch the new connection to the processes which run on that CPU.
> the server code will be like this:
>=20
> fd =3D accpet(fd, NULL, NULL);
> getsockopt(fd, SOL_SOCKET, SO_RPSCPU, &cpu, sizeof(cpu));
> asyncq_enqueue(work_queue[cpu], fd);
>=20
> For a client program, the rxhash can be got after the first packet of
> the connection is sent. So the client code will be:
>=20
> fd =3D connect(fd, &addr, addr_len);
> getsockopt(fd, SOL_SOCKET, SO_RPSCPU, &cpu, sizeof(cpu));
> asyncq_enqueue(work_queue[cpu], fd);
>=20
> I do think this idea is easier to understood. I'll cook a patch later
> if it is welcomed.
>=20

Whole point of Herbert patches is you dont need to change applications
and put complex logic in them, knowing exact machine topology.

Your suggestion is very complex, because you must bind each thread on a
particular cpu, and this is pretty bad for many reasons. We should allo=
w
thread migrations, because scheduler or admin know better than the
application.

Application writers should rely on standard kernel mechanisms, and
schedulers, because an application have a limited point of view of what
really happens on the machine.




