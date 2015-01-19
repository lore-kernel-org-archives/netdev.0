From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH tip 0/9] tracing: attach eBPF programs to tracepoints/syscalls/kprobe
Date: Mon, 19 Jan 2015 12:48:50 -0800
Message-ID: <CAMEtUuwzx-HZqEaTS30JFfF_RX5kGaZfsgE8wmogzcb2k5=k1g@mail.gmail.com>
References: <1421381770-4866-1-git-send-email-ast@plumgrid.com> <54BCD3CF.9040205@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:58545 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbbASUtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:49:12 -0500
Received: by mail-qg0-f49.google.com with SMTP id i50so2782442qgf.8
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 12:49:11 -0800 (PST)
In-Reply-To: <54BCD3CF.9040205@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 1:52 AM, Masami Hiramatsu
<masami.hiramatsu.pt@hitachi.com> wrote:
> If we can write the script as
>
> int bpf_prog4(s64 write_size)
> {
>    ...
> }
>
> This will be much easier to play with.

yes. that's the intent for user space to do.

>>   The example of this arbitrary pointer walking is tracex1_kern.c
>>   which does skb->dev->name == "lo" filtering.
>
> At least I would like to see this way on kprobes event too, since it should be
> treated as a traceevent.

it's done already... one can do the same skb->dev->name logic
in kprobe attached program... so from bpf program point of view,
tracepoints and kprobes feature-wise are exactly the same.
Only input is different.

>> - kprobe programs are architecture dependent and need user scripting
>>   language like ktap/stap/dtrace/perf that will dynamically generate
>>   them based on debug info in vmlinux
>
> If we can use kprobe event as a normal traceevent, user scripting can be
> architecture independent too. Only perf-probe fills the gap. All other
> userspace tools can collaborate with perf-probe to setup the events.
> If so, we can avoid redundant works on debuginfo. That is my point.

yes. perf already has infra to read debug info and it can be extended
to understand C like script as:
int kprobe:sys_write(int fd, char *buf, size_t count)
{
   // do stuff with 'count'
}
perf can be made to parse this text, recognize that it wants
to create kprobe on 'sys_write' function. Then based on
debuginfo figure out where 'count' is (either register or stack)
and generate corresponding bpf program either
using llvm/gcc backends or directly.
perf facility of extracting debug info can be made into
library too and used by ktap/dtrace tools for their
languages.
User space can innovate in many directions.
and, yes, once we have a scripting language whether
it's C like with perf or else, this language hides architecture
depend things from users.
Such scripting language will also hide the kernel
side differences between tracepoint and kprobe.
Just look how ktap scripts look alike for kprobes and tracepoints.
Whether ktap syntax becomes part of perf or perf invents
its own language, it's going to be good for users regardless.
The C examples here are just examples. Something
users can play with already until more user friendly
tools are being worked on.
