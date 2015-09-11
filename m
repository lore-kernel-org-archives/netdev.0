From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] ebpf: emit correct src_reg for conditional jumps
Date: Fri, 11 Sep 2015 18:53:30 +0200
Message-ID: <55F3070A.2090405@iogearbox.net>
References: <1441931107-17673-1-git-send-email-tycho.andersen@canonical.com> <55F294A9.9020005@iogearbox.net> <55F29EB8.50805@iogearbox.net> <20150911154041.GA5171@Alexeis-MBP-2.westell.com> <20150911155034.GO27574@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tycho Andersen <tycho.andersen@canonical.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54499 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbbIKQxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 12:53:35 -0400
In-Reply-To: <20150911155034.GO27574@smitten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2015 05:50 PM, Tycho Andersen wrote:
> On Fri, Sep 11, 2015 at 08:40:43AM -0700, Alexei Starovoitov wrote:
>> On Fri, Sep 11, 2015 at 11:28:24AM +0200, Daniel Borkmann wrote:
>>> [off topic for this patch]
>>>
>>> ... this requirement also breaks down for cases where you have a single
>>> classic BPF instruction that maps into 2 or more eBPF instructions, hitting
>>> BPF_MAXINSNS early at the time when you try to call into bpf(2) again with
>>> the dumped result. If I recall correctly, Chrome seems to use up quite a lot
>>> of insns space on (classic) seccomp-BPF, so this could potentially be a real
>>> issue, next to artificially crafted examples that would fail.
>>>
>>> With regards to the latter, also classic programs that could have holes of
>>> dead code where you jump over them (see lib/test_bpf.c for examples) are
>>> unfortunately allowed on the ABI side, so while the classic -> eBPF converter
>>> may translate this dead region 1:1, it will be rejected by the verifier when
>>> you dump and try to reload that. ;) Anyway, it's perhaps a silly example, but
>>> it shows that this use-case can only work on a 'best-effort' basis, and not
>>> cover everything of the classic BPF ABI, as opposed to having an interface
>>> that can dump/restore classic BPF instructions directly.
>>>
>>> Do you need this for checkpoint/restore? Wouldn't this therefore be better
>>> done as dump/restore classic<->classic and eBPF<->eBPF directly? In socket
>>> filters we do this by keeping orig_prog around, I guess it's better to bite
>>> the bullet of additional memory overhead in case of classic seccomp-BPF, too.
>>
>> I don't think so.
>> When I played with libseccomp and chrome I saw that browser installed
>> several bpf programs for every new tab. The longest program was 275
>> classic insns which translated to slightly more eBPF insns
>> (because in eBPF we don't have < and <= instructions, so converter
>> needs to emit extra jump insns)

Yes, these cases, and also exit code translates into two and you have a
preamble moving ctx to arg1 for every classic program. So it should be
slightly more overall, depending on the program structure.

>> Also they don't produce unreachable code.
>> So getting over 4k limit and unreachable are rather hypothetical
>> problems. I wouldn't want to have two interfaces to criu seccomp.

Thinking out loud, is there such a use-case where you checkpoint your
application on kernel X (that allows, say, to dump /and/ inject classic
seccomp insns) and restore it elsewhere on kernel Y, where Y is older
than X (f.e. it can easily inject classic insns on seccomp as it's
present for some time, but /not/ dump). I guess that could be ignored
as you couldn't move it away from there w/o dumping insns then? Also,
if the *whole* environment is even to a little degree non-homogeneous,
then your own seccomp rules can already kill you. ;)

>> eBPF is going to be used by seccomp as well, so having two is extra
>> burden for user space criu.

I don't know how much burden it actually is for criu, it for sure already
would need to do exactly this for eBPF socket filters. If I could choose
between adding extra complexity on user space or kernel space, I would
choose user space when possible.

> I think the burden is not so huge once we have eBPF c/r in place (we
> could just check the classic flag first, then dump the eBPF version or
> something). However, it doesn't seem ideal to have to support two
> interfaces.
>
>> If we start hitting 4k limit for eBPF, we can easily bump it
>> and/or add < and <= insns to eBPF (which was on my todo list anyway).

I think bumping BPF_MAXINSNS seems fragile wrt user space breakage, it's
at least unclear to me whether applications interacting with the kernel
depend on this in some [even weird] way. I'd probably go for the <, <=.

> I was hoping you might say this (assuming you mean add < BPF_MAXINSNS
> to the converter).
>
> The dead code is certainly a problem, but perhaps we can wait on this
> until there become some critical application that has this issue. I
> was hoping we could get away without extra memory usage on the kernel
> side (indeed, this patchset is mostly to try and avoid that).
>
> Tycho
>
