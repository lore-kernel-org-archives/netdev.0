From: Y Song <ys114321@gmail.com>
Subject: Re: running an eBPF program
Date: Sat, 27 May 2017 13:52:27 -0700
Message-ID: <CAH3MdRWg57Aw666ahVGb04UcSTqxrz1Wd33JDLyCqY4fh=xstA@mail.gmail.com>
References: <CAErYV9EjKGh9ta8TZ9PRmaATH5VcXQH4cd=WuL5NfMOpcuoLfw@mail.gmail.com>
 <CAH3MdRVMixv8s10gKF1jQjtSY7MHeB-Rs16hX6HwAgUOQ0g=EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Adel Fuchs <adelfuchs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:35337 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750746AbdE0UxI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 16:53:08 -0400
Received: by mail-ua0-f182.google.com with SMTP id y4so20500141uay.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 13:53:08 -0700 (PDT)
In-Reply-To: <CAH3MdRVMixv8s10gKF1jQjtSY7MHeB-Rs16hX6HwAgUOQ0g=EA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 27, 2017 at 1:23 PM, Y Song <ys114321@gmail.com> wrote:
>
> From verifier error message:
> ======
> 0: (bf) r6 = r1
>
> 1: (18) r9 = 0xffe0000e
>
> 3: (69) r0 = *(u16 *)(r6 +16)
>
> invalid bpf_context access off=16 size=2
> ======
>
> The offset 16 of struct __sk_buff is hash.
> What instruction #3 tries to do is to access 2 bytes of the hash value
> instead of full 4 bytes.
> This is explicitly not allowed in verifier due to endianness issue.


I can reproduce the issue now. My previous statement saying to access
"hash" field is not correct. It is accessing the protocol field.

static __inline__ bool flow_dissector(struct __sk_buff *skb,
                                      struct flow_keys *flow)
{
        int poff, nh_off = BPF_LL_OFF + ETH_HLEN;
        __be16 proto = skb->protocol;
        __u8 ip_proto;

The plan so far is to see whether we can fix the issue in LLVM side.

Yonghong

>
>
> Look at iproute2 example code, it looks like the following may be responsible:
>
> bpf_tailcall.c:#define MAX_JMP_SIZE    2
> bpf_tailcall.c:        tail_call(skb, &jmp_tc, skb->hash & (MAX_JMP_SIZE - 1));
>
> I am thinking of implementing something in LLVM to prevent
> optimization from LD4=>LD2/DL1 for context access like this.
>
>
> On Fri, May 26, 2017 at 4:00 AM, Adel Fuchs <adelfuchs@gmail.com> wrote:
> > Hi
> >
> > I'm trying to run this eBPF program:
> >
> > https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/tree/examples/bpf
> >
> >
> > and I get this error:
> >
> >
> > :~/iproute2/examples/bpf$sudo tc filter add dev enx00e11100329b parent
> > 1: bpf obj bpf.o exp /tmp/bpf-uds flowid 1:1 action bpf obj bpf.o sec
> > action-mark            action bpf obj bpf.o sec action-rand ok
> >
> > [sudo] password for adel:
> >
> >
> >
> > Prog section 'classifier' rejected: Permission denied (13)!
> >
> > - Type:         3
> >
> > - Instructions: 218 (0 over limit)
> >
> > - License:      GPL
> >
> >
> >
> > Verifier analysis:
> >
> >
> >
> > 0: (bf) r6 = r1
> >
> > 1: (18) r9 = 0xffe0000e
> >
> > 3: (69) r0 = *(u16 *)(r6 +16)
> >
> > invalid bpf_context access off=16 size=2
> >
> >
> >
> > Error fetching program/map!
> >
> > Failed to retrieve (e)BPF data!
> >
> >
> > Any suggestions?
> >
> > Thanks,
> >
> > Adel
