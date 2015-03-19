From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v7 tip 4/8] tracing: allow BPF programs to call bpf_trace_printk()
Date: Thu, 19 Mar 2015 08:51:29 -0700
Message-ID: <550AF081.1050104@plumgrid.com>
References: <1426542584-9406-1-git-send-email-ast@plumgrid.com>	<1426542584-9406-5-git-send-email-ast@plumgrid.com> <20150319112931.14f3569b@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150319112931.14f3569b@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/19/15 8:29 AM, Steven Rostedt wrote:
>> +	/* check format string for allowed specifiers */
>> +	for (i = 0; i < fmt_size; i++)
>
> Even though there's only a single "if" statement after the "for", it is
> usually considered proper to add the brackets if the next line is
> complex (more than one line). Which it is in this case.

ok.

>> +			} else if (fmt[i] == 'p') {
>> +				mod_l[fmt_cnt] = true;
>> +				fmt_cnt++;
>
> So you also allow pointer conversions like "%pS" and "%pF"?

good catch. it's a bug. We shouldn't allow things like pV, pD, etc
Something like pK and pS may be ok, but pF is not because of arch
dependencies. So instead of analyzing all possibilities. I'll allow
%p only. bpf_trace_printk is debug only anyway.

>> +	return __trace_printk(1/* fake ip will not be printed */, fmt,
>> +			      mod_l[0] ? r3 : (u32) r3,
>> +			      mod_l[1] ? r4 : (u32) r4,
>> +			      mod_l[2] ? r5 : (u32) r5);
>
> Does the above work on 32 bit machines? as "%ld" would be (u32), but
> here you are passing in u64.

another great catch. it wouldn't crash, but would print junk. will fix.
