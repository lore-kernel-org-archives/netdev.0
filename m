From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/4] bpf: add helper bpf_perf_read_counter_time
 for perf event array map
Date: Fri, 1 Sep 2017 22:50:40 +0200
Message-ID: <20170901205040.GU6524@worktop.programming.kicks-ass.net>
References: <20170901165357.465121-1-yhs@fb.com>
 <20170901165357.465121-2-yhs@fb.com>
 <a1905aeb-b49f-d4e8-91ee-a28a92869da1@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yonghong Song <yhs@fb.com>, rostedt@goodmis.org,
        daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:58084 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752338AbdIAUu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 16:50:57 -0400
Content-Disposition: inline
In-Reply-To: <a1905aeb-b49f-d4e8-91ee-a28a92869da1@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 01, 2017 at 01:29:17PM -0700, Alexei Starovoitov wrote:

> >+BPF_CALL_4(bpf_perf_read_counter_time, struct bpf_map *, map, u64, flags,
> >+	struct bpf_perf_counter_time *, buf, u32, size)
> >+{
> >+	struct perf_event *pe;
> >+	u64 now;
> >+	int err;
> >+
> >+	if (unlikely(size != sizeof(struct bpf_perf_counter_time)))
> >+		return -EINVAL;
> >+	err = get_map_perf_counter(map, flags, &buf->counter, &pe);
> >+	if (err)
> >+		return err;
> >+
> >+	calc_timer_values(pe, &now, &buf->time.enabled, &buf->time.running);
> >+	return 0;
> >+}
> 
> Peter,
> I believe we're doing it correctly above.
> It's a copy paste of the same logic as in total_time_enabled/running.
> We cannot expose total_time_enabled/running to bpf, since they are
> different counters. The above two are specific to bpf usage.
> See commit log.

No, the patch is atrocious and the usage is wrong.

Exporting a function called 'calc_timer_values' is a horrible violation
of the namespace.

And its wrong because it should be done in conjunction with
perf_event_read_local(). You cannot afterwards call this because you
don't know if the event was active when you read it and you don't have
temporal guarantees; that is, reading these timestamps long after or
before the read is wrong, and this interface allows it.

So no, sorry this is just fail.
