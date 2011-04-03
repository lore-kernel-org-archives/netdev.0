From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1] net: filter: Just In Time compiler
Date: Sun, 03 Apr 2011 07:41:58 +0200
Message-ID: <1301809318.2837.125.camel@edumazet-laptop>
References: <1301783301.2837.77.camel@edumazet-laptop>
	 <20110402225002.GJ3108@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54624 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479Ab1DCFmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 01:42:06 -0400
Received: by wwa36 with SMTP id 36so5399202wwa.1
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2011 22:42:04 -0700 (PDT)
In-Reply-To: <20110402225002.GJ3108@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 03 avril 2011 =C3=A0 00:50 +0200, Hagen Paul Pfeifer a =C3=A9=
crit :
> * Eric Dumazet | 2011-04-03 00:28:21 [+0200]:
>=20
> >In order to speedup packet filtering, here is an implementation of a=
 JIT
> >compiler for x86_64
>=20
> Great work! Eric, do you have some numbers? For a trivial "ret" filte=
r the
> performance gain should be marginal - if any. But what with complex f=
ilter
> rules? And as said last time: libpcap optimizer seems to be target nu=
mber one
> for optimization. Again: great work!

Preliminary performance results are good, even for basic filter.

(I changed the AND operator to be able to use "and $imm8,%al" for
typical net addr/[24-31] operations, and "and $imm16,%ax" for
addr/[16-23] ones)

case BPF_S_ALU_AND_K:
	if (K >=3D 0xFFFFFF00) {
		EMIT2(0x24, K & 0xFF); /* and imm8,%al */
	} else if (K >=3D 0xFFFF0000) {
		EMIT2(0x66, 0x25);	/* and imm16,%ax */
		EMIT2(K, 2);
	} else {
		EMIT1_off32(0x25, K);	/* and imm32,%eax */
	}
	break;


dummy0 udpflood, and following basic active tcpdump, catching no frames
(condition is not met)

# tcpdump -p -n -s 0 -i dummy0 net 192.168.2.0/24 -d
(000) ldh      [12]
(001) jeq      #0x800           jt 2	jf 8
(002) ld       [26]
(003) and      #0xffffff00
(004) jeq      #0xc0a80200      jt 16	jf 5
(005) ld       [30]
(006) and      #0xffffff00
(007) jeq      #0xc0a80200      jt 16	jf 17
(008) jeq      #0x806           jt 10	jf 9
(009) jeq      #0x8035          jt 10	jf 17
(010) ld       [28]
(011) and      #0xffffff00
(012) jeq      #0xc0a80200      jt 16	jf 13
(013) ld       [38]
(014) and      #0xffffff00
(015) jeq      #0xc0a80200      jt 16	jf 17
(016) ret      #65535
(017) ret      #0

flen=3D18 proglen=3D147 pass=3D3 image=3Dffffffffa00b5000
JIT code: ffffffffa00b5000: 55 48 89 e5 48 83 ec 60 48 89 5d f8 44 8b 4=
f 60
JIT code: ffffffffa00b5010: 44 2b 4f 64 4c 8b 87 b8 00 00 00 be 0c 00 0=
0 00
JIT code: ffffffffa00b5020: e8 24 dc 2e e1 3d 00 08 00 00 75 28 be 1a 0=
0 00
JIT code: ffffffffa00b5030: 00 e8 fe db 2e e1 24 00 3d 00 02 a8 c0 74 4=
9 be
JIT code: ffffffffa00b5040: 1e 00 00 00 e8 eb db 2e e1 24 00 3d 00 02 a=
8 c0
JIT code: ffffffffa00b5050: 74 36 eb 3b 3d 06 08 00 00 74 07 3d 35 80 0=
0 00
JIT code: ffffffffa00b5060: 75 2d be 1c 00 00 00 e8 c8 db 2e e1 24 00 3=
d 00
JIT code: ffffffffa00b5070: 02 a8 c0 74 13 be 26 00 00 00 e8 b5 db 2e e=
1 24
JIT code: ffffffffa00b5080: 00 3d 00 02 a8 c0 75 07 b8 ff ff 00 00 eb 0=
2 31
JIT code: ffffffffa00b5090: c0 c9 c3

Benchmark :
ifconfig dummy0 10.2.2.2 netmask 255.255.255.0 up

1) Baseline (no active tcpdump)

# time /root/udpflood -f -l 10000000 10.2.2.1

real	0m7.941s
user	0m0.823s
sys	0m7.103s

2) Time with normal filtering (JIT disabled)

# time /root/udpflood -f -l 10000000 10.2.2.1

real	0m10.165s
user	0m1.000s
sys	0m9.149s


3) JIT enabled

# time /root/udpflood -f -l 10000000 10.2.2.1

real	0m9.615s
user	0m1.022s
sys	0m8.578s

Thats about 50ns saved per invocation, on a E5540  @ 2.53GHz

We could get better results if we inline the fastpath of ld/ldh/ldb,
instead of calling helpers. (In this case, avoiding three call/ret
instructions pair).



