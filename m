From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Thu, 1 Jun 2017 14:48:00 -0700
Message-ID: <affe7228-edf1-5307-2c0c-3ddb0cf247ae@fb.com>
References: <cover.1496256722.git.kafai@fb.com>
 <20170531192256.0e0d0ce1@cakuba.lan>
 <3f269312-efd4-86fc-e8e2-814af5898648@gmail.com>
 <6ab73989-6246-ba15-7178-7863a110165c@fb.com>
 <18d3c571-7434-eaea-43dc-d237712309d1@gmail.com>
 <cae83d5f-85ea-4c16-5f6b-2b71f0768b05@fb.com>
 <5e8b1713-0220-5c53-210d-8040efd36cfb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
        <kernel-team@fb.com>
To: David Ahern <dsahern@gmail.com>, Jakub Kicinski <kubakici@wp.pl>,
        Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58536 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751050AbdFAVsX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 17:48:23 -0400
In-Reply-To: <5e8b1713-0220-5c53-210d-8040efd36cfb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/17 11:52 AM, David Ahern wrote:
> On 6/1/17 12:27 PM, Alexei Starovoitov wrote:
>> 'I want to retrieve original instructions' is not a problem. It's a
>> push for 'solution'. Explaining 'why' you want to see original
>> instructions would describe the actual problem.
>
> I have explained this.
>
> You are creating this hyper-complex almost completely invisible
> infrastructure. You are enabling binary blobs that can bypass the
> network stack and modify packets with almost no introspection on what is
> happening. BPF code can from a variety of sources -- OS vendors,
> upstream repos, 3rd party vendors (eg., H/W vendors), and "in-house"
> development. Each will swear to the end that any observed problem is not
> with their code. In my experience, it falls on to the OS and kernel
> experts to figure out why Linux is breaking something. To do that we
> need tools to look at what code is running where and something that can
> be used in production environments not requiring a disruption to the
> service that the box is providing.

You saw patch 7/8, right?
since I'm not following what exactly you're concerned about.
This patch set provided a way to retrieve post-verifier, post-blinding
instruction stream that gives users a way to know exactly what is 
running. Original instruction stream is not the one that is executed.
It's merely an interface between kernel and user space.
Before that stage the clang/llvm did many code transformations and
optimizations on original source code and after that verifier,
context rewriter, inliner, constant blinding did transformations on
these insns as well.

If there is a bug somewhere in all these transformations it can be
anywhere in clang, llvm optimizer, llvm codegen, elf or bcc loader
and in kernel side transformations. Yes. There can be bugs, but we
cannot keep all these stages in the kernel. I don't mind dumping
insn stream for debugging while doing these stages (just like llvm
has -print-before-all flag), but keeping all the intermediate stages
don't make sense to me. In that sense 'original instruction stream'
to me is one of the intermediate stages where source code in C
crossed user->kernel boundary.
I'd rather store more information about original C code than
this user->kernel instruction stream. That's where CTF is heading.
To provide info about types, names, etc. For both progs and maps.

I don't mind storing even that 'original instruction stream' _if_
there is a solid reason. I just didn't hear one so far.
I can imagine somebody saying that there is a bug in context rewriter
and xlated_prog_insns are accessing wrong field. That's bad, but how
keeping original_prog_insns will help such case?
And how such bug is different from llvm generating wrong code ?
If there is a bug anywhere in that transformation pipeline I'd want
to give original source code and final outcome to support people.
In practice everything is more complex, since maps are dynamic,
tail_calls are dynamic, the code flow changes. Debugging is not easy
and this patch set is the first step toward better debuggability.
I'm all for it, but statements like "without original insns
it's not debuggable" are concerning, since we either don't
explain the APIs well enough or understanding of the use case
is missing on our side.
