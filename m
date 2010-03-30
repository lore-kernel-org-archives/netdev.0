From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Tiny patch (w/ discussion) to provide the peer information on
 unix domain sockets
Date: Tue, 30 Mar 2010 16:56:53 +0200
Message-ID: <1269961013.2012.61.camel@edumazet-laptop>
References: <20100330143512.GF7980@coffee.modeemi.cs.tut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Erkki Seppala <flux-lkml@inside.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100330143512.GF7980@coffee.modeemi.cs.tut.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 30 mars 2010 =C3=A0 17:35 +0300, Erkki Seppala a =C3=A9crit :
> Hello,
>=20
> Attached you will find a patch that appends the field 'Peer' to
> /proc/net/unix indicating the peer of a connected unix domain
> socket. It shows its kernel address, as this is how unix domain
> sockets are identified in the same file. The preceding optional file
> name (actual address of the socket) field is replaced with "-" if it
> is not set. If there is no peer, 0 is used in its place.
>=20
> The purpose of the patch is to provide information on onto which
> services processes are connected. This information is readily
> available for TCP/IP sockets but not for unix domain sockets. The
> information can be retrieved with relative ease by using the followin=
g
> scripts for GDB, if you have GDB 7.1 and debugging symbols around:
>=20
>   http://www.modeemi.fi/~flux/software/list-unix-sockets.tar.gz
>=20
> But obviously this is not optimal :). With the patch, this is how you
> can find out the peers of the sockets of the X server:
>=20
>   # grep -E $(lsof -p `pidof X` | grep unix | awk '{print s $6; s=3D"=
|"}' |
>               tr -d '\n' | sed 's/0x//g;s/.*/(&)$/') /proc/net/unix
>   d913b000: 00000003 00000000 00000000 0001 03  5494 - d913b200
>   d9085600: 00000003 00000000 00000000 0001 03  5487 - d9085800
>   ..
>=20
> The number in the first column is the address, for which the process
> can be most easily found with lsof:=20
>=20
>   # lsof | grep d913b000=20
>   gnome-pow 1245        gdm    3u     unix 0xd913b000      0t0       =
5494 -
>=20
> Hopefully this kind of work would be integrated into lsof to display
> the information more easily.
>=20
> The patch does break the current API, but the impact seems rather
> light. I'm happy to incorporate alternative approaches if this seems
> to severe.
>=20
> Originally the last field in the field was fully optional: if it was
> not known, the line would terminate immediately after the field
> preceding it. Because we append a new field (instead of inserting it
> before Path, which causes more severe problems), the missing field
> value is indicated with a hyphen instead. So this (where $ indicates
> EOL):
>=20
>   de38f800: 00000003 00000000 00000000 0001 03  2323$
>=20
> becomes this:
>=20
>   de38f800: 00000003 00000000 00000000 0001 03  2323 - de2e4400$
>=20
> This changes the output of netstat -x for unix domain sockets that
> don't have a known address. I'm pretty sure nobody cares,
> though.. Similarly this changes the behavior of lsof, which before th=
e
> patch can display:
>=20
>   rxvt      17693         ese    6u     unix 0xffff880050ba8900      =
0t0     746261 socket
>=20
> but after the patch:
>=20
>   gconf-hel 1377        gdm    3u     unix 0xd9197800      0t0       =
5796 -
>=20
> Pretty sure this is pretty much the same for everyone as well
> :). Although that could likely be worked around by using "@" in place
> of "-". Infact this might be the proper thing to do: I'm not sure wha=
t
> the meaning of UNIX_ABSTRACT used in af_unix.c:unix_seq_show is,
> perhaps just that there is no name to be found? I cannot use the
> macro, though, because it uses the nondefined field addr.
>=20
> Btw, I noticed that af_unix.c:unix_seq_show does not quote the unix
> domain socket path (possibly due to lacking convenient quoting
> function in seq_file.c), which allows spoofing the contents of the
> file into a certain extent. Atleast spaces should be quoted for this
> patch to work properly in the cases when socket names have spaces in
> them.
>=20
> Here is the patch, also available at=20
>=20
>   http://www.modeemi.fi/~flux/software/linux-2.6.31-procfs-unix_peer_=
information.patch
>=20
> --- linux-2.6.31/net/unix/af_unix.c	2010-03-30 16:19:52.306372568 +03=
00
> +++ linux-2.6.31-flux/net/unix/af_unix.c	2010-03-30 14:32:47.00000000=
0 +0300
> @@ -2154,7 +2154,7 @@
> =20
>  	if (v =3D=3D SEQ_START_TOKEN)
>  		seq_puts(seq, "Num       RefCount Protocol Flags    Type St "
> -			 "Inode Path\n");
> +			 "Inode Path Peer\n");
>  	else {
>  		struct sock *s =3D v;
>  		struct unix_sock *u =3D unix_sk(s);
> @@ -2185,7 +2185,14 @@
>  			}
>  			for ( ; i < len; i++)
>  				seq_putc(seq, u->addr->name->sun_path[i]);
> -		}
> +		} else
> +			seq_puts(seq, " -");
> +
> +		if (u->peer)
> +			seq_printf(seq, " %p", u->peer);
> +		else
> +			seq_puts(seq, " 0");
> +	=09
>  		unix_state_unlock(s);
>  		seq_putc(seq, '\n');
>  	}
>=20
Hi Erkki

Such patches should be sent to netdev

I believe you missed some necessary locking.


Prior art from Kenan Kalajdzic :

 http://patchwork.ozlabs.org/patch/46561/
