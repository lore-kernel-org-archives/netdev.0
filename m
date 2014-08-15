From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 03/26] bpf: introduce syscall(BPF, ...)
 and BPF maps
Date: Thu, 14 Aug 2014 23:40:53 -0700
Message-ID: <CAMEtUux5UCxvJyVSXDixy2fjHOXhRFLipgN7aLj_ovYm2Svy9g@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-4-git-send-email-ast@plumgrid.com>
	<CAE40pdcCqu6zBqDgAXBpKHzX=y7hXtz83yEadYTE2yACiqyT3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAE40pdcCqu6zBqDgAXBpKHzX=y7hXtz83yEadYTE2yACiqyT3g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2014 at 3:28 PM, Brendan Gregg
<brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> [...]
>> maps can have different types: hash, bloom filter, radix-tree, etc.
>>
>> The map is defined by:
>>   . type
>>   . max number of elements
>>   . key size in bytes
>>   . value size in bytes
>
> Can values be strings or byte arrays? How would user-level bpf read
> them? The two types of uses I'm thinking are:
>
> A. Constructing a custom string in kernel-context, and using that as
> the value. Eg, a truncated filename, or a dotted quad IP address, or
> the raw contents of a packet.
> B. I have a pointer to an existing buffer or string, eg a filename,
> that will likely be around for some time (>1s). Instead of the value
> storing the string, it could just be a ptr, so long as user-level bpf
> has a way to read it.
>
> Also, can keys be strings? I'd ask about multiple keys, but if they
> can be a string, I can delimit in the key (eg, "PID:filename").

Both map keys and values are opaque byte arrays. eBPF program
can decide to store strings in there. Or concatenate multiple
strings as long as sizes are bounded.
High level scripting languages are dazzling with native strings
support, but I'm trying to stay away from it in the kernel.
Scripting languages should be able to convert string operations
into low level eBPF primitives which are being worked on.
So far I've been able to use ids and pointers and concatenations
of binary things as keys and values, and have user space interpret
them. I agree that having a script that does map[probe_name()]++
is definitely more human readable than storing probe ip into
ebpf map and converting addresses to names in userspace.
I'm hoping that the urge to make cool scripting language will push
somebody to have a dtrace/ktap/stap language compiler into eBPF :)
That will also address your concern of embedded setup where
full llvm is too big, but dtrace_into_ebpf compiler may be just right.
At the same time people who care about last bit of performance
will be using C and llvm or ebpf assembler directly.
Anyway will share string related ebpf helpers soon (not in V5 though)
