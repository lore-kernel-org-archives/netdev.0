From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH 1/3] net: bpf jit: ppc: optimize choose_load_func error
 path
Date: Sun, 13 Oct 2013 16:26:09 +0200
Message-ID: <20131013142607.GB1872@hp530>
References: <1381249910-17338-1-git-send-email-murzin.v@gmail.com>
 <52548C38.9040308@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, av1474@comtv.ru,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Matt Evans <matt@ozlabs.org>
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36695 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab3JMO0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 10:26:39 -0400
Received: by mail-lb0-f174.google.com with SMTP id w6so4813099lbh.5
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 07:26:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <52548C38.9040308@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 09, 2013 at 12:50:32AM +0200, Jan Seiffert wrote:
> Vladimir Murzin schrieb:
> > Macro CHOOSE_LOAD_FUNC returns handler for "any offset" if checks for K
> > were not passed. At the same time handlers for "any offset" cases make
> > the same checks against r_addr at run-time, that will always lead to
> > bpf_error.
> > 
> 
> Hmmm, if i only would remember why i wrote it that way....
> I memory serves me right the idea was to always have a solid fall back, no
> matter what, to the generic load function which works more like the load_pointer
> from filter.c.
> This way the COOSE-macro may could have been used at more places, but that
> never played out.
> 
> And since all i wanted was to get the negative indirect load fixed,
> optimizing the constant error case was not on my plate.
> That you can get your negative K filter JITed in the first place, even
> if the constant error case was slower than necessary, was good enough ;)
> 
> The ARM JIT is broken till this date...

... and s390 too.

> 
> You can have my
> I'm-OK-with-this: Jan Seiffert <kaffeemonster@googlemail.com>
> 
> for all three patches, -ENOTIME for a full review ATM.
> 

Thanks for feedback, Jan!

> > Run-time checks are still necessary for indirect load operations, but
> > error path for absolute and mesh loads are worth to optimize during bpf
> > compile time.
> > 
> > Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
> > 
> > Cc: Jan Seiffert <kaffeemonster@googlemail.com>
> > Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Cc: Daniel Borkmann <dborkman@redhat.com>
> > Cc: Matt Evans <matt@ozlabs.org>
> > 
> > ---
> >  arch/powerpc/net/bpf_jit_comp.c |    7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> > index bf56e33..754320a 100644
> > --- a/arch/powerpc/net/bpf_jit_comp.c
> > +++ b/arch/powerpc/net/bpf_jit_comp.c
> > @@ -132,7 +132,7 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
> >  }
> >  
> >  #define CHOOSE_LOAD_FUNC(K, func) \
> > -	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
> > +	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : NULL) : func##_positive_offset)
> >  
> >  /* Assemble the body code between the prologue & epilogue. */
> >  static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
> > @@ -427,6 +427,11 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
> >  		case BPF_S_LD_B_ABS:
> >  			func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
> >  		common_load:
> > +			if (!func) {
> > +				PPC_LI(r_ret, 0);
> > +				PPC_JMP(exit_addr);
> > +				break;
> > +			}
> >  			/* Load from [K]. */
> >  			ctx->seen |= SEEN_DATAREF;
> >  			PPC_LI64(r_scratch1, func);
> > 
> 
> 
> -- 
> An UDP packet walks into a
