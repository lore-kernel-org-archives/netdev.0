From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 12:22:06 +0200
Message-ID: <1349950926.21172.8521.camel@edumazet-glaptop>
References: <506E1762.3010601@gmail.com>
	 <CANLjY-no-L9=LRCvCetC5XCHicOoSWOfRZmUd7itAiUHWBhAyw@mail.gmail.com>
	 <CAG5Tg6Wuybruc31x1eh6mFafsg=7cOgYLgpZUBuJUo75ap3osQ@mail.gmail.com>
	 <506E3E58.80703@gmail.com>
	 <CAG5Tg6V0Vj9HTy3=AU-q+Qa3DuJs6R1Kw+3uOWU_jOGfkgyXzw@mail.gmail.com>
	 <20121005071216.GD4625@n2100.arm.linux.org.uk>
	 <CAG5Tg6VciuxJ=k+fatzLugcehF54mGNOLHpUwdMX99oCnAVg8Q@mail.gmail.com>
	 <20121005082439.GF4625@n2100.arm.linux.org.uk> <506ED18C.3010009@gmail.com>
	 <20121005140556.GQ4625@n2100.arm.linux.org.uk> <506EEFBB.3060705@gmail.com>
	 <507619FA.6080001@jonmasters.org> <yw1xtxu1pwtv.fsf@unicorn.mansr.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
	 <yw1xpq4ppcju.fsf@unicorn.mansr.com>
	 <1349949638.21172.8445.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	Jon Masters <jonathan@jonmasters.org>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60101 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758393Ab2JKKWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 06:22:10 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so862313bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 03:22:09 -0700 (PDT)
In-Reply-To: <1349949638.21172.8445.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 12:00 +0200, Eric Dumazet wrote:
> On Thu, 2012-10-11 at 10:45 +0100, M=C3=A5ns Rullg=C3=A5rd wrote:

>=20
> I have no idea what is the problem,=20
>=20
> -ENOTENOUGHCONTEXT
>=20
>=20

I took a look, and I dont see why/how gcc could use a ldm instruction

Doing so assumed the alignment of the structure was 8 bytes, but its
not.

Networking stack mandates that IP headers are aligned on 4 bytes
boundaries, not 8 bytes.

(Some arches like x86 dont care, so we might have some bugs in some
drivers, but not in the GRO code)

Some drivers are not aware of the NET_IP_ALIGN stuff.
They should be fixed, or else you have alignment faults.

struct iphdr {
 	__u8	ihl:4,
		version:4;
	__u8	tos;
	__be16	tot_len;
	__be16	id;
	__be16	frag_off;
	__u8	ttl;
	__u8	protocol;
	__sum16	check;
	__be32	saddr;
	__be32	daddr;
	/*The options start here. */
};

The alignment of iphdr is 4, not 8

doing id =3D ntohl(*(__be32 *)&iph->id); is valid

doing flush =3D (u16)((ntohl(*(__be32 *)iph) ^ len) | (id ^ IP_DF)); is=
 valid as well.

If arm compiler decided to use a 8bytes load, thats a compiler bug.

(unless compiler was specifically told that alignment did not matter)

c02ac020:       e8920840        ldm     r2, {r6, fp}    // HERE
c02ac024:       e6bfbf3b        rev     fp, fp
c02ac028:       e6bf6f36        rev     r6, r6
c02ac02c:       e22bc901        eor     ip, fp, #16384  ; 0x4000
c02ac030:       e0266008        eor     r6, r6, r8
c02ac034:       e18c6006        orr     r6, ip, r6
