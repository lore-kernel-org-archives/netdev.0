From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 2/5] s390/bpf: Fix multiple macro expansions
Date: Wed, 29 Jul 2015 10:32:05 +0200
Message-ID: <20150729103205.66b31a9e@holzheu>
References: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
	<1438092600-16221-3-git-send-email-holzheu@linux.vnet.ibm.com>
	<1438139621.2529.31.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:48572 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbbG2IcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 04:32:13 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
	Wed, 29 Jul 2015 09:32:12 +0100
In-Reply-To: <1438139621.2529.31.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jul 2015 20:13:41 -0700
Joe Perches <joe@perches.com> wrote:

> On Tue, 2015-07-28 at 16:09 +0200, Michael Holzheu wrote:
> > The EMIT6_DISP_LH macro passes the "disp" parameter to the _EMIT6_DISP_LH
> > macro. The _EMIT6_DISP_LH macro uses the "disp" parameter twice:
> > 
> >  unsigned int __disp_h = ((u32)disp) & 0xff000;
> >  unsigned int __disp_l = ((u32)disp) & 0x00fff;
> > 
> > The EMIT6_DISP_LH is used several times with EMIT_CONST_U64() as "disp"
> > parameter. Therefore always two constants are created per usage of
> > EMIT6_DISP_LH.
> > 
> > Fix this and add variable "__disp" to avoid multiple expansions.
> > 
> > Fixes: 054623105728 ("s390/bpf: Add s390x eBPF JIT compiler backend")
> > Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> > ---
> >  arch/s390/net/bpf_jit_comp.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
> > index 01ad166..de0f0bc 100644
> > --- a/arch/s390/net/bpf_jit_comp.c
> > +++ b/arch/s390/net/bpf_jit_comp.c
> > @@ -221,8 +221,9 @@ static inline void reg_set_seen(struct nbpf_jit *jit, u32 b1)
> >  
> >  #define EMIT6_DISP_LH(op1, op2, b1, b2, b3, disp)		\
> >  ({								\
> > +	int __disp = (disp);					\
> >  	_EMIT6_DISP_LH(op1 | reg(b1, b2) << 16 |		\
> > -		       reg_high(b3) << 8, op2, disp);		\
> > +		       reg_high(b3) << 8, op2, __disp);		\
> >  	REG_SET_SEEN(b1);					\
> >  	REG_SET_SEEN(b2);					\
> >  	REG_SET_SEEN(b3);					\
> 
> Perhaps it'd be better to change _EMIT6_DISP_LH

Looks a bit better. I will send the updated patch.

Thanks!
Michael

> ---
> diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
> index 3a15baa..409e206 100644
> --- a/arch/s390/net/bpf_jit_comp.c
> +++ b/arch/s390/net/bpf_jit_comp.c
> @@ -205,8 +205,9 @@ static inline void reg_set_seen(struct bpf_jit *jit,
> u32 b1)
> 
>  #define _EMIT6_DISP_LH(op1, op2, disp)				\
>  ({								\
> -	unsigned int __disp_h = ((u32)disp) & 0xff000;		\
> -	unsigned int __disp_l = ((u32)disp) & 0x00fff;		\
> +	u32 _disp = (u32)disp;					\
> +	unsigned int __disp_h = _disp & 0xff000;		\
> +	unsigned int __disp_l = _disp & 0x00fff;		\
>  	_EMIT6(op1 | __disp_l, op2 | __disp_h >> 4);		\
>  })
> 
> 
> 
