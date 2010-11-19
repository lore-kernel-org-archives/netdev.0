From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: cleanup codes[] init
Date: Fri, 19 Nov 2010 10:54:27 +0100
Message-ID: <1290160467.3034.33.camel@edumazet-laptop>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
	 <b2c34db84e88366e465af590900ae3db@localhost>
	 <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
	 <1290153111.29509.2.camel@edumazet-laptop>
	 <1290153398.29509.7.camel@edumazet-laptop>
	 <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60695 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab0KSJyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 04:54:32 -0500
Received: by wyb28 with SMTP id 28so4248998wyb.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 01:54:31 -0800 (PST)
In-Reply-To: <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 16:38 +0800, Changli Gao a =C3=A9cr=
it :

> I compared the asm code of sk_run_filter.

> As you see, an additional 'dec %edx' instruction is inserted.
> sk_chk_filter() only runs 1 times, I think we can afford the 'dec
> instruction' and 'dirty' code, but sk_run_filter() runs much often,
> this additional dec instruction isn't affordable.
>=20

Maybe on your setup. By the way, the=20

u32 f_k =3D fentry->k;

that David added in commit 57fe93b374a6b871

was much more a problem on arches with not enough registers.

x86_32 for example : compiler use a register (%esi on my gcc-4.5.1) to
store f_k, and more important A register is now stored in stack instead
of a cpu register.



On my compilers

 gcc version 4.4.5 (Ubuntu/Linaro 4.4.4-14ubuntu5) 64bit
 gcc-4.5.1 (self compiled) 32bit

result code was the same, before and after patch

Most probably you have "CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy" which
unfortunately is known to generate poor looking code.

 39b:	49 8d 14 c6          	lea    (%r14,%rax,8),%rdx
 39f:	66 83 3a 2d          	cmpw   $0x2d,(%rdx)
 3a3:	8b 42 04             	mov    0x4(%rdx),%eax             // f_k =3D=
 fentry->k;
 3a6:	76 28                	jbe    3d0 <sk_run_filter+0x70>

 3d0:	0f b7 0a             	movzwl (%rdx),%ecx
 3d3:	ff 24 cd 00 00 00 00 	jmpq   *0x0(,%rcx,8)


32bit code:

 2e0:	8d 04 df             	lea    (%edi,%ebx,8),%eax
 2e3:	66 83 38 2d          	cmpw   $0x2d,(%eax)
 2e7:	8b 70 04             	mov    0x4(%eax),%esi  // f_k =3D fentry->k=
;
 2ea:	76 1c                	jbe    308 <sk_run_filter+0x58>

 308:	0f b7 10             	movzwl (%eax),%edx
 30b:	ff 24 95 38 00 00 00 	jmp    *0x38(,%edx,4)


DIV_X instruction :
 480:	8b 45 a4             	mov    -0x5c(%ebp),%eax
 483:	85 c0                	test   %eax,%eax
 485:	0f 84 9d fe ff ff    	je     328 <sk_run_filter+0x78>
 48b:	8b 45 ac             	mov    -0x54(%ebp),%eax   // A
 48e:	31 d2                	xor    %edx,%edx
 490:	f7 75 a4             	divl   -0x5c(%ebp)
 493:	89 45 ac             	mov    %eax,-0x54(%ebp)  // A
 496:	e9 85 fe ff ff       	jmp    320 <sk_run_filter+0x70>


I believe we should revert the u32 f_k =3D fentry->k; part

fentry->k as is fast as f_k if stored on stack, and avoids one
instruction if fentry->k is not needed.



