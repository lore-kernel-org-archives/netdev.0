From: Alexei Starovoitov <ast@fb.com>
Subject: prog ID and next steps. Was: [RFC net-next 0/2] Introduce bpf_prog ID
 and iteration
Date: Thu, 27 Apr 2017 18:11:02 -0700
Message-ID: <40cf6893-4702-4773-1aaa-7dfdc51c6212@fb.com>
References: <20170427062449.80290-1-kafai@fb.com>
 <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41835 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1161004AbdD1BLb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 21:11:31 -0400
In-Reply-To: <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/17 6:36 AM, Hannes Frederic Sowa wrote:
> On 27.04.2017 08:24, Martin KaFai Lau wrote:
>> This patchset introduces the bpf_prog ID and a new bpf cmd to
>> iterate all bpf_prog in the system.
>>
>> It is still incomplete.  The idea can be extended to bpf_map.
>>
>> Martin KaFai Lau (2):
>>   bpf: Introduce bpf_prog ID
>>   bpf: Test for bpf_prog ID and BPF_PROG_GET_NEXT_ID
>
> Thanks Martin, I like the approach.
>
> I think the progid is also much more suitable to be used in kallsyms
> because it handles collisions correctly and let's correctly walk the
> chain (for example imaging loading two identical programs but install
> them at different hooks, kallsysms doesn't allow to find out which
> program is installed where).

i disagree re: kallsyms. The goal of prog_tag is to let program writers
understand which program is running in a stable way.
id is assigned dynamically and not suitable for that purpose.

> It would help a lot if you could pass the prog_id back during program
> creation, otherwise it will be kind of difficult to get a hold on which
> program is where. ;)

yes, but not a creation time. bpf_prog_load command will keep returning
an FD and all operations on programs will be allowed with FD only.

Think of this 'ID' as program handle or program pointer.
In other words it's obfuscated kernel 'struct bpf_prog *' given to
user space, so that user space can later convert this ID into FD.
The other patch (not shown) will take ID from user space and will
convert it to FD if prog->aux->user is the same or root.

We tried really hard to keep everything FD based. Unfortunately
netlink is not suitable to pass FDs, so to query TC and XDP
we either have to invent a way to install FD from netlink in recvmsg()
or pass something that can be converted to FD later.
That's what program ID is solving.

This set of patches look trivial with simple use of idr,
but it took us long time to get there.
We tried to use 64-bit ID to avoid wrap around issue, but association
between ID and bpf_prog needs to be kept somewhere. The obvious
answer is rhashtable, but it cannot be iterated easily.
Like we'd need to dump the whole thing through bpf syscall which
is not practical.
Then we tried to use 32-bit idr's id + 32-bit timestamp/random.
It works better, but then we hit the issue that bpf_prog_get_next_id
cannot be iterated in a stable way when programs are being deleted
while user space iterates over the whole list.
So at the end we scraped all the fancy things and went with
simple 32-bit ID allocated in _cyclic_ way via idr.
The reason for cyclic is to avoid prog delete/create races,
so ID seen by user space stays stable for 2B ids.
We were concerned that somebody might try to load/delete
a program 2B times to cause the counter to wrap around, but
it turned out not to be an issue. In that sense prog ID is similar
to PID.

So more complete picture of what we're trying to do:
- new bpf_get_fd_from_id syscall cmd will be used to convert
   prog ID into prog FD
- tc/xdp/sockets/tracing attachment points will return prog ID
- existing bpf_map_lookup() cmd from prog_array will be returning
   prog ID
- bpf_prog_next_id syscall cmd (this patch) is used to iterate
   over all prog IDs
- new bpf_prog_get_info syscall cmd (based on prog FD) will be used
   to get all or partial info about the program that kernel knows about

Example usage:
- if user space want to see instructions of all loaded programs
   it can use a loop like:
while (!bpf_prog_get_next_id(next_id, &next_id)) {
    int fd = bpf_prog_get_fd_from_id(next_id);
    struct bpf_prog_info info;
    bpf_prog_get_info(fd, &info, flags);
    // look into info.insns[]
    close(fd);
}

- if user space want to see prog_tag of xdp program attached to eth0
   // netlink sendmsg() into ifindex of eth0 that returns prog ID
    int fd = bpf_prog_get_fd_from_id(id_from_netlink);
    struct bpf_prog_info info;
    bpf_prog_get_info(fd, &info, flags);
    // look into info.prog_tag
    close(fd);

the 'flags' argument of bpf_prog_get_info() will be used
to tell kernel which info about the program needs to be dumped.
Otherwise if kernel always dumps everything about the program,
it will make the syscall too slow and too cumbersome.
Possible combinations:
- prog_type, prog_tag, license, prog ID
- array of prog instructions
- array of map IDs
Here we'll introduce similar IDs for maps and
bpf_map_get_info() syscall cmd that will return map_type, map_id, sizes.
If user wants to iterate over all elements of the map, they can
use map_fd = bpf_map_get_fd_from_id(map_id); command
and later use existing bpf_map_get_next_key+bpf_map_lookup_elem.

We believe this way the user space will be able to see _everything_
about bpf programs and maps and can pick and choose whether
it wants to see only programs or only maps or partial info
about progs (without instructions) and so on.

Once we have CTF (debug info) available for maps and progs,
we will extend bpf_prog_get_info() and bpf_map_get_info()
commands to optionally return that as well.
