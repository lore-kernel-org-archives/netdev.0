From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/2] bpf: add support for sys_{enter|exit}_*
 tracepoints
Date: Wed, 2 Aug 2017 14:07:33 +0200
Message-ID: <20170802120733.6vm6ylzgghjdukwf@hirez.programming.kicks-ass.net>
References: <20170802063005.3220186-1-yhs@fb.com>
 <20170802063005.3220186-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:46614 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753102AbdHBMHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 08:07:37 -0400
Content-Disposition: inline
In-Reply-To: <20170802063005.3220186-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 01, 2017 at 11:30:04PM -0700, Yonghong Song wrote:
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 426c2ff..623c977 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -8050,7 +8050,7 @@ static void perf_event_free_bpf_handler(struct perf_event *event)
>  
>  static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  {
> -	bool is_kprobe, is_tracepoint;
> +	bool is_cap_any, is_kprobe, is_tracepoint;
>  	struct bpf_prog *prog;
>  
>  	if (event->attr.type != PERF_TYPE_TRACEPOINT)
> @@ -8059,9 +8059,11 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  	if (event->tp_event->prog)
>  		return -EEXIST;
>  
> +	/* currently, CAP_ANY only for sys_enter_* and sys_exit_* tracepoints */
> +	is_cap_any = event->tp_event->flags & TRACE_EVENT_FL_CAP_ANY;
>  	is_kprobe = event->tp_event->flags & TRACE_EVENT_FL_UKPROBE;
>  	is_tracepoint = event->tp_event->flags & TRACE_EVENT_FL_TRACEPOINT;
> -	if (!is_kprobe && !is_tracepoint)
> +	if (!is_cap_any && !is_kprobe && !is_tracepoint)
>  		/* bpf programs can only be attached to u/kprobe or tracepoint */
>  		return -EINVAL;
>  
> @@ -8070,7 +8072,8 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
>  		return PTR_ERR(prog);
>  
>  	if ((is_kprobe && prog->type != BPF_PROG_TYPE_KPROBE) ||
> -	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
> +	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT) ||
> +	    (is_cap_any && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
>  		/* valid fd, but invalid bpf program type */
>  		bpf_prog_put(prog);
>  		return -EINVAL;

This looks wrong. FL_CAP_ANY is a privilege thing, not something that
identifies syscall hooks (it just so happens only those now have the bit
set, but that's an accident more than anything else).
