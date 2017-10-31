From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next] bpf: avoid rcu_dereference inside
 bpf_event_mutex lock region
Date: Tue, 31 Oct 2017 10:33:49 +0100
Message-ID: <20171031093349.ozyzbl33vkdjmyam@hirez.programming.kicks-ass.net>
References: <20171030205022.3980618-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, ast@fb.com, daniel@iogearbox.net,
        kafai@fb.com, netdev@vger.kernel.org, kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50444 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdJaJdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 05:33:55 -0400
Content-Disposition: inline
In-Reply-To: <20171030205022.3980618-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 01:50:22PM -0700, Yonghong Song wrote:
> Could you check whether the below change to remove rcu_dereference_protected
> is what you wanted or not?

Yep that looks fine. Thanks!

> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index b65011d..e7685c5 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -767,20 +767,19 @@ int perf_event_attach_bpf_prog(struct perf_event *event,
>  	mutex_lock(&bpf_event_mutex);
>  
>  	if (event->prog)
> -		goto out;
> +		goto unlock;
>  
> -	old_array = rcu_dereference_protected(event->tp_event->prog_array,
> -					      lockdep_is_held(&bpf_event_mutex));
> +	old_array = event->tp_event->prog_array;
>  	ret = bpf_prog_array_copy(old_array, NULL, prog, &new_array);
>  	if (ret < 0)
> -		goto out;
> +		goto unlock;
>  
>  	/* set the new array to event->tp_event and set event->prog */
>  	event->prog = prog;
>  	rcu_assign_pointer(event->tp_event->prog_array, new_array);
>  	bpf_prog_array_free(old_array);
>  
> -out:
> +unlock:
>  	mutex_unlock(&bpf_event_mutex);
>  	return ret;
>  }
> @@ -794,11 +793,9 @@ void perf_event_detach_bpf_prog(struct perf_event *event)
>  	mutex_lock(&bpf_event_mutex);
>  
>  	if (!event->prog)
> -		goto out;
> -
> -	old_array = rcu_dereference_protected(event->tp_event->prog_array,
> -					      lockdep_is_held(&bpf_event_mutex));
> +		goto unlock;
>  
> +	old_array = event->tp_event->prog_array;
>  	ret = bpf_prog_array_copy(old_array, event->prog, NULL, &new_array);
>  	if (ret < 0) {
>  		bpf_prog_array_delete_safe(old_array, event->prog);
> @@ -810,6 +807,6 @@ void perf_event_detach_bpf_prog(struct perf_event *event)
>  	bpf_prog_put(event->prog);
>  	event->prog = NULL;
>  
> -out:
> +unlock:
>  	mutex_unlock(&bpf_event_mutex);
>  }
> -- 
> 2.9.5
> 
