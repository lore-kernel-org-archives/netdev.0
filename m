From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Sat, 28 Jun 2014 23:20:00 -0700
Message-ID: <CAMEtUuy_NZYsi3OB3TRfutHKaryzGSy6W4cdjzU-iJKkv75DKQ@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<CALCETrV+uTamX2BShHsHnwTr4R7+MSQXX8bXe=2Xo1hbiSAipQ@mail.gmail.com>
	<CAMEtUuzq4ib6MFAsp_ZpBisRa=XFUgKkX7OwwrEoOfw7O1YXCQ@mail.gmail.com>
	<CALCETrV-uUL=NJ5_XP90cMmxvVJ0PHxCb7f4L=TqGX9tB5Vi2Q@mail.gmail.com>
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
In-Reply-To: <CALCETrV-uUL=NJ5_XP90cMmxvVJ0PHxCb7f4L=TqGX9tB5Vi2Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 28, 2014 at 6:58 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> These were great questions! I hope I answered them. If not, please
>> continue asking.
>
> I have plenty more questions, but here's one right now: does anything
> prevent programs from using pointers in comparisons, returning
> pointers, or otherwise figuring out the value of a pointer?  If so, I
> think it would be worthwhile to prevent that so that eBPF programs
> can't learn kernel addresses.

when we decide to let non-root users load such programs, yes.
Right now the goal is the opposite. Take a look at 'drop monitor' example.
It stores kernel addresses where packets were dropped into a map,
so that user space can read it. The goal of eBPF for tracing is to be able
to see all corners of the kernel without being able to crash it.
eBPF is a kernel module that cannot crash kernel or adversely affect
the execution. Though in the future I'd like to expand applicability and
let unprivileged users use them. In such cases exposing kernel
addresses will be prevented. It's easy to tweak verifier to prevent
comparison of pointers, storing pointers to a map or passing them into
a function. The verifier is already tracking all pointers. There ways to
leak them: store into map, pass to helper function, return from program,
compare to constant, obfuscate via arithmetic. Prevention by verifier
is trivial. Though not right now. User level security is a different topic.
If I try to solve both 'root user safety' and 'non-root security' it will
take ages to go anywhere. So this patch is root only. I'm deliberately
not addressing non-root security for now.
First step: root only, get kernel pieces in place, llvm upstream, perf
plus all other user level tools. Just this step will take months.
Then let's talk about non-root. I believe it will need minimal changes
to verifier and no syscall uapi changes, but even if I'm wrong and
new syscall would be needed, it's not a big deal. Adding things
gradually is way better than trying to solve everything at once.
