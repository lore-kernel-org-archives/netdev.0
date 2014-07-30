From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v3 net-next 3/3] samples: bpf: eBPF dropmon example in C
Date: Wed, 30 Jul 2014 11:53:54 -0700
Message-ID: <CAMEtUuzmiYDY=mSP2bxv90FA3_LpijBcdSNj6L72z0doxDqKLQ@mail.gmail.com>
References: <1406000723-4872-1-git-send-email-ast@plumgrid.com>
	<1406000723-4872-4-git-send-email-ast@plumgrid.com>
	<y0m1tt226lj.fsf@fche.csb>
	<CAMEtUuxNs=HBhtFwhBX3HOU6+QqtYZ+v7sJ74+cg-o+bi5GdoA@mail.gmail.com>
	<20140730173638.GB8745@redhat.com>
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
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Frank Ch. Eigler" <fche-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140730173638.GB8745-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 30, 2014 at 10:36 AM, Frank Ch. Eigler <fche-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> > What kind of locking/serialization is provided by the ebpf runtime
>> > over shared variables such as my_map?
>>
>> it's traditional rcu scheme.
>
> OK, that protects the table structure, but:
>
>> [...] In such case concurrent write access to map value can be done
>> with bpf_xadd instruction, though using normal read/write is also
>> allowed. In some cases the speed of racy var++ is preferred over
>> 'lock xadd'.
>
> ... so concurrency control over shared values is left up to the
> programmer.

yes. It has to be flexible and fast.
One of our main use cases is network analytics where a lot of
packets are going through ebpf programs, so every cycle counts.
Mandatory locks in critical path are not acceptable. If we add
locks they will be optional.

>> There are no lock/unlock function helpers available to ebpf
>> programs, since program may terminate early with div by zero
>> for example, so in-kernel lock helper implementation would
>> be complicated and slow. It's possible to do, but for the use
>> cases so far there is no need.
>
> OK, I hope that works out.  I've been told that dtrace does something
> similiar (!)  by eschewing protection on global variables such as
> strings.  In their case it's less bad than it sounds because they are
> used to offloading computation to userspace or to store only
> thread-local state, and accept the corollary limitations on control.

interesting.
btw, things like global variables, per-cpu storage are potential ebpf
features. So far they're 'nice to have' instead of 'mandatory'.
The maps are powerful enough to do the same:
Global storage is map of one element.
Per-cpu storage is map of num_cpu elements.
