From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [RESEND PATCH 2/2] ppc: bpf_jit: support MOD operation
Date: Sun, 22 Sep 2013 17:35:46 +0200
Message-ID: <20130922153542.GA2010@hp530>
References: <1379748334-3313-1-git-send-email-murzin.v@gmail.com>
 <1379748334-3313-2-git-send-email-murzin.v@gmail.com>
 <F41DB09C-2D43-48DA-AE0A-4988B887F65C@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"paulus@samba.org" <paulus@samba.org>,
	"edumazet@google.com" <edumazet@google.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>
To: Matt Evans <matt@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:40642 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab3IVPg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 11:36:28 -0400
Received: by mail-lb0-f175.google.com with SMTP id y6so1954086lbh.6
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 08:36:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <F41DB09C-2D43-48DA-AE0A-4988B887F65C@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 01:13:45AM +1000, Matt Evans wrote:
> Hi Vladimir,
> 
> On 21 Sep 2013, at 17:25, Vladimir Murzin <murzin.v@gmail.com> wrote:
> 
> > commit b6069a9570 (filter: add MOD operation) added generic
> > support for modulus operation in BPF.
> > 
> > This patch brings JIT support for PPC64
> > 
> > Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
> > Acked-by: Matt Evans <matt@ozlabs.org>
> 
> Not this version, though; see below. 
> 
> > ---
> > arch/powerpc/net/bpf_jit_comp.c | 22 ++++++++++++++++++++++
> > 1 file changed, 22 insertions(+)
> > 
> > diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> > index bf56e33..96f24dc 100644
> > --- a/arch/powerpc/net/bpf_jit_comp.c
> > +++ b/arch/powerpc/net/bpf_jit_comp.c
> > @@ -193,6 +193,28 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
> >                PPC_MUL(r_A, r_A, r_scratch1);
> >            }
> >            break;
> > +        case BPF_S_ALU_MOD_X: /* A %= X; */
> > +            ctx->seen |= SEEN_XREG;
> > +            PPC_CMPWI(r_X, 0);
> > +            if (ctx->pc_ret0 != -1) {
> > +                PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
> > +            } else {
> > +                PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
> > +                PPC_LI(r_ret, 0);
> > +                PPC_JMP(exit_addr);
> > +            }
> > +            PPC_DIVWU(r_scratch1, r_A, r_X);
> > +            PPC_MUL(r_scratch1, r_X, r_scratch1);
> > +            PPC_SUB(r_A, r_A, r_scratch1);
> > +            break;
> > +        case BPF_S_ALU_MOD_K: /* A %= K; */
> > +#define r_scratch2 (r_scratch1 + 1)
> 
> Old version of this patch, still?  I had hoped that r_scratch2 would be defined in the header.

Oops.. been keeping the old version.. sorry for that, Matt :(

> 
> > +            PPC_LI32(r_scratch2, K);
> > +            PPC_DIVWU(r_scratch1, r_A, r_scratch2);
> > +            PPC_MUL(r_scratch1, r_scratch2, r_scratch1);
> > +            PPC_SUB(r_A, r_A, r_scratch1);
> > +#undef r_scratch2
> 
> And remember this guy too.. :)

I've included the patch below. Nothing is missed this time, I hope ;) 

> 
> 
> Matt
> 
> > +            break;
> >        case BPF_S_ALU_DIV_X: /* A /= X; */
> >            ctx->seen |= SEEN_XREG;
> >            PPC_CMPWI(r_X, 0);
> > -- 
> > 1.8.1.5

---
From: Vladimir Murzin <murzin.v@gmail.com>
Date: Wed, 28 Aug 2013 01:29:39 +0400
Subject: [PATCH 2/2] ppc: bpf_jit: support MOD operation

commit b6069a9570 (filter: add MOD operation) added generic
support for modulus operation in BPF.

This patch brings JIT support for PPC64

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
Acked-by: Matt Evans <matt@ozlabs.org>
---
 arch/powerpc/net/bpf_jit.h      |  1 +
 arch/powerpc/net/bpf_jit_comp.c | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 8a5dfaf..42a115a 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -39,6 +39,7 @@
 #define r_X		5
 #define r_addr		6
 #define r_scratch1	7
+#define r_scratch2	8
 #define r_D		14
 #define r_HL		15
 #define r_M		16
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index bf56e33..cbb2702 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -193,6 +193,26 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 				PPC_MUL(r_A, r_A, r_scratch1);
 			}
 			break;
+		case BPF_S_ALU_MOD_X: /* A %= X; */
+			ctx->seen |= SEEN_XREG;
+			PPC_CMPWI(r_X, 0);
+			if (ctx->pc_ret0 != -1) {
+				PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
+			} else {
+				PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
+				PPC_LI(r_ret, 0);
+				PPC_JMP(exit_addr);
+			}
+			PPC_DIVWU(r_scratch1, r_A, r_X);
+			PPC_MUL(r_scratch1, r_X, r_scratch1);
+			PPC_SUB(r_A, r_A, r_scratch1);
+			break;
+		case BPF_S_ALU_MOD_K: /* A %= K; */
+			PPC_LI32(r_scratch2, K);
+			PPC_DIVWU(r_scratch1, r_A, r_scratch2);
+			PPC_MUL(r_scratch1, r_scratch2, r_scratch1);
+			PPC_SUB(r_A, r_A, r_scratch1);
+			break;
 		case BPF_S_ALU_DIV_X: /* A /= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_CMPWI(r_X, 0);
-- 
1.8.1.5
