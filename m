From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 22:12:54 +0200
Message-ID: <1307391174.2642.8.camel@edumazet-laptop>
References: <1307389540.2642.3.camel@edumazet-laptop>
	 <201106062206.29134.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60746 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441Ab1FFUM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:12:58 -0400
Received: by wya21 with SMTP id 21so3071664wya.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 13:12:56 -0700 (PDT)
In-Reply-To: <201106062206.29134.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 22:06 +0200, Arnd Bergmann a =C3=A9crit :
> On Monday 06 June 2011 21:45:40 Eric Dumazet wrote:
> > While trying Alexander Holler patch, I found a 32bit brctl program =
was
> > not able to work on a 64bit kernel. So I had to switch to another
> > machine for my tests.
> >=20
> > brctl addbr mybridge
> > ->
> > socket(PF_FILE, SOCK_STREAM, 0)         =3D 3
> > ioctl(3, SIOCSIFBR, 0xffd509c0)         =3D -1 EINVAL (Invalid argu=
ment)
> >=20
> > Should we care or not ?
> >=20
>=20
> Generally, we try to make all ioctls work in compat mode. For the old
> bridge ioctls, this is currently impossible because it uses SIOCPRIVA=
TE
> ioctls, but it would be easy to add an ndo_do_compat_ioctl.=20
>=20
> The solution that is documented in net/socket.c is to return=20
> an invalid version number for BRCTL_VERSION, in the hope that
> brctl would switch to the newer interfaces. The new style bridge
> ioctls (SIOCBRADDBR, SIOCBRADDIF, ...) are actually supposed to work,
> but I've never tried that.
>=20


I see... problem is brctl does :

int br_add_bridge(const char *brname)
{
        int ret;

#ifdef SIOCBRADDBR
        ret =3D ioctl(br_socket_fd, SIOCBRADDBR, brname);
        if (ret < 0)
#endif
        {
                char _br[IFNAMSIZ];
                unsigned long arg[3]
                        =3D { BRCTL_ADD_BRIDGE, (unsigned long) _br };

                strncpy(_br, brname, IFNAMSIZ);
                ret =3D ioctl(br_socket_fd, SIOCSIFBR, arg);
        }

        return ret < 0 ? errno : 0;
}


So for an old binary, compiled at the time SIOCBRADDBR wasnt there (in
include file I mean), we ended doing :

        {
                char _br[IFNAMSIZ];
                unsigned long arg[3]
                        =3D { BRCTL_ADD_BRIDGE, (unsigned long) _br };

                strncpy(_br, brname, IFNAMSIZ);
                ret =3D ioctl(br_socket_fd, SIOCSIFBR, arg);
        }

And this breaks on 64bit kernel

I guess we shall add some logic in kernel to support SIOCSIFBR
afterall ;)

Thanks !

BTW: I confirm that compiling an up2date 32bit brctl with an up2date
include files is OK on 64bit kernel.



