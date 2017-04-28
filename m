From: Alexei Starovoitov <ast@fb.com>
Subject: Re: prog ID and next steps. Was: [RFC net-next 0/2] Introduce
 bpf_prog ID and iteration
Date: Fri, 28 Apr 2017 12:31:39 -0700
Message-ID: <7f7e86bb-6475-3971-42a6-6f8f6b74979f@fb.com>
References: <20170427062449.80290-1-kafai@fb.com>
 <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
 <40cf6893-4702-4773-1aaa-7dfdc51c6212@fb.com>
 <44cdb2d2-9f5c-5d28-2966-3e43e6d2a2ef@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Thomas Graf <tgraf@suug.ch>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60221 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1423891AbdD1TcL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 15:32:11 -0400
In-Reply-To: <44cdb2d2-9f5c-5d28-2966-3e43e6d2a2ef@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 4:50 AM, Hannes Frederic Sowa wrote:
> Hello Alexei,
>
> On 28.04.2017 03:11, Alexei Starovoitov wrote:
>> On 4/27/17 6:36 AM, Hannes Frederic Sowa wrote:
>>> On 27.04.2017 08:24, Martin KaFai Lau wrote:
>>>> This patchset introduces the bpf_prog ID and a new bpf cmd to
>>>> iterate all bpf_prog in the system.
>>>>
>>>> It is still incomplete.  The idea can be extended to bpf_map.
>>>>
>>>> Martin KaFai Lau (2):
>>>>   bpf: Introduce bpf_prog ID
>>>>   bpf: Test for bpf_prog ID and BPF_PROG_GET_NEXT_ID
>>>
>>> Thanks Martin, I like the approach.
>>>
>>> I think the progid is also much more suitable to be used in kallsyms
>>> because it handles collisions correctly and let's correctly walk the
>>> chain (for example imaging loading two identical programs but install
>>> them at different hooks, kallsysms doesn't allow to find out which
>>> program is installed where).
>>
>> i disagree re: kallsyms. The goal of prog_tag is to let program writers
>> understand which program is running in a stable way.
>
> But exactly it doesn't let program writers do that, it just confuses them:
>
> ---
>
> jit on:
>
> perf record -e bpf_redirect -agR
>
> The unwinder walks the stack, extracts address of upper function and
> sends it to user space (perf) or handles it inside the kernel/kallsyms
> (ftrace).
>
> User takes tag of bpf program and wants to inspect related maps to the
> program. Unfortunately the tag is not unique and thus we need to expand
> the tag back to all possible programs with the same tag and expand that
> to the union of all possible maps that those programs reference again.

'all possible programs with the same tag' == all exactly the same 
programs == the same single program which was either compiled
multiple times or loaded multiple times.

When debugging you want to see which program is running.
You don't care that it was loaded 10 times with different maps.
Same prog_tag == same program code. We don't add maps into tag
of the program, because it will only confuse users and makes such
tag useless, since the user won't be able to correlate such reported tag
with what they have on disk.

The programs gets unloaded too and this 'perf record' and stack
traces come from the past, hence the need for stable prog_tag.
We can take a 'perf record' from yesterday and today find the program
(if we have elf file for it) which was part of that trace.
That's the key value of the prog_tag.
The program ID is only valid at one point in time and adding it
to kallsyms doesn't help much at all.
Say, we added an id to kallsym, now in the stack trace you'll see
bpf_prog_da4fc6a3f41761a2_12
and
bpf_prog_da4fc6a3f41761a2_25

The only thing it tells you that the same program was loaded twice.
The IDs 12 and 25 won't help to debug at all unless you have
full crashdump of the system at the same exact time and can go and
examine the memory.
But if you have the crashdump, you don't need these IDs.
All kernel data structures can be reconstructed without any IDs.

> That is what we present to the application developer. I would seriously
> be very confused.

documentation needs to be improved. That's for sure.

> ---
>
> jit off:
>
> perf probe -a '__bpf_prog_run ctx insn'
> perf probe -a 'bpf_redirect flags ifindex'
> perf record -e bpf_redirect -agR
>
> Situation doesn't change. We do get the insn pointer thus have a unique
> id for the program.

without JIT+kallsyms the situation is indeed not great, since
__bpf_prog_run is the same for all programs and 'perf record' from
yesterday is useless for debugging today.
That's the reason why I very much in favor of enabling
net.core.bpf_jit_kallsyms by default.

> My proposal would be to maybe hash a map id into the program, so instead
> of replacing the user space file descriptor with zero, take a map id
> (like discussed below) or an inode number of the map into the register
> and hash with that, so that those program have unique identifiers.
>
> Otherwise construct kallsym entries with prog id instead of tag.

That doesn't make sense as explained above.

> Also I do think in future the difference between non-jit and jit
> operation in regards to tracing should also be lifted. We could add a
> manual tracing point into the interpreter for reporting the same event
> as if the program was jitted.

When JIT is off, I'd like to be able to have different __bpf_prog_run
appearing in stack traces for different programs, but don't see how 
that's possible yet.

> Debugging should not be that different based on the sysctl flags.

debugging is already different depending which sysctl's are on.
All the sysctl net.* knobs affect debugging.

> Sure, what about tag -> id? Tag is being reported from tracing and thus
> should be one of the starting points to explore which programs are running.

based on prog_tag and list of elf files the user space can tell
precisely which program was or is running.
The elf file may have full debug info as well, so the user will
see source code of the program too.
Which is the ultimate goal of anyone doing debugging.
