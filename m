From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Tue, 09 Aug 2011 07:00:27 +0200
Message-ID: <1312866027.2531.42.camel@edumazet-laptop>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
	 <20110801181652.GB2732@nuttenaction>
	 <1312223866.2719.3.camel@edumazet-laptop>
	 <20110801.175705.2074393848482150971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, rui314@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47915 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab1HIFAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 01:00:35 -0400
Received: by wyg24 with SMTP id 24so102390wyg.19
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 22:00:34 -0700 (PDT)
In-Reply-To: <20110801.175705.2074393848482150971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 ao=C3=BBt 2011 =C3=A0 17:57 -0700, David Miller a =C3=A9cri=
t :

> Maybe it won't if we use an enum and make sure all enum values are ha=
ndled
> in the switch? :-)

I tried this idea since its already an enum and all enum values are
handled in the witch, but all gcc versions I used still generate the
useless compare and branch (always predicted by modern CPU, so harmless
anyway ?)

348:   83 c3 08                add    $0x8,%ebx
34b:   66 83 3b 37             cmpw   $0x37,(%ebx)
34f:   77 f7                   ja     348 <sk_run_filter+0x18>
351:   0f b7 03                movzwl (%ebx),%eax
354:   ff 24 85 34 01 00 00    jmp    *0x134(,%eax,4)


It would be nice to try the jump table idea and avoid the array
indirection and get instead :

add	$0xc,%ebx
jmp	*(ebx)

(But this would need to use a larger kernel_sock_filter with not an u16
code, but the target address).


diff --git a/include/linux/filter.h b/include/linux/filter.h
index 741956f..f2a1b37 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -171,7 +171,7 @@ static inline void bpf_jit_free(struct sk_filter *f=
p)
 #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
 #endif
=20
-enum {
+enum bpf_inst {
 	BPF_S_RET_K =3D 1,
 	BPF_S_RET_A,
 	BPF_S_ALU_ADD_K,
diff --git a/net/core/filter.c b/net/core/filter.c
index 36f975f..ea1f467 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -119,17 +119,15 @@ unsigned int sk_run_filter(const struct sk_buff *=
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
-		switch (fentry->code) {
+		fentry++;
+		switch ((enum bpf_inst)fentry->code) {
 		case BPF_S_ALU_ADD_X:
 			A +=3D X;
 			continue;
@@ -350,11 +348,6 @@ load_b:
 				A =3D 0;
 			continue;
 		}
-		default:
-			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
-				       fentry->code, fentry->jt,
-				       fentry->jf, fentry->k);
-			return 0;
 		}
 	}
=20


