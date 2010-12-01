From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 20:48:57 +0100
Message-ID: <1291232937.2856.1042.camel@edumazet-laptop>
References: <18eaf7d286236427b1632b9af62be513@localhost>
	 <20101201.101809.71122121.davem@davemloft.net>
	 <1291227893.2856.1039.camel@edumazet-laptop>
	 <20101201.104450.183053379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, xiaosuo@gmail.com, wirelesser@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52326 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab0LATtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:49:04 -0500
Received: by wyb28 with SMTP id 28so7328912wyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 11:49:03 -0800 (PST)
In-Reply-To: <20101201.104450.183053379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 10:44 -0800, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 01 Dec 2010 19:24:53 +0100
>=20
> > A third work in progress (from my side) is to add a check in
> > sk_chk_filter() to remove the memvalid we added lately to protect t=
he
> > LOAD M(K).
>=20
> I understand your idea, but the static checkers are still going to
> complain.  So better add a huge comment in sk_run_filter() explaining
> why the checker's complaint should be ignored :-)

Sure, here is the patch I plan to test ASAP

 net/core/filter.c |   70 ++++++++++++++++++++++++++++++++++++++------
 1 file changed, 61 insertions(+), 9 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index a44d27f..1e713b3 100644
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
@@ -419,6 +413,63 @@ load_b:
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
+	masks =3D kmalloc(flen * sizeof(*masks), GFP_KERNEL);
+	if (!masks)
+		return -ENOMEM;
+	memset(masks, 0xff, flen * sizeof(*masks));
+
+	for (pc =3D 0; pc < flen; pc++) {
+		memvalid &=3D masks[pc];
+		switch (filter[pc].code) {
+		case BPF_S_ST:
+		case BPF_S_STX:
+			memvalid |=3D (1 << filter[pc].k);
+			break;
+		case BPF_S_LD_MEM:
+		case BPF_S_LDX_MEM:
+			if (!(memvalid & (1 << filter[pc].k))) {
+				pr_err("filter: bad load(%d) memvalid=3D%x\n", filter[pc].k, memva=
lid);
+				ret =3D -EINVAL;
+				goto error;
+			}
+			break;
+		case BPF_S_JMP_JA:
+			/* a jump must set masks on target */
+			masks[pc + 1 + filter[pc].k] &=3D memvalid;
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
@@ -432,6 +483,7 @@ EXPORT_SYMBOL(sk_run_filter);
  * All jumps are forward as they are not signed.
  *
  * Returns 0 if the rule set is legal or -EINVAL if not.
+ *
  */
 int sk_chk_filter(struct sock_filter *filter, int flen)
 {
@@ -547,7 +599,7 @@ int sk_chk_filter(struct sock_filter *filter, int f=
len)
 	switch (filter[flen - 1].code) {
 	case BPF_S_RET_K:
 	case BPF_S_RET_A:
-		return 0;
+		return check_load_and_stores(filter, flen);
 	}
 	return -EINVAL;
 }


