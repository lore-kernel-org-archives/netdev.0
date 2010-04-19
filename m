From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC]: soreuseport: Bind multiple sockets to same port
Date: Mon, 19 Apr 2010 09:28:23 +0200
Message-ID: <1271662103.16881.7300.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004182321480.1822@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:53772 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab0DSH2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 03:28:33 -0400
Received: by bwz25 with SMTP id 25so5102066bwz.28
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 00:28:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004182321480.1822@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 avril 2010 =C3=A0 23:33 -0700, Tom Herbert a =C3=A9crit =
:
> This is some work we've done to scale TCP listeners/UDP servers.  It
> might be apropos with some of the discussion on SO_REUSEADDR for UDP.
> ---
> This patch implements so_reuseport (SO_REUSEPORT socket option) for
> TCP and UDP.  For TCP, so_reuseport allows multiple listener sockets
> to be bound to the same port.  In the case of UDP, so_reuseport allow=
s
> multiple sockets to bind to the same port.  To prevent port hijacking
> all sockets bound to the same port using so_reuseport must have the
> same uid.  Received packets are distributed to multiple sockets bound
> to the same port using a 4-tuple hash.
>=20
> The motivating case for so_resuseport in TCP would be something like
> a web server binding to port 80 running with multiple threads, where
> each thread might have it's own listener socket.  This could be done
> as an alternative to other models: 1) have one listener thread which
> dispatches completed connections to workers. 2) accept on a single
> listener socket from multiple threads.  In case #1 the listener threa=
d
> can easily become the bottleneck with high connection turn-over rate.
> In case #2, the proportion of connections accepted per thread tends
> to be uneven under high connection load (assuming simple event loop:
> while (1) { accept(); process() }, wakeup does not promote fairness
> among the sockets.  We have seen the  disproportion to be as high
> as 3:1 ratio between thread accepting most connections and the one
> accepting the fewest.  With so_reusport the distribution is
> uniform.
>=20
> The TCP implementation has a problem in that the request sockets for =
a
> listener are attached to a listener socket.  If a SYN is received, a
> listener socket is chosen and request structure is created (SYN-RECV
> state).  If the subsequent ack in 3WHS does not match the same port
> by so_reusport, the connection state is not found (reset) and the
> request structure is orphaned.  This scenario would occur when the
> number of listener sockets bound to a port changes (new ones are
> added, or old ones closed).  We are looking for a solution to this,
> maybe allow multiple sockets to share the same request table...
>=20
> The motivating case for so_reuseport in UDP would be something like a
> DNS server.  An alternative would be to recv on the same socket from
> multiple threads.  As in the case of TCP, the load across these threa=
ds
> tends to be disproportionate and we also see a lot of contection on
> the socket lock.  Note that SO_REUSEADDR already allows multiple UDP
> sockets to bind to the same port, however there is no provision to
> prevent hijacking and nothing to distribute packets across all the
> sockets sharing the same bound port.  This patch does not change the
> semantics of SO_REUSEADDR, but provides usable functionality of it
> for unicast.


Hmm...

I am wondering how this thing is scalable...

In fact it is not.

We live in a world with 16 cpus machines not uncommon right now.

High perf DNS server on such machine would have 16 threads, and probabl=
y
64 threads in two years.

I understand you want 16 UDP sockets to avoid lock contention, but
__udp4_lib_lookup() becomes a nightmare (It may already be ...)

My idea was to add a cpu lookup key.

thread0 would use a new setsockopt() option to bind a socket to a
virtual cpu0. Then do its normal bind( port=3D53)

=2E..

threadN would use a new setsockopt() option to bind a socket to a
virtual cpuN. Then do its normal bind( port=3D53)

Each thread then do its normal worker loop.

Then, when receiving a frame on cpuN, we would automatically select the
right socket because its score is higher than others.


Another possibility would be to extend socket structure to be able to
have a dynamically sized queues/locks.



