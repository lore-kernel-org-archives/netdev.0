From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v13 net-next 07/11] bpf: verifier (add ability to receive
 verification log)
Date: Wed, 17 Sep 2014 21:17:37 +0200
Message-ID: <5419DE51.1060904@redhat.com>
References: <1410914370-29883-1-git-send-email-ast@plumgrid.com> <1410914370-29883-8-git-send-email-ast@plumgrid.com> <54192F66.8020200@redhat.com> <CAMEtUuxK68ZoJ-izjLoygv0f+rLtPmMLUUq1=BJ+_ZBGfynkdA@mail.gmail.com> <5419BED8.5020309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5419BED8.5020309@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/17/2014 07:03 PM, Daniel Borkmann wrote:
> On 09/17/2014 06:08 PM, Alexei Starovoitov wrote:
>> On Tue, Sep 16, 2014 at 11:51 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>>>>
>>>>    /* last field in 'union bpf_attr' used by this command */
>>>> -#define        BPF_PROG_LOAD_LAST_FIELD license
>>>> +#define        BPF_PROG_LOAD_LAST_FIELD log_buf
>>>
>>> I was looking to find a use case for this item, but couldn't find anything,
>>> so
>>> this seems to be dead code?
>>
>> See CHECK_ATTR() macro and comment next to it in patch #1
>>
>>> Was it, so that each time you extend an uapi structure like above that you
>>> would
>>> only access the structure up to BPF_PROG_LOAD_LAST_FIELD? That might not
>>> work for
>>> old binaries using this ABI running on newer kernels where there are
>>> different
>>> expectations of what BPF_PROG_LOAD_LAST_FIELD has been at the time of
>>> compilation.
>>
>> exactly the opposite.
>> CHECK_ATTR() is checking that all fields beyond last for given
>> command are zero, so we can extend bpf_attr with new fields
>> added after last.
>> Transition from patch 4 to patch 7 and the hunk you quoted are
>> demonstrating exactly that. Say, userspace was compiled
>> with bpf_attr as defined in patch 4 and it populated fields all the way
>> till 'license', and kernel is compiled with patch 7. Kernel does:
>> union bpf_attr attr = {};
>> /* copy attributes from user space, may be less than sizeof(bpf_attr) */
>> copy_from_user(&attr, uattr, size)
>> so newer fields (all the way till log_buf) stay zero and kernel
>> behavior is the same as it was in patch 4.
>> So older user space works as-is with newer kernel.
>
> Ok, I see. Lets say, since the introduction of this syscall you have
> added a couple of features and thus extended union bpf_attr where it
> grew in size over time.
>
> You built your shiny new binary on that uapi setting, and later on
> decide to run it on an older kernel. What will happen is that in your
> bpf syscall handler you will return with -EINVAL on that kernel right
> away since the size of union bpf_attr is greater.
>
> That would mean over time when new features will get added, applications
> that want to make sure to run on _all_ kernels where the bpf syscall is
> available have to make sure to either use the _initial_ version of
> union bpf_attr in order to not get an -EINVAL, or worse they have
> to probe though a syscall different versions of union bpf_attr if they
> wish to make use of a particular feature until they do not get an -EINVAL
> anymore.
>
> I guess that might be problematic for an application developer that
> wants to ship its application across different distributions usually
> running different kernels. At least those people might then consider
> holding a private copy of the _initial_ version of union bpf_attr in
> their own source code, but it's not pleasant I guess.
>
> I know you seem to have the constraint to run on NET-less systems, but
> netlink could partially resolve that in the sense that it would allow
> to at least load an eBPF program with initial feature set. Couldn't
> there be some mechanism to make this interaction more pleasant? E.g.
> in BPF extensions we can ask the kernel up to what extension it
> supports and accordingly adapt to it up front. I know it's just a
> /trivial/ example but have you thought about something on that kind for
> the syscall?

Hm, thinking out loudly ... perhaps this could be made a library problem.
Such that the library which wraps the syscall needs to be aware of a
marker where the initial version ends, and if the application doesn't
make use of any of the new features, it would just pass in the length up
to the marker as size attribute into the syscall. Similarly, if new
features are always added to the end of a structure and the library
truncates the overall-length after the last used member we might have
a chance to load something on older kernels, haven't tried that though.
