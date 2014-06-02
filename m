From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [bug report] buffer overflow in isdn capi
Date: Tue, 03 Jun 2014 00:48:02 +0200
Message-ID: <538CFF22.5020800@imap.cc>
References: <20140401154830.GA16759@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55359 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752116AbaFBWsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 18:48:03 -0400
Received: from compute2.internal (compute2.nyi.mail.srv.osa [10.202.2.42])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 2902F21522
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2014 18:48:02 -0400 (EDT)
In-Reply-To: <20140401154830.GA16759@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello all,

on 01.04.2014 17:48, Dan Carpenter wrote:
> The command_2_index() function is buggy and leads to a buffer
> overflow. Does anyone know how to fix this?

AFAICS this is still unfixed.
As an easy fix I propose:

- --- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -203,14 +203,7 @@ static unsigned char *cpars[] =3D
 /*-------------------------------------------------------*/
 static unsigned command_2_index(unsigned c, unsigned sc)
 {
- -       if (c & 0x80)
- -               c =3D 0x9 + (c & 0x0f);
- -       else if (c <=3D 0x0f);
- -       else if (c =3D=3D 0x41)
- -               c =3D 0x9 + 0x1;
- -       else if (c =3D=3D 0xff)
- -               c =3D 0x00;
- -       return (sc & 3) * (0x9 + 0x9) + c;
+       return (sc & 3) * (0x9 + 0x9) + ((c & 0xf0) ? 0x9 : 0) + (c &
0x0f);
 }

 /*-------------------------------------------------------*/

This produces identical results to the current function for
all legal values of c (0x00..0x08, 0x41, 0x80..0x88, 0xff)
and guarantees that the result is <=3D 0x4e for all possible
inputs, whether legal or not. It also makes it clearer what
that function actually does.

Unless somebody points out a serious flaw with this I'll test it
and submit a formal patch.

Karsten's other concern about unhandled NULL pointers in the
mnames[] and cpars[] arrays should be addressed separately IMHO.

Regards,
Tilman

- --=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlOM/yIACgkQQ3+did9BuFuwMwCfVZq5Lx0P+ddhe/5WlxuO5zzp
VV4AoIn50I1wa4r4DtWfHFErMysgjsxr
=3Dk/+h
-----END PGP SIGNATURE-----
