From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Fri, 2 Jun 2017 10:06:05 +0200
Message-ID: <20170602080605.h42o7i27vmjrhz25@hirez.programming.kicks-ass.net>
References: <20170602020336.1062853-1-ast@fb.com>
 <20170602020336.1062853-2-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170602020336.1062853-2-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 01, 2017 at 07:03:34PM -0700, Alexei Starovoitov wrote:
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index 172dc8ee0e3b..ab93490d1a00 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -452,39 +452,18 @@ static void bpf_event_entry_free_rcu(struct bpf_event_entry *ee)
>  static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
>  					 struct file *map_file, int fd)
>  {
> -	const struct perf_event_attr *attr;
>  	struct bpf_event_entry *ee;
> -	struct perf_event *event;
>  	struct file *perf_file;
>  
>  	perf_file = perf_event_get(fd);
>  	if (IS_ERR(perf_file))
>  		return perf_file;
>  
> -	event = perf_file->private_data;
> -	ee = ERR_PTR(-EINVAL);
> -
> -	attr = perf_event_attrs(event);
> -	if (IS_ERR(attr) || attr->inherit)
> -		goto err_out;
> -
> -	switch (attr->type) {
> -	case PERF_TYPE_SOFTWARE:
> -		if (attr->config != PERF_COUNT_SW_BPF_OUTPUT)
> -			goto err_out;
> -		/* fall-through */
> -	case PERF_TYPE_RAW:
> -	case PERF_TYPE_HARDWARE:
> -		ee = bpf_event_entry_gen(perf_file, map_file);
> -		if (ee)
> -			return ee;
> -		ee = ERR_PTR(-ENOMEM);
> -		/* fall-through */
> -	default:
> -		break;
> -	}

Would it make sense to call perf_event_read_local() on the events here
in order to weed out the -EOPNOTSUPP  ones?

> +	ee = bpf_event_entry_gen(perf_file, map_file);
> +	if (ee)
> +		return ee;
>  
> -err_out:
> +	ee = ERR_PTR(-ENOMEM);
>  	fput(perf_file);
>  	return ee;
>  }
