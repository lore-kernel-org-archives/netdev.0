From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 04 Sep 2014 13:50:12 +0200
Message-ID: <1409831412.23465.3.camel@localhost>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
	 <54078FBC.5050402@redhat.com>
	 <CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
	 <1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1409793959.3362714.163402573.6A26EDE1@webmail.messagingengine.com>
	 <1409796348.26422.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQLh6qOD2epUq0S5P8RkUgZA38JNxeP40uBMScLHC2SsJg@mail.gmail.com>
	 <CAHj3AVn8q-JS0Eq0QrfpBo-WfJ+-wXumhNoeDAdkPZC7LSeB5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Denis Kirjanov <kirjanov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:40965 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753779AbaIDLuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 07:50:16 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 390B620AF1
	for <netdev@vger.kernel.org>; Thu,  4 Sep 2014 07:50:15 -0400 (EDT)
In-Reply-To: <CAHj3AVn8q-JS0Eq0QrfpBo-WfJ+-wXumhNoeDAdkPZC7LSeB5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-09-04 at 10:09 +0400, Denis Kirjanov wrote:
> On Thursday, September 4, 2014, Alexei Starovoitov <
> alexei.starovoitov@gmail.com> wrote:
> 
> > On Wed, Sep 3, 2014 at 7:05 PM, Eric Dumazet <eric.dumazet@gmail.com
> > <javascript:;>> wrote:
> > > On Thu, 2014-09-04 at 03:25 +0200, Hannes Frederic Sowa wrote:
> > >
> > >> Can't we add an address marker to struct sk_buff?
> > >>
> > >> Several possibilities are available:
> > >>
> > >> ptrdiff_t pkt_type_offset[0]  before the pkt_type flags field
> > >>
> > >> If one wants to make it more expressive:
> > >> typedef struct {} mark_struct_offset;
> > >> and add
> > >> mark_struct_offset pkt_type_offset;
> > >> at appropriate places
> > >>
> > >> Or maybe an anonymous union?
> > >>
> > >> pkt_type_offset would become a simple offsetof(struct sk_buff,
> > >> pkt_type_offset) then and there is no need for BUG_ON then.
> > >
> > >
> > > You can try, and make sure this works on all gcc compilers, even the one
> > > Andrew Morton uses.
> > >
> > > And of course, you need to not introduce holes doing so.

Sure, it will work as expected. kmemleak uses the field[0] technique and
is already used in struct sk_buff.

I checked below patch with pahole and it doesn't change anything in size
or fieldoffsets.

> >
> > good points.
> > I think Hannes's idea is the best.
> 
> Agreed.
> 
> > It will help to get rid of helper altogether.
> > For my bpf syscall proposal I've used anonymous unions and tested
> > them with gcc 4.2 - 4.9 on x64/i386/arm32/sparc64 and clang.
> > All compilers were doing just fine. So it should work.
> 
> Nice. Alexei, care to send a patch then?

Denis, I thought about something like this, you can incorperate this in
your patch if you can give it a test and check for other architectures,
thanks!

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 05a5661..0fd3f95 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -765,27 +765,6 @@ static u64 jit_get_skb_w(struct sk_buff *skb,
unsigned offset)
 	return (u64)err << 32 | ntohl(ret);
 }
 
-#ifdef __BIG_ENDIAN_BITFIELD
-#define PKT_TYPE_MAX	(7 << 5)
-#else
-#define PKT_TYPE_MAX	7
-#endif
-static int pkt_type_offset(void)
-{
-	struct sk_buff skb_probe = {
-		.pkt_type = ~0,
-	};
-	u8 *ct = (u8 *)&skb_probe;
-	unsigned int off;
-
-	for (off = 0; off < sizeof(struct sk_buff); off++) {
-		if (ct[off] == PKT_TYPE_MAX)
-			return off;
-	}
-	pr_err_once("Please fix pkt_type_offset(), as pkt_type couldn't be
found\n");
-	return -1;
-}
-
 static int build_body(struct jit_ctx *ctx)
 {
 	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
@@ -1332,11 +1311,7 @@ jmp_cmp:
 		case BPF_ANC | SKF_AD_PKTTYPE:
 			ctx->flags |= SEEN_SKB;
 
-			off = pkt_type_offset();
-
-			if (off < 0)
-				return -1;
-			emit_load_byte(r_tmp, r_skb, off, ctx);
+			emit_load_byte(r_tmp, r_skb, skb_pkt_type_offset(), ctx);
 			/* Keep only the last 3 bits */
 			emit_andi(r_A, r_tmp, PKT_TYPE_MAX, ctx);
 #ifdef __BIG_ENDIAN_BITFIELD
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 61e45b7..8039bb8 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -223,37 +223,6 @@ static void bpf_jit_epilogue(struct bpf_jit *jit)
 	EMIT2(0x07fe);
 }
 
-/* Helper to find the offset of pkt_type in sk_buff
- * Make sure its still a 3bit field starting at the MSBs within a byte.
- */
-#define PKT_TYPE_MAX 0xe0
-static int pkt_type_offset;
-
-static int __init bpf_pkt_type_offset_init(void)
-{
-	struct sk_buff skb_probe = {
-		.pkt_type = ~0,
-	};
-	char *ct = (char *)&skb_probe;
-	int off;
-
-	pkt_type_offset = -1;
-	for (off = 0; off < sizeof(struct sk_buff); off++) {
-		if (!ct[off])
-			continue;
-		if (ct[off] == PKT_TYPE_MAX)
-			pkt_type_offset = off;
-		else {
-			/* Found non matching bit pattern, fix needed. */
-			WARN_ON_ONCE(1);
-			pkt_type_offset = -1;
-			return -1;
-		}
-	}
-	return 0;
-}
-device_initcall(bpf_pkt_type_offset_init);
-
 /*
  * make sure we dont leak kernel information to user
  */
@@ -753,12 +722,10 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 		}
 		break;
 	case BPF_ANC | SKF_AD_PKTTYPE:
-		if (pkt_type_offset < 0)
-			goto out;
 		/* lhi %r5,0 */
 		EMIT4(0xa7580000);
 		/* ic %r5,<d(pkt_type_offset)>(%r2) */
-		EMIT4_DISP(0x43502000, pkt_type_offset);
+		EMIT4_DISP(0x43502000, skb_pkt_type_offset());
 		/* srl %r5,5 */
 		EMIT4_DISP(0x88500000, 5);
 		break;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 02529fc..87b86aa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -548,6 +548,10 @@ struct sk_buff {
 				ip_summed:2,
 				nohdr:1,
 				nfctinfo:3;
+	/* __pkt_type_offset marks the offset of the bitfield pkt_type
+	 * contains, so bpf can relatively address it
+	 */
+	int			__pkt_type_offset[0];
 	__u8			pkt_type:3,
 				fclone:2,
 				ipvs_property:1,
@@ -647,6 +651,17 @@ struct sk_buff {
 #define SKB_ALLOC_FCLONE	0x01
 #define SKB_ALLOC_RX		0x02
 
+#ifdef __BIG_ENDIAN_BITFIELD
+#define PKT_TYPE_MAX   (7 << 5)
+#else
+#define PKT_TYPE_MAX   7
+#endif
+
+static inline size_t skb_pkt_type_offset(void)
+{
+	return offsetof(struct sk_buff, __pkt_type_offset);
+}
+
 /* Returns true if the skb was allocated from PFMEMALLOC reserves */
 static inline bool skb_pfmemalloc(const struct sk_buff *skb)
 {
diff --git a/net/core/filter.c b/net/core/filter.c
index d814b8a..ca64d7a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -87,30 +87,6 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sk_filter);
 
-/* Helper to find the offset of pkt_type in sk_buff structure. We want
- * to make sure its still a 3bit field starting at a byte boundary;
- * taken from arch/x86/net/bpf_jit_comp.c.
- */
-#ifdef __BIG_ENDIAN_BITFIELD
-#define PKT_TYPE_MAX	(7 << 5)
-#else
-#define PKT_TYPE_MAX	7
-#endif
-static unsigned int pkt_type_offset(void)
-{
-	struct sk_buff skb_probe = { .pkt_type = ~0, };
-	u8 *ct = (u8 *) &skb_probe;
-	unsigned int off;
-
-	for (off = 0; off < sizeof(struct sk_buff); off++) {
-		if (ct[off] == PKT_TYPE_MAX)
-			return off;
-	}
-
-	pr_err_once("Please fix %s, as pkt_type couldn't be found!\n",
__func__);
-	return -1;
-}
-
 static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
 	return __skb_get_poff((struct sk_buff *)(unsigned long) ctx);
@@ -191,7 +167,7 @@ static bool convert_bpf_extensions(struct
sock_filter *fp,
 
 	case SKF_AD_OFF + SKF_AD_PKTTYPE:
 		*insn = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
-				    pkt_type_offset());
+				    skb_pkt_type_offset());
 		if (insn->off < 0)
 			return false;
 		insn++;
