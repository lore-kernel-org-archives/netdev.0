From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Tue, 3 Jun 2014 08:44:15 -0700
Message-ID: <CAMEtUuw8uyCGeLeUB0PXm5cCpqcsjPLZt6y9FcKjapbVPjWTuw@mail.gmail.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
	<538C3C94.3080206@redhat.com>
	<CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com>
	<538CAEA6.4060307@redhat.com>
	<CAMEtUuwxJOgYgFjg9deQZOffeg6-JUGZXZ1Rj344eQmriQ0F0Q@mail.gmail.com>
	<538D8DAA.7090105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:58881 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932627AbaFCPoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 11:44:16 -0400
Received: by mail-we0-f169.google.com with SMTP id u56so7138594wes.14
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 08:44:15 -0700 (PDT)
In-Reply-To: <538D8DAA.7090105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 3, 2014 at 1:56 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 06/02/2014 09:02 PM, Alexei Starovoitov wrote:
> ...
>>
>> Classic has all sorts of hard coded assumptions. The whole
>>
>> concept of 'load from magic constant' to mean different things
>> is flawed. We all got used to it and now think that it's normal
>> for "ld_abs -4056" to mean "a ^= x"
>
>
> I think everyone knows that, no? Sure it doesn't fit into the
> concept, but I think at the time BPF extensions were introduced,
> it was probably seen as the best trade-off available to access
> useful skb fields while still trying to minimize exposure to uapi
> as much as possible.

Exactly. It _was_ seen as right trade-off in the past.
Now we have a lot more bpf users, so considerations are different.

>> This split is not trying to make classic easier to hack.
>> With eBPF underneath classic, it got a lot easier to add extensions
>> to classic, but we shouldn't be doing it.
>> Classic BPF is not generic and cannot become one. It's eBPF's job.
>>
>> The split is mainly helping to clearly see the boundary of eBPF core
>> vs its socket use case. It doesn't change or add any API.
>
>
> So what's the plan with everything in arch/*/net/, tools/net/ and
> in Documentation/networking/filter.txt, plus MAINTAINERS file, that
> the current patch doesn't address?

I have multi-year long plan of actions in eBPF area and as
was seen in past several month I would have to adjust it many times
based on community feedback.
The plan includes taking care of arch/*/net, but I'm not bringing it up
right now, since the filter.c split itself doesn't depend on what
we're going to do with JITs in arch/*/net/
As you saw I mentioned JITs in the cover letter, so I obviously
thought about it before proposing this filter.c split.
I even have rough patches to take care of it, but let's not get ahead
of ourselves.
My plan also includes upstreaming of LLVM eBPF backend, but linux
needs to expose it to userspace first.
It includes eBPF assembler to write programs like:
 r1 = r5
 *(u32 *) (fp - 10) = 0
 call foo
 if (r0 == 0) goto Label
^^above is assembler. I don't like current bpf_asm syntax,
since it's too assemblish. C-looking assembler is easier to understand.
It includes bpf maps, 'perf run filter.c' and all sorts of other things.
I cannot put the year long plan in one email, since tl;dr kicks in.

filter.c split is a tiny first step.
next step is filter.h split
renaming arch/*/net/bpf_jit_comp.c into arch/*/bpf/jit_comp.c is
the least of my concerns. If JITs stay with strong dependency
to NET, it's also fine.
As I said in cover letter filter.c split is not about NET dependency.
Even tiny embedded systems rely on networking, so all real world
.config's will include 'NET'. The split is about logical separation
of eBPF vs sockets. Having them in one file just not doing any good,
since people are jumping into hacking things quickly without seeing
that eBPF is not only about sockets.

MAINTAINERS file is a good question too.
I would be happy to maintain bpf/ebpf, since it's my full time job anyway,
but again let's not jump the gun.

> We want changes to go via netdev@vger.kernel.org as they always
> did, since [ although other use cases pop up ] the main user, as
> I said, is simply still packet filtering in various networking
> subsystems, no?

Obviously sockets is the main, but not the only user, so I think
both lkml and netdev would need to be cc-ed in the future.
Or we can create 'bpf' alias for anyone interested.

All of your points are valid. They are right questions to ask. I just
don't see why you're still arguing about first step of filter.c split,
whereas your concerns are about steps 2, 3, 4.
