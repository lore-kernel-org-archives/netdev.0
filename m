From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next 11/14] tracing: allow eBPF programs to be
 attached to events
Date: Wed, 2 Jul 2014 00:29:44 -0700
Message-ID: <CAMEtUuyUqUsQbdvCWQvGjD5kuUQ8OzXzf7-7v+UJq+dDsBMv8A@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-12-git-send-email-ast@plumgrid.com>
	<87tx70496q.fsf@sejong.aot.lge.com>
	<CAMEtUuzHakFzJYRR0WgwRBnsQL24KGsNax5DTfRNMJrGhvfQMA@mail.gmail.com>
	<CAM9d7cisUq9nJbSXZMtD+nQ_g+ZCKSsu_ghRDZY9vvkq51oiKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
To: Namhyung Kim <namhyung@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM9d7cisUq9nJbSXZMtD+nQ_g+ZCKSsu_ghRDZY9vvkq51oiKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 1, 2014 at 11:39 PM, Namhyung Kim <namhyung@kernel.org> wrote:
> On Wed, Jul 2, 2014 at 3:14 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>
>> Can manipulate what at compile time? Entry records of tracepoints are
>> hard coded based on the event. For verifier it's easier to treat all
>> tracepoint events as they received the same 'struct bpf_context'
>> of N arguments then the same program can be attached to multiple
>> tracepoint events at the same time.
>
> I was thinking about perf creates a bpf program for filtering some
> events like recording kfree_skb if protocol == xx.  So perf can
> calculate the offset and size of the protocol field and make
> appropriate insns for the filter.

When I'm saying 'tracing filter' in patch 11/14, I really mean
stap/dtrace-like facility for live debugging, where tracing infra plays
a key role. At the end the programs are written in C with annotations
and perf orchestrates compilation, insertion, attaching, printing results.
Your meaning of 'tracing filter' is canonical: a filter that says whether
event should be recorded or not. And it makes sense.
When perf sees 'protocol==xx' on command line it can generate
ebpf program for it. In such case my earlier proposal for replacing
predicate tree walker with ebpf programs in kernel becomes obsolete?
If I understood correctly, you're proposing to teach perf to generate
ebpf programs for existing command line interface and use it instead
of predicate tree. This way predicate tree can be removed, right?
In such case programs would need to access event records.

> Maybe it needs to pass the event format to the verifier somehow then.

The integer fields are easy to verify. dynamic_array part is tricky, since
16-bit offset  + 16-bit length accessors are very tracing specific.
I need to think it through.

> Your scenario looks like just calling a bpf program when it hits a
> event.  It could use event triggering for that purpose IMHO.

Sure. Calling ebpf program can be one of even trigger types.
On the other side ebpf programs themselves can replace the whole
triggering, filtering, recording code. We can have events that
do nothing or call ebpf programs. Then programs walk all necessary
data structures, store stuff into a maps, etc Just look at amount of
events that perf processes. Some of it can be done in kernel by
dynamic program.
