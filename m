From: Y Song <ys114321@gmail.com>
Subject: Re: running an eBPF program
Date: Sat, 27 May 2017 13:23:35 -0700
Message-ID: <CAH3MdRVMixv8s10gKF1jQjtSY7MHeB-Rs16hX6HwAgUOQ0g=EA@mail.gmail.com>
References: <CAErYV9EjKGh9ta8TZ9PRmaATH5VcXQH4cd=WuL5NfMOpcuoLfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Adel Fuchs <adelfuchs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:36217 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdE0UYQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 16:24:16 -0400
Received: by mail-vk0-f54.google.com with SMTP id p85so18006478vkd.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 13:24:16 -0700 (PDT)
In-Reply-To: <CAErYV9EjKGh9ta8TZ9PRmaATH5VcXQH4cd=WuL5NfMOpcuoLfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From verifier error message:
======
0: (bf) r6 = r1

1: (18) r9 = 0xffe0000e

3: (69) r0 = *(u16 *)(r6 +16)

invalid bpf_context access off=16 size=2
======

The offset 16 of struct __sk_buff is hash.
What instruction #3 tries to do is to access 2 bytes of the hash value
instead of full 4 bytes.
This is explicitly not allowed in verifier due to endianness issue.

Look at iproute2 example code, it looks like the following may be responsible:

bpf_tailcall.c:#define MAX_JMP_SIZE    2
bpf_tailcall.c:        tail_call(skb, &jmp_tc, skb->hash & (MAX_JMP_SIZE - 1));

I am thinking of implementing something in LLVM to prevent
optimization from LD4=>LD2/DL1 for context access like this.


On Fri, May 26, 2017 at 4:00 AM, Adel Fuchs <adelfuchs@gmail.com> wrote:
> Hi
>
> I'm trying to run this eBPF program:
>
> https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/tree/examples/bpf
>
>
> and I get this error:
>
>
> :~/iproute2/examples/bpf$sudo tc filter add dev enx00e11100329b parent
> 1: bpf obj bpf.o exp /tmp/bpf-uds flowid 1:1 action bpf obj bpf.o sec
> action-mark            action bpf obj bpf.o sec action-rand ok
>
> [sudo] password for adel:
>
>
>
> Prog section 'classifier' rejected: Permission denied (13)!
>
> - Type:         3
>
> - Instructions: 218 (0 over limit)
>
> - License:      GPL
>
>
>
> Verifier analysis:
>
>
>
> 0: (bf) r6 = r1
>
> 1: (18) r9 = 0xffe0000e
>
> 3: (69) r0 = *(u16 *)(r6 +16)
>
> invalid bpf_context access off=16 size=2
>
>
>
> Error fetching program/map!
>
> Failed to retrieve (e)BPF data!
>
>
> Any suggestions?
>
> Thanks,
>
> Adel
