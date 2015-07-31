From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v5 3/4] bpf: Implement function bpf_perf_event_read() that
 get the selected hardware PMU conuter
Date: Fri, 31 Jul 2015 09:43:45 -0700
Message-ID: <55BBA5C1.1080403@plumgrid.com>
References: <1438343970-11974-1-git-send-email-xiakaixu@huawei.com>
 <1438343970-11974-4-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34894 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124AbbGaQnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 12:43:46 -0400
Received: by pabkd10 with SMTP id kd10so43548293pab.2
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 09:43:46 -0700 (PDT)
In-Reply-To: <1438343970-11974-4-git-send-email-xiakaixu@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/15 4:59 AM, Kaixu Xia wrote:
> +static int check_func_limit(struct bpf_map **mapp, int func_id)
> +{
> +	struct bpf_map *map = *mapp;
> +
> +	if (map && map->map_type == BPF_MAP_TYPE_PROG_ARRAY &&
> +	    func_id != BPF_FUNC_tail_call)
> +		/* prog_array map type needs extra care:
> +		 * only allow to pass it into bpf_tail_call() for now.
> +		 * bpf_map_delete_elem() can be allowed in the future,
> +		 * while bpf_map_update_elem() must only be done via syscall
> +		 */
> +		return -EINVAL;
> +
> +	if (func_id == BPF_FUNC_tail_call &&
> +	    map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
> +		/* don't allow any other map type to be passed into
> +		 * bpf_tail_call()
> +		 */
> +		return -EINVAL;
> +
> +	if (map && map->map_type == BPF_MAP_TYPE_PERF_EVENT_ARRAY &&
> +	    func_id != BPF_FUNC_perf_event_read)
> +		/* perf_event_array map type needs extra care:
> +		 * only allow to pass it into bpf_perf_event_read() for now.
> +		 * bpf_map_update/delete_elem() must only be done via syscall
> +		 */
> +		return -EINVAL;
> +
> +	if (func_id == BPF_FUNC_perf_event_read &&
> +	    map->map_type != BPF_MAP_TYPE_PERF_EVENT_ARRAY)
> +		/* don't allow any other map type to be passed into
> +		 * bpf_perf_event_read()
> +		 */
> +		return -EINVAL;

copy paste of comments is too much.
The whole thing probably can be better generalized with an array
{{BPF_MAP_TYPE_PROG_ARRAY, BPF_FUNC_tail_call},
  {BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_read},
}
and a loop?
