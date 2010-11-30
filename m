From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Tue, 30 Nov 2010 12:17:16 +0100
Message-ID: <1291115836.2904.49.camel@edumazet-laptop>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rui <wirelesser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:48354 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab0K3LRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 06:17:21 -0500
Received: by wwb39 with SMTP id 39so4811wwb.1
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 03:17:20 -0800 (PST)
In-Reply-To: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 17:22 +0800, Rui a =C3=A9crit :

> PCAP_FRAMES=3D32000 ./tcpdump_MMAP -i eth4 'udp dst port 2152 and (
> (((ether[48:1]&0x07)>0) and
> (((ether[66:1]+ether[67:1]+ether[68:1]+ether[69:1]+ether[70:1]+ether[=
71:1]+ether[72:1]+ether[73:1])&0x03)=3D=3D0))
> or (((ether[48:1]&0x07)=3D=3D0) and
> (((ether[62:1]+ether[63:1]+ether[64:1]+ether[65:1]+ether[66:1]+ether[=
67:1]+ether[68:1]+ether[69:1])&0x03)=3D=3D0))
> ) ' -w /dev/null -s 4096 2>f1.log &

(000) ldh      [12]
(001) jeq      #0x86dd          jt 2	jf 6
(002) ldb      [20]
(003) jeq      #0x11            jt 4	jf 95
(004) ldh      [56]
(005) jeq      #0x868           jt 14	jf 95
(006) jeq      #0x800           jt 7	jf 95
(007) ldb      [23]
(008) jeq      #0x11            jt 9	jf 95
(009) ldh      [20]
(010) jset     #0x1fff          jt 95	jf 11
(011) ldxb     4*([14]&0xf)
(012) ldh      [x + 16]
(013) jeq      #0x868           jt 14	jf 95
(014) ldb      [48]
(015) and      #0x7
(016) ldx      #0x0
(017) jgt      x                jt 18	jf 55
(018) ldb      [66]
(019) st       M[4]
(020) ldb      [67]
(021) tax     =20
(022) ld       M[4]
(023) add      x
(024) st       M[6]
(025) ldb      [68]
(026) tax     =20
(027) ld       M[6]
(028) add      x
(029) st       M[8]
(030) ldb      [69]
(031) tax     =20
(032) ld       M[8]
(033) add      x
(034) st       M[10]
(035) ldb      [70]
(036) tax     =20
(037) ld       M[10]
(038) add      x
(039) st       M[12]
(040) ldb      [71]
(041) tax     =20
(042) ld       M[12]
(043) add      x
(044) st       M[14]
(045) ldb      [72]
(046) tax     =20
(047) ld       M[14]
(048) add      x
(049) st       M[0]
(050) ldb      [73]
(051) tax     =20
(052) ld       M[0]
(053) add      x

[deleted part]

Ouch... we miss a "add{bh } [byteoff]" instruction, or "ldx{bh } [byteo=
ff]"

ldb	[66]
ldxb	[67]
add	x
ldxb	[68]
add	x
ldxb	[69]
add	x
ldxb	[70]
add	x
ldxb	[71]
add	x
ldxb	[72]
add	x
ldxb	[73]
add	x
=2E..

With current instruction set, pcap optimizer could at least do somethin=
g like :

ldb	[66]
tax
ldb	[67]
add	x
tax
ldb	[68]
add	x
tax
ldb	[69]
add	x
tax
ldb	[70]
add	x
tax
ldb	[71]
add	x
tax
ldb	[72]
add	x
tax
ldb	[73]
add	x
=2E..



