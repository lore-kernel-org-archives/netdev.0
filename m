From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 2/5] seccomp: make underlying bpf ref counted as well
Date: Mon, 14 Sep 2015 18:48:43 +0200
Message-ID: <55F6FA6B.1060108@iogearbox.net>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com> <1441930862-14347-3-git-send-email-tycho.andersen@canonical.com> <55F2D0EC.9090004@iogearbox.net> <20150911144400.GI27574@smitten> <55F2FB6F.7050708@iogearbox.net> <20150911173311.GB7244@smitten> <55F31D43.5080001@iogearbox.net> <20150914160030.GC31864@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44951 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbbINQsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 12:48:55 -0400
In-Reply-To: <20150914160030.GC31864@smitten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2015 06:00 PM, Tycho Andersen wrote:
> On Fri, Sep 11, 2015 at 08:28:19PM +0200, Daniel Borkmann wrote:
>> I think due to the given insns restrictions on classic seccomp, this
>> could work for "most cases" (see below) for the time being until pointer
>> sanitation is resolved and that seccomp-only restriction from the dump
>> could be removed,
>
> Ok, thanks.
>
>> BUT there's one more stone in the road which you still
>> need to take care of with this whole 'giving classic seccomp-BPF -> eBPF
>> transforms an fd, dumping and restoring that via bpf(2)' approach:
>>
>> If you have JIT enabled on ARM32, and add a classic seccomp-BPF filter,
>> and dump that via your bpf(2) interface based on the current patches, what
>> you'll get is not eBPF opcodes but classic (!) BPF opcodes as ARM32 classic
>> JIT supports compilation of seccomp, since commit 24e737c1ebac ("ARM: net:
>> add JIT support for loads from struct seccomp_data.").
>>
>> So in that case, bpf_prepare_filter() will not call into bpf_migrate_filter()
>> as there's simply no need for it, because the classic code could already
>> be JITed there. I guess other archs where JIT support for eBPF in not yet
>> within near sight might sooner or later support this insn for their classic
>> JITs, too ...
>
> Thanks for pointing this out.
>
> What if we legislate that the output of bpf(BPF_PROG_DUMP, ...) is
> always eBPF? As near as I can tell there is no way to determine if a
> struct bpf_prog is classic or eBPF, so we'd need to add a bit to
> indicate whether or not the prog has been converted so that
> BPF_PROG_DUMP knows when to convert it.

As I said, you have bpf_prog_was_classic() function to determine exactly
this (so without your type re-assignment you have a way to distinguish it).

Wouldn't it be much easier to rip this set apart into multiple ones, solving
one individual thing at a time, f.e. starting out simple and 1) only add
native eBPF support to seccomp, after that 2) add a method to dump native-only
eBPF programs for criu, then 3) think about a right interface for classic
BPF seccomp dumping, etc, etc? Currently, it tries to solve everything at
once, and with some early assumptions that have non-trivial side-effects.

Thanks,
Daniel
