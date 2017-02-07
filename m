From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Tue, 7 Feb 2017 10:22:22 -0700
Message-ID: <83e2bd44-fbe0-38a5-f080-3042572d8a64@cumulusnetworks.com>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
 <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com>
 <5894F19A.60305@iogearbox.net>
 <34456681-46d1-0761-3b61-4e308f363126@cumulusnetworks.com>
 <ddfeb9be-31a7-a2ba-abe2-55a1f90cc548@6wind.com>
 <5898847B.2060400@iogearbox.net>
 <20170206192114.GA54756@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Quentin Monnet <quentin.monnet@6wind.com>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36160 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754249AbdBGRWY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 12:22:24 -0500
Received: by mail-pg0-f46.google.com with SMTP id v184so40346814pgv.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 09:22:24 -0800 (PST)
In-Reply-To: <20170206192114.GA54756@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/6/17 12:21 PM, Alexei Starovoitov wrote:
>> Well, worst case cost would be ~8 additional pages per program that
>> are very rarely used; assume you want to attach a prog per netdevice,
>> or worse, one for ingress, one for egress ... and yet we already
>> complain that netdevice itself is way too big and needs a diet ...
>> That makes it much much worse, though. Using the remainder of the
>> used page is thus not enough, I'm afraid.

sure, 8 bytes per instruction, 4k instructions so worst case is ~8 pages.

>> But also then, what do you do with 4k insns (or multiple of these in
>> case of tail calls), is there a decompiler in the works? Understandably
>> that for vrf it might be trivial to just read disasm, but that's just
>> one very specific use-case. I can see the point of dumping for the

Dumping bpf bytecode is no different than dumping asm with objdump. To
those who know/learn how to read it and make sense of the asm, it is an
important tool. I contend the ability to retrieve and dump BPF code is
equally important.


>> sake of CRIU use-case given that cBPF is supported there in the past,
>> and CRIU strives to catch up with all kind of kernel APIs. It's
>> restricted wrt restore to either the same kernel version or newer
>> kernels, but that's generic issue for CRIU. So far I'm not aware of
>> user requests for CRIU support, but it could come in future, though.
>> Thus, should we have some dump interface it definitely needs to be
>> i) generic and ii) usable for CRIU, so we don't end up with multiple
>> dump mechanisms due to one API not being designed good enough to
>> already cover it.
>>
>> Dump result would need to look a bit similar to what we have in ELF
>> file, that is, you'd need to construct map descriptions and reference
>> them in the insn sequence similar to relocations in the loader. I

That is a userspace problem, not a kernel problem. This discussion is on
the API to return BPF code to userspace. How that program is presented
to the user is up to the tools.


>> haven't looked into whether it's feasible, but we should definitely
>> evaluate possibilities to transform the post-verifier insn sequence
>> back into a pre-verifier one for dumping, so we don't need to pay the
>> huge additional cost (also a major fraction of the insns might be
>> just duplicated here as they weren't rewritten). Perhaps it could
>> be done with the help of small annotations, or some sort of diff
>> that we only need to store. Not saying it's trivial, but we should
>> definitely try hard first and design it carefully if we want to
>> support such API.

I looked at a reverse_convert_ctx_access at the end of last week. I only
have code to reverse sock_filter_convert_ctx_access, but scanning the
other convert functions nothing jumped out suggesting it is not doable.
Saving the original bpf code is the simplest solution, hence I decided
to use it for this discussion.


> +1
> 
> such instruction dump is meaningful only for stateless programs.
> Out of the top of my head the minium requirement is that they
> shouldn't use maps and no tailcalls.
> Also the extra memory is the concern, so I think we need a flag
> for BPF_PROG_LOAD command like 'store stateless original prog'.
> Then at load time we can check that maps are not used and so on.
> The get_attach approach from patch 2 is imo too specific.
> I think two independent commands would be better.
> One to return new prog_fd from attachment point and
> second to do the actual instruction dump based on given prog_fd.
> Most of the programs today are stateful, so I'm reluctant to add
> all that complexity for small fraction of programs, so I would
> like to understand the motivation first.
> 'ss --bpf' is imo part of the answer. It would need to print
> attachment info as well, right? and this is for debugging only?
> In case of 'ip vrf' the programs are trivial, so it's really
> to debug 'ip vrf' only? and tracepoints somehow not enough?
> Or there is more to it that I'm missing?
> 

My motivation for pursing this discussion now is to verify cgroups are
correctly configured on running systems. But, I am also interested in
the generic OS case and being able to debug and understand networking
problems because of bugs in BPF code.

For example, consider the case of enterprise distributions used by
companies as part of their platforms and products with BPF programs
coming from the OS vendor, the hardware vendors, and custom, locally
developed programs (remember that BPF store comment I made in October? I
was only half-joking). As an open OS, you have to anticipate programs
coming from multiple sources, and those programs can and will have bugs.
Further, people make mistakes; people forget commands that were run. It
is fairly easy to see that the wrong bpf program could get attached to
some object.

In both the VRF/cgroup case and Quentin's case, we are talking about
retrieving programs attached to specific objects, not just retrieving
some BPF code that has been loaded into the kernel. bpf programs are
loaded using the bpf system call, but they are attached to objects using
different APIs. Given that, retrieval of the programs attached to
specific objects need to be retrieved with object specific APIs. No?
e.g., In Quentin's patch, the bpf code is added as part of the tc dump
which seems appropriate. For the cgroup case, programs are attached to
cgroups using the bpf system call hence an extension to it is needed to
retrieve the attached program.

Tracepoints are wrong here for multiple reasons: tracepoints do not and
should not look at the bpf code, and auditing / verifying a config can
not rely on executing code that can, hopefully, trigger the tracepoint
to return some information that might shed light on a problem. That is
not a reliable mechanism for verifying something is (or is not in the
case of the default VRF) properly configured.
