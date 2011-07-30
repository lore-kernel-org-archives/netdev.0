From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Sat, 30 Jul 2011 08:04:59 +0200
Message-ID: <1312005899.2873.70.camel@edumazet-laptop>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
	 <1311931816.2843.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CACKH++afaAaa7a6ViYjo_PjpF1bXYtOuJaa-4umEOSVgW1+g3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rui Ueyama <rui314@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57941 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab1G3GHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2011 02:07:48 -0400
Received: by wwe5 with SMTP id 5so4148258wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 23:07:46 -0700 (PDT)
In-Reply-To: <CACKH++afaAaa7a6ViYjo_PjpF1bXYtOuJaa-4umEOSVgW1+g3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 22:09 -0700, Rui Ueyama a =C3=A9crit=
 :
> The result of benchmark looks good. A simple benchmark that sends 10M=
 UDP
> packets to lo took 76.24 seconds on average on Core 2 Duo L7500@1.6GH=
z.when
> tcpdump is running. With this patch it took 75.41 seconds, which mean=
s we save
> 80ns for each packet on that processor.
>=20
> I think converting the VM to threaded code is low hanging fruit, even
> if we'd have
> JIT compilers for popular architectures. Most of the lines in my patc=
h
> are indentation
> change, so the actual change is not big.
>=20
=2E..
> Tcpdump I used is this: tcpdump -p -n -s -i lo net 192.168.2.0/24
>=20

Thanks for providing numbers. Was it on 32 or 64bit kernel ?

Have you done a test with a cold instruction cache ?

Your patch adds 540 bytes of code, so its a potential latency increase.

# size net/core/filter.o net/core/filter.o.old
   text	   data	    bss	    dec	    hex	filename
   4243	      0	      0	   4243	   1093	net/core/filter.o
   3703	     24	      0	   3727	    e8f	net/core/filter.o.old

Each 'NEXT' translates to :

 4db:	83 c3 08             	add    $0x8,%ebx
 4de:	0f b7 03             	movzwl (%ebx),%eax
 4e1:	8b 04 85 00 02 00 00 	mov    0x200(,%eax,4),%eax
 4e8:	ff e0                	jmp    *%eax


And this is on i386, expect more on cpus with 32bit fixed
instructions ...

We can remove one branch per BPF instruction with following patch :

diff --git a/net/core/filter.c b/net/core/filter.c
index 36f975f..377f3ca 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -119,16 +119,14 @@ unsigned int sk_run_filter(const struct sk_buff *=
skb,
 	u32 tmp;
 	int k;
=20
+	fentry--;
 	/*
 	 * Process array of filter instructions.
 	 */
-	for (;; fentry++) {
-#if defined(CONFIG_X86_32)
+	for (;;) {
 #define	K (fentry->k)
-#else
-		const u32 K =3D fentry->k;
-#endif
=20
+		fentry++;
 		switch (fentry->code) {
 		case BPF_S_ALU_ADD_X:
 			A +=3D X;



