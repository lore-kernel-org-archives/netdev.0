From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Fri, 23 Oct 2015 14:03:35 +0200
Message-ID: <20151023120335.GZ17308@twins.programming.kicks-ass.net>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50005 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbbJWMDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 08:03:53 -0400
Content-Disposition: inline
In-Reply-To: <1445559014-4667-1-git-send-email-ast@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 05:10:14PM -0700, Alexei Starovoitov wrote:
> +++ b/kernel/trace/bpf_trace.c
> @@ -199,6 +199,11 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
>  	if (!event)
>  		return -ENOENT;
>  
> +	/* make sure event is local and doesn't have pmu::count */
> +	if (event->oncpu != smp_processor_id() ||
> +	    event->pmu->count)
> +		return -EINVAL;
> +
>  	/*
>  	 * we don't know if the function is run successfully by the
>  	 * return value. It can be judged in other places, such as

I might want to go turn that into a helper function to keep !perf code
from poking around in the event itself, but its ok for now I suppose.

> @@ -207,7 +212,7 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
>  	return perf_event_read_local(event);
>  }

So the bpf_perf_event_read() returns the count value, does this not also
mean that returning -EINVAL here is also 'wrong'?

I mean, sure an actual count value that high is unlikely, but its still
a broken interface.
