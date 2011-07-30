From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Sat, 30 Jul 2011 08:20:06 +0200
Message-ID: <1312006806.2873.74.camel@edumazet-laptop>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
	 <1311931816.2843.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CACKH++afaAaa7a6ViYjo_PjpF1bXYtOuJaa-4umEOSVgW1+g3w@mail.gmail.com>
	 <1312005899.2873.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rui Ueyama <rui314@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34458 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab1G3GUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2011 02:20:11 -0400
Received: by wwe5 with SMTP id 5so4152992wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 23:20:10 -0700 (PDT)
In-Reply-To: <1312005899.2873.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 30 juillet 2011 =C3=A0 08:04 +0200, Eric Dumazet a =C3=A9crit=
 :

> We can remove one branch per BPF instruction with following patch :
>=20
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 36f975f..377f3ca 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -119,16 +119,14 @@ unsigned int sk_run_filter(const struct sk_buff=
 *skb,
>  	u32 tmp;
>  	int k;
> =20
> +	fentry--;
>  	/*
>  	 * Process array of filter instructions.
>  	 */
> -	for (;; fentry++) {
> -#if defined(CONFIG_X86_32)
> +	for (;;) {
>  #define	K (fentry->k)
> -#else
> -		const u32 K =3D fentry->k;
> -#endif
> =20
> +		fentry++;
>  		switch (fentry->code) {
>  		case BPF_S_ALU_ADD_X:
>  			A +=3D X;
>=20
>=20

BTW, I tried to add one unreachable() in the default: branch, and gcc
4.5.2 generates interesting code :

It still does the compare and test, but both branches ends on same
location :

 348:	83 c3 08             	add    $0x8,%ebx
 34b:	66 83 3b 37          	cmpw   $0x37,(%ebx)
 34f:	76 07                	jbe    358 <sk_run_filter+0x28>
 351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 358:	0f b7 03             	movzwl (%ebx),%eax
 35b:	ff 24 85 34 01 00 00 	jmp    *0x134(,%eax,4)


On a 64bit build and gcc 4.1.2, it even generates an infinite loop

 730:	66 83 3b 37          	cmpw   $0x37,(%rbx)
 734:	76 02                	jbe    738 <sk_run_filter+0x28>
 736:	eb fe                	jmp    736 <sk_run_filter+0x26>
 738:	0f b7 03             	movzwl (%rbx),%eax
 73b:	ff 24 c5 00 00 00 00 	jmpq   *0x0(,%rax,8)


diff --git a/net/core/filter.c b/net/core/filter.c
index 36f975f..89221e7 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -122,13 +122,11 @@ unsigned int sk_run_filter(const struct sk_buff *=
skb,
 	/*
 	 * Process array of filter instructions.
 	 */
-	for (;; fentry++) {
-#if defined(CONFIG_X86_32)
+	fentry--;
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
@@ -351,6 +349,7 @@ load_b:
 			continue;
 		}
 		default:
+			unreachable();
 			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
 				       fentry->code, fentry->jt,
 				       fentry->jf, fentry->k);


