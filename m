From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/8] perf, bpf: allow bpf programs attach to
 tracepoints
Date: Mon, 18 Apr 2016 18:15:04 -0700
Message-ID: <57158698.9080104@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
 <1459831974-2891931-3-git-send-email-ast@fb.com>
 <20160418162905.220df2f4@gandalf.local.home> <571554EB.9010702@fb.com>
 <20160418181631.2efee46e@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418181631.2efee46e@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/16 3:16 PM, Steven Rostedt wrote:
> On Mon, 18 Apr 2016 14:43:07 -0700
> Alexei Starovoitov <ast@fb.com> wrote:
>
>
>> I was worried about this too, but single 'if' and two calls
>> (as in commit 98b5c2c65c295) is a better way, since it's faster, cleaner
>> and doesn't need to refactor the whole perf_trace_buf_submit() to pass
>> extra event_call argument to it.
>> perf_trace_buf_submit() is already ugly with 8 arguments!
>
> Right, but I solved that in ftrace by creating an on-stack descriptor
> that can be passed by a single parameter. See the "fbuffer" in the
> trace_event_raw_event* code.

Yes. That what I referred to in below 'a struct to pass args'...
But, fine, will try to optimize the size further.
Frankly much bigger .text savings will come from combining
trace_event_raw_event_*() with perf_trace_*()
Especially if you're ok with copying tp args into perf's percpu
buffer first and then copying into ftrace's ring buffer.
Then we can half the number of such auto-generated functions.

>> Passing more args or creating a struct to pass args only going to
>> hurt performance without much reduction in .text size.
>> tinyfication folks will disable tracepoints anyway.
>> Note that the most common case is bpf returning 0 and not even
>> calling perf_trace_buf_submit() which is already slow due
>> to so many args passed on stack.
>> This stuff is called million times a second, so every instruction
>> counts.
>
> Note, that doesn't matter if you are bloating the kernel for the 99.9%
> of those that don't use bpf.
>
> Please remember this! Us tracing folks are second class citizens! If
> there's a way to speed up tracing by 10%, but in doing so we cause
> mainline to be hurt by over 1%, we shouldn't be doing it. Tracing and
> hooks on tracepoints are really not used by many people. Don't fall
> into Linus's category of "my code is the most important". That's
> especially true for tracing.

tracing was indeed not used that often in the past, but
bpf+tracing completely changed the picture. It's no longer just
debugging. It is the first class citizen that runs 24/7 in production
and its performance and lowest overhead are crucial.
