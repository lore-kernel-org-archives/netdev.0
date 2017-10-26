From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/3] bpf: permit multiple bpf attachments for a
 single perf event
Date: Thu, 26 Oct 2017 15:56:41 +0200
Message-ID: <20171026135641.GT3165@worktop.lehotels.local>
References: <20171023175805.2898366-1-yhs@fb.com>
 <20171023175805.2898366-3-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, ast@fb.com, daniel@iogearbox.net,
        kafai@fb.com, netdev@vger.kernel.org, kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:40181 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932234AbdJZOE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 10:04:57 -0400
Content-Disposition: inline
In-Reply-To: <20171023175805.2898366-3-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 10:58:04AM -0700, Yonghong Song wrote:
> This patch enables multiple bpf attachments for a
> kprobe/uprobe/tracepoint single trace event.

This forgets to explain _why_ this is a good thing to do.

> +static DEFINE_MUTEX(bpf_event_mutex);
> +
> +int perf_event_attach_bpf_prog(struct perf_event *event,
> +			   struct bpf_prog *prog)
> +{
> +	struct bpf_prog_array __rcu *old_array;
> +	struct bpf_prog_array *new_array;
> +	int ret;
> +
> +	mutex_lock(&bpf_event_mutex);
> +
> +	if (event->prog)
> +		return -EEXIST;
> +
> +	old_array = rcu_dereference_protected(event->tp_event->prog_array,
> +					      lockdep_is_held(&bpf_event_mutex));

Since all modifications to prog_array are serialized by this one mutex;
you don't need rcu_dereference() here, there are no possible ordering
problems.

> +	ret = bpf_prog_array_copy(old_array, NULL, prog, &new_array);
> +	if (ret < 0)
> +		goto out;
> +
> +	/* set the new array to event->tp_event and set event->prog */
> +	event->prog = prog;
> +	rcu_assign_pointer(event->tp_event->prog_array, new_array);
> +
> +	if (old_array)
> +		bpf_prog_array_free(old_array);
> +
> +out:

Its customary to call that unlock:

> +	mutex_unlock(&bpf_event_mutex);
> +	return ret;
> +}
