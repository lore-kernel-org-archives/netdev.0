From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 14:16:47 +0100
Message-ID: <1290172607.3034.124.camel@edumazet-laptop>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
	 <b2c34db84e88366e465af590900ae3db@localhost>
	 <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
	 <1290153111.29509.2.camel@edumazet-laptop>
	 <1290153398.29509.7.camel@edumazet-laptop>
	 <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
	 <1290160467.3034.33.camel@edumazet-laptop>
	 <1290165472.3034.109.camel@edumazet-laptop>
	 <AANLkTi=ed79a5HjGULPdwuqmUhj=W8BGzRh7tm2L11ef@mail.gmail.com>
	 <AANLkTi==Ovw8xFA1K6rVabg9MW0w6wd=2qvo=XojUXpM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58888 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141Ab0KSNQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 08:16:55 -0500
Received: by wyb28 with SMTP id 28so4442716wyb.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 05:16:53 -0800 (PST)
In-Reply-To: <AANLkTi==Ovw8xFA1K6rVabg9MW0w6wd=2qvo=XojUXpM@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 20:57 +0800, Changli Gao a =C3=A9cr=
it :
> On Fri, Nov 19, 2010 at 8:32 PM, Changli Gao <xiaosuo@gmail.com> wrot=
e:
> >
> > you missed the users of sk_run_filter in directory dev/.
> >
>=20
> Sorry, the directory is drivers/.
>=20
>=20

You're right, thanks !

[PATCH net-next-2.6 v2] filter: optimize sk_run_filter

Remove pc variable to avoid arithmetic to compute fentry at each filter
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
   text    data     bss     dec     hex filename
   2948       0       0    2948     b84 net/core/filter.o
   3349       0       0    3349     d15 net/core/filter_pre.o

on x86_64 :
# size net/core/filter.o net/core/filter_pre.o
   text    data     bss     dec     hex filename
   5173       0       0    5173    1435 net/core/filter.o
   5224       0       0    5224    1468 net/core/filter_pre.o

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
---
V2: add missing changes for drivers/isdn/i4l/isdn_ppp.c &
drivers/net/ppp_generic.c

 drivers/isdn/i4l/isdn_ppp.c |   14 ++---
 drivers/net/ppp_generic.c   |   12 +---
 include/linux/filter.h      |    2=20
 net/core/filter.c           |   93 +++++++++++++++++-----------------
 net/core/timestamping.c     |    2=20
 net/packet/af_packet.c      |    2=20
 6 files changed, 61 insertions(+), 64 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 97c5cc2..9e8162c 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1147,15 +1147,14 @@ isdn_ppp_push_higher(isdn_net_dev * net_dev, is=
dn_net_local * lp, struct sk_buff
 	}
=20
 	if (is->pass_filter
-	    && sk_run_filter(skb, is->pass_filter, is->pass_len) =3D=3D 0) {
+	    && sk_run_filter(skb, is->pass_filter) =3D=3D 0) {
 		if (is->debug & 0x2)
 			printk(KERN_DEBUG "IPPP: inbound frame filtered.\n");
 		kfree_skb(skb);
 		return;
 	}
 	if (!(is->active_filter
-	      && sk_run_filter(skb, is->active_filter,
-	                       is->active_len) =3D=3D 0)) {
+	      && sk_run_filter(skb, is->active_filter) =3D=3D 0)) {
 		if (is->debug & 0x2)
 			printk(KERN_DEBUG "IPPP: link-active filter: reseting huptimer.\n")=
;
 		lp->huptimer =3D 0;
@@ -1294,15 +1293,14 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_d=
evice *netdev)
 	}
=20
 	if (ipt->pass_filter
-	    && sk_run_filter(skb, ipt->pass_filter, ipt->pass_len) =3D=3D 0) =
{
+	    && sk_run_filter(skb, ipt->pass_filter) =3D=3D 0) {
 		if (ipt->debug & 0x4)
 			printk(KERN_DEBUG "IPPP: outbound frame filtered.\n");
 		kfree_skb(skb);
 		goto unlock;
 	}
 	if (!(ipt->active_filter
-	      && sk_run_filter(skb, ipt->active_filter,
-		               ipt->active_len) =3D=3D 0)) {
+	      && sk_run_filter(skb, ipt->active_filter) =3D=3D 0)) {
 		if (ipt->debug & 0x4)
 			printk(KERN_DEBUG "IPPP: link-active filter: reseting huptimer.\n")=
;
 		lp->huptimer =3D 0;
@@ -1492,9 +1490,9 @@ int isdn_ppp_autodial_filter(struct sk_buff *skb,=
 isdn_net_local *lp)
 	}
 =09
 	drop |=3D is->pass_filter
-	        && sk_run_filter(skb, is->pass_filter, is->pass_len) =3D=3D 0=
;
+	        && sk_run_filter(skb, is->pass_filter) =3D=3D 0;
 	drop |=3D is->active_filter
-	        && sk_run_filter(skb, is->active_filter, is->active_len) =3D=3D=
 0;
+	        && sk_run_filter(skb, is->active_filter) =3D=3D 0;
 =09
 	skb_push(skb, IPPP_MAX_HEADER - 4);
 	return drop;
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 09cf56d..0c91598a 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1136,8 +1136,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *s=
kb)
 		   a four-byte PPP header on each packet */
 		*skb_push(skb, 2) =3D 1;
 		if (ppp->pass_filter &&
-		    sk_run_filter(skb, ppp->pass_filter,
-				  ppp->pass_len) =3D=3D 0) {
+		    sk_run_filter(skb, ppp->pass_filter) =3D=3D 0) {
 			if (ppp->debug & 1)
 				printk(KERN_DEBUG "PPP: outbound frame not passed\n");
 			kfree_skb(skb);
@@ -1145,8 +1144,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *s=
kb)
 		}
 		/* if this packet passes the active filter, record the time */
 		if (!(ppp->active_filter &&
-		      sk_run_filter(skb, ppp->active_filter,
-				    ppp->active_len) =3D=3D 0))
+		      sk_run_filter(skb, ppp->active_filter) =3D=3D 0))
 			ppp->last_xmit =3D jiffies;
 		skb_pull(skb, 2);
 #else
@@ -1758,8 +1756,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct s=
k_buff *skb)
=20
 			*skb_push(skb, 2) =3D 0;
 			if (ppp->pass_filter &&
-			    sk_run_filter(skb, ppp->pass_filter,
-					  ppp->pass_len) =3D=3D 0) {
+			    sk_run_filter(skb, ppp->pass_filter) =3D=3D 0) {
 				if (ppp->debug & 1)
 					printk(KERN_DEBUG "PPP: inbound frame "
 					       "not passed\n");
@@ -1767,8 +1764,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct s=
k_buff *skb)
 				return;
 			}
 			if (!(ppp->active_filter &&
-			      sk_run_filter(skb, ppp->active_filter,
-					    ppp->active_len) =3D=3D 0))
+			      sk_run_filter(skb, ppp->active_filter) =3D=3D 0))
 				ppp->last_recv =3D jiffies;
 			__skb_pull(skb, 2);
 		} else
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


