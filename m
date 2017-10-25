From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v3 2/3] bpf: permit multiple bpf attachments for
 a single perf event
Date: Wed, 25 Oct 2017 10:01:14 -0700
Message-ID: <131eefd1-43ae-ac2e-b3f6-d362bd8b9f37@fb.com>
References: <20171024065309.2401893-1-yhs@fb.com>
 <20171024065309.2401893-3-yhs@fb.com> <20171025113249.3283aebc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <peterz@infradead.org>, <rostedt@goodmis.org>,
        <daniel@iogearbox.net>, <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38712 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751792AbdJYRCL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 13:02:11 -0400
In-Reply-To: <20171025113249.3283aebc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/17 2:32 AM, Jesper Dangaard Brouer wrote:
>
> On Mon, 23 Oct 2017 23:53:08 -0700 Yonghong Song <yhs@fb.com> wrote:
>
>> This patch enables multiple bpf attachments for a
>> kprobe/uprobe/tracepoint single trace event.
>
> Thanks for working on this, I've hit this issue, where another program
> BPF-attach to a tracepoint, and the existing userspace-side prog
> doesn't notice.  (Specifically in samples/bpf/xdp_monitor_user.c)
>
> Should my issue be gone now?

that issue was fixed earlier in 'net' by
commit ec9dd352d591 ("bpf: one perf event close won't free bpf program 
attached by another perf event")
Back then the was a concern that fix added extra pointer to
struct trace_event_call just to fix the bug.
Now with this commit the extra pointer is gone and we can attach
multiple programs. Two birds.
We still only allow one program per FD received from perf_event_open().
Main difference that different user space processes can attach their
progs to the same tracepoint/kprobe.

>> Each trace_event keeps a list of attached perf events.
>> When an event happens, all attached bpf programs will
>> be executed based on the order of attachment.
>
> Can I somehow view/list the attached bpf programs from userspace?

this work is ongoing.
The api is not yet obvious, since it's not clear whether to reuse
sys_bpf's BPF_PROG_QUERY command that is used for bpf-cgroup
introspection or extend perf_event's ioctl.
There are pros and cons to both.

> [...]
>
> You didn't describe the expected semantics of bpf-programs return codes.
> From below code it looks like, that if single program in the list/array
> returns 0 then the collective return code is also 0 (is that correct?).

the logic is the same used by BPF_PROG_RUN_ARRAY in bpf-cgroup, which is
"all yes is yes, any no is no" ...

> Where 0 means don't store the event into the perf record ring-buffer.

... meaning that all attached programs are run and any program
returning 0 will not store into the ring buffer.

> Is this a good semantics?

This semantic was there from day one.
The view point back then on bpf programs were that they act as
global filters for kprobes and tracepoints which are global objects
on their own. This patch doesn't change that.

> I do use the return 0 trick to save cycles (in samples/bpf/xdp_monitor_kern.c).
> But when someone attach a new tracepoint, e.g. via perf record -e, then
> they might be surprised that they don't receive any events, when my
> xdp_monitor happen to be running at the same time...?

yes. Most bpf monitoring scripts return 0 to save cycles and
yes it prevents parallel 'perf record -e of_the_same_kprobe'
to see anything.
It's a trade off that programs do. If they want to be fast they
return 0, if they want to be friendly to parallel users through
ring buffer they return 1.
