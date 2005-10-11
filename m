From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: 32 bit (socket layer) ioctl emulation for 64 bit kernels- Question regarding...
Date: Tue, 11 Oct 2005 13:17:41 +0200
Message-ID: <200510111317.41646.arnd@arndb.de>
References: <3ad486780510092121h78a522cat11f33581dfc670dc@mail.gmail.com> <200510101348.49598.arnd@arndb.de> <3ad486780510110009s2de65e68vf19e283edf997e89@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751455AbVJKLQZ@vger.kernel.org>
To: spereira <pereira.shaun@gmail.com>
In-Reply-To: <3ad486780510110009s2de65e68vf19e283edf997e89@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dinsdag 11 Oktober 2005 09:09, spereira wrote:
> If I have understood correctly the following would be the changes I
> would have to make in the kernel...Please correct me if I am wrong.
>=20
> It seems to me step (d) would be as you say a little tricky but I
> could attempt it
> depending on the amount of time I have in the project I am on at the =
moment.
> Proposed modifications...
> a) Struct file_operations(include/linux/fs.h) has a compat_ioctl hook=
 for file
> ioctls. Include a compat_proto_ioctl hook in proto_ops(include/net.h)=
 for
> modular socket ioctls.

Yes, but the hook would be called 'compat_ioctl' by convention, not
'compat_proto_ioctl'.

> b) socket.c has a 'file_operations' type struct socket_file_ops where=
 the
> .compat_ioctl member is currently not used. Define compat_sock_ioctl =
in
> socket.c and assign to .compat_ioctl member of socket_file_ops
> This is ifdef'd with CONFIG_COMPAT

Yes
=20
> c) compat_sock_ioctl will by default call the protocol's ioctl
> =A0currently supporting the socket interface when handling modular
> =A0socket ioctls, like so. socket->ops->compat_proto_ioctl(...)
> which in this case is x25_compat_ioctl.

Yes, and return -ENOIOCTLCMD if there is no socket->ops->compat_ioctl()
handler installed. That will cause the current mechanism to be used as
a fallback.

> d)If compat_sock_ioctl has to perform a function similar to
> sock_ioctl(socket.c)
> where in SIOC* commands are handled, then introduce a newly defined
> compat_dev_ioctl that would have stuff like dev_ifsioc that would hav=
e
> previously
> been removed from fs/compat_ioctl.c.
> Then the protocol's ioctl (called by default in the step c above) wou=
ld itself
> default to compat_dev_ioctl ensuring other socket layer
> ioctls are handled by the device layer function, compat_dev_ioctl

I realized that it's even more complicated than this. For the ipv4 and =
ipv6
protocols, there is also an ioctl operation in struct proto, not only o=
ne
in struct proto_ops, so that one would also need a compat_ioctl that ca=
n
be called from inet{,6}_ioctl in the default path before calling dev_io=
ctl.
Similarly, the struct net_device contains a do_ioctl method that would
need a new compat_do_ioctl companion.

Maybe you can leave the current dev_ifsioc in place for now (though
I believe it should go away eventually) and just put the infrastructure=
 in
place to have compat_ioctl functions in struct proto_ops, struct proto =
and=20
struct net_device that are called when !NULL or otherwise return -ENOIO=
CTLCMD.

	Arnd <><
