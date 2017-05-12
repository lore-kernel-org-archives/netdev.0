From: Alexei Starovoitov <ast@fb.com>
Subject: Re: BPF relocations
Date: Thu, 11 May 2017 19:17:21 -0700
Message-ID: <7c4afd3f-7ff5-292c-57ad-c4aa2058a8eb@fb.com>
References: <20170511.153118.2082025756694634804.davem@davemloft.net>
 <b39b79d6-4fe2-f887-dc7e-03b62d6eb3e4@fb.com>
 <20170511.211920.2220259143750653022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37423 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753128AbdELCRp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 22:17:45 -0400
In-Reply-To: <20170511.211920.2220259143750653022.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/17 6:19 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Thu, 11 May 2017 16:10:35 -0700
>
>> I don't see what we would use pc-relative relo for.
>
> We must have them at least for banches.
>
> Internally, we have to emit some kind of relocation as GAS makes it's
> first pass over the instructions.
>
> Afterwards, it walks the relocations and resolves all that can be done
> at assembly time, and preserves as relocations in the object file for
> those which it cannot.

got it. yes.
llvm has this thing as well. It calls it FK_PCRel_2
(FK stands for Fixup Kind) which is 16-bit pc relative relo
into 'off' bits of insn.
Fortunately for LLVM this fixup is never converted to actual relo
and it is applied before final .o is emitted.

So, indeed, defining 16-bit pc-relative relo for branches is
definitely useful.
I can imagine someone combining two .o files with 'goto's
crossing two functions or something.
Let's pick a code for it.

> Thinking further down the line many other kinds of PC relative
> relocations are possible, even if you don't allow calls.  For example:
>
> 	ldimm64	R1, 24 + (. - external_label)
>
> This would be a 64-bit PC relative reloc, with the value 24 in the
> addend.

yes. that would be useful as well.
I don't mind defining it for our semi-official bpf relo spec :)

> And eventually we want full linking.
>
> The example above may seem silly, but every other full CPU ELF
> specification handles these things completely and we should seek to be
> complete as well.

I agree that the further we go the more complete it will become.
My concern that if we define too many things because other archs
have them we may end up not using them when time comes, since we
didn't think of some minor detail.
So today I would only add 16-bit pc-relative and 64-bit pc-relative.
The former is clearly useful for branches and the latter for calls
and jmp tables.
Right now we don't have simple 'switch()'. llvm has to convert it
into a sequence of branches. It's ok-ish. Ideally we need jmp-table
like normal cpus do and ldimm64 + relo should work for such purpose.
