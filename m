From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 net-next 4/6] bpf: enable bpf syscall on x64 and i386
Date: Tue, 26 Aug 2014 09:29:08 -0700
Message-ID: <CAMEtUuw_AE8BC+u-2C6_B8UpKh_ryi-DDdUTQ77ZuARqd_dgcw@mail.gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
	<1409014858-1410-5-git-send-email-ast@plumgrid.com>
	<20140825.180718.137768107010295086.davem@davemloft.net>
	<CAMEtUuy1DXFMABAg2Uup5HtqmiJHw0WR=or-z9CfpVMscrVcVg@mail.gmail.com>
	<20140826074534.GA19799@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140826074534.GA19799@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2014 at 12:45 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> On Mon, Aug 25, 2014 at 6:07 PM, David Miller <davem@davemloft.net> wrote:
>> > From: Alexei Starovoitov <ast@plumgrid.com>
>> > Date: Mon, 25 Aug 2014 18:00:56 -0700
>> >
>> >> -
>> >> +asmlinkage long sys_bpf(int cmd, unsigned long arg2, unsigned long arg3,
>> >> +                     unsigned long arg4, unsigned long arg5);
>> >
>> > Please do not add interfaces with opaque types as arguments.
>> >
>> > It is impossible for the compiler to type check the args at
>> > compile time when userspace tries to use this stuff.
>>
>> I share this concern. I went with single BPF syscall, because
>> alternative is 6 syscalls for every command and more
>> syscalls in the future when we'd need to add another command.
>
> See 'struct perf_event_attr':
>
> SYSCALL_DEFINE5(perf_event_open,
>                 struct perf_event_attr __user *, attr_uptr,
>                 pid_t, pid, int, cpu, int, group_fd, unsigned long, flags)
>
> This way we were able to gradually grow to the sophisticated ABI
> you can find in include/uapi/linux/perf_event.h, without having
> to touch the syscall interface. (It's not the only method: we
> also have a handful of ioctls, where that's the most natural
> interface for a perf event fd.)

Thanks! that's a good alternative.
One approach would be to have two bpf syscalls:
map_fd = bpf_map_create(map_type, nlattr)
+ bunch of ioctl()s that do lookup/update/delete/...
prog_fd = bpf_prog_load(prog_type, nlattr)
but ioctl()s would still do a lot of type casting.

so how about single syscall:
fd = bpf(int cmd, union bpf_attr *attrs, int size)
union bpf_attr {
  struct bpf_map_create_attr { /* used by bpf_map_create cmd */
    __u32 key_size, value_size, ...
  };
  struct bpf_map_access_attr { /* by lookup/update/delete/get_next */
    int map_fd;
    void __user *key; /* used by all */
    void __user *value; /* used by lookup/update */
    void __user *next_key; /* used by get_next */
  };
  struct nlattr prog_attr[0]; /* used by bpf_prog_load cmd */
};

If you prefer I can make prog_load attrs to be explicit struct
as well, but nlattr feels cleaner, since there can be optional
sections that are quite large. Like one with 'readonly constants'
that I'm still working on as part of cleaner strings support.

Also I think I will change tracing attachment interface.
Currently write("prog_fd_as_int") -> "/sys/../tracing/events/..."
does the attachment, but as Andy noticed that may be not
secure enough if there is fork() somewhere in the process
that does open() of debugfs and write().
Looks like another ioctl() like PERF_EVENT_IOC_SET_FILTER_BPF
on top of perf_event_open() would be cleaner and event->owner
check can be done easily.
Can I create kprobe event through perf_event_open() ?
