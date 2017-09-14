From: Y Song <ys114321@gmail.com>
Subject: Re: Bug with BPF_ALU64 | BPF_END?
Date: Thu, 14 Sep 2017 14:22:55 -0700
Message-ID: <CAH3MdRVNKCM-WLvm_1REOnqwNJ+iPnTiu-f=n7hZifzXPtsZZg@mail.gmail.com>
References: <52c7df55-84d9-f6d2-ed84-51ac90eb6bcc@solarflare.com> <20170914.111424.934672262035736390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Edward Cree <ecree@solarflare.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:32917 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdINVXg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 17:23:36 -0400
Received: by mail-vk0-f66.google.com with SMTP id j189so156824vka.0
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 14:23:36 -0700 (PDT)
In-Reply-To: <20170914.111424.934672262035736390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 14, 2017 at 11:14 AM, David Miller <davem@davemloft.net> wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Thu, 14 Sep 2017 18:53:17 +0100
>
>> Is BPF_END supposed to only be used with BPF_ALU, never with BPF_ALU64?

Yes, only BPF_ALU. The below is LLVM bpf swap insn encoding:

...
// bswap16, bswap32, bswap64
class BSWAP ...
...
  let op = 0xd;     // BPF_END
  let BPFSrc = 1;   // BPF_TO_BE (TODO: use BPF_TO_LE for big-endian target)
  let BPFClass = 4; // BPF_ALU
...

>> In kernel/bpf/core.c:___bpf_prog_run(), there are only jump table targets
>>  for the BPF_ALU case, not for the BPF_ALU64 case (opcodes 0xd7 and 0xdf).
>> But the verifier doesn't enforce this; by crafting a program that uses
>>  these opcodes I can get a WARN when they're run (without JIT; it looks
>>  like the x86 JIT, at least, won't like it either).
>> Proposed patch below the cut; build-tested only.
>
> Good catch.
>
> A really neat test would be a program that uploads random BPF programs
> into the kernel, in a syzkaller'ish way.  It might have triggered this
> (eventually).
>
