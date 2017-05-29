From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Mon, 29 May 2017 11:12:53 +0200
Message-ID: <20170529091253.lopsd33qticsbgii@hirez.programming.kicks-ass.net>
References: <20170526055549.557818-1-ast@fb.com>
 <20170526055549.557818-2-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:36158 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdE2JNX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 05:13:23 -0400
Content-Disposition: inline
In-Reply-To: <20170526055549.557818-2-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 10:55:47PM -0700, Alexei Starovoitov wrote:

> +++ b/kernel/bpf/arraymap.c
> @@ -462,26 +462,22 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
>  
>  	event = perf_file->private_data;
>  	ee = ERR_PTR(-EINVAL);
> +	/* Per-task events are not supported */
> +	if (event->attach_state & PERF_ATTACH_TASK)
> +		goto err_out;
>  
>  	attr = perf_event_attrs(event);
>  	if (IS_ERR(attr) || attr->inherit)
>  		goto err_out;

> +	/* TRACEPOINT and BREAKPOINT not supported in perf_event_read_local */

I cannot find reason for this comment. That is, why would
perf_event_read_local() not support those two types?

> +	if (attr->type == PERF_TYPE_TRACEPOINT ||
> +	    attr->type == PERF_TYPE_BREAKPOINT)
> +		goto err_out;
>  
> +	ee = bpf_event_entry_gen(perf_file, map_file);
> +	if (ee)
> +		return ee;
> +	ee = ERR_PTR(-ENOMEM);
>  
>  err_out:
>  	fput(perf_file);
