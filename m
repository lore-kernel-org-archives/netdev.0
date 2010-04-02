From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 14:01:48 +0200
Message-ID: <1270209708.1989.30.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
	 <j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com>
	 <1270193393.1936.52.camel@edumazet-laptop>
	 <o2j412e6f7f1004020358mf9455fcbqdbb2d762d94a7aa2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:49056 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017Ab0DBMBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 08:01:54 -0400
Received: by bwz9 with SMTP id 9so1543027bwz.29
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 05:01:52 -0700 (PDT)
In-Reply-To: <o2j412e6f7f1004020358mf9455fcbqdbb2d762d94a7aa2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 avril 2010 =C3=A0 18:58 +0800, Changli Gao a =C3=A9crit =
:

> Yes, it is more complex. Some high performance server use the
> event-driven model, such as memcached, nginx and lighttpd. This model
> has high performance on UP with no doubt, and on SMP they usually use
> one individual epoll fd for each Core/CPU, and the acceptor dispatche=
s
> works among these epoll fds. This program model is popular, and  it
> bypass the  system scheduler. I think the socket option SO_RPSCPU can
> help this kind of applications work better, why not do that?
> Compatility with other Unixes isn't a good cause, for high performanc=
e
> applications, there are always lots of OS special features used. For
> example: epoll vs kqueue, tcp defer accept vs accept filter.
>=20
>=20

This dispatch things in UserLand is a poor workaround even if its
popular (because people try to code portable applications), the hard
work is already done, this increases latencies and bus traffic.

=46or short works, that is too expensive.

If you really want to speedup memcached/DNS_server like apps, you might
add a generic mechanism in kernel to split queues of _individual_
socket.

Aka multiqueue capabilities at socket level. Combined to multiqueue
devices or RPS, this can be great.


That is, an application tells kernel in how many queues incoming UDP
frames for a given port can be dispatched (number of worker threads)
No more contention, and this can be done regardless of RPS/RFS.

UDP frame comes in, and is stored on the appropriate sub-queue (can be =
a
mapping given by current cpu number). Wakeup the thread that is likely
running on same cpu.

Same for outgoing frames (answers). You might split the sk_wmemalloc
thing to make sure several cpus can concurrently use same UDP socket to
send their frames.



