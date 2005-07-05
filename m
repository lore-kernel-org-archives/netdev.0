From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 05 Jul 2005 17:58:39 +0200
Message-ID: <42CAAE2F.5070807@cosmosbay.com>
References: <20050704.154712.63128211.davem@davemloft.net> <42C9BE69.2070008@cosmosbay.com> <42C9BEF6.4080402@cosmosbay.com> <20050704.160140.21591849.davem@davemloft.net> <42CA390C.9000801@cosmosbay.com> <20050705115108.GE16076@postel.suug.ch> <42CA8555.9050607@cosmosbay.com> <20050705134805.GH16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050705134805.GH16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf a =E9crit :

>>OK. At least my compiler (gcc-3.3.1) does NOT unroll the loop :
>=20
>=20
> Because you don't specify -funroll-loop

I'm using vanilla 2.6.12 : no -funroll-loop in it. Maybe in your tree, no=
t on 99.9% of 2.6.12 trees.

Are you suggesting everybody should use this compiler flag ?
Something like :

net/sched/Makefile:

CFLAGS_sch_generic.o :=3D -funroll-loops

?

>=20
> [...]
>=20
>=20
>>Please give us the code your compiler produces,
>=20
>=20
> Unrolled version:
>=20
> pfifo_fast_dequeue:
> 	pushl	%esi
> 	xorl	%edx, %edx
> 	pushl	%ebx
> 	movl	12(%esp), %esi
> 	movl	128(%esi), %eax
> 	leal	128(%esi), %ecx
> 	cmpl	%ecx, %eax
> 	je	.L132
> 	movl	%eax, %edx
> 	movl	(%eax), %eax
> 	decl	8(%ecx)
> 	movl	$0, 8(%edx)
> 	movl	%ecx, 4(%eax)
> 	movl	%eax, 128(%esi)
> 	movl	$0, 4(%edx)
> 	movl	$0, (%edx)
> .L132:
> 	testl	%edx, %edx
> 	je	.L131
> 	movl	96(%edx), %ebx
> 	movl	80(%esi), %eax
> 	decl	40(%esi)
> 	subl	%ebx, %eax
> 	movl	%eax, 80(%esi)
> 	movl	%edx, %eax
> .L117:
> 	popl	%ebx
> 	popl	%esi
> 	ret
> .L131:
> 	movl	20(%ecx), %eax
> 	leal	20(%ecx), %edx
> 	xorl	%ebx, %ebx
> 	cmpl	%edx, %eax
> 	je	.L137
> 	movl	%eax, %ebx
> 	movl	(%eax), %eax
> 	decl	8(%edx)
> 	movl	$0, 8(%ebx)
> 	movl	%edx, 4(%eax)
> 	movl	%eax, 20(%ecx)
> 	movl	$0, 4(%ebx)
> 	movl	$0, (%ebx)
> .L137:
> 	testl	%ebx, %ebx
> 	je	.L147
> .L146:
> 	movl	96(%ebx), %ecx
> 	movl	80(%esi), %eax
> 	decl	40(%esi)
> 	subl	%ecx, %eax
> 	movl	%eax, 80(%esi)
> 	movl	%ebx, %eax
> 	jmp	.L117
> .L147:
> 	movl	40(%ecx), %eax
> 	leal	40(%ecx), %edx
> 	xorl	%ebx, %ebx
> 	cmpl	%edx, %eax
> 	je	.L142
> 	movl	%eax, %ebx
> 	movl	(%eax), %eax
> 	decl	8(%edx)
> 	movl	$0, 8(%ebx)
> 	movl	%edx, 4(%eax)
> 	movl	%eax, 40(%ecx)
> 	movl	$0, 4(%ebx)
> 	movl	$0, (%ebx)
> .L142:
> 	xorl	%eax, %eax
> 	testl	%ebx, %ebx
> 	jne	.L146
> 	jmp	.L117
>=20

OK thanks, but you dont give the code for my version :) shorter and unrol=
led as you can see, and with nice predicted branches.

00000fc0 <pfifo_fast_dequeue>:
      fc0:       56                      push   %esi
      fc1:       89 c1                   mov    %eax,%ecx
      fc3:       53                      push   %ebx
      fc4:       8d 98 a0 00 00 00       lea    0xa0(%eax),%ebx
      fca:       39 98 a0 00 00 00       cmp    %ebx,0xa0(%eax)
      fd0:       89 da                   mov    %ebx,%edx
      fd2:       75 22                   jne    ff6 <pfifo_fast_dequeue+0=
x36>
      fd4:       8d 90 c4 00 00 00       lea    0xc4(%eax),%edx
      fda:       39 90 c4 00 00 00       cmp    %edx,0xc4(%eax)
      fe0:       89 d3                   mov    %edx,%ebx
      fe2:       75 12                   jne    ff6 <pfifo_fast_dequeue+0=
x36>
      fe4:       8d 98 e8 00 00 00       lea    0xe8(%eax),%ebx
      fea:       31 f6                   xor    %esi,%esi
      fec:       39 98 e8 00 00 00       cmp    %ebx,0xe8(%eax)
      ff2:       89 da                   mov    %ebx,%edx
      ff4:       74 27                   je     101d <pfifo_fast_dequeue+=
0x5d>
      ff6:       8b 32                   mov    (%edx),%esi
      ff8:       39 d6                   cmp    %edx,%esi
      ffa:       74 26                   je     1022 <pfifo_fast_dequeue+=
0x62>
      ffc:       8b 06                   mov    (%esi),%eax
      ffe:       ff 4b 08                decl   0x8(%ebx)
     1001:       c7 46 08 00 00 00 00    movl   $0x0,0x8(%esi)
     1008:       89 50 04                mov    %edx,0x4(%eax)
     100b:       89 02                   mov    %eax,(%edx)
     100d:       c7 46 04 00 00 00 00    movl   $0x0,0x4(%esi)
     1014:       c7 06 00 00 00 00       movl   $0x0,(%esi)
     101a:       ff 49 28                decl   0x28(%ecx)
     101d:       5b                      pop    %ebx
     101e:       89 f0                   mov    %esi,%eax
     1020:       5e                      pop    %esi
     1021:       c3                      ret
     1022:       ff 49 28                decl   0x28(%ecx)
     1025:       31 f6                   xor    %esi,%esi
     1027:       eb f4                   jmp    101d <pfifo_fast_dequeue+=
0x5d>


>=20
> I just noticed that this is a local modification of my own, so in
> the vanilla tree it indeed doesn't have any impact on the code
> generated.
>=20
> Still, your patch does not make sense to me. The latest tree
> also includes my pfifo_fast changes wich modified the code to
> maintain a backlog and made it easy to add more fifos at compile
> time.  If you want the loop unrolled then let the compiler do it
> via -funroll-loop. These kind of optimization seem as uncessary
> to me as all the loopback optimizations.
>=20

I dont want change compiler flags in my tree and loose this optim when 2.=
6.13 is released.

I dont know about loopback optimization, I am not involved with this stuf=
f, maybe you think I'm another guy ?

It seems to me you give unrelated arguments.
I dont know what are your plans, but mine were not to say you are writing=
 bad code.
Just to give my performance analysis and feedback, I'm sorry if it hurts =
you.


Eric Dumazet
