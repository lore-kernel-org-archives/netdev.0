From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF
 syscall, verifier, testsuite)
Date: Fri, 26 Sep 2014 13:39:03 -0700
Message-ID: <CALCETrXS5KBHm-3Fz031VFPpTHC_BDOLd_zNB6DjCidZa5-x2A@mail.gmail.com>
References: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
 <CAMEtUuyt9RASKZ4NeqK_OUYNN8QT6P20+kjcwywchur6QXSt0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuyt9RASKZ4NeqK_OUYNN8QT6P20+kjcwywchur6QXSt0A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 1:00 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Fri, Sep 26, 2014 at 12:34 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> On Fri, Sep 26, 2014 at 12:06 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>>> From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>>> Date: Fri, 26 Sep 2014 00:16:56 -0700
>>>
>>>> v14 -> v15:
>>>> - got rid of macros with hidden control flow (suggested by David)
>>>>   replaced macro with explicit goto or return and simplified
>>>>   where possible (affected patches #9 and #10)
>>>> - rebased, retested
>>>
>>> Series applied to net-next, thanks.
>>
>> Hi all-
>>
>> I read through the verifier.  Sorry this email is a little bit late.
>> Here are some thoughts, in no particular order.
>>
>> Programs should IMO have feature flags.  One such feature would be
>> "can use pointers as integers", for example.
>
> of course.
> I believe we discussed it in the past.
> programs will have flags. I'm not sure why you insist on this in
> the first version.
>
>> UNKNOWN_VALUE is IMO a crappy type.  I think that it should renamed to
>> INTEGER and that a bunch of the things that generate it should be
>> errors.
>
> it's an internal type.
> Sure, I'm ok renaming it, but 'integer' name doesn't fit.
> It's not integer type.
> When I post a patch for "can use pointers as integers" flag
> you'll see that this 'unknown_value' will be broken down
> into more precise types.
>
>> ALU ops like adding two pointers should IMO be failures.  I don't
>> think that they should result in UNKNOWN_VALUE.
>
> they will be failures for unprivileged programs.
> In this patch the whole thing is for root only and root programs need
> arithmetic on pointers to compute hashes and so on.
> I wish we spent more time chatting, so I could explain this better.
>
>> I don't like PTR_TO_MAP_VALUE as a type.  I think that there should
>> instead be "pointer to (const?) buffer of N bytes".
>>
>> ARG_PTR_TO_MAP_KEY is odd.  Why do we care what a function does with a
>> key?  It just needs to be a big enough buffer, right?
>
> not quite. there is a distinction between key and value.
> They both come from map definition and correspond to key_size
> and value_size, so they have to have two different corresponding
> _internal_ types 'ptr_to_map_key' and 'ptr_to_map_value'
> This distinction is needed to properly describe function
> arguments constraints.

But they're still just pointers to buffers of some size known to the
verifier, right?  By calling them "pointer to map key" and "pointer to
map value" you're tying them to map objects in a way that makes little
sense to me.

>
>> All of the stack spill stuff seems overcomplicated.  Can you just
>> disallow unaligned stack access?  Right off the bat, that will delete
>> a bunch of code and cut down runtime memory use by nearly a factor of
>> eight.
>
> not quite. stack spill/fill is not for unaligned access.
> unaligned access is disallowed first.
> See line 663 in check_mem_access().
> Often enough gcc/llvm ran out of registers and have to spill
> them into stack. This spill/fill tracking mechanism keeps
> track of what is stored into stack. Otherwise type violation will be
> possible. We cannot get rid of it. It essential for safety.

So what's "spill part"?  Unless I misunderstood the stack tracking
code, you're tracking each byte separately.

You're also tracking the type for each stack slot separately for each
instruction.  That looks like it'll account for the considerable
majority of total memory usage.

>
>> Also, there are no calls to functions written eBPF, right?  If so, why
>> not just give each stack slot a *fixed* type for the lifetime of the
>> program?  That would be a huge time complexity win, not to mention
>> being more comprehensible.  When function calls get added, they'll
>> need a whole pile of new infrastructure anyway.
>
> you cannot. stack cannot be fixed. It's very small and valuable
> resources. Programs will be using differently.
>
>> check_call is a mess.  I predict that it will be unmaintainable.
>
> why? care to provide details?

I may have misread my notes.

I don't like the fact that the function proto comes from the
environment instead of from the program.

>
>> check_ld_abs is messy, IMO.  Can't there be a real type "pointer to
>> object of type [type]", where skb would be a type?  Then you could use
>> the normal function call logic for skb pointers instead of hardcoded
>> crud.
>>
>> You're doing a depth-first search.  I don't like it.  You need complex
>> pruning logic to avoid exponential behavior, and it's not obvious to
>
> there was in patch in previous series that did the prunning.
> I dropped out of this set to simplify things.
>
>> me that pathological programs that cause exponential blowups in the
>> verifier don't exist.  Wouldn't it make more sense to do a
>> breadth-first search instead and to give each reg/stack slot a
>> definite type at each point in the control flow?  You'd need a
>> function to find the intersection of two types, but I think that would
>> be preferable to the current code that tests whether one type is a
>> subset of another.
>
> nope. breadth-first just doesn't work at all.

Sorry, I didn't actually mean BFS.  I meant to order the search such
that all incoming control flow edges to an insn are visited before any
of the outgoing edges are visited.

>
>> At some point someone will want loops, and that will open a huge can
>> of worms involving explicit typing or type inference.  It might pay to
>> add some kind of stack slot (and maybe even register slot) type
>> declarations now to get things ready for that.
>
> sure. As discussed we may allow loops in the future.
>
>> NB: If this code is actually invoked in net-next when loading a
>> filter, please don't push to Linus until there's a convincing argument
>> that the verifier has acceptable asymptotic complexity.
>
> complexity is actually described in the doc.
> There are several limits. Verifier will be aborted if it walks
> more then 32k instructions or more then 1k branches.
> So the very worst case takes micro seconds to reject
> the program. So I don't see your concern.

That this will randomly fail, then.  For all I know, there are
existing valid BPF programs with vastly more than 32k "instructions"
as counted by the verifier.

--Andy
