From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Mon, 02 Nov 2009 11:56:06 +0100
Message-ID: <4AEEBAC6.7020308@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AEEB6D2.7090505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754859AbZKBK4E@vger.kernel.org>
In-Reply-To: <4AEEB6D2.7090505@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson a =E9crit :
>
> The (buggy?) syncookie code that I'm avoiding/replacing is:
>=20
> static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
>               ipv4_cookie_scratch);
>=20
> static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be=
16
> dport,
>                u32 count, int c)
> {
>     __u32 *tmp =3D __get_cpu_var(ipv4_cookie_scratch);
>=20
>     memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]))=
;
>     tmp[0] =3D (__force u32)saddr;
>     tmp[1] =3D (__force u32)daddr;
>     tmp[2] =3D ((__force u32)sport << 16) + (__force u32)dport;
>     tmp[3] =3D count;
>     sha_transform(tmp + 16, (__u8 *)tmp, tmp + 16 + 5);
>=20
>     return tmp[17];
> }
>=20
> It appears to me that the operations could be interrupted at any time=
, and
> the fairly expensive sha transform (or probably any of the assignment=
s)
> could be corrupted?
>=20
> That is, cpu0 grabs a scratch area, copies some data into it, interru=
pts,
> cpu0 comes along again with another packet, points into the same work=
space,
> mashes the data, while cpu1 completes the previous operation with the
> old tmp pointer on the stack.
>=20
> Worse, this is called twice, each time getting tmp, and mashing the d=
ata,
> and at the same time others are calling it twice more for verificatio=
n.
>=20
> Since syncookies only occur under stress, the code isn't well tested,=
 and
> the only symptom would be the returned packet would be dropped after
> failing to verify.  Since this only happens when lots of packets are
> arriving, dropped packets probably aren't noticed.
>=20
> However, that would be unacceptable for my code.
>


cookie_hash() runs in a non preemptable context. CPU cannot change unde=
r us.

(or else, we would not use __get_cpu_var(ipv4_cookie_scratch); )

And of course, each cpu gets its own scratch area, thanks to __get_cpu_=
var()
