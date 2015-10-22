From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 13:31:17 +0800
Message-ID: <562874A5.1050307@huawei.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	"Daniel Borkmann" <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445468283-4592-1-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/22 6:58, Alexei Starovoitov wrote:
> Fix safety checks for bpf_perf_event_read():
> - only non-inherited events can be added to perf_event_array map
>    (do this check statically at map insertion time)
> - dynamically check that event is local and !pmu->count
> Otherwise buggy bpf program can cause kernel splat.
>
> Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
> v1->v2: fix compile in case of !CONFIG_PERF_EVENTS
>
> This patch is on top of
> http://patchwork.ozlabs.org/patch/533585/
> to avoid conflicts.
> Even in the worst case the crash is not possible.
> Only warn_on_once, so imo net-next is ok.
>
>   kernel/bpf/arraymap.c |    9 +++++----
>   kernel/events/core.c  |   16 ++++++++++------
>   2 files changed, 15 insertions(+), 10 deletions(-)
>
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index e3cfe46b074f..75529cc94304 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -294,10 +294,11 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
>   	if (IS_ERR(attr))
>   		return (void *)attr;
>   
> -	if (attr->type != PERF_TYPE_RAW &&
> -	    !(attr->type == PERF_TYPE_SOFTWARE &&
> -	      attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
> -	    attr->type != PERF_TYPE_HARDWARE) {
> +	if ((attr->type != PERF_TYPE_RAW &&
> +	     !(attr->type == PERF_TYPE_SOFTWARE &&
> +	       attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
> +	     attr->type != PERF_TYPE_HARDWARE) ||
> +	    attr->inherit) {

This 'if' statement is so complex. What about using a inline function 
instead?

Thank you.
