From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] tracing/kprobes: expose maxactive for kretprobe in
 kprobe_events
Date: Tue, 28 Mar 2017 11:11:36 -0400
Message-ID: <20170328111136.3c127e17@gandalf.local.home>
References: <1490709142-8856-1-git-send-email-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Ingo Molnar <mingo@redhat.com>,
        Masami Hiramatsu <mhiramat@kernel.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iago@kinvolk.io, michael@kinvolk.io
To: Alban Crequy <alban.crequy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:54356 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751417AbdC1PMC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 11:12:02 -0400
In-Reply-To: <1490709142-8856-1-git-send-email-alban@kinvolk.io>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


"[PATCH v1]" I like your confidence, or lack of, that there isn't going
to be a v2 or v3 ;-)


Masami, what do you think of this?

-- Steve

On Tue, 28 Mar 2017 15:52:22 +0200
Alban Crequy <alban.crequy@gmail.com> wrote:

> When a kretprobe is installed on a kernel function, there is a maximum
> limit of how many calls in parallel it can catch (aka "maxactive"). A
> kernel module could call register_kretprobe() and initialize maxactive
> (see example in samples/kprobes/kretprobe_example.c).
> 
> But that is not exposed to userspace and it is currently not possible to
> choose maxactive when writing to /sys/kernel/debug/tracing/kprobe_events
> 
> The default maxactive can be as low as 1 on single-core with a
> non-preemptive kernel. This is too low and we need to increase it not
> only for recursive functions, but for functions that sleep or resched.
> 
> This patch updates the format of the command that can be written to
> kprobe_events so that maxactive can be optionally specified.
> 
> I need this for a bpf program attached to the kretprobe of
> inet_csk_accept, which can sleep for a long time.
> 
> BugLink: https://github.com/iovisor/bcc/issues/1072
> Signed-off-by: Alban Crequy <alban@kinvolk.io>
> ---
>  Documentation/trace/kprobetrace.txt |  4 +++-
>  kernel/trace/trace_kprobe.c         | 34 +++++++++++++++++++++++++++++-----
>  2 files changed, 32 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/trace/kprobetrace.txt b/Documentation/trace/kprobetrace.txt
> index 41ef9d8..655ca7e 100644
> --- a/Documentation/trace/kprobetrace.txt
> +++ b/Documentation/trace/kprobetrace.txt
> @@ -23,7 +23,7 @@ current_tracer. Instead of that, add probe points via
>  Synopsis of kprobe_events
>  -------------------------
>    p[:[GRP/]EVENT] [MOD:]SYM[+offs]|MEMADDR [FETCHARGS]	: Set a probe
> -  r[:[GRP/]EVENT] [MOD:]SYM[+0] [FETCHARGS]		: Set a return probe
> +  r[MAXACTIVE][:[GRP/]EVENT] [MOD:]SYM[+0] [FETCHARGS]	: Set a return probe
>    -:[GRP/]EVENT						: Clear a probe
>  
>   GRP		: Group name. If omitted, use "kprobes" for it.
> @@ -32,6 +32,8 @@ Synopsis of kprobe_events
>   MOD		: Module name which has given SYM.
>   SYM[+offs]	: Symbol+offset where the probe is inserted.
>   MEMADDR	: Address where the probe is inserted.
> + MAXACTIVE	: Maximum number of instances of the specified function that
> +		  can be probed simultaneously, or 0 for the default.(*)
>  
>   FETCHARGS	: Arguments. Each probe can have up to 128 args.
>    %REG		: Fetch register REG
> diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
> index 5f688cc..807e01c 100644
> --- a/kernel/trace/trace_kprobe.c
> +++ b/kernel/trace/trace_kprobe.c
> @@ -282,6 +282,7 @@ static struct trace_kprobe *alloc_trace_kprobe(const char *group,
>  					     void *addr,
>  					     const char *symbol,
>  					     unsigned long offs,
> +					     int maxactive,
>  					     int nargs, bool is_return)
>  {
>  	struct trace_kprobe *tk;
> @@ -309,6 +310,8 @@ static struct trace_kprobe *alloc_trace_kprobe(const char *group,
>  	else
>  		tk->rp.kp.pre_handler = kprobe_dispatcher;
>  
> +	tk->rp.maxactive = maxactive;
> +
>  	if (!event || !is_good_name(event)) {
>  		ret = -EINVAL;
>  		goto error;
> @@ -598,8 +601,10 @@ static int create_trace_kprobe(int argc, char **argv)
>  {
>  	/*
>  	 * Argument syntax:
> -	 *  - Add kprobe: p[:[GRP/]EVENT] [MOD:]KSYM[+OFFS]|KADDR [FETCHARGS]
> -	 *  - Add kretprobe: r[:[GRP/]EVENT] [MOD:]KSYM[+0] [FETCHARGS]
> +	 *  - Add kprobe:
> +	 *      p[:[GRP/]EVENT] [MOD:]KSYM[+OFFS]|KADDR [FETCHARGS]
> +	 *  - Add kretprobe:
> +	 *      r[MAXACTIVE][:[GRP/]EVENT] [MOD:]KSYM[+0] [FETCHARGS]
>  	 * Fetch args:
>  	 *  $retval	: fetch return value
>  	 *  $stack	: fetch stack address
> @@ -619,6 +624,7 @@ static int create_trace_kprobe(int argc, char **argv)
>  	int i, ret = 0;
>  	bool is_return = false, is_delete = false;
>  	char *symbol = NULL, *event = NULL, *group = NULL;
> +	int maxactive = 0;
>  	char *arg;
>  	unsigned long offset = 0;
>  	void *addr = NULL;
> @@ -637,8 +643,26 @@ static int create_trace_kprobe(int argc, char **argv)
>  		return -EINVAL;
>  	}
>  
> -	if (argv[0][1] == ':') {
> +	if (is_return && isdigit(argv[0][1]) && strchr(&argv[0][1], ':')) {
> +		event = strchr(&argv[0][1], ':') + 1;
> +		event[-1] = '\0';
> +		ret = kstrtouint(&argv[0][1], 0, &maxactive);
> +		if (ret) {
> +			pr_info("Failed to parse maxactive.\n");
> +			return ret;
> +		}
> +		/* kretprobes instances are iterated over via a list. The
> +		 * maximum should stay reasonable.
> +		 */
> +		if (maxactive > 1024) {
> +			pr_info("Maxactive is too big.\n");
> +			return -EINVAL;
> +		}
> +	} else if (argv[0][1] == ':') {
>  		event = &argv[0][2];
> +	}
> +
> +	if (event) {
>  		if (strchr(event, '/')) {
>  			group = event;
>  			event = strchr(group, '/') + 1;
> @@ -718,8 +742,8 @@ static int create_trace_kprobe(int argc, char **argv)
>  				 is_return ? 'r' : 'p', addr);
>  		event = buf;
>  	}
> -	tk = alloc_trace_kprobe(group, event, addr, symbol, offset, argc,
> -			       is_return);
> +	tk = alloc_trace_kprobe(group, event, addr, symbol, offset, maxactive,
> +			       argc, is_return);
>  	if (IS_ERR(tk)) {
>  		pr_info("Failed to allocate trace_probe.(%d)\n",
>  			(int)PTR_ERR(tk));
