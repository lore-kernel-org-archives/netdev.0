From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: refcounting on dgram Unix sockets for poll(POLLOUT)
Date: Thu, 09 Dec 2010 03:47:01 +0100
Message-ID: <1291862821.2795.27.camel@edumazet-laptop>
References: <20101208210100.46c894dd@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42762 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200Ab0LICrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 21:47:06 -0500
Received: by wyb28 with SMTP id 28so1789324wyb.19
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 18:47:05 -0800 (PST)
In-Reply-To: <20101208210100.46c894dd@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 21:01 +0000, Alban Crequy a =C3=
=A9crit :
> Hi,
>=20
> When a connected datagram Unix socket is polled for POLLOUT events, t=
he
> poller is added in the wait_queue_head_t of the "server" socket:
>=20
> net/unix/af_unix.c::unix_dgram_poll()
>   other =3D unix_peer_get(sk);
>   if (other) {
>     if (unix_peer(other) !=3D sk) {
>       sock_poll_wait(file, &unix_sk(other)->peer_wait,
>                      wait);
>       ...
>=20
> I wonder what prevent the "server" socket ("other") to be released
> while the poller is still waiting for POLLOUT events.
>=20
> There is a reference taken on the "server" socket when the client
> connects:
> net/unix/af_unix.c::unix_dgram_connect()
>   other =3D unix_find_other(net, sunaddr, alen, sock->type,
>             hash, &err);
>=20
> But that reference could be released when the client socket
> disconnects from another thread in one of the 3 possible locations:
>=20
> 1. unix_dgram_connect() when connecting to a different socket
>      if (other !=3D old_peer)
>        unix_dgram_disconnected(sk, old_peer);
>      sock_put(old_peer);
>=20
> 2. unix_dgram_sendmsg() when the server socket is SOCK_DEAD:
>      unix_dgram_disconnected(sk, other);
>      sock_put(other);
>=20
> 3. unix_release_sock() when the client socket is released:
>      skpair =3D unix_peer(sk);
>      if (skpair !=3D NULL) {
>        sock_put(skpair); /* It may now die */
>=20
> I tried to release all the references to server_sockfd with
> close(server_sockfd) on the server thread and with
> connect(client_sockfd) to a different socket while client_sockfd is
> being polled for POLLOUT events in a different thread, hoping to cras=
h
> the poller with the stack:
> free_poll_entry()->remove_wait_queue()->spin_lock_irqsave()
> But I didn't manage to crash the kernel.
>=20

Maybe you need to add some options to detect/trigger this ?

CONFIG_DEBUG_LOCK_ALLOC

and

slub_debug=3DFZP
cf Documentation/vm/slub.txt

to force slub to overwrite data when freeing master socket.

> Am I missing something? Is there another reference taken on
> server_sockfd to protect the kernel from this scenario?
>=20
> And btw, what is the test (unix_peer(other) !=3D sk) in unix_dgram_po=
ll()?
>=20
> Alban


