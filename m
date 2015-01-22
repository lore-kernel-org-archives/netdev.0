From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH tip 0/9] tracing: attach eBPF programs to
 tracepoints/syscalls/kprobe
Date: Thu, 22 Jan 2015 10:03:16 +0900
Message-ID: <20150122010316.GA15871@sejong>
References: <CAMEtUuxhjef+9QaFccfSyA3DbVJ3H6qP=eu-uZCkku1rVWViSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuxhjef+9QaFccfSyA3DbVJ3H6qP=eu-uZCkku1rVWViSQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On Fri, Jan 16, 2015 at 10:57:15AM -0800, Alexei Starovoitov wrote:
> On Fri, Jan 16, 2015 at 7:02 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> > One last thing. If the ebpf is used for anything but filtering, it
> > should go into the trigger file. The filtering is only a way to say if
> > the event should be recorded or not. But the trigger could do something
> > else (a printk, a stacktrace, etc).
> 
> it does way more than just filtering, but
> invoking program as a trigger is too slow.
> When program is called as soon as tracepoint fires,
> it can fetch other fields, evaluate them, printk some of them,
> optionally dump stack, aggregate into maps.
> We can let it call triggers too, so that user program will
> be able to enable/disable other events.
> I'm not against invoking programs as a trigger, but I don't
> see a use case for it. It's just too slow for production
> analytics that needs to act on huge number of events
> per second.

AFAIK a trigger can be fired before allocating a ring buffer if it
doesn't use the event record (i.e. has filter) or ->post_trigger bit
set (stacktrace).  Please see ftrace_trigger_soft_disabled().

This also makes it keeping events in the soft-disabled state.

Thanks,
Namhyung


> We must minimize the overhead between tracepoint
> firing and program executing, so that programs can
> be used on events like packet receive which will be
> in millions per second. Every nsec counts.
> For example:
> - raw dd if=/dev/zero of=/dev/null
>   does 760 MB/s (on my debug kernel)
> - echo 1 > events/syscalls/sys_enter_write/enable
>   drops it to 400 MB/s
> - echo "echo "count == 123 " > events/syscalls/sys_enter_write/filter
>   drops it even further down to 388 MB/s
> This slowdown is too high for this to be used on a live system.
> - tracex4 that computes histogram of sys_write sizes
>   and stores log2(count) into a map does 580 MB/s
>   This is still not great, but this slowdown is now usable
>   and we can work further on minimizing the overhead.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
