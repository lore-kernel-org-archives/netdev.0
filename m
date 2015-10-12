From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH 1/2] perf: Add the flag sample_disable not to output
 data on samples
Date: Mon, 12 Oct 2015 12:20:00 -0700
Message-ID: <561C07E0.6070203@plumgrid.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
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
In-Reply-To: <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/15 2:02 AM, Kaixu Xia wrote:
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index f57d7fe..25e073d 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -39,6 +39,7 @@ struct bpf_map {
>   	u32 max_entries;
>   	const struct bpf_map_ops *ops;
>   	struct work_struct work;
> +	atomic_t perf_sample_disable;
>   };
>
>   struct bpf_map_type_list {
> diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
> index 092a0e8..0606d1d 100644
> --- a/include/linux/perf_event.h
> +++ b/include/linux/perf_event.h
> @@ -483,6 +483,8 @@ struct perf_event {
>   	perf_overflow_handler_t		overflow_handler;
>   	void				*overflow_handler_context;
>
> +	atomic_t			*sample_disable;

this looks fragile and unnecessary.
Why add such field to generic bpf_map and carry its pointer into perf_event?
Single extra field in perf_event would have been enough.
Even better is to avoid adding any fields.
There is already event->state why not to use that?
The proper perf_event_enable/disable are so heavy that another
mechanism needed? cpu_function_call is probably too much to do
from bpf program, but that can be simplified?
Based on the use case from cover letter, sounds like you want
something like soft_disable?
Then extending event->state would make the most sense.
Also consider the case of re-entrant event enable/disable.
So inc/dec of a flag may be needed?
