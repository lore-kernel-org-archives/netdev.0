From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 net-next 4/6] bpf: enable bpf syscall on x64 and i386
Date: Tue, 26 Aug 2014 09:45:34 +0200
Message-ID: <20140826074534.GA19799@gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
 <1409014858-1410-5-git-send-email-ast@plumgrid.com>
 <20140825.180718.137768107010295086.davem@davemloft.net>
 <CAMEtUuy1DXFMABAg2Uup5HtqmiJHw0WR=or-z9CfpVMscrVcVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuy1DXFMABAg2Uup5HtqmiJHw0WR=or-z9CfpVMscrVcVg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> On Mon, Aug 25, 2014 at 6:07 PM, David Miller <davem@davemloft.net> wrote:
> > From: Alexei Starovoitov <ast@plumgrid.com>
> > Date: Mon, 25 Aug 2014 18:00:56 -0700
> >
> >> -
> >> +asmlinkage long sys_bpf(int cmd, unsigned long arg2, unsigned long arg3,
> >> +                     unsigned long arg4, unsigned long arg5);
> >
> > Please do not add interfaces with opaque types as arguments.
> >
> > It is impossible for the compiler to type check the args at
> > compile time when userspace tries to use this stuff.
> 
> I share this concern. I went with single BPF syscall, because
> alternative is 6 syscalls for every command and more
> syscalls in the future when we'd need to add another command.

We had a similar problem growing the perf syscall - and we were 
able to hold to a single syscall, which I think has served us 
well. Had we gone with a per functionality syscall we'd have 
something like a dozen syscalls today, scattered all around 
non-continuously in the syscall space on most platforms.

But note that 'opaque or non-opaque' is a false dichotomy, as 
there are 3 options in reality: what we used instead of an opaque 
type was an extensible data type, and extensible C structure, 
with structure size expectations part of the structure.

See 'struct perf_event_attr':

SYSCALL_DEFINE5(perf_event_open,
                struct perf_event_attr __user *, attr_uptr,
                pid_t, pid, int, cpu, int, group_fd, unsigned long, flags)

That way new versions of the data type are immediately obvious to 
the kernel, and compatibility can be handled well. Smaller, 
previous versions received from old user-space are padded out 
transparently to the kernel's value of the structure, with zeroes 
filled in.

See perf_copy_attr() in kernel/events/core.c. Instead of 
versioning the structure, we use its size as a finegrained and 
robust version indicator in essence.

That way it's both forwards and backwards compatible, as much as 
possible technically: old kernel can run new user-space, and new 
user-space will be able to take advantage of as much of an old 
kernel's capabilities as possible, and in the typical case of 
version match there's no extra overhead worth speaking of.

This way we were able to gradually grow to the sophisticated ABI 
you can find in include/uapi/linux/perf_event.h, without having 
to touch the syscall interface. (It's not the only method: we 
also have a handful of ioctls, where that's the most natural 
interface for a perf event fd.)

Thanks,

	Ingo
