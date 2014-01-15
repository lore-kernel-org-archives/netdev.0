From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bpf: do not use reciprocal divide
Date: Tue, 14 Jan 2014 23:39:36 -0800
Message-ID: <1389771576.31367.327.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140113214249.GK6586@order.stressinduktion.org>
	 <1389769361.31367.325.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140114.232846.647632973151148430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	dborkman@redhat.com, darkjames-ws@darkjames.pl, mgherzan@gmail.com,
	rmk+kernel@arm.linux.org.uk, matt@ozlabs.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:55190 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaAOHji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:39:38 -0500
Received: by mail-pa0-f47.google.com with SMTP id kp14so785310pab.6
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 23:39:38 -0800 (PST)
In-Reply-To: <20140114.232846.647632973151148430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 23:28 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 14 Jan 2014 23:02:41 -0800
> 
> > diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
> > index 218b6b23c378..125045063b91 100644
> > --- a/arch/sparc/net/bpf_jit_comp.c
> > +++ b/arch/sparc/net/bpf_jit_comp.c
> > @@ -498,8 +498,7 @@ void bpf_jit_compile(struct sk_filter *fp)
> >  				emit_alu_K(MUL, K);
> >  				break;
> >  			case BPF_S_ALU_DIV_K:	/* A /= K */
> > -				emit_alu_K(MUL, K);
> > -				emit_read_y(r_A);
> > +				emit_alu_K(DIV, K);
> >  				break;
> >  			case BPF_S_ALU_DIV_X:	/* A /= X; */
> >  				emit_cmpi(r_X, 0);
> 
> You have to clear the Y register before a divide, as it provides
> the top 32-bits of the 64-bit numerator.
> 
> You can just cut and paste the sequence used for BPF_S_ALU_DIV_X:
> 
> 				emit_write_y(G0);
> #ifdef CONFIG_SPARC32
> 				/* The Sparc v8 architecture requires
> 				 * three instructions between a %y
> 				 * register write and the first use.
> 				 */
> 				emit_nop();
> 				emit_nop();
> 				emit_nop();
> #endif
> 				emit_alu_X(DIV);

Thanks David, I will submit a v2 tomorrow morning, when/if I get more
feedback for other arches, and after some rest ;)
