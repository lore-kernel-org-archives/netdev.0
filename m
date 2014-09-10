From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Wed, 10 Sep 2014 13:21:29 -0700
Message-ID: <CAMEtUuyY0L2=tz5mSvQqR_=_oN18nA6V9fdbR8OiYTPbQth8AQ@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
	<CALCETrVBb_uQZpodv67XSTGVU40y6+9Ktw=3zAJgGV2mNJ=_0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrVBb_uQZpodv67XSTGVU40y6+9Ktw=3zAJgGV2mNJ=_0A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 10, 2014 at 11:22 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>
>>        attr   is a pointer to a union of type bpf_attr as defined below.
>>
>>        size   is the size of the union.
>
> I find this strange.  Why not just make attr be a pointer to the
> relevant struct for the operation being invoked?

you mean change attr to be 'void *' and type cast it to particular
struct type based on cmd ? Possible, but I tried to avoid all
typecasts as Dave doesn't like them.

>>        union bpf_attr {
>>            struct { /* anonymous struct used by BPF_MAP_CREATE command */
>>                enum bpf_map_type map_type;
>
> Does this reliably generate the same type on compat systems?  C++11
> has a fix for enum ABI compatibility, but this is plain C :(

enum is int on both 32 and 64-bit. What was the concern?
anonymous struct ?
I've checked that with gcc 4.2 - 4.9 and clang. All was fine
and it's part of C standard now.

>>            struct { /* anonymous struct used by BPF_PROG_LOAD command */
>>                enum bpf_prog_type    prog_type;
>>                __u32                 insn_cnt;
>>                const struct bpf_insn *insns;
>>                const char            *license;
>>                __u32                 log_level; /* verbosity level of eBPF verifier */
>>                __u32                 log_size;  /* size of user buffer */
>>                void                  *log_buf;  /* user supplied buffer */
>>            };
>>        };
>
> It might be a bit nicer to have separate in and out arguments.

would do you mean specifically?
const pointer is obviously 'in' argument.
'void *' is 'out'.

>>               int bpf_create_map(enum bpf_map_type map_type, int key_size,
>>                                  int value_size, int max_entries)
>>               {
>>                   union bpf_attr attr = {
>>                       .map_type = map_type,
>>                       .key_size = key_size,
>>                       .value_size = value_size,
>>                       .max_entries = max_entries
>>                   };
>
> I feel like this is asking for trouble, or at least bizarre namespace
> collisions in the anonymous struct members.  At least please give the
> structs names.  (Also, the first time I read this, I assumed that
> those were union members, which would have made the code be nonsense.)

if inner struct types had names they would need to
have field names as well, so the syscall wrapper above
would become much more verbose and uglier.
Also naming structs may give wrong ideas to some users,
since they might think it's ok to init struct only and type cast
it to pass into syscall. When inner structs don't have names,
the user space is forced to always use 'union bpf_attr' and
initialize relevant fields.

>>               char bpf_log_buf[LOG_BUF_SIZE];
>
> What happens if the size isn't LOG_BUF_SIZE?

would do you mean?
LOG_BUF_SIZE is just a user defined macro.
Can be anything.
it's passed along with pointer:
                       .log_buf = bpf_log_buf,
                       .log_size = LOG_BUF_SIZE,
                       .log_level = 1,

>>               enum bpf_prog_type {
>>                       BPF_PROG_TYPE_UNSPEC,
>>                       BPF_PROG_TYPE_SOCKET_FILTER,
>>                       BPF_PROG_TYPE_TRACING_FILTER,
>>               };
>
> Why does the type matter?

type is way to tell eBPF infra what this type of programs
is allowed to do. Different kernel subsystems
configure different types.
Like patch 12 configures TYPE_UNSPEC for testing.
This type allows one dummy function call and
bpf_context of two u64 fields.
tracing subsystem will configure TYPE_TRACING
to do different set of helper functions and different
body of 'bpf_context'.
PROG_TYPE and MAP_TYPE are two main ways
to configure eBPF infra for different use cases.

> This (the .imm thing) is sufficiently weird that I think it needs to
> be mentioned in the main docs, not just in an example.  It's
> especially odd since AFAIK essentially every other object format in
> the world uses a separate relocation table instead of inline magic
> opcodes like this.

we discussed relocations before, right? ;)
I believe relocations are ugly. elf has no other way to deal
with it, since .text has valid cpu instructions and generic
loader has to adjust them without knowing hw encoding.
Here we have pseudo instructions that are much easier
to check/track in verifier than relocations.
As you remember in previous series I've tried relocation
style and it was ugly. Both as user interface and as extra
complexity for verifier.
Does commit log of patch 8 explain map_fd conversion
well enough or not?
If not, I'll add more info, but please read it first.

>>        ENOENT For  BPF_MAP_LOOKUP_ELEM  or BPF_MAP_DELETE_ELEM, indicates that
>>               element with given key was not found.
>
> What does it return?  (The same question goes for a bunch of the map ops.)
...
> Shouldn't delete return different values depending on whether anything
> was deleted?
...
> Ah, here it is.  Please document this with the ops.

I believe it's a standard manpage style to document
return values at the end in 'return value' section.
I can duplicate it with ops, but is it really necessary?

>>        These commands may be used only by a privileged process (one having the
>>        CAP_SYS_ADMIN capability).
>
> I hope this goes away :)

hehe.
I think folks obsessed with security will say it should stay
this way for looooong time :)
My immediate goal is tracing and there this restriction is
necessary anyway.

> I can't shake the feeling that the whole syscall map API is wrong and
> that, instead, there should be a more general concept of objects
> provided by the eBPF runtime.  Those objects could have methods that
> are callable by the syscall and callable from eBPF code.

'concept of objects'... sounds abstractly good :)
Something concrete you have in mind?

Theoretically I can see how we can add a 'stream' object
which user space can read and programs feed stuff to.
In other words an 'abstract' trace buffer, but imo it's
overdesign. When we need a trace buffer, we'll just
add a helper function that pushes stuff to it.
That will be the time when you see how handy pseudo
instructions are. In this patch the only '.imm thing', as you
say, is map_fd. I'm working on per-cpu local buffer via
the same pseudo stuff. Seem to work quite nicely.
Let's not get carried on with future cool stuff, basics first :)

Thanks for the feedback!
