From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: 32 bit (socket layer) ioctl emulation for 64 bit kernels
Date: Mon, 16 Jan 2006 10:39:23 +0100
Message-ID: <200601161039.24333.arnd@arndb.de>
References: <1137045732.5221.21.camel@spereira05.tusc.com.au> <200601131146.48128.arnd@arndb.de> <1137391160.5588.32.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Andi Kleen <ak@muc.de>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, SP <pereira.shaun@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932310AbWAPJjx@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1137391160.5588.32.camel@spereira05.tusc.com.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 16 January 2006 06:59, Shaun Pereira wrote:
>=20
> I was wondering if this the compat_sock_get_timestamp function is
> needed? If I were to remove the SIOCGSTAMP case from the
> compat_x25_ioctl function, then a SIOCGSTAMP ioctl system call would
> return -ENOIOCTLCMD which could =A0then be handled by do_siocgstamp
> handler in the ioctl32_hash_table? (fs/compat_ioctl.c)
> In which case I could remove this patch from the rest of the series.

Yes, that would also work, as I already mentioned (or tried to)
in one of my earlier comments. I would prefer to have this patch
though, because in the long term, I think we should migrate more
stuff away from the hash table and having the function there
means that others can use it as well.

> +=A0=A0=A0=A0=A0=A0=A0err =3D -EFAULT;
> +=A0=A0=A0=A0=A0=A0=A0if(access_ok(VERIFTY_WRITE, ctv, sizeof(*ctv)))=
 {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0err =3D __put_user(sk->=
sk_stamp.tv_sec, &ctv->tv_sec);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0err !=3D __put_user(sk-=
>sk_stamp.tv_usec, &ctv->tv_usec);
> +=A0=A0=A0=A0=A0=A0=A0}
> +=A0=A0=A0=A0=A0=A0=A0return err;
> +}

This copies the correct data down to user space now, but might result
in returning an invalid error code.
In the second line you now have 'err !=3D __put_user(...);', which is
a comparison, not an assignment!
=46or readability, I would simply write that as:

	ret =3D 0;
	if (put_user(sk->sk_stamp.tv_sec, &ctv->tv_sec) |
	    put_user(sk->sk_stamp.tv_usec, &ctv->tv_usec))
		err =3D -EFAULT;

You can also write it like your code, but with '|' instead of '!', but
that requires the additional knowledge that __put_user can only ever
return '0' or '-EFAULT' itself and that the bitwise or of those is
therefore also one of these two.

	Arnd <><
