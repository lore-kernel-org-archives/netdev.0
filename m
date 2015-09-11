From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 2/5] seccomp: make underlying bpf ref counted as well
Date: Fri, 11 Sep 2015 20:28:19 +0200
Message-ID: <55F31D43.5080001@iogearbox.net>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com> <1441930862-14347-3-git-send-email-tycho.andersen@canonical.com> <55F2D0EC.9090004@iogearbox.net> <20150911144400.GI27574@smitten> <55F2FB6F.7050708@iogearbox.net> <20150911173311.GB7244@smitten>
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
Received: from www62.your-server.de ([213.133.104.62]:33753 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbIKS2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 14:28:36 -0400
In-Reply-To: <20150911173311.GB7244@smitten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2015 07:33 PM, Tycho Andersen wrote:
> On Fri, Sep 11, 2015 at 06:03:59PM +0200, Daniel Borkmann wrote:
>> On 09/11/2015 04:44 PM, Tycho Andersen wrote:
>>> On Fri, Sep 11, 2015 at 03:02:36PM +0200, Daniel Borkmann wrote:
>>>> On 09/11/2015 02:20 AM, Tycho Andersen wrote:
>>>>> In the next patch, we're going to add a way to access the underlying
>>>>> filters via bpf fds. This means that we need to ref-count both the
>>>>> struct seccomp_filter objects and the struct bpf_prog objects separately,
>>>>> in case a process dies but a filter is still referred to by another
>>>>> process.
>>>>>
>>>>> Additionally, we mark classic converted seccomp filters as seccomp eBPF
>>>>> programs, since they are a subset of what is supported in seccomp eBPF.
>>>>>
>>>>> Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
>>>>> CC: Kees Cook <keescook@chromium.org>
>>>>> CC: Will Drewry <wad@chromium.org>
>>>>> CC: Oleg Nesterov <oleg@redhat.com>
>>>>> CC: Andy Lutomirski <luto@amacapital.net>
>>>>> CC: Pavel Emelyanov <xemul@parallels.com>
>>>>> CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
>>>>> CC: Alexei Starovoitov <ast@kernel.org>
>>>>> CC: Daniel Borkmann <daniel@iogearbox.net>
>>>>> ---
>>>>>   kernel/seccomp.c | 4 +++-
>>>>>   1 file changed, 3 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>>>>> index 245df6b..afaeddf 100644
>>>>> --- a/kernel/seccomp.c
>>>>> +++ b/kernel/seccomp.c
>>>>> @@ -378,6 +378,8 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
>>>>>   	}
>>>>>
>>>>>   	atomic_set(&sfilter->usage, 1);
>>>>> +	atomic_set(&sfilter->prog->aux->refcnt, 1);
>>>>> +	sfilter->prog->type = BPF_PROG_TYPE_SECCOMP;
>>>>
>>>> So, if you do this, then this breaks the assumption of eBPF JITs
>>>> that, currently, all classic converted BPF programs always have a
>>>> prog->type of BPF_PROG_TYPE_UNSPEC (see: bpf_prog_was_classic()).
>>>>
>>>> Currently, JITs make use of this information to determine whether
>>>> A and X mappings for such programs should or should not be cleared
>>>> in the prologue (s390 currently).
>>>>
>>>> In the seccomp_prepare_filter() stage, we're already past that, so
>>>> it will not cause an issue, but we certainly would need to be very
>>>> careful in future, if bpf_prog_was_classic() is then used at a later
>>>> stage when we already have a generated bpf_prog somewhere, as then
>>>> this assumption will break.
>>>
>>> The only reason we need to do this is to allow BPF_DUMP_PROG to work,
>>> since we were restricting it to only allow dumping of seccomp
>>> programs, since those don't have maps. Instead, perhaps we could allow
>>> dumping of BPF_PROG_TYPE_SECCOMP and BPF_PROG_TYPE_UNSPEC?
>>
>> There are possibilities that BPF_PROG_TYPE_UNSPEC is calling helpers
>> already today, at least in networking case, not seccomp. So, since
>> you want to export [classic -> eBPF] only for seccomp, put fds on them
>> and dump these via bpf(2), you could allow that (with a big comment
>> stating why it's safe), but mid-term we really need to sanitize all
>> this stuff properly as this is needed for other types, too.
>
> Sorry, just to be clear, you're suggesting that the patch is ok modulo
> a comment describing the jit issues?

I think due to the given insns restrictions on classic seccomp, this
could work for "most cases" (see below) for the time being until pointer
sanitation is resolved and that seccomp-only restriction from the dump
could be removed, BUT there's one more stone in the road which you still
need to take care of with this whole 'giving classic seccomp-BPF -> eBPF
transforms an fd, dumping and restoring that via bpf(2)' approach:

If you have JIT enabled on ARM32, and add a classic seccomp-BPF filter,
and dump that via your bpf(2) interface based on the current patches, what
you'll get is not eBPF opcodes but classic (!) BPF opcodes as ARM32 classic
JIT supports compilation of seccomp, since commit 24e737c1ebac ("ARM: net:
add JIT support for loads from struct seccomp_data.").

So in that case, bpf_prepare_filter() will not call into bpf_migrate_filter()
as there's simply no need for it, because the classic code could already
be JITed there. I guess other archs where JIT support for eBPF in not yet
within near sight might sooner or later support this insn for their classic
JITs, too ...
