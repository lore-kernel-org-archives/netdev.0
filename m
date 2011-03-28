From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: zero copy for relay server
Date: Mon, 28 Mar 2011 18:52:18 +0200
Message-ID: <1301331138.3182.43.camel@edumazet-laptop>
References: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Viral Mehta <Viral.Mehta@lntinfotech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45261 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754949Ab1C1Qwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 12:52:32 -0400
Received: by fxm17 with SMTP id 17so2814706fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 09:52:31 -0700 (PDT)
In-Reply-To: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 mars 2011 =C3=A0 21:57 +0530, Viral Mehta a =C3=A9crit :
> Hi,
> I am implementing a particular application where
> my application acts nothing but like Relay Server.
>=20
> Relay server accepts connection from machine A.
> It also accepts connection from Machine B.
>=20
> Machine A and B are on different LAN/subnnets.
> Now, there are two connections.
> What server is supposed to do is RECV packets from machine A and SEND=
 same
> to machine B.
>=20
> Pseudo Code is something like,
> while(1)
> {
> recvagain:
>    n =3D3D recv(incoming_fd, &buf, 8192, ...)
>    if(n < 0)
>         goto recvagain;
>    send(outgoing_fd, &buf, n, ...);
> }
>=20
> Now the question is,
> I want to avoid kernel-user copy for such application.
> I found that a syscall like "sendfile"; I wanted to know if there is =
any
> similar thing exists in-kernel which can take 2 socket descriptors...=
=2E
>=20
> If not, is it possible ? I would like to implement the same if someon=
e
> can suggest some pointers.

linux way (if you want to avoid netfilter stuff and use userland code)
is to use splice() system call, and a pipe between two sockets.


/* skeleton : must add error checking to exit the loop properly */
int fds[2];
pipe(fds);

while (1) {
	splice(incoming_fd, NULL, fds[1], NULL, 65536, 0);
	splice(fds[0], NULL, outgoing_fd, NULL, 65536, 0);
}

This way, messages dont cross kernel<>user boundary.

The pipe is acting as a buffer between the two sockets.



