From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 2/4] bpf: Add new bpf map type to store the pointer to
 struct perf_event
Date: Tue, 4 Aug 2015 10:43:35 -0700
Message-ID: <55C0F9C7.6070901@plumgrid.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-3-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438678696-88289-3-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/4/15 1:58 AM, Kaixu Xia wrote:
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index 45df657..b1e98ff 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -273,3 +273,60 @@ static int __init register_prog_array_map(void)
>   	return 0;
>   }
>   late_initcall(register_prog_array_map);
> +
> +static void perf_event_array_map_free(struct bpf_map *map)
> +{
> +	bpf_fd_array_map_clear(map);
> +	fd_array_map_free(map);
> +}
> +
> +static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
> +{
> +	struct perf_event *event;
> +	struct perf_event_attr *attr;
> +
> +	event = perf_event_get(fd);
> +	if (IS_ERR(event))
> +		return event;
> +
> +	attr = perf_event_attrs(event);
> +	if (IS_ERR(attr))
> +		return attr;
> +
> +	if (attr->type != PERF_TYPE_RAW &&
> +	    attr->type != PERF_TYPE_HARDWARE) {
> +		perf_event_release_kernel(event);
> +		return ERR_PTR(-EINVAL);
> +	}
> +	return event;
> +}

I'm not sure whether Peter wanted to see the above function to be
in events/core.c or not.
imo it's fine here, since perf_event_attr is an uapi struct.
