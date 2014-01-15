From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bpf: do not use reciprocal divide
Date: Wed, 15 Jan 2014 06:25:26 -0800
Message-ID: <1389795926.31367.334.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140113214249.GK6586@order.stressinduktion.org>
	 <1389769361.31367.325.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140115080007.GA6638@osiris> <20140115091322.3a7740a7@mschwide>
	 <20140115105114.GB6638@osiris>
	 <1389795716.31367.333.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, dborkman@redhat.com,
	darkjames-ws@darkjames.pl, Mircea Gherzan <mgherzan@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Matt Evans <matt@ozlabs.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:56634 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaAOOZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:25:28 -0500
Received: by mail-pa0-f41.google.com with SMTP id fb1so1221359pad.0
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 06:25:28 -0800 (PST)
In-Reply-To: <1389795716.31367.333.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 06:21 -0800, Eric Dumazet wrote:
> On Wed, 2014-01-15 at 11:51 +0100, Heiko Carstens wrote:
> > On Wed, Jan 15, 2014 at 09:13:22AM +0100, Martin Schwidefsky wrote:
> > > On Wed, 15 Jan 2014 09:00:07 +0100
> > > Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> > > 
> > > > On Tue, Jan 14, 2014 at 11:02:41PM -0800, Eric Dumazet wrote:
> > > > > diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
> > > > > index 16871da37371..e349dc7d0992 100644
> > > > > --- a/arch/s390/net/bpf_jit_comp.c
> > > > > +++ b/arch/s390/net/bpf_jit_comp.c
> > > > > @@ -371,11 +371,11 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
> > > > >  		/* dr %r4,%r12 */
> > > > >  		EMIT2(0x1d4c);
> > > > >  		break;
> > > > > -	case BPF_S_ALU_DIV_K: /* A = reciprocal_divide(A, K) */
> > > > > -		/* m %r4,<d(K)>(%r13) */
> > > > > -		EMIT4_DISP(0x5c40d000, EMIT_CONST(K));
> > > > > -		/* lr %r5,%r4 */
> > > > > -		EMIT2(0x1854);
> > > > > +	case BPF_S_ALU_DIV_K: /* A /= K */
> > > > > +		/* lhi %r4,0 */
> > > > > +		EMIT4(0xa7480000);
> > > > > +		/* d %r4,<d(K)>(%r13) */
> > > > > +		EMIT4_DISP(0x5d40d000, EMIT_CONST(K));
> > > > >  		break;
> > > > 
> > > > The s390 part looks good.
> > > 
> > > Does it? The divide instruction is signed, for the special
> > > case of K==1 this can now cause an exception if the quotient
> > > gets too large. We should add a check for K==1 and do nothing
> > > in this case. With a divisor of at least 2 the result will
> > > stay in the limit.
> > 
> > Indeed. That's quite subtle.
> 
> net/core/filter.c does :
> 
> A /= K;
> 
> Why is this working in generic code (if K == 1), not in s390 one ?

Note that I copied code found in BPF_S_ALU_MOD_K, so this one would need
a fix as well.
