From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 5 Jul 2005 15:48:05 +0200
Message-ID: <20050705134805.GH16076@postel.suug.ch>
References: <20050704.154712.63128211.davem@davemloft.net> <42C9BE69.2070008@cosmosbay.com> <42C9BEF6.4080402@cosmosbay.com> <20050704.160140.21591849.davem@davemloft.net> <42CA390C.9000801@cosmosbay.com> <20050705115108.GE16076@postel.suug.ch> <42CA8555.9050607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <42CA8555.9050607@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Dumazet <42CA8555.9050607@cosmosbay.com> 2005-07-05 15:04
> Thomas Graf a =E9crit :
> >* Eric Dumazet <42CA390C.9000801@cosmosbay.com> 2005-07-05 09:38
> >
> >>[NET] : unroll a small loop in pfifo_fast_dequeue(). Compiler generat=
es=20
> >>better code.
> >>	(Using skb_queue_empty() to test the queue is faster than trying to=20
> >>	__skb_dequeue())
> >>	oprofile says this function uses now 0.29% instead of 1.22 %, on a=20
> >>	x86_64 target.
> >
> >
> >I think this patch is pretty much pointless. __skb_dequeue() and
> >!skb_queue_empty() should produce almost the same code and as soon
> >as you disable profiling and debugging you'll see that the compiler
> >unrolls the loop itself if possible.
> >
> >
>=20
> OK. At least my compiler (gcc-3.3.1) does NOT unroll the loop :

Because you don't specify -funroll-loop

[...]

> Please give us the code your compiler produces,

Unrolled version:

pfifo_fast_dequeue:
	pushl	%esi
	xorl	%edx, %edx
	pushl	%ebx
	movl	12(%esp), %esi
	movl	128(%esi), %eax
	leal	128(%esi), %ecx
	cmpl	%ecx, %eax
	je	.L132
	movl	%eax, %edx
	movl	(%eax), %eax
	decl	8(%ecx)
	movl	$0, 8(%edx)
	movl	%ecx, 4(%eax)
	movl	%eax, 128(%esi)
	movl	$0, 4(%edx)
	movl	$0, (%edx)
.L132:
	testl	%edx, %edx
	je	.L131
	movl	96(%edx), %ebx
	movl	80(%esi), %eax
	decl	40(%esi)
	subl	%ebx, %eax
	movl	%eax, 80(%esi)
	movl	%edx, %eax
.L117:
	popl	%ebx
	popl	%esi
	ret
.L131:
	movl	20(%ecx), %eax
	leal	20(%ecx), %edx
	xorl	%ebx, %ebx
	cmpl	%edx, %eax
	je	.L137
	movl	%eax, %ebx
	movl	(%eax), %eax
	decl	8(%edx)
	movl	$0, 8(%ebx)
	movl	%edx, 4(%eax)
	movl	%eax, 20(%ecx)
	movl	$0, 4(%ebx)
	movl	$0, (%ebx)
.L137:
	testl	%ebx, %ebx
	je	.L147
.L146:
	movl	96(%ebx), %ecx
	movl	80(%esi), %eax
	decl	40(%esi)
	subl	%ecx, %eax
	movl	%eax, 80(%esi)
	movl	%ebx, %eax
	jmp	.L117
.L147:
	movl	40(%ecx), %eax
	leal	40(%ecx), %edx
	xorl	%ebx, %ebx
	cmpl	%edx, %eax
	je	.L142
	movl	%eax, %ebx
	movl	(%eax), %eax
	decl	8(%edx)
	movl	$0, 8(%ebx)
	movl	%edx, 4(%eax)
	movl	%eax, 40(%ecx)
	movl	$0, 4(%ebx)
	movl	$0, (%ebx)
.L142:
	xorl	%eax, %eax
	testl	%ebx, %ebx
	jne	.L146
	jmp	.L117

> and explain me how=20
> disabling oprofile can change the generated assembly. :)
> Debugging has no impact on this code either.

I just noticed that this is a local modification of my own, so in
the vanilla tree it indeed doesn't have any impact on the code
generated.

Still, your patch does not make sense to me. The latest tree
also includes my pfifo_fast changes wich modified the code to
maintain a backlog and made it easy to add more fifos at compile
time.  If you want the loop unrolled then let the compiler do it
via -funroll-loop. These kind of optimization seem as uncessary
to me as all the loopback optimizations.
