From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH net] bpf: do not use reciprocal divide
Date: Wed, 15 Jan 2014 09:13:22 +0100
Message-ID: <20140115091322.3a7740a7@mschwide>
References: <20140113214249.GK6586@order.stressinduktion.org>
	<1389769361.31367.325.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140115080007.GA6638@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, dborkman@redhat.com,
	darkjames-ws@darkjames.pl, Mircea Gherzan <mgherzan@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Matt Evans <matt@ozlabs.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:39800 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbaAOINe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 03:13:34 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <schwidefsky@de.ibm.com>;
	Wed, 15 Jan 2014 08:13:32 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id C96B617D8059
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:13:41 +0000 (GMT)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0F8DH1R58785866
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:13:17 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0F8DPJW020043
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 01:13:28 -0700
In-Reply-To: <20140115080007.GA6638@osiris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jan 2014 09:00:07 +0100
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

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

Does it? The divide instruction is signed, for the special
case of K==1 this can now cause an exception if the quotient
gets too large. We should add a check for K==1 and do nothing
in this case. With a divisor of at least 2 the result will
stay in the limit.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
