From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Mon, 06 Feb 2017 15:13:15 +0100
Message-ID: <5898847B.2060400@iogearbox.net>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com> <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com> <5894F19A.60305@iogearbox.net> <34456681-46d1-0761-3b61-4e308f363126@cumulusnetworks.com> <ddfeb9be-31a7-a2ba-abe2-55a1f90cc548@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: Quentin Monnet <quentin.monnet@6wind.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36467 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbdBFONT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 09:13:19 -0500
In-Reply-To: <ddfeb9be-31a7-a2ba-abe2-55a1f90cc548@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2017 11:56 AM, Quentin Monnet wrote:
> 2017-02-03 (15:28 -0700) ~ David Ahern <dsa@cumulusnetworks.com>
>> On 2/3/17 2:09 PM, Daniel Borkmann wrote:
>>> On 02/03/2017 09:38 PM, David Ahern wrote:
>>>> Similar to classic bpf, support saving original ebpf instructions
>>>>
>>>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>>>
>>> Not convinced that this is in the right direction, this not only *significantly*
>>> increases mem footprint for each and every program, but also when you dump this,
>>> then map references from relocs inside the insns are meaningless (f.e. what about
>>> prog arrays used in tail calls?), so things like criu also won't be able to use
>>> this kind of interface for dump and restore. If it's just for debugging, then
>>> why not extend the existing tracing infrastructure around bpf that was started
>>> with intention to gain more visibility.
>>
>> Yes, saving the original bpf increases the memory footprint. If you noticed, a kmemdup is used for the exact instruction size (no page round up). Right now programs are limited to a single page, so worst case  is an extra page per program. I am open to other suggestions. For example, bpf_prog is rounded up to a page which means there could be room at the end of the page for the original instructions. This is definitely true for the ip vrf programs which will be < 32 instructions even with the namespace checking and the conversions done kernel side.
>>
>> Tracepoints will not solve the problem for me for a number of reasons. Tracepoints have to be hit to return data, and there is no way the tracepoint can return relevant information for me to verify that the correct filter was downloaded. I want the original code. I want to audit what was installed. In my case there could be N VRFs, and I want 'ip vrf' or ifupdown2 or any other command to be able to verify that each cgroup has the correct program, and to verify that the default VRF does *not* have a program installed.
>>
>> Generically, the bpf code might contain relative data but that's for the user or decoder program to deal with. Surely there is no harm in returning the original, downloaded bpf code to a properly privileged process. If I am debugging some weird network behavior, I want to be able to determine what bpf code is running where and to see what it is doing to whatever degree possible. Saving the original code is the first part of this.

Well, worst case cost would be ~8 additional pages per program that
are very rarely used; assume you want to attach a prog per netdevice,
or worse, one for ingress, one for egress ... and yet we already
complain that netdevice itself is way too big and needs a diet ...
That makes it much much worse, though. Using the remainder of the
used page is thus not enough, I'm afraid.

But also then, what do you do with 4k insns (or multiple of these in
case of tail calls), is there a decompiler in the works? Understandably
that for vrf it might be trivial to just read disasm, but that's just
one very specific use-case. I can see the point of dumping for the
sake of CRIU use-case given that cBPF is supported there in the past,
and CRIU strives to catch up with all kind of kernel APIs. It's
restricted wrt restore to either the same kernel version or newer
kernels, but that's generic issue for CRIU. So far I'm not aware of
user requests for CRIU support, but it could come in future, though.
Thus, should we have some dump interface it definitely needs to be
i) generic and ii) usable for CRIU, so we don't end up with multiple
dump mechanisms due to one API not being designed good enough to
already cover it.

Dump result would need to look a bit similar to what we have in ELF
file, that is, you'd need to construct map descriptions and reference
them in the insn sequence similar to relocations in the loader. I
haven't looked into whether it's feasible, but we should definitely
evaluate possibilities to transform the post-verifier insn sequence
back into a pre-verifier one for dumping, so we don't need to pay the
huge additional cost (also a major fraction of the insns might be
just duplicated here as they weren't rewritten). Perhaps it could
be done with the help of small annotations, or some sort of diff
that we only need to store. Not saying it's trivial, but we should
definitely try hard first and design it carefully if we want to
support such API.

> This reminds me of that patchset I sent some time ago [1] to dump a
> program, and which was rejected for the same reasons. I'd like to stand
> with David and confirm that I am interested as well in a solution that
> would allow to dump the bytecode without relying on tracepoints.
>
> Quentin
>
> [1] https://www.spinics.net/lists/netdev/msg373259.html
>
