From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Wed, 09 Sep 2015 18:07:57 +0200
Message-ID: <55F0595D.2080409@iogearbox.net>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com> <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com> <CAGXu5j+9YvL6XzX=x8krZbdJXFpe-3FuMu=hAZX9Ew=hYyuK7Q@mail.gmail.com> <20150904210615.GR26679@smitten> <CAGXu5jKGBuD15KBfXKoYbGB40cNsbh=Dz8GM=bmUL-oECRhzxA@mail.gmail.com> <20150909155035.GA26679@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>,
	Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46020 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbbIIQIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 12:08:07 -0400
In-Reply-To: <20150909155035.GA26679@smitten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2015 05:50 PM, Tycho Andersen wrote:
> On Fri, Sep 04, 2015 at 02:08:37PM -0700, Kees Cook wrote:
>> On Fri, Sep 4, 2015 at 2:06 PM, Tycho Andersen
[...]
>>>> I was expecting to see a validator, similar to the existing BPF
>>>> validator that is called when creating seccomp filters currently. Can
>>>> we add a similar validator for new BPF_PROG_TYPE_SECCOMP?
>>>
>>> That's effectively what this patch does; when the eBPF is loaded via
>>> bpf(), you tell bpf() you want a BPF_PROG_TYPE_SECCOMP, and it invokes
>>> this validation/translation code, i.e. it uses
>>> seccomp_is_valid_access() to check and make sure access are aligned
>>> and inside struct seccomp_data.
>>
>> What about limiting the possible instructions?
>
> I totally overlooked this. A quick glance through the eBPF verifier
> makes me think that we can just add another function to struct
> bpf_verifier_ops called valid_instruction, which shouldn't be too
> hard. Perhaps a more interesting question is what to allow:

It's possible, but keep in mind that when you disallow various
instructions from the base insns set, you won't be able to leverage
filter creation in the minimal C subset via clang/llvm anymore, so
usability would suffer from this side, even if you just use clang/llvm
to create the raw insns and later keep them in your application
directly.

And if you later on decide to allow maps, etc, hacking this together
by hand is a bit of a pain. ;)

[ Restricting helper functions and ctx access, etc via bpf_verifier_ops
   (as you can currently do) should not affect this. ]

> BPF_LD(X) and BPF_ST(X): it looks like all types of stores are
>    allowed, and only BPF_MEM and BPF_IMM loads are allowed; I think
>    these can stay the same. BPF_XADD is new in eBPF, and I don't think
>    we need it for seccomp (yet), since we don't have any shared memory
>    via maps.
>
> BPF_ALU: It looks like we're also not allowing regular BPF_ALU
>    instruction BPF_MOD; eBPF adds a few ones: BPF_MOV (register move),
>    BPF_ARSH (sign extended right shift), and BPF_END (endianness
>    conversion), wich I think should all be safe. In particular, we need
>    to allow BPF_MOV at least, since that's how the converter implements
>    BPF_MISC | BPF_TAX from classic.
>
> BPF_ALU64: I think we can safely allow all these as above, since
>    they're just the 64-bit versions.
>
> BPF_JMP: eBPF adds BPF_JNE, BPF_JSGT, BPF_JSGE, BPF_CALL, and
>    BPF_EXIT, which I think all should be safe (except maybe BPF_CALL
>    since we're not allowing functions really). Again we have to allow
>    one of the new eBPF codes, as the converter implements BPF_RET as
>    BPF_JMP | BPF_EXIT.
>
> Thoughts?
>
> Tycho
