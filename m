From: Will Deacon <will.deacon@arm.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Fri, 20 Oct 2017 10:18:23 +0100
Message-ID: <20171020091823.GA18282@arm.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <CANn89iJgoiY_ky4F_1iE_o6moZXp5e6OcNZZe=B8F-OhWJx8nQ@mail.gmail.com>
 <FF5A6DF1-0E5F-4C7E-A31B-06ED33366039@gmail.com>
 <CANn89iKj45+zqMt7XqPkCG+8PQwhzjHUBZ0vu-REvZWs1HuqOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Wei Wei <dotweiba@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        David Miller <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANn89iKj45+zqMt7XqPkCG+8PQwhzjHUBZ0vu-REvZWs1HuqOw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 19, 2017 at 10:34:54PM -0700, Eric Dumazet wrote:
> On Thu, Oct 19, 2017 at 8:13 PM, Wei Wei <dotweiba@gmail.com> wrote:
> > Code: f9406680 8b010000 91009000 f9800011 (885f7c01)
> > All code
> > ========
> >    0:   80 66 40 f9             andb   $0xf9,0x40(%rsi)
> >    4:   00 00                   add    %al,(%rax)
> >    6:   01 8b 00 90 00 91       add    %ecx,-0x6eff7000(%rbx)
> >    c:   11 00                   adc    %eax,(%rax)
> >    e:   80 f9 01                cmp    $0x1,%cl
> >   11:   7c 5f                   jl     0x72
> >   13:*  88 00                   mov    %al,(%rax)               <-- trapping instruction
> >   15:   00 00                   add    %al,(%rax)
> >         ...
> >
> > Code starting with the faulting instruction
> > ===========================================
> >    0:   01 7c 5f 88             add    %edi,-0x78(%rdi,%rbx,2)
> >    4:   00 00                   add    %al,(%rax)
> >         ...
> > —[ end trace 261e7ac1458ccc0a ]---
> >
> 
> I thought it was happening on arm64 ?
> 
> This is x86_64 disassembly :/

I guess they forgot the ARCH/CROSS_COMPILE env vars for decodecode. here
you go:

Code: f9406680 8b010000 91009000 f9800011 (885f7c01)
All code
========
   0:	f9406680 	ldr	x0, [x20,#200]
   4:	8b010000 	add	x0, x0, x1
   8:	91009000 	add	x0, x0, #0x24
   c:	f9800011 	prfm	pstl1strm, [x0]
  10:*	885f7c01 	ldxr	w1, [x0]		<-- trapping instruction

Code starting with the faulting instruction
===========================================
   0:	885f7c01 	ldxr	w1, [x0]

so it's faulting on the load part of an atomic rmw.

Will
