From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Tue, 18 Oct 2011 14:24:25 +0200
Message-ID: <1318940665.2657.60.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111018111422.GA1979@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Nico Schottelius <nico-linux-20111017@schottelius.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111018111422.GA1979@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 octobre 2011 =C3=A0 13:14 +0200, Nico Schottelius a =C3=A9c=
rit :
> Dear LKML,
>=20
> there is a rather nasty bug in all recent kernels (probably older as
> well):
>=20
> If wpa_supplicant looses the connection to an AP, all network calls
> hang, uninterruptle.
>=20
> This is a snippet of running fetchmail after the problem started:
>=20
> socket(PF_NETLINK, SOCK_RAW, 0)         =3D 4
> bind(4, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D=
 0
> getsockname(4, {sa_family=3DAF_NETLINK, pid=3D9734, groups=3D00000000=
}, [12]) =3D 0
> sendto(4, "\24\0\0\0\26\0\1\3\225\\\235N\0\0\0\0\0\0\0\0", 20, 0, {sa=
_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12
>=20
> [12:59] brief:linux-2.6% ps aux | grep fetchmail
> nico      9063  0.0  0.0  20652  1492 pts/3    D+   12:55   0:00 fetc=
hmail
> nico      9564  0.0  0.0  20652  1496 pts/15   D+   13:01   0:00 fetc=
hmail
> nico      9731  0.0  0.0   4288   724 pts/34   S+   13:01   0:00 stra=
ce -fF fetchmail
> nico      9734  0.0  0.0  20652  1492 pts/34   D+   13:01   0:00 fetc=
hmail
>=20
> This is particular nasty, because even calling "sudo -i" does a sendt=
o() call
> and thus hangs, as well as trying to send this mail with sendmail mak=
es mutt hang.
>=20
> I've seen that on stock Archlinux kernel (linux 3.0.6-2),
> latest from Linus (v3.1-rc9-93-ga84a79e), merged trees from Keith and=
 Jiri
> (3.1.0-rc6-gbee709a).
>=20
> Listing of hanging processes:
>=20
> [13:05] brief:linux-2.6% ps aux | grep D       =20
> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMM=
AND
> root      9056  0.2  0.0      0     0 ?        D    12:54   0:02 [kwo=
rker/u:0]
> nico      9063  0.0  0.0  20652  1492 pts/3    D+   12:55   0:00 fetc=
hmail
> nico      9066  0.0  0.0  16548  1180 ?        D    12:56   0:00 send=
mail -oem -oi -f ME@inf.ethz.ch -- RECIPIENT
> root      9067  0.0  0.0   6060   320 pts/14   DN   12:56   0:00 ip r
> root      9124  0.0  0.0   6060   320 pts/14   DN   12:57   0:00 ip r=
 add 192.168.42.1/24 dev lo
> root      9390  0.0  0.0  11996   784 pts/12   D+   13:01   0:00 sudo=
 -i
> nico      9564  0.0  0.0  20652  1496 pts/15   D+   13:01   0:00 fetc=
hmail
> nico      9734  0.0  0.0  20652  1492 pts/34   D+   13:01   0:00 fetc=
hmail
> root     12304  0.0  0.0  28624  2228 ?        Ds   09:16   0:00 wpa_=
supplicant -B -P /run/wpa_supplicant_wlan0.pid -i wlan0 -D nl80211,wext=
 -c /run/network//wpa.wlan0/wpa.conf
> [13:07] brief:linux-2.6%=20
>=20
> The hardware is again the (in)famous MacBook Air 4,2, so I imagine th=
is may be
> related to brcmsmac.
>=20
> Attached are config, dmesg, lsmod.


Must be a mutex_unlock(some_mltex) missing somewhere.

Then later, a process holding RTNL is blocking on mutex_lock(some_mutex=
)

Try a "CONFIG_LOCKDEP=3Dy" enabled build
