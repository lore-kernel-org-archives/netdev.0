From: Eric Leblond <eric@regit.org>
Subject: ebpf: issue with clang
Date: Thu, 09 Jun 2016 23:10:05 +0200
Message-ID: <1465506605.23482.10.camel@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:38003 "EHLO home.regit.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848AbcFIVj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:39:26 -0400
Received: from amarseille-655-1-603-186.w92-158.abo.wanadoo.fr ([92.158.236.186] helo=tiger2)
	by home.regit.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.84_2)
	(envelope-from <eric@regit.org>)
	id 1bB7DK-0000rF-NX
	for netdev@vger.kernel.org; Thu, 09 Jun 2016 23:10:08 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm working on integrating ebpf cluster load balancing for AF_PACKET
and I've got some problem to get real code inside the EBPF filter.

I've tried different command lines in the build process. One of them
is:
clang-3.9 -Wall -O2 -emit-llvm -c hash_ports.c -o - | llc-3.9 -march=3D=
bpf -filetype=3Dobj -o hash_ports.bpf

If I use that one, then the generated code is almost void. If I remove
the -O2 then I've got a generated code that fails during load. When not
using -O2, I manage to load a trivial filter (return of static value).
=C2=A0
The C code is the following (a derivative of http-simple-filter.c used
for testing):

int filter(struct __sk_buff *skb) {
	uint8_t *cursor =3D 0;
	struct ethernet_t *ethernet =3D cursor_advance(cursor, sizeof(*etherne=
t));
=09
	if (!(ethernet->type =3D=3D (unsigned int)0x0800)) {
		goto DEFAULT;=09
	}
	struct ip_t *ip =3D cursor_advance(cursor, sizeof(*ip));
	if (ip->nextp !=3D IP_TCP) {
		goto DEFAULT;
	}
    return 1;
DEFAULT:
    return 0;
}

And error is as follows

bpf: Permission denied
bpf verifier:
0: (7b) *(u64 *)(r10 -16) =3D r1
1: (b7) r1 =3D 0
2: (7b) *(u64 *)(r10 -24) =3D r1
3: (7b) *(u64 *)(r10 -40) =3D r1
4: (79) r2 =3D *(u64 *)(r10 -24)
5: (07) r2 +=3D 14
6: (7b) *(u64 *)(r10 -24) =3D r2
7: (79) r2 =3D *(u64 *)(r10 -40)
8: (7b) *(u64 *)(r10 -48) =3D r2
9: (7b) *(u64 *)(r10 -32) =3D r2
10: (71) r3 =3D *(u8 *)(r2 +12)
R2 invalid mem access 'inv'

This has been tested with a 4.6.0 kernel and a 4.5.x kernel.

What did I miss here ?

BR,
--=20

Eric Leblond <eric@regit.org>
Blog: https://home.regit.org/
