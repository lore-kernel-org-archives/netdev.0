From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Wed, 8 Feb 2017 12:40:47 -0700
Message-ID: <c19a41f5-7737-d971-67e0-919276b47b95@cumulusnetworks.com>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
 <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com>
 <5894F19A.60305@iogearbox.net>
 <34456681-46d1-0761-3b61-4e308f363126@cumulusnetworks.com>
 <ddfeb9be-31a7-a2ba-abe2-55a1f90cc548@6wind.com>
 <5898847B.2060400@iogearbox.net>
 <20170206192114.GA54756@ast-mbp.thefacebook.com>
 <83e2bd44-fbe0-38a5-f080-3042572d8a64@cumulusnetworks.com>
 <589AF867.3020009@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Quentin Monnet <quentin.monnet@6wind.com>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:38163 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdBHTlZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:41:25 -0500
Received: by mail-it0-f51.google.com with SMTP id c7so110918384itd.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 11:40:49 -0800 (PST)
In-Reply-To: <589AF867.3020009@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/8/17 3:52 AM, Daniel Borkmann wrote:
> I agree that dumping might be useful particularly with further
> tooling on top (f.e. decompiler), but in any case the interface for
> that needs to be designed carefully and generic, so it covers various
> use cases (meaning also CRIU). Above, I was rather referring to what
> an admin can make sense of when you have worst-case 4k insns with
> complex control flow and you just dump the asm (or in case of [1] it
> was pure opcodes) in, say, ss or tc; goal was on debugability and
> the people debugging are not always kernel devs. Actually currently,
> for cBPF dumps it looks like this in ss. Can you tell me what these
> 11 insns do? Likely you can, but can a normal admin?
> 
> # ss -0 -b
> Netid  Recv-Q Send-Q                                       Local
> Address:Port                                                        Peer
> Address:Port
> p_raw  0      0                                                       
> *:em1                                                                *
>     bpf filter (11):  0x28 0 0 12, 0x15 0 8 2048, 0x30 0 0 23, 0x15 0 6
> 17, 0x28 0 0 20, 0x45 4 0 8191, 0xb1 0 0 14, 0x48 0 0 16, 0x15 0 1 68,
> 0x06 0 0 4294967295, 0x06 0 0 0,

Yes, that byte stream needs some pretty printing. It is not as easily
decipherable, but this form is (quick, ballpark conversion by hand to
get the intent):


0x28 0 0 12         BPF_LD  | BPF_ABS | BPF_H     0, 0, 12
-- load 2 bytes at offset 12 of ethernet header (h_proto)

0x15 0 8 2048               | BPF_JMP |           0, 8, 0x0800
-- if protocol is not ipv4 jump forward 8 (exit prog 0)

0x30 0 0 23         BPF_LD  | BPF_ABS | BPF_B     0, 0, 23
-- load byte 9 of ipv4 hdr (ipv4 protocol)

0x15 0 6 17                 | BPF_JMP | BPF_B     0, 6, 17
-- if protocol is not 17 (udp) jump forward 6 (exit program)

0x28 0 0 20         BPF_LD  | BPF_ABS | BPF_H     0, 0, 20
-- load 2-bytes at offset 6 of ipv4 hdr (frag offset)

0x45 4 0 8191       BPF_LDX | BPF_IND | BPF_JMP   4, 0, 0x1fff
-- frag_offset & 0x1fff. if not 0 jump forward 4

0xb1 0 0 14         BPF_LDX | BPF_MSH | BPF_B     0, 0, 14
-- load ipv4 header length

0x48 0 0 16                 | BPF_IND | BPF_H     0, 0, 16
-- load 2-bytes at offset 2 of ipv4 hdr (tot_len)

0x15 0 1 68         BPF_LDX | BPF_ALU | BPF_B     0, 1, 68
-- jump to exit 0 if total ipv4 payload length is not 68

0x06 0 0 4294967295 BPF_RET                       0, 0, 0xffffffff
-- exit -1 / 0xffffffff

0x06 0 0 0          BPF_RET                       0, 0, 0
-- exit 0


So basically, match ipv4/udp packets that are not fragments with a total
ip length of 68. Or roughly this tcpdump filter:

'ether[12:2] == 0x800 && ip[9] == 17 && (ip[6:2] & 0x1fff == 0) &&
ip[2:2] == 68'



> 
> Certainly that can and should be further improved (f.e. see bpf_disasm()
> in tools/net/bpf_dbg.c) to make it actually more readable w/o any
> external tooling that does not ship with iproute2. That could help
> already, but is still hard. Oddly enough, for cBPF everyone was fine
> so far with plain opcode dump it seems?! For eBPF, it could be same
> kind of disasm that people are used from verifier with further debug
> help when it comes to context access and helpers. So I'm not against
> this, but if it's just plain opcodes smashed to the user w/o further
> tooling/infra on top aiding the reverse engineering process, it's
> pretty much obfuscated and unusable. Thus, both needs to be provided
> here. Admittedly, I don't know how your iproute2 plans looked like.

It's not rocket science. We should be able to write tools that do the
same for bpf as objdump does for assembly. It is a matter of someone
having the need and taking the initiative. BTW, the bpf option was added
to ss by Nicolas, so a history of 6wind saying 'give me the bpf'.


> It's not a user space problem. When you want to CRIU your program,
> then you also need the correlation to maps that are used in the program.
> So the dump needs to export both, the map meta data and references to
> it in the insns stream where src_reg is BPF_PSEUDO_MAP_FD. With map meta
> data, I mean the attrs used to originally create the map via bpf(2), so
> that you can later restore the same thing (taking the actual map data
> aside for now as also not part of that specific api). Since a bpf prog
> has all the maps referenced in its aux data, it should be doable.
> Perhaps in case the map was pinned, that meta data should also contain
> dev/indoe of the pinned map. There's still the issue of generating a
> snapshot of map data itself, and to extract/dump prog insns from a tail
> call map, though.

I have not used CRIU and have no idea what it needs here. At a high
level it would seem to be a completely different use case -- perhaps
wanting all of the loaded programs and their attach points.  What I am
referring to and what 6wind has expressed an interest in is pulling
programs attached to specific objects, so the overlap with CRIU would be
just the intent to retrieve bpf programs.


>>>> haven't looked into whether it's feasible, but we should definitely
>>>> evaluate possibilities to transform the post-verifier insn sequence
>>>> back into a pre-verifier one for dumping, so we don't need to pay the
>>>> huge additional cost (also a major fraction of the insns might be
>>>> just duplicated here as they weren't rewritten). Perhaps it could
>>>> be done with the help of small annotations, or some sort of diff
>>>> that we only need to store. Not saying it's trivial, but we should
>>>> definitely try hard first and design it carefully if we want to
>>>> support such API.
>>
>> I looked at a reverse_convert_ctx_access at the end of last week. I only
>> have code to reverse sock_filter_convert_ctx_access, but scanning the
>> other convert functions nothing jumped out suggesting it is not doable.
> 
> Ok.
> 
>> Saving the original bpf code is the simplest solution, hence I decided
>> to use it for this discussion.
> 
> Simplest but with downside of huge worst-case cost, see my earlier
> comparison to bloating net devices, where the progs are eventually
> attached to, at least in tc case. So lets find ways to avoid this big
> overhead when designing this API.

I saw the comparison and I agree on avoiding the memory waste.

So next steps ?

1. Looking at reverse functions for the convert accesses done by the
verifier. Programs returned to userspace would be reversed

2. API for retrieving programs attached to objects. We can discuss this
further at netdev if you are going to be there, but for starters:
   - for existing rtnetlink dumps why can't the bpf be attached as a
netlink attribute as 6wind proposed? It is an attribute of that object.

   - Alternatively, the attach is always done by passing the FD as an
attribute, so the netlink dump could attach an fd to the running
program, return the FD as an attribute and the bpf program is retrieved
from the fd. This is a major departure from how dumps work with
processing attributes and needing to attach open files to a process will
be problematic. Integrating the bpf into the dump is a natural fit.

   - for cgroups the attach/detach go through the bpf syscall. There is
no rtnetlink here and Alexei resisted any cgroup based files for
accessing the filters. This suggests retrieving cgroup programs has to
go through bpf syscall as I proposed.

3. tools to pretty print the bpf
