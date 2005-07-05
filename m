From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 05 Jul 2005 15:04:21 +0200
Message-ID: <42CA8555.9050607@cosmosbay.com>
References: <20050704.154712.63128211.davem@davemloft.net> <42C9BE69.2070008@cosmosbay.com> <42C9BEF6.4080402@cosmosbay.com> <20050704.160140.21591849.davem@davemloft.net> <42CA390C.9000801@cosmosbay.com> <20050705115108.GE16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050705115108.GE16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf a =E9crit :
> * Eric Dumazet <42CA390C.9000801@cosmosbay.com> 2005-07-05 09:38
>=20
>>[NET] : unroll a small loop in pfifo_fast_dequeue(). Compiler generates=
=20
>>better code.
>>	(Using skb_queue_empty() to test the queue is faster than trying to=20
>>	__skb_dequeue())
>>	oprofile says this function uses now 0.29% instead of 1.22 %, on a=20
>>	x86_64 target.
>=20
>=20
> I think this patch is pretty much pointless. __skb_dequeue() and
> !skb_queue_empty() should produce almost the same code and as soon
> as you disable profiling and debugging you'll see that the compiler
> unrolls the loop itself if possible.
>=20
>=20

OK. At least my compiler (gcc-3.3.1) does NOT unroll the loop :

Original 2.6.12 gives :

ffffffff802a9790 <pfifo_fast_dequeue>: /* pfifo_fast_dequeue total: 29040=
54  1.9531 */
258371  0.1738 :ffffffff802a9790:       lea    0xc0(%rdi),%rcx
273669  0.1841 :ffffffff802a9797:       xor    %esi,%esi
  12533  0.0084 :ffffffff802a9799:       mov    (%rcx),%rdx
292315  0.1966 :ffffffff802a979c:       cmp    %rcx,%rdx
  11717  0.0079 :ffffffff802a979f:       je     ffffffff802a97d1 <pfifo_f=
ast_dequeue+0x41>
   4474  0.0030 :ffffffff802a97a1:       mov    %rdx,%rax
   6238  0.0042 :ffffffff802a97a4:       mov    (%rdx),%rdx
     41 2.8e-05 :ffffffff802a97a7:       decl   0x10(%rcx)
   6089  0.0041 :ffffffff802a97aa:       test   %rax,%rax
    126 8.5e-05 :ffffffff802a97ad:       movq   $0x0,0x10(%rax)
     39 2.6e-05 :ffffffff802a97b5:       mov    %rcx,0x8(%rdx)
   6974  0.0047 :ffffffff802a97b9:       mov    %rdx,(%rcx)
   2841  0.0019 :ffffffff802a97bc:       movq   $0x0,0x8(%rax)
    366 2.5e-04 :ffffffff802a97c4:       movq   $0x0,(%rax)
  14757  0.0099 :ffffffff802a97cb:       je     ffffffff802a97d1 <pfifo_f=
ast_dequeue+0x41>
    288 1.9e-04 :ffffffff802a97cd:       decl   0x40(%rdi)
     94 6.3e-05 :ffffffff802a97d0:       retq
970400  0.6526 :ffffffff802a97d1:       inc    %esi
982402  0.6607 :ffffffff802a97d3:       add    $0x18,%rcx
      4 2.7e-06 :ffffffff802a97d7:       cmp    $0x2,%esi
      1 6.7e-07 :ffffffff802a97da:       jle    ffffffff802a9799 <pfifo_f=
ast_dequeue+0x9>
  59754  0.0402 :ffffffff802a97dc:       xor    %eax,%eax
    561 3.8e-04 :ffffffff802a97de:       data16
                :ffffffff802a97df:       nop
                :ffffffff802a97e0:       retq


And new code (2.6.12-ed):

ffffffff802b1020 <pfifo_fast_dequeue>: /* pfifo_fast_dequeue total: 15313=
9  0.2934 */
  27388  0.0525 :ffffffff802b1020:       lea    0xc0(%rdi),%rdx
  42091  0.0806 :ffffffff802b1027:       cmp    %rdx,0xc0(%rdi)
                :ffffffff802b102e:       jne    ffffffff802b1052 <pfifo_f=
ast_dequeue+0x32>
    474 9.1e-04 :ffffffff802b1030:       lea    0xd8(%rdi),%rdx
   5571  0.0107 :ffffffff802b1037:       cmp    %rdx,0xd8(%rdi)
      2 3.8e-06 :ffffffff802b103e:       jne    ffffffff802b1052 <pfifo_f=
ast_dequeue+0x32>
      1 1.9e-06 :ffffffff802b1040:       lea    0xf0(%rdi),%rdx
  20030  0.0384 :ffffffff802b1047:       xor    %eax,%eax
      6 1.1e-05 :ffffffff802b1049:       cmp    %rdx,0xf0(%rdi)
      6 1.1e-05 :ffffffff802b1050:       je     ffffffff802b1086 <pfifo_f=
ast_dequeue+0x66>
                :ffffffff802b1052:       mov    (%rdx),%rcx
  11796  0.0226 :ffffffff802b1055:       xor    %eax,%eax
                :ffffffff802b1057:       cmp    %rdx,%rcx
      8 1.5e-05 :ffffffff802b105a:       je     ffffffff802b1083 <pfifo_f=
ast_dequeue+0x63>
   3146  0.0060 :ffffffff802b105c:       mov    %rcx,%rax
     12 2.3e-05 :ffffffff802b105f:       mov    (%rcx),%rcx
    118 2.3e-04 :ffffffff802b1062:       decl   0x10(%rdx)
   4924  0.0094 :ffffffff802b1065:       movq   $0x0,0x10(%rax)
     65 1.2e-04 :ffffffff802b106d:       mov    %rdx,0x8(%rcx)
    725  0.0014 :ffffffff802b1071:       mov    %rcx,(%rdx)
  11493  0.0220 :ffffffff802b1074:       movq   $0x0,0x8(%rax)
    194 3.7e-04 :ffffffff802b107c:       movq   $0x0,(%rax)
   2995  0.0057 :ffffffff802b1083:       decl   0x40(%rdi)
  19607  0.0376 :ffffffff802b1086:       nop
   2487  0.0048 :ffffffff802b1087:       retq


Please give us the code your compiler produces, and explain me how disabl=
ing oprofile can change the generated assembly. :)
Debugging has no impact on this code either.

Thank you

Eric
