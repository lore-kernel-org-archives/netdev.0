From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next 2/8] perf, bpf: allow bpf programs attach to
 tracepoints
Date: Mon, 18 Apr 2016 18:16:31 -0400
Message-ID: <20160418181631.2efee46e@gandalf.local.home>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
	<1459831974-2891931-3-git-send-email-ast@fb.com>
	<20160418162905.220df2f4@gandalf.local.home>
	<571554EB.9010702@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0235.hostedemail.com ([216.40.44.235]:33918 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751343AbcDRWQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:16:34 -0400
In-Reply-To: <571554EB.9010702@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Apr 2016 14:43:07 -0700
Alexei Starovoitov <ast@fb.com> wrote:


> I was worried about this too, but single 'if' and two calls
> (as in commit 98b5c2c65c295) is a better way, since it's faster, cleaner
> and doesn't need to refactor the whole perf_trace_buf_submit() to pass
> extra event_call argument to it.
> perf_trace_buf_submit() is already ugly with 8 arguments!

Right, but I solved that in ftrace by creating an on-stack descriptor
that can be passed by a single parameter. See the "fbuffer" in the
trace_event_raw_event* code.


> Passing more args or creating a struct to pass args only going to
> hurt performance without much reduction in .text size.
> tinyfication folks will disable tracepoints anyway.
> Note that the most common case is bpf returning 0 and not even
> calling perf_trace_buf_submit() which is already slow due
> to so many args passed on stack.
> This stuff is called million times a second, so every instruction
> counts.

Note, that doesn't matter if you are bloating the kernel for the 99.9%
of those that don't use bpf.

Please remember this! Us tracing folks are second class citizens! If
there's a way to speed up tracing by 10%, but in doing so we cause
mainline to be hurt by over 1%, we shouldn't be doing it. Tracing and
hooks on tracepoints are really not used by many people. Don't fall
into Linus's category of "my code is the most important". That's
especially true for tracing.

These macros causes bloat. There's been many complaints about it.
There's a way around it that isn't that bad (with the descriptor), we
should be using it.

-- Steve
