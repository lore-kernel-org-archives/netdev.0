From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: prog ID and next steps. Was: [RFC net-next 0/2] Introduce
 bpf_prog ID and iteration
Date: Fri, 28 Apr 2017 13:50:13 +0200
Message-ID: <44cdb2d2-9f5c-5d28-2966-3e43e6d2a2ef@stressinduktion.org>
References: <20170427062449.80290-1-kafai@fb.com>
 <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
 <40cf6893-4702-4773-1aaa-7dfdc51c6212@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, kernel-team@fb.com,
        "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Thomas Graf <tgraf@suug.ch>
To: Alexei Starovoitov <ast@fb.com>, Martin KaFai Lau <kafai@fb.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:46577 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S939622AbdD1LuR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 07:50:17 -0400
In-Reply-To: <40cf6893-4702-4773-1aaa-7dfdc51c6212@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alexei,

On 28.04.2017 03:11, Alexei Starovoitov wrote:
> On 4/27/17 6:36 AM, Hannes Frederic Sowa wrote:
>> On 27.04.2017 08:24, Martin KaFai Lau wrote:
>>> This patchset introduces the bpf_prog ID and a new bpf cmd to
>>> iterate all bpf_prog in the system.
>>>
>>> It is still incomplete.  The idea can be extended to bpf_map.
>>>
>>> Martin KaFai Lau (2):
>>>   bpf: Introduce bpf_prog ID
>>>   bpf: Test for bpf_prog ID and BPF_PROG_GET_NEXT_ID
>>
>> Thanks Martin, I like the approach.
>>
>> I think the progid is also much more suitable to be used in kallsyms
>> because it handles collisions correctly and let's correctly walk the
>> chain (for example imaging loading two identical programs but install
>> them at different hooks, kallsysms doesn't allow to find out which
>> program is installed where).
> 
> i disagree re: kallsyms. The goal of prog_tag is to let program writers
> understand which program is running in a stable way.

But exactly it doesn't let program writers do that, it just confuses them:

---

jit on:

perf record -e bpf_redirect -agR

The unwinder walks the stack, extracts address of upper function and
sends it to user space (perf) or handles it inside the kernel/kallsyms
(ftrace).

User takes tag of bpf program and wants to inspect related maps to the
program. Unfortunately the tag is not unique and thus we need to expand
the tag back to all possible programs with the same tag and expand that
to the union of all possible maps that those programs reference again.

That is what we present to the application developer. I would seriously
be very confused.

If application developer doesn't trust perf and uses instruction pointer
value from the stack directly he can't find out which program there is,
because fdinfo e.g. doesn't show the actual address of where the program
is allocated. I would use /dev/kmem now.

---

jit off:

perf probe -a '__bpf_prog_run ctx insn'
perf probe -a 'bpf_redirect flags ifindex'
perf record -e bpf_redirect -agR

Situation doesn't change. We do get the insn pointer thus have a unique
id for the program. That's it, no further introspection. I can read
/dev/kmem now.

---

Personally I wouldn't rely on such infrastructure.

My proposal would be to maybe hash a map id into the program, so instead
of replacing the user space file descriptor with zero, take a map id
(like discussed below) or an inode number of the map into the register
and hash with that, so that those program have unique identifiers.

Otherwise construct kallsym entries with prog id instead of tag.

I think that the hash should try to reassemble some kind of identity
function and mapping two programs to the same tag, that do something
completely differently is not good (based on we don't include the map).

Also I do think in future the difference between non-jit and jit
operation in regards to tracing should also be lifted. We could add a
manual tracing point into the interpreter for reporting the same event
as if the program was jitted.

Debugging should not be that different based on the sysctl flags.

> id is assigned dynamically and not suitable for that purpose.
> 
>> It would help a lot if you could pass the prog_id back during program
>> creation, otherwise it will be kind of difficult to get a hold on which
>> program is where. ;)
> 
> yes, but not a creation time. bpf_prog_load command will keep returning
> an FD and all operations on programs will be allowed with FD only.

Yes, yes, yes, fd should be primary return value, no questions asked.

If it is not possible to return back additional data via the bpf
syscall, add an operation to get id from fd. This is also fine.

> Think of this 'ID' as program handle or program pointer.
I do. My first idea was to use the inode of the bpffs as prog id and
just allocate it regardless, but it seems to be okay how you do it.
Maybe it even is better because you control the (re)cycling of numbers.

> In other words it's obfuscated kernel 'struct bpf_prog *' given to
> user space, so that user space can later convert this ID into FD.
> The other patch (not shown) will take ID from user space and will
> convert it to FD if prog->aux->user is the same or root.

Sure, what about tag -> id? Tag is being reported from tracing and thus
should be one of the starting points to explore which programs are running.

> We tried really hard to keep everything FD based. Unfortunately
> netlink is not suitable to pass FDs, so to query TC and XDP
> we either have to invent a way to install FD from netlink in recvmsg()
> or pass something that can be converted to FD later.
> That's what program ID is solving.

Hmm, I am not sure why netlink is not suitable to pass up file
descriptors. We certainly pass down file descriptors with netlink. But I
am fine with either bpf syscall or netlink. But also the introduction of
bpf prog id depends a bit on this reasoning.

> This set of patches look trivial with simple use of idr,
> but it took us long time to get there.
> We tried to use 64-bit ID to avoid wrap around issue, but association
> between ID and bpf_prog needs to be kept somewhere. The obvious
> answer is rhashtable, but it cannot be iterated easily.
> Like we'd need to dump the whole thing through bpf syscall which
> is not practical.
> Then we tried to use 32-bit idr's id + 32-bit timestamp/random.
> It works better, but then we hit the issue that bpf_prog_get_next_id
> cannot be iterated in a stable way when programs are being deleted
> while user space iterates over the whole list.
> So at the end we scraped all the fancy things and went with
> simple 32-bit ID allocated in _cyclic_ way via idr.
> The reason for cyclic is to avoid prog delete/create races,
> so ID seen by user space stays stable for 2B ids.
> We were concerned that somebody might try to load/delete
> a program 2B times to cause the counter to wrap around, but
> it turned out not to be an issue. In that sense prog ID is similar
> to PID.

Or to ifindex. I don't have concerns and think this should be okay.

> So more complete picture of what we're trying to do:
> - new bpf_get_fd_from_id syscall cmd will be used to convert
>   prog ID into prog FD
> - tc/xdp/sockets/tracing attachment points will return prog ID
> - existing bpf_map_lookup() cmd from prog_array will be returning
>   prog ID
> - bpf_prog_next_id syscall cmd (this patch) is used to iterate
>   over all prog IDs
> - new bpf_prog_get_info syscall cmd (based on prog FD) will be used
>   to get all or partial info about the program that kernel knows about

Sounds all good to me.

> Example usage:
> - if user space want to see instructions of all loaded programs
>   it can use a loop like:
> while (!bpf_prog_get_next_id(next_id, &next_id)) {
>    int fd = bpf_prog_get_fd_from_id(next_id);
>    struct bpf_prog_info info;
>    bpf_prog_get_info(fd, &info, flags);
>    // look into info.insns[]
>    close(fd);
> }
> 
> - if user space want to see prog_tag of xdp program attached to eth0
>   // netlink sendmsg() into ifindex of eth0 that returns prog ID
>    int fd = bpf_prog_get_fd_from_id(id_from_netlink);
>    struct bpf_prog_info info;
>    bpf_prog_get_info(fd, &info, flags);
>    // look into info.prog_tag
>    close(fd);

No problems with the above examples. We would also like to be able to
close the loop from the tracing side as well as outlined above.

> the 'flags' argument of bpf_prog_get_info() will be used
> to tell kernel which info about the program needs to be dumped.
> Otherwise if kernel always dumps everything about the program,
> it will make the syscall too slow and too cumbersome.
> Possible combinations:
> - prog_type, prog_tag, license, prog ID
> - array of prog instructions
> - array of map IDs
> Here we'll introduce similar IDs for maps and
> bpf_map_get_info() syscall cmd that will return map_type, map_id, sizes.
> If user wants to iterate over all elements of the map, they can
> use map_fd = bpf_map_get_fd_from_id(map_id); command
> and later use existing bpf_map_get_next_key+bpf_map_lookup_elem.
> 
> We believe this way the user space will be able to see _everything_
> about bpf programs and maps and can pick and choose whether
> it wants to see only programs or only maps or partial info
> about progs (without instructions) and so on.
> 
> Once we have CTF (debug info) available for maps and progs,
> we will extend bpf_prog_get_info() and bpf_map_get_info()
> commands to optionally return that as well.
> 

I think this is all non controversial!

Thanks,
Hannes
