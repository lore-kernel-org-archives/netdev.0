From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: [PATCH RFC v3 net-next 3/3] samples: bpf: eBPF dropmon example in C
Date: Wed, 30 Jul 2014 13:36:38 -0400
Message-ID: <20140730173638.GB8745@redhat.com>
References: <1406000723-4872-1-git-send-email-ast@plumgrid.com> <1406000723-4872-4-git-send-email-ast@plumgrid.com> <y0m1tt226lj.fsf@fche.csb> <CAMEtUuxNs=HBhtFwhBX3HOU6+QqtYZ+v7sJ74+cg-o+bi5GdoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuxNs=HBhtFwhBX3HOU6+QqtYZ+v7sJ74+cg-o+bi5GdoA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Alexei -

> My understanding of systemtap is that the whole .stp script is converted
> to C, compiled as .ko and loaded, so all map walking and prints are
> happening in the kernel. Similarly for ktap which has special functions
> in kernel to print histograms.

That is correct.

> I thought dtrace printf are also happening from the kernel. What is
> the trick they use to know which pieces of dtrace script should be
> run in user space?

It appears as though the bytecode language running in the kernel sends
some action commands back out to userspace, not just plain data.


> In ebpf examples there are two C files: one for kernel with ebpf isa
> and one for userspace as native. I thought about combining them,
> but couldn't figure out a clean way of doing it.

(#if ?)


> > What kind of locking/serialization is provided by the ebpf runtime
> > over shared variables such as my_map?
> 
> it's traditional rcu scheme.

OK, that protects the table structure, but:

> [...] In such case concurrent write access to map value can be done
> with bpf_xadd instruction, though using normal read/write is also
> allowed. In some cases the speed of racy var++ is preferred over
> 'lock xadd'.

... so concurrency control over shared values is left up to the
programmer.

> There are no lock/unlock function helpers available to ebpf
> programs, since program may terminate early with div by zero
> for example, so in-kernel lock helper implementation would
> be complicated and slow. It's possible to do, but for the use
> cases so far there is no need.

OK, I hope that works out.  I've been told that dtrace does something
similiar (!)  by eschewing protection on global variables such as
strings.  In their case it's less bad than it sounds because they are
used to offloading computation to userspace or to store only
thread-local state, and accept the corollary limitations on control.

(Systemtap does fully & automatically protect shared variables, even
in the face of run-time script errors.)


- FChE
