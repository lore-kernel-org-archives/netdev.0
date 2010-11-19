From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 12:17:52 +0100
Message-ID: <1290165472.3034.109.camel@edumazet-laptop>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
	 <b2c34db84e88366e465af590900ae3db@localhost>
	 <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
	 <1290153111.29509.2.camel@edumazet-laptop>
	 <1290153398.29509.7.camel@edumazet-laptop>
	 <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
	 <1290160467.3034.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48571 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255Ab0KSLR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 06:17:57 -0500
Received: by fxm13 with SMTP id 13so550422fxm.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 03:17:56 -0800 (PST)
In-Reply-To: <1290160467.3034.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 10:54 +0100, Eric Dumazet a =C3=A9c=
rit :

> I believe we should revert the u32 f_k =3D fentry->k; part
>=20
> fentry->k as is fast as f_k if stored on stack, and avoids one
> instruction if fentry->k is not needed.
>=20
>=20

A revert is not good on arches with decent number of registers (x86_64
for example).

Maybe have some CONFIG_ARCH_HAS_{FEW|MANY}_REGISTERS is needed, (or
already exist ?)

Here is the patch to save 400 bytes on x86_32, and really speedup the
damn thing on all arches.

Thanks

[PATCH net-next-2.6] filter: optimize sk_run_filter

remove pc variable to avoid arithmetic to compute fentry at each filter
instruction. Jumps directly manipulate fentry pointer.

As the last instruction of filter[] is guaranteed to be a RETURN, and
all jumps are before the last instruction, we dont need to check filter
bounds (number of instructions in filter array) at each iteration, so w=
e
remove it from sk_run_filter() params.

On x86_32 remove f_k var introduced in commit 57fe93b374a6b871
(filter: make sure filters dont read uninitialized memory)

Note : We could use a CONFIG_ARCH_HAS_{FEW|MANY}_REGISTERS in order to
avoid too many ifdefs in this code.

This helps compiler to use cpu registers to hold fentry and A
accumulator.

On x86_32, this saves 401 bytes, and more important, sk_run_filter()
runs much faster because less register pressure (One less conditional
branch per BPF instruction)

# size net/core/filter.o net/core/filter_pre.o
   text	   data	    bss	    dec	    hex	filename
   2948	      0	      0	   2948	    b84	net/core/filter.o
   3349	      0	      0	   3349	    d15	net/core/filter_pre.o

on x86_64 :
# size net/core/filter.o net/core/filter_pre.o
   text	   data	    bss	    dec	    hex	filename
   5173	      0	      0	   5173	   1435	net/core/filter.o
   5224	      0	      0	   5224	   1468	net/core/filter_pre.o

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/linux/filter.h  |    2=20
 net/core/filter.c       |   93 +++++++++++++++++++-------------------
 net/core/timestamping.c |    2=20
 net/packet/af_packet.c  |    2=20
 4 files changed, 51 insertions(+), 48 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 151f5d7..447a775 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -147,7 +147,7 @@ struct sock;
=20
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
 extern unsigned int sk_run_filter(struct sk_buff *skb,
-				  struct sock_filter *filter, int flen);
+				  const struct sock_filter *filter);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)=
;
 extern int sk_detach_filter(struct sock *sk);
 extern int sk_chk_filter(struct sock_filter *filter, int flen);
diff --git a/net/core/filter.c b/net/core/filter.c
index 15a545d..9e77b3c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -137,7 +137,7 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 	rcu_read_lock_bh();
 	filter =3D rcu_dereference_bh(sk->sk_filter);
 	if (filter) {
-		unsigned int pkt_len =3D sk_run_filter(skb, filter->insns, filter->l=
en);
+		unsigned int pkt_len =3D sk_run_filter(skb, filter->insns);
=20
 		err =3D pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
 	}
@@ -151,14 +151,15 @@ EXPORT_SYMBOL(sk_filter);
  *	sk_run_filter - run a filter on a socket
  *	@skb: buffer to run the filter on
  *	@filter: filter to apply
- *	@flen: length of filter
  *
  * Decode and apply filter instructions to the skb->data.
- * Return length to keep, 0 for none. skb is the data we are
- * filtering, filter is the array of filter instructions, and
- * len is the number of filter blocks in the array.
+ * Return length to keep, 0 for none. @skb is the data we are
+ * filtering, @filter is the array of filter instructions.
+ * Because all jumps are guaranteed to be before last instruction,
+ * and last instruction guaranteed to be a RET, we dont need to check
+ * flen. (We used to pass to this function the length of filter)
  */
-unsigned int sk_run_filter(struct sk_buff *skb, struct sock_filter *fi=
lter, int flen)
+unsigned int sk_run_filter(struct sk_buff *skb, const struct sock_filt=
er *fentry)
 {
 	void *ptr;
 	u32 A =3D 0;			/* Accumulator */
@@ -167,34 +168,36 @@ unsigned int sk_run_filter(struct sk_buff *skb, s=
truct sock_filter *filter, int
 	unsigned long memvalid =3D 0;
 	u32 tmp;
 	int k;
-	int pc;
=20
 	BUILD_BUG_ON(BPF_MEMWORDS > BITS_PER_LONG);
 	/*
 	 * Process array of filter instructions.
 	 */
-	for (pc =3D 0; pc < flen; pc++) {
-		const struct sock_filter *fentry =3D &filter[pc];
-		u32 f_k =3D fentry->k;
+	for (;; fentry++) {
+#if defined(CONFIG_X86_32)
+#define	K (fentry->k)
+#else
+		const u32 K =3D fentry->k;
+#endif
=20
 		switch (fentry->code) {
 		case BPF_S_ALU_ADD_X:
 			A +=3D X;
 			continue;
 		case BPF_S_ALU_ADD_K:
-			A +=3D f_k;
+			A +=3D K;
 			continue;
 		case BPF_S_ALU_SUB_X:
 			A -=3D X;
 			continue;
 		case BPF_S_ALU_SUB_K:
-			A -=3D f_k;
+			A -=3D K;
 			continue;
 		case BPF_S_ALU_MUL_X:
 			A *=3D X;
 			continue;
 		case BPF_S_ALU_MUL_K:
-			A *=3D f_k;
+			A *=3D K;
 			continue;
 		case BPF_S_ALU_DIV_X:
 			if (X =3D=3D 0)
@@ -202,64 +205,64 @@ unsigned int sk_run_filter(struct sk_buff *skb, s=
truct sock_filter *filter, int
 			A /=3D X;
 			continue;
 		case BPF_S_ALU_DIV_K:
-			A /=3D f_k;
+			A /=3D K;
 			continue;
 		case BPF_S_ALU_AND_X:
 			A &=3D X;
 			continue;
 		case BPF_S_ALU_AND_K:
-			A &=3D f_k;
+			A &=3D K;
 			continue;
 		case BPF_S_ALU_OR_X:
 			A |=3D X;
 			continue;
 		case BPF_S_ALU_OR_K:
-			A |=3D f_k;
+			A |=3D K;
 			continue;
 		case BPF_S_ALU_LSH_X:
 			A <<=3D X;
 			continue;
 		case BPF_S_ALU_LSH_K:
-			A <<=3D f_k;
+			A <<=3D K;
 			continue;
 		case BPF_S_ALU_RSH_X:
 			A >>=3D X;
 			continue;
 		case BPF_S_ALU_RSH_K:
-			A >>=3D f_k;
+			A >>=3D K;
 			continue;
 		case BPF_S_ALU_NEG:
 			A =3D -A;
 			continue;
 		case BPF_S_JMP_JA:
-			pc +=3D f_k;
+			fentry +=3D K;
 			continue;
 		case BPF_S_JMP_JGT_K:
-			pc +=3D (A > f_k) ? fentry->jt : fentry->jf;
+			fentry +=3D (A > K) ? fentry->jt : fentry->jf;
 			continue;
 		case BPF_S_JMP_JGE_K:
-			pc +=3D (A >=3D f_k) ? fentry->jt : fentry->jf;
+			fentry +=3D (A >=3D K) ? fentry->jt : fentry->jf;
 			continue;
 		case BPF_S_JMP_JEQ_K:
-			pc +=3D (A =3D=3D f_k) ? fentry->jt : fentry->jf;
+			fentry +=3D (A =3D=3D K) ? fentry->jt : fentry->jf;
 			continue;
 		case BPF_S_JMP_JSET_K:
-			pc +=3D (A & f_k) ? fentry->jt : fentry->jf;
+			fentry +=3D (A & K) ? fentry->jt : fentry->jf;
 			continue;
 		case BPF_S_JMP_JGT_X:
-			pc +=3D (A > X) ? fentry->jt : fentry->jf;
+			fentry +=3D (A > X) ? fentry->jt : fentry->jf;
 			continue;
 		case BPF_S_JMP_JGE_X:
-			pc +=3D (A >=3D X) ? fentry->jt : fentry->jf;
+			fentry +=3D (A >=3D X) ? fentry->jt : fentry->jf;
 			continue;
 		case BPF_S_JMP_JEQ_X:
-			pc +=3D (A =3D=3D X) ? fentry->jt : fentry->jf;
+			fentry +=3D (A =3D=3D X) ? fentry->jt : fentry->jf;
 			continue;
 		case BPF_S_JMP_JSET_X:
-			pc +=3D (A & X) ? fentry->jt : fentry->jf;
+			fentry +=3D (A & X) ? fentry->jt : fentry->jf;
 			continue;
 		case BPF_S_LD_W_ABS:
-			k =3D f_k;
+			k =3D K;
 load_w:
 			ptr =3D load_pointer(skb, k, 4, &tmp);
 			if (ptr !=3D NULL) {
@@ -268,7 +271,7 @@ load_w:
 			}
 			break;
 		case BPF_S_LD_H_ABS:
-			k =3D f_k;
+			k =3D K;
 load_h:
 			ptr =3D load_pointer(skb, k, 2, &tmp);
 			if (ptr !=3D NULL) {
@@ -277,7 +280,7 @@ load_h:
 			}
 			break;
 		case BPF_S_LD_B_ABS:
-			k =3D f_k;
+			k =3D K;
 load_b:
 			ptr =3D load_pointer(skb, k, 1, &tmp);
 			if (ptr !=3D NULL) {
@@ -292,34 +295,34 @@ load_b:
 			X =3D skb->len;
 			continue;
 		case BPF_S_LD_W_IND:
-			k =3D X + f_k;
+			k =3D X + K;
 			goto load_w;
 		case BPF_S_LD_H_IND:
-			k =3D X + f_k;
+			k =3D X + K;
 			goto load_h;
 		case BPF_S_LD_B_IND:
-			k =3D X + f_k;
+			k =3D X + K;
 			goto load_b;
 		case BPF_S_LDX_B_MSH:
-			ptr =3D load_pointer(skb, f_k, 1, &tmp);
+			ptr =3D load_pointer(skb, K, 1, &tmp);
 			if (ptr !=3D NULL) {
 				X =3D (*(u8 *)ptr & 0xf) << 2;
 				continue;
 			}
 			return 0;
 		case BPF_S_LD_IMM:
-			A =3D f_k;
+			A =3D K;
 			continue;
 		case BPF_S_LDX_IMM:
-			X =3D f_k;
+			X =3D K;
 			continue;
 		case BPF_S_LD_MEM:
-			A =3D (memvalid & (1UL << f_k)) ?
-				mem[f_k] : 0;
+			A =3D (memvalid & (1UL << K)) ?
+				mem[K] : 0;
 			continue;
 		case BPF_S_LDX_MEM:
-			X =3D (memvalid & (1UL << f_k)) ?
-				mem[f_k] : 0;
+			X =3D (memvalid & (1UL << K)) ?
+				mem[K] : 0;
 			continue;
 		case BPF_S_MISC_TAX:
 			X =3D A;
@@ -328,16 +331,16 @@ load_b:
 			A =3D X;
 			continue;
 		case BPF_S_RET_K:
-			return f_k;
+			return K;
 		case BPF_S_RET_A:
 			return A;
 		case BPF_S_ST:
-			memvalid |=3D 1UL << f_k;
-			mem[f_k] =3D A;
+			memvalid |=3D 1UL << K;
+			mem[K] =3D A;
 			continue;
 		case BPF_S_STX:
-			memvalid |=3D 1UL << f_k;
-			mem[f_k] =3D X;
+			memvalid |=3D 1UL << K;
+			mem[K] =3D X;
 			continue;
 		default:
 			WARN_ON(1);
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 0ae6c22..dac7ed6 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -31,7 +31,7 @@ static unsigned int classify(struct sk_buff *skb)
 	if (likely(skb->dev &&
 		   skb->dev->phydev &&
 		   skb->dev->phydev->drv))
-		return sk_run_filter(skb, ptp_filter, ARRAY_SIZE(ptp_filter));
+		return sk_run_filter(skb, ptp_filter);
 	else
 		return PTP_CLASS_NONE;
 }
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2096456..b6372dd 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -519,7 +519,7 @@ static inline unsigned int run_filter(struct sk_buf=
f *skb, struct sock *sk,
 	rcu_read_lock_bh();
 	filter =3D rcu_dereference_bh(sk->sk_filter);
 	if (filter !=3D NULL)
-		res =3D sk_run_filter(skb, filter->insns, filter->len);
+		res =3D sk_run_filter(skb, filter->insns);
 	rcu_read_unlock_bh();
=20
 	return res;


