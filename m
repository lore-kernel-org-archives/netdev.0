From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] net_sched: act: remove spinlock in fast
 path
Date: Fri, 03 Jul 2015 14:08:05 +0200
Message-ID: <1435925285.11970.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com>
	 <1435842455-30501-7-git-send-email-edumazet@google.com>
	 <5595684D.90500@gmail.com>
	 <1435870750.11970.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55967137.7080806@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37986 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbbGCMIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 08:08:10 -0400
Received: by wibdq8 with SMTP id dq8so98601055wib.1
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 05:08:09 -0700 (PDT)
In-Reply-To: <55967137.7080806@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-03 at 07:25 -0400, Jamal Hadi Salim wrote:
> On 07/02/15 16:59, Eric Dumazet wrote:
> > On Thu, 2015-07-02 at 09:35 -0700, John Fastabend wrote:
>=20
> >
> > Point is to not dirty cache line for every packet ?
> >
> > Doing the test means we attempt dirtying only ~HZ times per second,
> > which really matters to handle millions of packets per second.
> >
> > My tests show a good enough performance, not sure we want a percpu =
thing
> > for this lastuse field.
> >
>=20
> Does it harm to always set gact->tcf_tm.lastuse ?


Yes it harms, because of one false sharing on a cache line, for every
packet...

Samples: 20K of event 'cycles:pp', Event count (approx.): 15451660731  =
                                                                       =
             =20
 32.50%  ksoftirqd/1  [kernel.kallsyms]  [k] tcf_gact
 19.43%  ksoftirqd/1  [kernel.kallsyms]  [k] put_compound_page
  4.34%  ksoftirqd/1  [kernel.kallsyms]  [k] __skb_get_hash
  3.88%  ksoftirqd/1  [kernel.kallsyms]  [k] memcpy_erms
  2.95%  ksoftirqd/1  [kernel.kallsyms]  [k] get_rps_cpu
  2.81%  ksoftirqd/1  [kernel.kallsyms]  [k] __build_skb


Note that gact->tcf_action & gact->tcf_tm.lastuse share same cache line


      =E2=94=82    Disassembly of section load0:
       =E2=94=82
       =E2=94=82    ffffffffa016f040 <load0>:
  0.11 =E2=94=82      nop
  0.06 =E2=94=82      push   %rbp
  0.14 =E2=94=82      mov    %rsp,%rbp
  0.06 =E2=94=82      push   %r12
       =E2=94=82      mov    %rdi,%r12
       =E2=94=82      push   %rbx
  0.16 =E2=94=82      mov    (%rsi),%rbx
 98.46 =E2=94=82      mov    0x20(%rbx),%eax         action =3D READ_ON=
CE(gact->tcf_action);=20

_huge_ stall here because another cpu dirtied gact->tcf_tm.lastuse

  0.33 =E2=94=82      movzwl 0x98(%rbx),%edx
       =E2=94=82      test   %edx,%edx
       =E2=94=82      jne    87
       =E2=94=8220:   mov    0x88(%rbx),%rdx
  0.11 =E2=94=82      add    %gs:0x5fe9b0b9(%rip),%rdx
       =E2=94=82      mov    0x28(%r12),%ecx
  0.02 =E2=94=82      mov    0x8(%rdx),%edi
       =E2=94=82      mov    $0x1,%esi
  0.11 =E2=94=82      add    %rcx,(%rdx)
       =E2=94=82      mov    0xc8(%r12),%ecx
       =E2=94=82      add    0xd0(%r12),%rcx
  0.08 =E2=94=82      cmpw   $0x0,0x2(%rcx)
       =E2=94=82      je     5a
       =E2=94=82      movzwl 0x4(%rcx),%esi
       =E2=94=825a:   add    %edi,%esi
       =E2=94=82      cmp    $0x2,%eax
  0.14 =E2=94=82      mov    %esi,0x8(%rdx)
       =E2=94=82      jne    77
       =E2=94=82      mov    0x90(%rbx),%rdx
       =E2=94=82      add    %gs:0x5fe9b075(%rip),%rdx
  0.11 =E2=94=82      addl   $0x1,0x8(%rdx)
       =E2=94=8277:   mov    -0x1e5640be(%rip),%rdx
       =E2=94=82      mov    %rdx,0x30(%rbx)                 gact->tcf_=
tm.lastuse =3D jiffies;
  0.08 =E2=94=82      pop    %rbx
  0.02 =E2=94=82      pop    %r12
       =E2=94=82      pop    %rbp
       =E2=94=82      retq
       =E2=94=8287:   mov    %edx,%edx
       =E2=94=82      mov    %rbx,%rdi
       =E2=94=82      callq  *-0x5fe90b70(,%rdx,8)
       =E2=94=82      jmp    20
