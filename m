From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF
 syscall, verifier, testsuite)
Date: Fri, 26 Sep 2014 14:25:27 -0700
Message-ID: <CAMEtUux-WFOGABTrWW=BGUstE=Zz6agXTGCGrRJtNXDfRmx-5A@mail.gmail.com>
References: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
	<CAMEtUuyt9RASKZ4NeqK_OUYNN8QT6P20+kjcwywchur6QXSt0A@mail.gmail.com>
	<CALCETrXS5KBHm-3Fz031VFPpTHC_BDOLd_zNB6DjCidZa5-x2A@mail.gmail.com>
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
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXS5KBHm-3Fz031VFPpTHC_BDOLd_zNB6DjCidZa5-x2A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 1:39 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> not quite. there is a distinction between key and value.
>> They both come from map definition and correspond to key_size
>> and value_size, so they have to have two different corresponding
>> _internal_ types 'ptr_to_map_key' and 'ptr_to_map_value'
>> This distinction is needed to properly describe function
>> arguments constraints.
>
> But they're still just pointers to buffers of some size known to the
> verifier, right?  By calling them "pointer to map key" and "pointer to
> map value" you're tying them to map objects in a way that makes little
> sense to me.

'pointer_to_map_key' is internal argument constraint of the
in-kernel helper function. It tells verifier how to check the values
passed into function.
Just pointer + size abstraction is not enough here.
verifier has to know the type of what it's checking.

> So what's "spill part"?  Unless I misunderstood the stack tracking
> code, you're tracking each byte separately.
>
> You're also tracking the type for each stack slot separately for each
> instruction.  That looks like it'll account for the considerable
> majority of total memory usage.

verifier has to track each byte separately, because
malicious program may write a pointer into stack with 8-byte
write, then modify single byte with 1-byte write and then
try to read 8-byte back. Verifier has to catch that and
that's why it's tracking every byte-sized slot independently.

> I don't like the fact that the function proto comes from the
> environment instead of from the program.

that's must have.
in-kernel function argument constraints must come from
kernel. where else?
User program says I want to call function foo() and here
is my code that invokes it. Kernel sees prototype of this
foo() and checks arguments.
There is no point for user space program to also
pass foo() constraints. The only thing kernel can do
with this extra info is to check that it matches what
kernel already knows.

>> nope. breadth-first just doesn't work at all.
>
> Sorry, I didn't actually mean BFS.  I meant to order the search such
> that all incoming control flow edges to an insn are visited before any
> of the outgoing edges are visited.

hmm. I'm not sure how exactly you plan on achieving that.
I don't think we want to see real control/data flow graph
analysis in the kernel the way compilers do things.
It will be tens of thousands lines of code.
The algorithm you see in this verifier is straight forward and
tiny. I guess when time passes by when may get enough
courage to attempt something like this, but
today 'kiss' principle rules.

>> complexity is actually described in the doc.
>> There are several limits. Verifier will be aborted if it walks
>> more then 32k instructions or more then 1k branches.
>> So the very worst case takes micro seconds to reject
>> the program. So I don't see your concern.
>
> That this will randomly fail, then.  For all I know, there are
> existing valid BPF programs with vastly more than 32k "instructions"
> as counted by the verifier.

you need to double check your data :)
classic bpf limit is 4k instructions per program.
We're keeping the same limit for eBPF.
32k limit says that verifier will visit each instruction
no more than 8 times.
if we have a program full of branches, then yes, 32k limit will
be reached and that's exactly what 'state pruning' patch is
addressing! As I already said, I dropped it out of this set
to ease review and to keep patch set size minimal.
You can see it my tree:
https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/commit/?h=v14&id=1d9529ae4ce24bc31ca245a156299aa9e59a29f0
I was planning to send it next.
It's small incremental patch on top of existing things.
