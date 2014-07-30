From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v3 net-next 3/3] samples: bpf: eBPF dropmon example in C
Date: Wed, 30 Jul 2014 10:17:17 -0700
Message-ID: <CAMEtUuxNs=HBhtFwhBX3HOU6+QqtYZ+v7sJ74+cg-o+bi5GdoA@mail.gmail.com>
References: <1406000723-4872-1-git-send-email-ast@plumgrid.com>
	<1406000723-4872-4-git-send-email-ast@plumgrid.com>
	<y0m1tt226lj.fsf@fche.csb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:54777 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454AbaG3RRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 13:17:19 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so8022814wiw.0
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 10:17:18 -0700 (PDT)
In-Reply-To: <y0m1tt226lj.fsf@fche.csb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2014 at 8:45 AM, Frank Ch. Eigler <fche@redhat.com> wrote:
> For the record, this is not entirely accurate as to dtrace.  dtrace
> delegates aggregation and most reporting to userspace.  Also,
> systemtap is "short and deterministic" even for aggregations & nice
> graphs, but since it limits its storage & cpu consumption, its
> arrays/reports cannot get super large.

My understanding of systemtap is that the whole .stp script is converted
to C, compiled as .ko and loaded, so all map walking and prints are
happening in the kernel. Similarly for ktap which has special functions
in kernel to print histograms.
I thought dtrace printf are also happening from the kernel. What is the
trick they use to know which pieces of dtrace script should be run in
user space?
In ebpf examples there are two C files: one for kernel with ebpf isa
and one for userspace as native. I thought about combining them,
but couldn't figure out a clean way of doing it.

>> [...]
>> +SEC("events/skb/kfree_skb")
>> +int bpf_prog2(struct bpf_context *ctx)
>> +{
>> +[...]
>> +     value = bpf_map_lookup_elem(&my_map, &loc);
>> +     if (value)
>> +             (*(long *) value) += 1;
>> +     else
>> +             bpf_map_update_elem(&my_map, &loc, &init_val);
>> +     return 0;
>> +}
>
> What kind of locking/serialization is provided by the ebpf runtime
> over shared variables such as my_map?

it's traditional rcu scheme.
Programs are running under rcu_read_lock(), so that
bpf_map_lookup_elem() can return pointer to map value which
won't disappear while program is running.
In-kernel map implementation needs to use rcu style to match
ebpf program assumptions. map implementation is enforcing
the limit to the number of elements.
I didn't post 'array' type of map yet. bpf_map_lookup in this
implementation will just return 'base + index' pointer.
Regardless of type of map the same ebpf program running on
different cpus may lookup the same 'key' and receive the same
map value pointer. In such case concurrent write access to
map value can be done with bpf_xadd instruction, though
using normal read/write is also allowed. In some cases
the speed of racy var++ is preferred over 'lock xadd'.
There are no lock/unlock function helpers available to ebpf
programs, since program may terminate early with div by zero
for example, so in-kernel lock helper implementation would
be complicated and slow. It's possible to do, but for the use
cases so far there is no need.
