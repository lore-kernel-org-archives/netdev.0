From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next v3 2/3] bpf: permit multiple bpf attachments
 for a single perf event
Date: Wed, 25 Oct 2017 11:32:49 +0200
Message-ID: <20171025113249.3283aebc@redhat.com>
References: <20171024065309.2401893-1-yhs@fb.com>
        <20171024065309.2401893-3-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: brouer@redhat.com, <peterz@infradead.org>, <rostedt@goodmis.org>,
        <ast@fb.com>, <daniel@iogearbox.net>, <kafai@fb.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62426 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932300AbdJYJc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 05:32:58 -0400
In-Reply-To: <20171024065309.2401893-3-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 23 Oct 2017 23:53:08 -0700 Yonghong Song <yhs@fb.com> wrote:

> This patch enables multiple bpf attachments for a
> kprobe/uprobe/tracepoint single trace event.

Thanks for working on this, I've hit this issue, where another program
BPF-attach to a tracepoint, and the existing userspace-side prog
doesn't notice.  (Specifically in samples/bpf/xdp_monitor_user.c)

Should my issue be gone now?


> Each trace_event keeps a list of attached perf events.
> When an event happens, all attached bpf programs will
> be executed based on the order of attachment.

Can I somehow view/list the attached bpf programs from userspace?

[...]

You didn't describe the expected semantics of bpf-programs return codes.
>From below code it looks like, that if single program in the list/array
returns 0 then the collective return code is also 0 (is that correct?).

Where 0 means don't store the event into the perf record ring-buffer.

Is this a good semantics?

I do use the return 0 trick to save cycles (in samples/bpf/xdp_monitor_kern.c).
But when someone attach a new tracepoint, e.g. via perf record -e, then
they might be surprised that they don't receive any events, when my
xdp_monitor happen to be running at the same time...?


> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 1e334b2..172be7f 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -273,18 +273,38 @@ int bpf_prog_array_length(struct bpf_prog_array __rcu *progs);
>  int bpf_prog_array_copy_to_user(struct bpf_prog_array __rcu *progs,
>  				__u32 __user *prog_ids, u32 cnt);
>  
> -#define BPF_PROG_RUN_ARRAY(array, ctx, func)		\
> +void bpf_prog_array_delete_safe(struct bpf_prog_array __rcu *progs,
> +				struct bpf_prog *old_prog);
> +int bpf_prog_array_copy(struct bpf_prog_array __rcu *old_array,
> +			struct bpf_prog *exclude_prog,
> +			struct bpf_prog *include_prog,
> +			struct bpf_prog_array **new_array);
> +
> +#define __BPF_PROG_RUN_ARRAY(array, ctx, func, check_non_null)	\
>  	({						\
> -		struct bpf_prog **_prog;		\
> +		struct bpf_prog **_prog, *__prog;	\
> +		struct bpf_prog_array *_array;		\
>  		u32 _ret = 1;				\
>  		rcu_read_lock();			\
> -		_prog = rcu_dereference(array)->progs;	\
> -		for (; *_prog; _prog++)			\
> -			_ret &= func(*_prog, ctx);	\
> +		_array = rcu_dereference(array);	\
> +		if (unlikely(check_non_null && !_array))\
> +			goto _out;			\
> +		_prog = _array->progs;			\
> +		while ((__prog = READ_ONCE(*_prog))) {	\
> +			_ret &= func(__prog, ctx);	\
> +			_prog++;			\
> +		}					\
> +_out:							\
>  		rcu_read_unlock();			\
>  		_ret;					\
>  	 })
>  
> +#define BPF_PROG_RUN_ARRAY(array, ctx, func)		\
> +	__BPF_PROG_RUN_ARRAY(array, ctx, func, false)
> +
> +#define BPF_PROG_RUN_ARRAY_CHECK(array, ctx, func)	\
> +	__BPF_PROG_RUN_ARRAY(array, ctx, func, true)
> +
>  #ifdef CONFIG_BPF_SYSCALL
>  DECLARE_PER_CPU(int, bpf_prog_active);

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
