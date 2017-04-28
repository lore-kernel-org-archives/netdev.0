From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: prog ID and next steps. Was: [RFC net-next 0/2] Introduce
 bpf_prog ID and iteration
Date: Fri, 28 Apr 2017 20:51:28 +0200
Message-ID: <e4931eaa-c126-bd7f-4865-84a251624583@stressinduktion.org>
References: <20170427062449.80290-1-kafai@fb.com>
 <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
 <40cf6893-4702-4773-1aaa-7dfdc51c6212@fb.com>
 <44cdb2d2-9f5c-5d28-2966-3e43e6d2a2ef@stressinduktion.org>
 <590388C2.7080000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Thomas Graf <tgraf@suug.ch>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:49867 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S967236AbdD1Svd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 14:51:33 -0400
In-Reply-To: <590388C2.7080000@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 28.04.2017 20:24, Daniel Borkmann wrote:
> On 04/28/2017 01:50 PM, Hannes Frederic Sowa wrote:
>> On 28.04.2017 03:11, Alexei Starovoitov wrote:
> [...]
>>> i disagree re: kallsyms. The goal of prog_tag is to let program writers
>>> understand which program is running in a stable way.
>>
>> But exactly it doesn't let program writers do that, it just confuses
>> them:
>>
>> ---
>>
>> jit on:
>>
>> perf record -e bpf_redirect -agR
>>
>> The unwinder walks the stack, extracts address of upper function and
>> sends it to user space (perf) or handles it inside the kernel/kallsyms
>> (ftrace).
>>
>> User takes tag of bpf program and wants to inspect related maps to the
>> program. Unfortunately the tag is not unique and thus we need to expand
>> the tag back to all possible programs with the same tag and expand that
>> to the union of all possible maps that those programs reference again.
>>
>> That is what we present to the application developer. I would seriously
>> be very confused.
>>
>> If application developer doesn't trust perf and uses instruction pointer
>> value from the stack directly he can't find out which program there is,
>> because fdinfo e.g. doesn't show the actual address of where the program
>> is allocated. I would use /dev/kmem now.
> 
> I don't think it would be reasonable to let fdinfo unconditionally
> dump the address of the program including unprivileged progs. We
> probably could add a run-time check into bpf_prog_show_fdinfo() and
> show it dynamically when user has cap_sys_admin.

Okay, it doesn't seem as clean as using an id, but this would work to
correlate traces.

>> ---
>>
>> jit off:
>>
>> perf probe -a '__bpf_prog_run ctx insn'
>> perf probe -a 'bpf_redirect flags ifindex'
>> perf record -e bpf_redirect -agR
>>
>> Situation doesn't change. We do get the insn pointer thus have a unique
>> id for the program. That's it, no further introspection. I can read
>> /dev/kmem now.
>>
>> ---
>>
>> Personally I wouldn't rely on such infrastructure.
>>
>> My proposal would be to maybe hash a map id into the program, so instead
>> of replacing the user space file descriptor with zero, take a map id
>> (like discussed below) or an inode number of the map into the register
>> and hash with that, so that those program have unique identifiers.
> 
> I don't think that proposal would work, f.e. placing dev + inode number
> (inode itself wouldn't be sufficient either; map would also have to be
> pinned as anonymous inode from fd wouldn't work) or map id into insn
> won't give you out of a sudden a unique prog id, since maps can be shared
> among multiple progs, but also the same prog can be attached to, say,
> multiple attachment points.

Yep, about the dev + inode number I know about the problems (and wasn't
sure if bpffs was a singelton fs or not - but it is not as I just
tested). I wanted to outline the idea conceptually. The idea behind
mentioning inode number was to save one additional map_id. I don't know
if it works to register an object with the filesystem but not making it
visible.

Anyway the unique map_id (a la Martin's prog_id) would work as well.

I just wonder why we can't use Martin's prog_id for registering the
programs in kallsyms. Problem seemed to be solved and identity of
programs is preserved. Easy to use it for dumping and walking of maps.

>> Otherwise construct kallsym entries with prog id instead of tag.
>>
>> I think that the hash should try to reassemble some kind of identity
>> function and mapping two programs to the same tag, that do something
>> completely differently is not good (based on we don't include the map).
>>
>> Also I do think in future the difference between non-jit and jit
>> operation in regards to tracing should also be lifted. We could add a
>> manual tracing point into the interpreter for reporting the same event
>> as if the program was jitted.
>>
>> Debugging should not be that different based on the sysctl flags.
> 
> With regards to tracing it's quite useful to see whether a program was
> JITed or not JITed (aka __bpf_prog_run()), so I don't think it makes
> sense to e.g. have everything named __bpf_prog_run(), at least the other
> way around wouldn't work for interpreter as far as I see.

I don't want to have everything named __bpf_prog_run. Tracepoints have
lots of additional attributes/arguments. The tracepoint should pass a
jit=0/1 argument to user space while using the same name for the hook.
(I didn't check if the dynamic hook registration works - I just assume so).

> But lets assume JIT is off for a moment, and you only see __bpf_prog_run().
> Then, in the stack trace you'll also see related functions that call this
> in the first place, for example, mlx4_en_poll_rx_cq() /
> mlx4_en_process_rx_cq()
> in case of XDP, meaning, you get the call path context as well, for which
> you later on (with the proposed infrastructure for getting fds from
> attachment points + dumping them) can return the attached prog fd and
> with that also dump the code or map data.

Doesn't this break if I have 2 mlx4 cards in the system with different
XDP programs attached? I would have to add an additional parameter to
one of the mlx4 functions to extract the net_device pointer to make the
correlation then. Probably it will be much more difficult for other hooks.

Thanks and bye,
Hannes
