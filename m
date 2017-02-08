From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Wed, 08 Feb 2017 11:52:23 +0100
Message-ID: <589AF867.3020009@iogearbox.net>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com> <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com> <5894F19A.60305@iogearbox.net> <34456681-46d1-0761-3b61-4e308f363126@cumulusnetworks.com> <ddfeb9be-31a7-a2ba-abe2-55a1f90cc548@6wind.com> <5898847B.2060400@iogearbox.net> <20170206192114.GA54756@ast-mbp.thefacebook.com> <83e2bd44-fbe0-38a5-f080-3042572d8a64@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Quentin Monnet <quentin.monnet@6wind.com>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35569 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbdBHLap (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 06:30:45 -0500
In-Reply-To: <83e2bd44-fbe0-38a5-f080-3042572d8a64@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2017 06:22 PM, David Ahern wrote:
> On 2/6/17 12:21 PM, Alexei Starovoitov wrote:
>>> Well, worst case cost would be ~8 additional pages per program that
>>> are very rarely used; assume you want to attach a prog per netdevice,
>>> or worse, one for ingress, one for egress ... and yet we already
>>> complain that netdevice itself is way too big and needs a diet ...
>>> That makes it much much worse, though. Using the remainder of the
>>> used page is thus not enough, I'm afraid.
>
> sure, 8 bytes per instruction, 4k instructions so worst case is ~8 pages.
>
>>> But also then, what do you do with 4k insns (or multiple of these in
>>> case of tail calls), is there a decompiler in the works? Understandably
>>> that for vrf it might be trivial to just read disasm, but that's just
>>> one very specific use-case. I can see the point of dumping for the
>
> Dumping bpf bytecode is no different than dumping asm with objdump. To
> those who know/learn how to read it and make sense of the asm, it is an
> important tool. I contend the ability to retrieve and dump BPF code is
> equally important.

I agree that dumping might be useful particularly with further
tooling on top (f.e. decompiler), but in any case the interface for
that needs to be designed carefully and generic, so it covers various
use cases (meaning also CRIU). Above, I was rather referring to what
an admin can make sense of when you have worst-case 4k insns with
complex control flow and you just dump the asm (or in case of [1] it
was pure opcodes) in, say, ss or tc; goal was on debugability and
the people debugging are not always kernel devs. Actually currently,
for cBPF dumps it looks like this in ss. Can you tell me what these
11 insns do? Likely you can, but can a normal admin?

# ss -0 -b
Netid  Recv-Q Send-Q                                       Local Address:Port                                                        Peer Address:Port
p_raw  0      0                                                        *:em1                                                                *
	bpf filter (11):  0x28 0 0 12, 0x15 0 8 2048, 0x30 0 0 23, 0x15 0 6 17, 0x28 0 0 20, 0x45 4 0 8191, 0xb1 0 0 14, 0x48 0 0 16, 0x15 0 1 68, 0x06 0 0 4294967295, 0x06 0 0 0,

Certainly that can and should be further improved (f.e. see bpf_disasm()
in tools/net/bpf_dbg.c) to make it actually more readable w/o any
external tooling that does not ship with iproute2. That could help
already, but is still hard. Oddly enough, for cBPF everyone was fine
so far with plain opcode dump it seems?! For eBPF, it could be same
kind of disasm that people are used from verifier with further debug
help when it comes to context access and helpers. So I'm not against
this, but if it's just plain opcodes smashed to the user w/o further
tooling/infra on top aiding the reverse engineering process, it's
pretty much obfuscated and unusable. Thus, both needs to be provided
here. Admittedly, I don't know how your iproute2 plans looked like.

   [1] https://github.com/6WIND/iproute2/commit/288af23f4dc0adac6c288b3f70ae25997ea5bebf

>>> sake of CRIU use-case given that cBPF is supported there in the past,
>>> and CRIU strives to catch up with all kind of kernel APIs. It's
>>> restricted wrt restore to either the same kernel version or newer
>>> kernels, but that's generic issue for CRIU. So far I'm not aware of
>>> user requests for CRIU support, but it could come in future, though.
>>> Thus, should we have some dump interface it definitely needs to be
>>> i) generic and ii) usable for CRIU, so we don't end up with multiple
>>> dump mechanisms due to one API not being designed good enough to
>>> already cover it.
>>>
>>> Dump result would need to look a bit similar to what we have in ELF
>>> file, that is, you'd need to construct map descriptions and reference
>>> them in the insn sequence similar to relocations in the loader. I
>
> That is a userspace problem, not a kernel problem. This discussion is on
> the API to return BPF code to userspace. How that program is presented
> to the user is up to the tools.

It's not a user space problem. When you want to CRIU your program,
then you also need the correlation to maps that are used in the program.
So the dump needs to export both, the map meta data and references to
it in the insns stream where src_reg is BPF_PSEUDO_MAP_FD. With map meta
data, I mean the attrs used to originally create the map via bpf(2), so
that you can later restore the same thing (taking the actual map data
aside for now as also not part of that specific api). Since a bpf prog
has all the maps referenced in its aux data, it should be doable.
Perhaps in case the map was pinned, that meta data should also contain
dev/indoe of the pinned map. There's still the issue of generating a
snapshot of map data itself, and to extract/dump prog insns from a tail
call map, though.

>>> haven't looked into whether it's feasible, but we should definitely
>>> evaluate possibilities to transform the post-verifier insn sequence
>>> back into a pre-verifier one for dumping, so we don't need to pay the
>>> huge additional cost (also a major fraction of the insns might be
>>> just duplicated here as they weren't rewritten). Perhaps it could
>>> be done with the help of small annotations, or some sort of diff
>>> that we only need to store. Not saying it's trivial, but we should
>>> definitely try hard first and design it carefully if we want to
>>> support such API.
>
> I looked at a reverse_convert_ctx_access at the end of last week. I only
> have code to reverse sock_filter_convert_ctx_access, but scanning the
> other convert functions nothing jumped out suggesting it is not doable.

Ok.

> Saving the original bpf code is the simplest solution, hence I decided
> to use it for this discussion.

Simplest but with downside of huge worst-case cost, see my earlier
comparison to bloating net devices, where the progs are eventually
attached to, at least in tc case. So lets find ways to avoid this big
overhead when designing this API.

>> +1
>>
>> such instruction dump is meaningful only for stateless programs.
>> Out of the top of my head the minium requirement is that they
>> shouldn't use maps and no tailcalls.
>> Also the extra memory is the concern, so I think we need a flag
>> for BPF_PROG_LOAD command like 'store stateless original prog'.
>> Then at load time we can check that maps are not used and so on.
>> The get_attach approach from patch 2 is imo too specific.
>> I think two independent commands would be better.
>> One to return new prog_fd from attachment point and
>> second to do the actual instruction dump based on given prog_fd.
>> Most of the programs today are stateful, so I'm reluctant to add
>> all that complexity for small fraction of programs, so I would
>> like to understand the motivation first.
>> 'ss --bpf' is imo part of the answer. It would need to print
>> attachment info as well, right? and this is for debugging only?
>> In case of 'ip vrf' the programs are trivial, so it's really
>> to debug 'ip vrf' only? and tracepoints somehow not enough?
>> Or there is more to it that I'm missing?
>
> My motivation for pursing this discussion now is to verify cgroups are
> correctly configured on running systems. But, I am also interested in
> the generic OS case and being able to debug and understand networking
> problems because of bugs in BPF code.
>
> For example, consider the case of enterprise distributions used by
> companies as part of their platforms and products with BPF programs
> coming from the OS vendor, the hardware vendors, and custom, locally
> developed programs (remember that BPF store comment I made in October? I
> was only half-joking). As an open OS, you have to anticipate programs
> coming from multiple sources, and those programs can and will have bugs.
> Further, people make mistakes; people forget commands that were run. It
> is fairly easy to see that the wrong bpf program could get attached to
> some object.
>
> In both the VRF/cgroup case and Quentin's case, we are talking about
> retrieving programs attached to specific objects, not just retrieving
> some BPF code that has been loaded into the kernel. bpf programs are
> loaded using the bpf system call, but they are attached to objects using
> different APIs. Given that, retrieval of the programs attached to
> specific objects need to be retrieved with object specific APIs. No?
> e.g., In Quentin's patch, the bpf code is added as part of the tc dump
> which seems appropriate. For the cgroup case, programs are attached to
> cgroups using the bpf system call hence an extension to it is needed to
> retrieve the attached program.
>
> Tracepoints are wrong here for multiple reasons: tracepoints do not and
> should not look at the bpf code, and auditing / verifying a config can
> not rely on executing code that can, hopefully, trigger the tracepoint
> to return some information that might shed light on a problem. That is
> not a reliable mechanism for verifying something is (or is not in the
> case of the default VRF) properly configured.
>
