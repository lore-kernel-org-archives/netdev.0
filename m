From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: Re: Re: [PATCH tip 0/9] tracing: attach eBPF programs to tracepoints/syscalls/kprobe
Date: Tue, 20 Jan 2015 11:58:51 +0900
Message-ID: <54BDC46B.5080109@hitachi.com>
References: <1421381770-4866-1-git-send-email-ast@plumgrid.com> <54BCD3CF.9040205@hitachi.com> <CAMEtUuwzx-HZqEaTS30JFfF_RX5kGaZfsgE8wmogzcb2k5=k1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
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
	LKML <linux-kernel@vger.kernel.org>,
	"zhangwei(Jovi)" <jovi.zhangwei@huawei.com>,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuwzx-HZqEaTS30JFfF_RX5kGaZfsgE8wmogzcb2k5=k1g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2015/01/20 5:48), Alexei Starovoitov wrote:
> On Mon, Jan 19, 2015 at 1:52 AM, Masami Hiramatsu
> <masami.hiramatsu.pt@hitachi.com> wrote:
>> If we can write the script as
>>
>> int bpf_prog4(s64 write_size)
>> {
>>    ...
>> }
>>
>> This will be much easier to play with.
> 
> yes. that's the intent for user space to do.
> 
>>>   The example of this arbitrary pointer walking is tracex1_kern.c
>>>   which does skb->dev->name == "lo" filtering.
>>
>> At least I would like to see this way on kprobes event too, since it should be
>> treated as a traceevent.
> 
> it's done already... one can do the same skb->dev->name logic
> in kprobe attached program... so from bpf program point of view,
> tracepoints and kprobes feature-wise are exactly the same.
> Only input is different.

No, I meant that the input should also be same, at least for the first step.
I guess it is easy to hook the ring buffer committing and fetch arguments
from the event entry.

>>> - kprobe programs are architecture dependent and need user scripting
>>>   language like ktap/stap/dtrace/perf that will dynamically generate
>>>   them based on debug info in vmlinux
>>
>> If we can use kprobe event as a normal traceevent, user scripting can be
>> architecture independent too. Only perf-probe fills the gap. All other
>> userspace tools can collaborate with perf-probe to setup the events.
>> If so, we can avoid redundant works on debuginfo. That is my point.
> 
> yes. perf already has infra to read debug info and it can be extended
> to understand C like script as:
> int kprobe:sys_write(int fd, char *buf, size_t count)
> {
>    // do stuff with 'count'
> }
> perf can be made to parse this text, recognize that it wants
> to create kprobe on 'sys_write' function. Then based on
> debuginfo figure out where 'count' is (either register or stack)
> and generate corresponding bpf program either
> using llvm/gcc backends or directly.

And what I expected scenario was

1. setup kprobe traceevent with fd, buf, count by using perf-probe.
2. load bpf module
3. the module processes given event arguments.

> perf facility of extracting debug info can be made into
> library too and used by ktap/dtrace tools for their
> languages.
> User space can innovate in many directions.
> and, yes, once we have a scripting language whether
> it's C like with perf or else, this language hides architecture
> depend things from users.
> Such scripting language will also hide the kernel
> side differences between tracepoint and kprobe.

Hmm, it sounds making another systemtap on top of tracepoint and kprobes.
Why don't you just reuse the existing facilities (perftools and ftrace)
instead of co-exist?

> Just look how ktap scripts look alike for kprobes and tracepoints.

Ktap is a good example, it provides only a language parser and a runtime engine.
Actually, currently it lacks a feature to execute "perf-probe" helper from
script, but it is easy to add such feature.

Jovi, if you hire perf-probe helper, you could do

trace probe:do_sys_open dfd fname flags mode {
...
}

instead of

trace probe:do_sys_open dfd=%di fname=%dx flags=%cx mode=+4($stack) {
...
}

For this usecase, I've made --output option for perf probe
https://lkml.org/lkml/2014/10/31/210

It currently stopped, but easy to resume on the latest perf.

Thank you,

> Whether ktap syntax becomes part of perf or perf invents
> its own language, it's going to be good for users regardless.
> The C examples here are just examples. Something
> users can play with already until more user friendly
> tools are being worked on.


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com
