From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next 07/14] bpf: expand BPF syscall with program load/unload
Date: Fri, 27 Jun 2014 23:12:33 -0700
Message-ID: <CAMEtUuywNHVcZ__296NzXK7RPXUBOf7gNQY9JFx0a9PV0Se+wA@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-8-git-send-email-ast@plumgrid.com>
	<CALCETrXDR1LVmbigTicBiddgvcucM1dGk1R7rxdJyBCvGEBQMw@mail.gmail.com>
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
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrXDR1LVmbigTicBiddgvcucM1dGk1R7rxdJyBCvGEBQMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2014 at 5:19 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Jun 27, 2014 at 5:05 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> eBPF programs are safe run-to-completion functions with load/unload
>> methods from userspace similar to kernel modules.
>>
>> User space API:
>>
>> - load eBPF program
>>   prog_id = bpf_prog_load(int prog_id, bpf_prog_type, struct nlattr *prog, int len)
>>
>>   where 'prog' is a sequence of sections (currently TEXT and LICENSE)
>>   TEXT - array of eBPF instructions
>>   LICENSE - GPL compatible
>> +
>> +       err = -EINVAL;
>> +       /* look for mandatory license string */
>> +       if (!tb[BPF_PROG_LICENSE])
>> +               goto free_attr;
>> +
>> +       /* eBPF programs must be GPL compatible */
>> +       if (!license_is_gpl_compatible(nla_data(tb[BPF_PROG_LICENSE])))
>> +               goto free_attr;
>
> Seriously?  My mind boggles.

Yes. Quite a bit of logic can fit into one eBPF program. I don't think it's wise
to leave this door open for abuse. This check makes it clear that if you
write a program in C, the source code must be available.
If program is written in assembler than this check is nop anyway.

btw this patch doesn't include debugfs access to all loaded eBPF programs.
Similarly to kernel modules I'm planning to have a way to list all loaded
programs with optional assembler dump of instructions.
