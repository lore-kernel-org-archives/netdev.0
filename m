From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add a security check at install
 time
Date: Thu, 02 Dec 2010 07:46:24 +0100
Message-ID: <1291272384.2856.1074.camel@edumazet-laptop>
References: <1291227893.2856.1039.camel@edumazet-laptop>
	 <20101201.104450.183053379.davem@davemloft.net>
	 <1291232937.2856.1042.camel@edumazet-laptop>
	 <20101201.122312.229751364.davem@davemloft.net>
	 <1291236342.2856.1057.camel@edumazet-laptop>
	 <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	wirelesser@gmail.com, netdev@vger.kernel.org,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f66.google.com ([74.125.82.66]:34407 "EHLO
	mail-ww0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581Ab0LBGqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 01:46:32 -0500
Received: by wwe15 with SMTP id 15so373814wwe.1
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 22:46:31 -0800 (PST)
In-Reply-To: <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 d=C3=A9cembre 2010 =C3=A0 10:30 +0800, Changli Gao a =C3=A9=
crit :

> It seems wrong. Think about the following instructions:
>=20
> /* m[1] isn't set */
>    jeq jt jf
> jt:
>    st m[1]
>    jmp ja
> jf:
>    jmp ja2 /* m[1] is invalidated by masks */
> ja:
>    ld m[1] /* -EINVAL is returned */
> ja2:
>=20
> So you need to search all the possible branches to validate the instr=
uctions.

Well, I already did this branch search.

Its only that the instruction following a JMP should not inherit
memvalid from the JMP itself, but the AND of memvalid of all possible
jumps that can arrive to this instruction.

I'll think about it after some coffee, but I feel I might just set
memvalid to ~0 after the JMPS

Thanks

[PATCH v2 net-next-2.6] filter: add a security check at install time

We added some security checks in commit 57fe93b374a6
(filter: make sure filters dont read uninitialized memory) to close a
potential leak of kernel information to user.

This added a potential extra cost at run time, while we can perform a
check of the filter itself, to make sure a malicious user doesnt try to
abuse us.

This patch adds a check_loads() function, whole unique purpose is to
make this check, allocating a temporary array of mask. We scan the
filter and propagate a bitmask information, telling us if a load M(K) i=
s
allowed because a previous store M(K) is guaranteed. (So that
sk_run_filter() can possibly not read unitialized memory)

Note: this can uncover application bug, denying a filter attach,
previously allowed.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: Changli Gao <xiaosuo@gmail.com>
---
v2: set memvalid to ~0 on JMP instructions

diff --git a/net/core/filter.c b/net/core/filter.c
index a44d27f..0d636ef 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -166,11 +166,9 @@ unsigned int sk_run_filter(struct sk_buff *skb, co=
nst struct sock_filter *fentry
 	u32 A =3D 0;			/* Accumulator */
 	u32 X =3D 0;			/* Index Register */
 	u32 mem[BPF_MEMWORDS];		/* Scratch Memory Store */
-	unsigned long memvalid =3D 0;
 	u32 tmp;
 	int k;
=20
-	BUILD_BUG_ON(BPF_MEMWORDS > BITS_PER_LONG);
 	/*
 	 * Process array of filter instructions.
 	 */
@@ -318,12 +316,10 @@ load_b:
 			X =3D K;
 			continue;
 		case BPF_S_LD_MEM:
-			A =3D (memvalid & (1UL << K)) ?
-				mem[K] : 0;
+			A =3D mem[K];
 			continue;
 		case BPF_S_LDX_MEM:
-			X =3D (memvalid & (1UL << K)) ?
-				mem[K] : 0;
+			X =3D mem[K];
 			continue;
 		case BPF_S_MISC_TAX:
 			X =3D A;
@@ -336,11 +332,9 @@ load_b:
 		case BPF_S_RET_A:
 			return A;
 		case BPF_S_ST:
-			memvalid |=3D 1UL << K;
 			mem[K] =3D A;
 			continue;
 		case BPF_S_STX:
-			memvalid |=3D 1UL << K;
 			mem[K] =3D X;
 			continue;
 		default:
@@ -419,6 +413,66 @@ load_b:
 }
 EXPORT_SYMBOL(sk_run_filter);
=20
+/*
+ * Security :
+ * A BPF program is able to use 16 cells of memory to store intermedia=
te
+ * values (check u32 mem[BPF_MEMWORDS] in sk_run_filter())
+ * As we dont want to clear mem[] array for each packet going through
+ * sk_run_filter(), we check that filter loaded by user never try to r=
ead
+ * a cell if not previously written, and we check all branches to be s=
ure
+ * a malicious user doesnt try to abuse us.
+ */
+static int check_load_and_stores(struct sock_filter *filter, int flen)
+{
+	u16 *masks, memvalid =3D 0; /* one bit per cell, 16 cells */
+	int pc, ret =3D 0;
+
+	BUILD_BUG_ON(BPF_MEMWORDS > 16);
+	masks =3D kmalloc(flen * sizeof(*masks), GFP_KERNEL);
+	if (!masks)
+		return -ENOMEM;
+	memset(masks, 0xff, flen * sizeof(*masks));
+
+	for (pc =3D 0; pc < flen; pc++) {
+		memvalid &=3D masks[pc];
+
+		switch (filter[pc].code) {
+		case BPF_S_ST:
+		case BPF_S_STX:
+			memvalid |=3D (1 << filter[pc].k);
+			break;
+		case BPF_S_LD_MEM:
+		case BPF_S_LDX_MEM:
+			if (!(memvalid & (1 << filter[pc].k))) {
+				ret =3D -EINVAL;
+				goto error;
+			}
+			break;
+		case BPF_S_JMP_JA:
+			/* a jump must set masks on target */
+			masks[pc + 1 + filter[pc].k] &=3D memvalid;
+			memvalid =3D ~0;
+			break;
+		case BPF_S_JMP_JEQ_K:
+		case BPF_S_JMP_JEQ_X:
+		case BPF_S_JMP_JGE_K:
+		case BPF_S_JMP_JGE_X:
+		case BPF_S_JMP_JGT_K:
+		case BPF_S_JMP_JGT_X:
+		case BPF_S_JMP_JSET_X:
+		case BPF_S_JMP_JSET_K:
+			/* a jump must set masks on targets */
+			masks[pc + 1 + filter[pc].jt] &=3D memvalid;
+			masks[pc + 1 + filter[pc].jf] &=3D memvalid;
+			memvalid =3D ~0;
+			break;
+		}
+	}
+error:
+	kfree(masks);
+	return ret;
+}
+
 /**
  *	sk_chk_filter - verify socket filter code
  *	@filter: filter to verify
@@ -547,7 +601,7 @@ int sk_chk_filter(struct sock_filter *filter, int f=
len)
 	switch (filter[flen - 1].code) {
 	case BPF_S_RET_K:
 	case BPF_S_RET_A:
-		return 0;
+		return check_load_and_stores(filter, flen);
 	}
 	return -EINVAL;
 }





