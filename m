From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socket
 filters
Date: Wed, 10 Nov 2010 08:22:51 +0100
Message-ID: <1289373771.2700.110.camel@edumazet-laptop>
References: <1289341724.7380.13.camel@dan>
	 <20101109.212838.193698340.davem@davemloft.net>
	 <1289368423.2700.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: drosenberg@vsecurity.com, netdev@vger.kernel.org,
	stable@kernel.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53352 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab0KJHW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 02:22:57 -0500
Received: by wyb36 with SMTP id 36so342577wyb.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 23:22:56 -0800 (PST)
In-Reply-To: <1289368423.2700.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 06:53 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mardi 09 novembre 2010 =C3=A0 21:28 -0800, David Miller a =C3=A9cr=
it :
> > From: Dan Rosenberg <drosenberg@vsecurity.com>
> > Date: Tue, 09 Nov 2010 17:28:44 -0500
> >=20
> > > The "mem" array used as scratch space for socket filters is not
> > > initialized, allowing unprivileged users to leak kernel stack byt=
es.
> > >=20
> > > Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> >=20
> > Prove it.
>=20
> And once done, add the checks in sk_chk_filter() ?
>=20
> Allow a load of mem[X] only if a prior store of mem[X] is proven.
>=20
>=20

This seems complex, and might fail on some valid filters.

What about the following patch then ?

[PATCH] filter: make sure filters dont read uninitialized memory

There is a possibility malicious users can get limited information abou=
t
uninitialized stack mem array. Even if sk_run_filter() result is bound
to packet length (0 .. 65535), we could imagine this can be used by
hostile user.

Initializing mem[] array, like Dan Rosenberg suggested in his patch is
expensive since most filters dont even use this array.

Its hard to make the filter validation in sk_chk_filter(), because of
the jumps. This might be done later.

In this patch, I use a bitmap (a single long var) so that only filters
using mem[] loads/stores pay the price of added security checks.

=46or other filters, additional cost is a single instruction.

Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/filter.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 7beaec3..4d84dc2 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -117,10 +117,12 @@ unsigned int sk_run_filter(struct sk_buff *skb, s=
truct sock_filter *filter, int
 	u32 A =3D 0;			/* Accumulator */
 	u32 X =3D 0;			/* Index Register */
 	u32 mem[BPF_MEMWORDS];		/* Scratch Memory Store */
+	unsigned long memvalid =3D 0;
 	u32 tmp;
 	int k;
 	int pc;
=20
+	BUILD_BUG_ON(BPF_MEMWORDS > BITS_PER_LONG);
 	/*
 	 * Process array of filter instructions.
 	 */
@@ -264,10 +266,12 @@ load_b:
 			X =3D fentry->k;
 			continue;
 		case BPF_S_LD_MEM:
-			A =3D mem[fentry->k];
+			A =3D (memvalid & (1UL << fentry->k)) ?
+				mem[fentry->k] : 0;
 			continue;
 		case BPF_S_LDX_MEM:
-			X =3D mem[fentry->k];
+			X =3D (memvalid & (1UL << fentry->k)) ?
+				mem[fentry->k] : 0;
 			continue;
 		case BPF_S_MISC_TAX:
 			X =3D A;
@@ -280,9 +284,11 @@ load_b:
 		case BPF_S_RET_A:
 			return A;
 		case BPF_S_ST:
+			memvalid |=3D 1UL << fentry->k;
 			mem[fentry->k] =3D A;
 			continue;
 		case BPF_S_STX:
+			memvalid |=3D 1UL << fentry->k;
 			mem[fentry->k] =3D X;
 			continue;
 		default:


