From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Thu, 4 Sep 2008 02:03:47 +0400
Message-ID: <20080903220347.GA22395@2ka.mipt.ru>
References: <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com> <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com> <20080903.040626.198546183.davem@davemloft.net> <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com> <20080903132734.GA17541@2ka.mipt.ru> <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com> <20080903151340.GA7566@2ka.mipt.ru> <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com> <20080903164346.GA6729@2ka.mipt.ru> <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:55309 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754222AbYICWEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 18:04:15 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2008 at 10:30:14PM +0200, Johann Baudy (johaahn@gmail.c=
om) wrote:
> > It will endup with generic_splice_sendpage() and pipe_to_sendpage()=
=2E
> >
> Indeed, I've double checked, but pipe_to_sendpage() will end up with
> packet_sendmsg()
>=20
> .splice_write =3D generic_splice_sendpage,
> generic_splice_sendpage()
> splice_from_pipe();
> pipe_to_sendpage() from err =3D actor(pipe, buf, sd);
> sock_sendpage() from ile->f_op->sendpage()
> sock_no_sendpage() from sock->ops->sendpage()
> kernel_sendmsg()
> sock_sendmsg();
> packet_sendmsg() from sock->ops->sendmsg();
> memcpy() :'(
>=20
> I think a non-generic splice_write function should do the job.
> What do you think?

Looks like you try to sendfile() over packet socket.
Both tcp and udp sockets have sendpage method.

Or your hardware or driver do not support needed fucntionality, so
tcp_sendpage() falls back to sock_no_sendpage(). From your dump I think
it is the first case above. Well, after I read it again, I found word
packet_sendmsg(), which explains everything. Please use tcp or udp
socket for splice/sendfile test.

> I mean the transfer unit size (ethernet frame length) that must be <=3D=
 MTU.
> Jumbo frames are enabled in the driver and mtu size is set to 7200.
> I'm currently using wireshark on a remote pc to check bitrate and for=
mat.
> I think performance can decrease because CPU will spend the same time
> to send 7200 or 4096 bytes but not the DMA.(~50=C2=B5s for 7200, ~30=C2=
=B5s for
> 4096)

If you use jumbo frames, than yes, the bigger allocation unit is
(assuming allocation succeeded), the bigger speed will be, so this resu=
lt
is expectable.

--=20
	Evgeniy Polyakov
