From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH 2/3] net: bpf jit: x86: optimize choose_load_func error
 path
Date: Sun, 13 Oct 2013 16:21:21 +0200
Message-ID: <20131013142115.GA1872@hp530>
References: <1381249910-17338-1-git-send-email-murzin.v@gmail.com>
 <1381249910-17338-2-git-send-email-murzin.v@gmail.com>
 <20131011.145613.332487610005117559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, av1474@comtv.ru,
	kaffeemonster@googlemail.com, edumazet@google.com,
	mingo@redhat.com, tglx@linutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:34552 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab3JMOV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 10:21:57 -0400
Received: by mail-la0-f46.google.com with SMTP id eh20so4874997lab.33
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 07:21:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131011.145613.332487610005117559.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 11, 2013 at 02:56:13PM -0400, David Miller wrote:
> From: Vladimir Murzin <murzin.v@gmail.com>
> Date: Tue,  8 Oct 2013 20:31:49 +0400
> 
> > Macro CHOOSE_LOAD_FUNC returns handler for "any offset" if checks for K
> > were not passed. At the same time handlers for "any offset" cases make
> > the same checks against r_addr at run-time, that will always lead to
> > bpf_error.
> > 
> > Run-time checks are still necessary for indirect load operations, but
> > error path for absolute and mesh loads are worth to optimize during bpf
> > compile time.
> > 
> > Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
> > 
> > Cc: Jan Seiffert <kaffeemonster@googlemail.com>
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: "David S. Miller" <davem@davemloft.net
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > 
> > ---
> >  arch/x86/net/bpf_jit_comp.c |   15 +++++++++------
> >  1 file changed, 9 insertions(+), 6 deletions(-)
> > 
> > diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
> > index 79c216a..28ac17f 100644
> > --- a/arch/x86/net/bpf_jit_comp.c
> > +++ b/arch/x86/net/bpf_jit_comp.c
> > @@ -123,7 +123,7 @@ static inline void bpf_flush_icache(void *start, void *end)
> >  }
> >  
> >  #define CHOOSE_LOAD_FUNC(K, func) \
> > -	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
> > +	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : NULL) : func##_positive_offset)
> >  
> >  /* Helper to find the offset of pkt_type in sk_buff
> >   * We want to make sure its still a 3bit field starting at a byte boundary.
> > @@ -611,7 +611,13 @@ void bpf_jit_compile(struct sk_filter *fp)
> >  			}
> >  			case BPF_S_LD_W_ABS:
> >  				func = CHOOSE_LOAD_FUNC(K, sk_load_word);
> > -common_load:			seen |= SEEN_DATAREF;
> > +common_load:
> > +				if (!func) {
> > +					CLEAR_A();
> > +					EMIT_JMP(cleanup_addr - addrs[i]);
> > +					break;
> > +				}
> > +				seen |= SEEN_DATAREF;
> >  				t_offset = func - (image + addrs[i]);
> >  				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
> >  				EMIT1_off32(0xe8, t_offset); /* call */
> > @@ -625,10 +631,7 @@ common_load:			seen |= SEEN_DATAREF;
> >  			case BPF_S_LDX_B_MSH:
> >  				func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
> >  				seen |= SEEN_DATAREF | SEEN_XREG;
> > -				t_offset = func - (image + addrs[i]);
> > -				EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
> > -				EMIT1_off32(0xe8, t_offset); /* call sk_load_byte_msh */
> > -				break;
> > +				goto common_load;
> 
> This second hunk will set SEEN_DATAREF even if common_load takes the
> !func path, that is not the intention at all here.
> 
> There's a reason why these two code blocks aren't shared.

Thanks for review, David!

What about patch bellow?

---
 arch/x86/net/bpf_jit_comp.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 79c216a..92128fe 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -123,7 +123,7 @@ static inline void bpf_flush_icache(void *start, void *end)
 }
 
 #define CHOOSE_LOAD_FUNC(K, func) \
-	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
+	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : NULL) : func##_positive_offset)
 
 /* Helper to find the offset of pkt_type in sk_buff
  * We want to make sure its still a 3bit field starting at a byte boundary.
@@ -611,7 +611,14 @@ void bpf_jit_compile(struct sk_filter *fp)
 			}
 			case BPF_S_LD_W_ABS:
 				func = CHOOSE_LOAD_FUNC(K, sk_load_word);
-common_load:			seen |= SEEN_DATAREF;
+common_load:
+				if (!func) {
+					CLEAR_A();
+					EIT_JMP(cleanup_addr - addrs[i]);
+					break;
+				}
+
+				seen |= SEEN_DATAREF;
 				t_offset = func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
 				EMIT1_off32(0xe8, t_offset); /* call */
@@ -624,6 +631,13 @@ common_load:			seen |= SEEN_DATAREF;
 				goto common_load;
 			case BPF_S_LDX_B_MSH:
 				func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
+
+				if (!func) {
+					CLEAR_A();
+					EIT_JMP(cleanup_addr - addrs[i]);
+					break;
+				}
+
 				seen |= SEEN_DATAREF | SEEN_XREG;
 				t_offset = func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
-- 
1.8.1.5

Vladimir
