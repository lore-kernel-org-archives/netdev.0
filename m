From: Andy Lutomirski <luto@amacapital.net>
Subject: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF syscall,
 verifier, testsuite)
Date: Fri, 26 Sep 2014 12:34:39 -0700
Message-ID: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
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
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 12:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Fri, 26 Sep 2014 00:16:56 -0700
>
>> v14 -> v15:
>> - got rid of macros with hidden control flow (suggested by David)
>>   replaced macro with explicit goto or return and simplified
>>   where possible (affected patches #9 and #10)
>> - rebased, retested
>
> Series applied to net-next, thanks.

Hi all-

I read through the verifier.  Sorry this email is a little bit late.
Here are some thoughts, in no particular order.

Programs should IMO have feature flags.  One such feature would be
"can use pointers as integers", for example.

UNKNOWN_VALUE is IMO a crappy type.  I think that it should renamed to
INTEGER and that a bunch of the things that generate it should be
errors.

ALU ops like adding two pointers should IMO be failures.  I don't
think that they should result in UNKNOWN_VALUE.

I don't like PTR_TO_MAP_VALUE as a type.  I think that there should
instead be "pointer to (const?) buffer of N bytes".

ARG_PTR_TO_MAP_KEY is odd.  Why do we care what a function does with a
key?  It just needs to be a big enough buffer, right?

All of the stack spill stuff seems overcomplicated.  Can you just
disallow unaligned stack access?  Right off the bat, that will delete
a bunch of code and cut down runtime memory use by nearly a factor of
eight.

Also, there are no calls to functions written eBPF, right?  If so, why
not just give each stack slot a *fixed* type for the lifetime of the
program?  That would be a huge time complexity win, not to mention
being more comprehensible.  When function calls get added, they'll
need a whole pile of new infrastructure anyway.

check_call is a mess.  I predict that it will be unmaintainable.

check_ld_abs is messy, IMO.  Can't there be a real type "pointer to
object of type [type]", where skb would be a type?  Then you could use
the normal function call logic for skb pointers instead of hardcoded
crud.

You're doing a depth-first search.  I don't like it.  You need complex
pruning logic to avoid exponential behavior, and it's not obvious to
me that pathological programs that cause exponential blowups in the
verifier don't exist.  Wouldn't it make more sense to do a
breadth-first search instead and to give each reg/stack slot a
definite type at each point in the control flow?  You'd need a
function to find the intersection of two types, but I think that would
be preferable to the current code that tests whether one type is a
subset of another.

At some point someone will want loops, and that will open a huge can
of worms involving explicit typing or type inference.  It might pay to
add some kind of stack slot (and maybe even register slot) type
declarations now to get things ready for that.

NB: If this code is actually invoked in net-next when loading a
filter, please don't push to Linus until there's a convincing argument
that the verifier has acceptable asymptotic complexity.

--Andy
