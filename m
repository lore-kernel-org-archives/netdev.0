From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple calls
 in eBPF
Date: Tue, 3 Jun 2014 14:12:19 -0700
Message-ID: <CA+ZOOTPdDDeGxZVGXVRZmjkxqkGefgDLrawo_9YXbjwTQ_FLzA@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1401389758-13252-1-git-send-email-chema@google.com>
	<5387C8AD.6000909@redhat.com>
	<CA+ZOOTNobzzJPgQnVVZ+b6rRD=0_pdjUB8q5FQVkbO+dob0BSg@mail.gmail.com>
	<538C6FD8.9040305@redhat.com>
	<CAMEtUuyduk1sHBeVm=d5GYEgB4ma7sVFYeBLdapbeEpQY9nA1Q@mail.gmail.com>
	<538D884E.5030007@redhat.com>
	<CAMEtUuxK5hV_eORRLaSHSiwF5X82Ae91vL6W0-6au48v8H6bAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuxK5hV_eORRLaSHSiwF5X82Ae91vL6W0-6au48v8H6bAA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 3, 2014 at 1:15 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Tue, Jun 3, 2014 at 1:33 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 06/02/2014 06:48 PM, Alexei Starovoitov wrote:
>>>
>>> imo there are pros and cons in Daniel's and Chema's proposals
>>> for classic BPF extensions.
>>> I like Chema's a bit more, since his proposal doesn't require to
>>> change classic BPF verifier and that's always a delicate area
>>> (seccomp also allows to use M[] slots).
>>
>>
>> What bothers me is that you have to *special case* this extension
>> all over the BPF converter and stack, even you need to introduce a
>> prologue just to walk the whole filter program and to check if the
>> extension is present; next to that instead of one extension you
>> need to add a couple of them to uapi. I understand Chema's proposal
>
> Agree. The walking part and multiple anc loads are not clean, but in your
> approach you'd need to hack sk_chk_filter() to recognize very specific
> anc load and do even fancier things in check_load_and_stores()
> to make sure that 'ld #5, ld #keys' is safe from M[] usage point of view.
I think you may be confusing the two parts of the patch, namely
whether we implement the code as 1 anc load with N parameters or as N
anc loads, and the existence of a prologue.

- Adding just 1 anc load ("ld #keys" in your pseudo-code) requires
less UAPI changes, but effectively exports the flow_keys struct to the
user (which means we cannot change it in the future). The fact that
you're proposing your own version of the flow_keys ( {nhoff, nproto,
thoff, tproto, poff} ) does not make it less of a problem: You're just
exporting an alternative (albeit IMO way better one, as all the
dissected info can be obtained from your 5-tuple) flow_keys. From a
usability PoV, the user may have to either do "ld #0; ld #keys"
(knowing that "#0" refers to "nhoff"), or "ld #nhoff". I definitely
prefer the second, but I can easily rewrite the patch to use the
first.

- Now, the existence of a prologue is a must if you want to ensure the
filter only calls the actual flow dissector once (this is the main
goal of the patch, actually). Having 2 insns separated by N insns that
access data obtained from the same flow dissector call means you have
to both (a) ensure the first caller -- whether it's the first or the
second insn -- does perform the BPF_CALL, and (b) ensure that none of
the N insns in the middle mucks with the result of the first call (my
solution deals with (b) by using the stack outside of M[], while yours
requires verifying the code. I find mine easier).

In order to achieve (a), you need the prologue code: Because the code
can have jumps, you can never know whether the "ld #keys" was actually
called or not. What my solution's prologue does is to write a 0 on a
flow_inited u32, which states that the flow dissector hasn't been
called. Now, every call for any of the sub-fields checks this
flow_inited field, and runs the flow dissector iff it's zero (hasn't
been called yet), in which case it also sets flow_inited to 1.

Your approach needs it too. Citing from your pseudo-code:

> ld #5     <-- indicates to fill the first 5 slots of M[], so M[0] to M[4]
> ld #keys  <-- triggers the extension to fill the M[] slots
> ld M[0]   <-- loads nhoff from M[0] into accu

How does the "ld M[0]" know that the actual flow dissector has already
been called? What if the insn just before the "ld #5" was "jmp +2" ?
In that case, the "ld #keys" would have never been called.

> ld M[0]   <-- loads nhoff from M[0] into accu
> <do sth with it>
> ld M[3]   <-- loads tproto into accu, etc

>> or his need to easily access these data but that's why I proposed
>> the above if he wants to go for that. Btw, seccomp doesn't allow
>> for loading BPF extensions, you said so yourself Alexei.
>
> of course, but seccomp does use ld/st M[] which will overlap
> with your socket extension and since check_load_and_stores()
> will be hacked, seccomp verification needs to be considered as well.
> From user api point of view, your approach is cleaner than Chema's,
> but from implementation Chema's is much safer and smaller.
>
> Anyway as I said before I'm not excited about either.
> I don't think we should be adding classic BPF extensions any more.
> The long term headache of supporting classic BPF extensions
> outweighs the short term benefits.
I see a couple of issues with (effectively) freezing classic BPF
development while waiting for direct eBPF access to happen. The first
one is that the kernel has to accept it. I can see many questions
about this, especially security and usability (I'll send an email
about the "split BPF out of core later"). Now, the main issue is
whether/when the tools will support it. IMO, this is useful iff I can
quickly write/reuse filters and run tcpdump filters based on them. I'm
trying to get upstream libpcap to accept support for raw (classic) BPF
filters, and it's taking a long time. I can imagine how they may be
less receptive about supporting a Linux-only eBPF mechanism. Tools do
matter.

Even if eBPF happens, it's not that the extensions are so hard to port
to eBPF: It's one BPF_CALL per extension. And they have a
straightforward porting path to the C-like code.

-Chema


> Not having to constantly tweak kernel for such cases was the key
> goal of eBPF. My two eBPF approaches to solve Chema's need
> are both cleaner, since nothing special is being done in eBPF
> core to support this new need. Both instruction set and verifier
> stay generic and cover tracing and this new socket use at once.
> I do realize that I'm talking here about future eBPF verifier that
> is not in tree yet and eBPF is not exposed to user space, but
> I think we should consider longer term perspective.
> If I'm forced to pick between yours or Chema's classic extensions,
> I would pick Chema's because it's lesser evil :)
>
>>> I think exposing eBPF to user space is not a matter of 'if' but 'when'.
>>>
>>> I'm not sure how pressing it is now to add another extension to classic,
>>> when the goal of this patch set fits into eBPF model just fine.
>>> yes, eBPF verifier is not in tree yet and it will obviously take longer to
>>> review than Chema's or Daniel's set.
>>>
>>> When eBPF is exposed to user space the inner header access can
>>> be done in two ways without changing eBPF instruction set or eBPF
>>> verifier.
>>>
>>> eBPF approach #1:
>>> -- code packet parser in restricted C
>>> Pros:
>>> skb_flow_dissect() stays hidden in kernel.
>>> No additional uapi headache which exist if we start reusing
>>> in-kernel skb_flow_dissect() either via classic or eBPF.
>>> Such eBPF program will be just as fast as in-kernel skb_flow_dissect()
>>> (I provided performance numbers before)
>>> Cons:
>>> in-kernel skb_flow_dissect() is not reused, but mostly copy-pasted to
>>> userspace.
>>>
>>> eBPF approach #2:
>>> -- reuse in-kernel skb_flow_dissect() via bpf_call insn from eBPF program
>>> Pros:
>>> eBPF program becomes much shorter and can be done in asm like:
>>> bpf_mov r2, fp
>>> bpf_sub r2, 64
>>> bpf_call bpf_skb_flow_dissect  // call in-kernel helper function from
>>> eBPF program
>>> bpf_ldx r1, [fp - 64]  // access flow_keys data
>>> bpf_ldx r2, [fp - 60]
>>>
>>> Cons:
>>> bpf_skb_flow_dissect() (wrapper on top of skb_flow_dissect()) becomes
>>> uapi visible helper function
>>>
>>> imo both eBPF approaches are cleaner than extending classic.
>>>
>>
