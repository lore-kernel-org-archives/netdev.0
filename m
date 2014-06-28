From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 13/14] samples: bpf: example of stateful
 socket filtering
Date: Fri, 27 Jun 2014 23:21:05 -0700
Message-ID: <CAMEtUuyPF3KRLmJQ=_6nb4kBfc+nBdAyib_3VSgFZ8oSTgHXRg@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-14-git-send-email-ast@plumgrid.com>
	<CALCETrWGUui53hpRYtA9zmLKLf-r-nC8urq_JgJoRnzRb1d_1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrWGUui53hpRYtA9zmLKLf-r-nC8urq_JgJoRnzRb1d_1w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2014 at 5:21 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Fri, Jun 27, 2014 at 5:06 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> this socket filter example does:
>>
>> - creates a hashtable in kernel with key 4 bytes and value 8 bytes
>>
>> - populates map[6] = 0; map[17] = 0;  // 6 - tcp_proto, 17 - udp_proto
>>
>> - loads eBPF program:
>>   r0 = skb[14 + 9]; // load one byte of ip->proto
>>   *(u32*)(fp - 4) = r0;
>>   value = bpf_map_lookup_elem(map_id, fp - 4);
>>   if (value)
>>        (*(u64*)value) += 1;
>
> In the code below, this is XADD.  Is there anything that validates
> that shared things like this can only be poked at by atomic
> operations?

Correct. The asm code uses xadd to increment packet stats.
It's up to the program itself to decide what it's doing.
Some programs may prefer speed vs accuracy when counting
and they will be using regular "ld, add, st", instead of xadd.
Verifier checks that programs can only access a valid memory
region. The program itself needs to do something sensible with it.
Theoretically I can add a check to verifier that shared map elements
are read-only and xadd-only, but that limits usability and unnecessary.
We actually do have a use case when we do a regular add, since
'lock add' is too costly at high event rates.
