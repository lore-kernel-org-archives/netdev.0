From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bpf: do not use reciprocal divide
Date: Wed, 15 Jan 2014 06:16:38 -0800
Message-ID: <1389795398.31367.329.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140113214249.GK6586@order.stressinduktion.org>
	 <1389769361.31367.325.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140115080007.GA6638@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, dborkman@redhat.com,
	darkjames-ws@darkjames.pl, Mircea Gherzan <mgherzan@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Matt Evans <matt@ozlabs.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:62088 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbaAOOQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:16:40 -0500
Received: by mail-pb0-f41.google.com with SMTP id up15so666264pbc.0
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 06:16:40 -0800 (PST)
In-Reply-To: <20140115080007.GA6638@osiris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 09:00 +0100, Heiko Carstens wrote:
> On Tue, Jan 14, 2014 at 11:02:41PM -0800, Eric Dumazet wrote:
> > diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
> > index 16871da37371..e349dc7d0992 100644
> > --- a/arch/s390/net/bpf_jit_comp.c
> > +++ b/arch/s390/net/bpf_jit_comp.c
> > @@ -371,11 +371,11 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
> >  		/* dr %r4,%r12 */
> >  		EMIT2(0x1d4c);
> >  		break;
> > -	case BPF_S_ALU_DIV_K: /* A = reciprocal_divide(A, K) */
> > -		/* m %r4,<d(K)>(%r13) */
> > -		EMIT4_DISP(0x5c40d000, EMIT_CONST(K));
> > -		/* lr %r5,%r4 */
> > -		EMIT2(0x1854);
> > +	case BPF_S_ALU_DIV_K: /* A /= K */
> > +		/* lhi %r4,0 */
> > +		EMIT4(0xa7480000);
> > +		/* d %r4,<d(K)>(%r13) */
> > +		EMIT4_DISP(0x5d40d000, EMIT_CONST(K));
> >  		break;
> 
> The s390 part looks good.
> 
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 01b780856db2..ad30d626a5bd 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -166,7 +165,7 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
> >  			A /= X;
> >  			continue;
> >  		case BPF_S_ALU_DIV_K:
> > -			A = reciprocal_divide(A, K);
> > +			A /= K;
> >  			continue;
> >  		case BPF_S_ALU_MOD_X:
> >  			if (X == 0)
> > @@ -553,11 +552,6 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
> >  		/* Some instructions need special checks */
> >  		switch (code) {
> >  		case BPF_S_ALU_DIV_K:
> > -			/* check for division by zero */
> > -			if (ftest->k == 0)
> > -				return -EINVAL;
> > -			ftest->k = reciprocal_value(ftest->k);
> > -			break;
> 
> Are you sure you want to remove the k == 0 check? Is there something
> else that would prevent a division by zero?

This is done by factoring the two cases, modulo and divide :

 vi +553 net/core/filter.c 

                /* Some instructions need special checks */
                switch (code) {
                case BPF_S_ALU_DIV_K:
                case BPF_S_ALU_MOD_K:
                        /* check for division by zero */
                        if (ftest->k == 0)
                                return -EINVAL;
                        break;
