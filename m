From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 06 Jul 2005 02:53:24 +0200
Message-ID: <42CB2B84.50702@cosmosbay.com>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch> <42CB2698.2080904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42CB2698.2080904@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
>
>=20
> Maybe we can rewrite the whole thing without branches, examining prio=20
> from PFIFO_FAST_BANDS-1 down to 0, at least for modern cpu with=20
> conditional mov (cmov)
>=20
> struct sk_buff_head *best =3D NULL;
> struct sk_buff_head *list =3D qdisc_priv(qdisc)+PFIFO_FAST_BANDS-1;
> if (skb_queue_empty(list)) best =3D list ;
> list--;
> if (skb_queue_empty(list)) best =3D list ;
> list--;
> if (skb_queue_empty(list)) best =3D list ;
> if (best !=3D NULL) {
>     qdisc->q.qlen--;
>     return __qdisc_dequeue_head(qdisc, best);
>     }
>=20
> This version should have one branch.
> I will test this after some sleep :)
> See you
> Eric
>=20
>=20

(Sorry, still using 2.6.12, but the idea remains)

static struct sk_buff *
pfifo_fast_dequeue(struct Qdisc* qdisc)
{
         struct sk_buff_head *list =3D qdisc_priv(qdisc);
         struct sk_buff_head *best =3D NULL;

	list +=3D 2;
         if (!skb_queue_empty(list))
                 best =3D list;
         list--;
         if (!skb_queue_empty(list))
                 best =3D list;
         list--;
         if (!skb_queue_empty(list))
                 best =3D list;
         if (best) {
                 qdisc->q.qlen--;
                 return __skb_dequeue(best);
                 }
         return NULL;
}



At least the compiler output seems promising :

0000000000000550 <pfifo_fast_dequeue>:
  550:   48 8d 97 f0 00 00 00    lea    0xf0(%rdi),%rdx
  557:   31 c9                   xor    %ecx,%ecx
  559:   48 8d 87 c0 00 00 00    lea    0xc0(%rdi),%rax
  560:   48 39 97 f0 00 00 00    cmp    %rdx,0xf0(%rdi)
  567:   48 0f 45 ca             cmovne %rdx,%rcx
  56b:   48 8d 97 d8 00 00 00    lea    0xd8(%rdi),%rdx
  572:   48 39 97 d8 00 00 00    cmp    %rdx,0xd8(%rdi)
  579:   48 0f 45 ca             cmovne %rdx,%rcx
  57d:   48 39 87 c0 00 00 00    cmp    %rax,0xc0(%rdi)
  584:   48 0f 45 c8             cmovne %rax,%rcx
  588:   31 c0                   xor    %eax,%eax
  58a:   48 85 c9                test   %rcx,%rcx
  58d:   74 32                   je     5c1 <pfifo_fast_dequeue+0x71> // =
one conditional branch
  58f:   ff 4f 40                decl   0x40(%rdi)
  592:   48 8b 11                mov    (%rcx),%rdx
  595:   48 39 ca                cmp    %rcx,%rdx
  598:   74 27                   je     5c1 <pfifo_fast_dequeue+0x71> // =
never taken branch : always predicted OK
  59a:   48 89 d0                mov    %rdx,%rax
  59d:   48 8b 12                mov    (%rdx),%rdx
  5a0:   ff 49 10                decl   0x10(%rcx)
  5a3:   48 c7 40 10 00 00 00    movq   $0x0,0x10(%rax)
  5aa:   00
  5ab:   48 89 4a 08             mov    %rcx,0x8(%rdx)
  5af:   48 89 11                mov    %rdx,(%rcx)
  5b2:   48 c7 40 08 00 00 00    movq   $0x0,0x8(%rax)
  5b9:   00
  5ba:   48 c7 00 00 00 00 00    movq   $0x0,(%rax)
  5c1:   90                      nop
  5c2:   c3                      retq

I Will post tomorrow some profiling results.
Eric
