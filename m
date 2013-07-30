From: Joe Perches <joe@perches.com>
Subject: Re: [patch] net_sched: stack info leak in cbq_dump_wrr()
Date: Tue, 30 Jul 2013 00:12:32 -0700
Message-ID: <1375168352.2075.110.camel@joe-AO722>
References: <20130729193651.GA12525@elgon.mountain>
	 <1375127072.2075.48.camel@joe-AO722> <20130729200114.GA29160@mwanda>
	 <1375128751.2075.58.camel@joe-AO722> <20130730065509.GB29160@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46337 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757217Ab3G3HMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 03:12:33 -0400
In-Reply-To: <20130730065509.GB29160@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 09:55 +0300, Dan Carpenter wrote:
> On Mon, Jul 29, 2013 at 01:12:31PM -0700, Joe Perches wrote:
> > On Mon, 2013-07-29 at 23:01 +0300, Dan Carpenter wrote:
> > > On Mon, Jul 29, 2013 at 12:44:32PM -0700, Joe Perches wrote:
> > > > On Mon, 2013-07-29 at 22:36 +0300, Dan Carpenter wrote:
> > > > > opt.__reserved isn't cleared so we leak a byte of stack information.
> > > > []
> > > > > diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> > > > []
> > > > > @@ -1469,6 +1469,7 @@ static int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
> > > > >  	opt.allot = cl->allot;
> > > > >  	opt.priority = cl->priority + 1;
> > > > >  	opt.cpriority = cl->cpriority + 1;
> > > > > +	opt.__reserved = 0;
> > > > >  	opt.weight = cl->weight;
> > > > >  	if (nla_put(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt))
> > > > >  		goto nla_put_failure;
> > > > 
> > > > Alignment isn't guaranteed here so it'd
> > > > probably be better with a memset.
> > > > 
> > > 
> > > Hm...  Which arches would align it differently?
> > 
> > Hey Dan.
> > 
> > None so far as I know, but what difference does it make
> > when it's a general correctness issue?
> > 
> 
> Because I would assume if these aren't aligned the same way we have
> far more serious problems than just this one case.  It would change
> the user space API and break network protocols.

<shrug>

I didn't say it was necessary to be done here, I said it
was a correctness issue.  I still believe that's true.

The nla_put here is by structure, the struct is unpacked,
and it's local to the arch, not a particular endian type.

btw: to answer David's question, gcc 4.7 is smart enough
to elide resetting values when the struct is initialized
to 0 either with a memset or using {0}.

$ cat t.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct foo {
	int a;
	char b;
	long c;
};

void init1(void)
{
	struct foo bar = {0};
	bar.a = 1;
	bar.b = 2;
	bar.c = 3;
	printf("%p\n", &bar);
}

void init2(void)
{
	struct foo bar;
	memset(&bar, 0, sizeof(bar));
	bar.a = 1;
	bar.b = 2;
	bar.c = 3;
	printf("%p\n", &bar);

$ gcc -S -O2 t.c
$ cat t.s
	.file	"t.c"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"%p\n"
	.text
	.p2align 4,,15
	.globl	init1
	.type	init1, @function
init1:
.LFB60:
	.cfi_startproc
	subl	$44, %esp
	.cfi_def_cfa_offset 48
	leal	20(%esp), %eax
	movl	%eax, 8(%esp)
	movl	$.LC0, 4(%esp)
	movl	$1, (%esp)
	movl	$0, 24(%esp)
	movl	$1, 20(%esp)
	movb	$2, 24(%esp)
	movl	$3, 28(%esp)
	call	__printf_chk
	addl	$44, %esp
	.cfi_def_cfa_offset 4
	ret
	.cfi_endproc
.LFE60:
	.size	init1, .-init1
	.p2align 4,,15
	.globl	init2
	.type	init2, @function
init2:
.LFB61:
	.cfi_startproc
	subl	$44, %esp
	.cfi_def_cfa_offset 48
	leal	20(%esp), %eax
	movl	%eax, 8(%esp)
	movl	$.LC0, 4(%esp)
	movl	$1, (%esp)
	movl	$0, 24(%esp)
	movl	$1, 20(%esp)
	movb	$2, 24(%esp)
	movl	$3, 28(%esp)
	call	__printf_chk
	addl	$44, %esp
	.cfi_def_cfa_offset 4
	ret
	.cfi_endproc
.LFE61:
	.size	init2, .-init2
	.ident	"GCC: (Ubuntu/Linaro 4.7.3-1ubuntu1) 4.7.3"
	.section	.note.GNU-stack,"",@progbits
