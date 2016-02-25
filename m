From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/3] bpf: introduce BPF_MAP_TYPE_STACK_TRACE
Date: Thu, 25 Feb 2016 15:23:28 +0100
Message-ID: <20160225142328.GN6357@twins.programming.kicks-ass.net>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <1455767939-2700534-3-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39731 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760375AbcBYOXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 09:23:38 -0500
Content-Disposition: inline
In-Reply-To: <1455767939-2700534-3-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 07:58:58PM -0800, Alexei Starovoitov wrote:
> +static u64 bpf_get_stackid(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
> +{
> +	struct pt_regs *regs = (struct pt_regs *) (long) r1;
> +	struct bpf_map *map = (struct bpf_map *) (long) r2;
> +	struct bpf_stack_map *smap = container_of(map, struct bpf_stack_map, map);
> +	struct perf_callchain_entry *trace;
> +	struct stack_map_bucket *bucket, *new_bucket, *old_bucket;
> +	u32 max_depth = map->value_size / 8;
> +	/* stack_map_alloc() checks that max_depth <= PERF_MAX_STACK_DEPTH */
> +	u32 init_nr = PERF_MAX_STACK_DEPTH - max_depth;
> +	u32 skip = flags & BPF_F_SKIP_FIELD_MASK;
> +	u32 hash, id, trace_nr, trace_len;
> +	bool user = flags & BPF_F_USER_STACK;
> +	bool kernel = !user;
> +	u64 *ips;
> +
> +	if (unlikely(flags & ~(BPF_F_SKIP_FIELD_MASK | BPF_F_USER_STACK |
> +			       BPF_F_FAST_STACK_CMP | BPF_F_REUSE_STACKID)))
> +		return -EINVAL;
> +
> +	trace = get_perf_callchain(regs, init_nr, kernel, user, false, false);
> +
> +	if (unlikely(!trace))
> +		/* couldn't fetch the stack trace */
> +		return -EFAULT;
> +
> +	/* get_perf_callchain() guarantees that trace->nr >= init_nr
> +	 * and trace-nr <= PERF_MAX_STACK_DEPTH, so trace_nr <= max_depth
> +	 */
> +	trace_nr = trace->nr - init_nr;
> +
> +	if (trace_nr <= skip)
> +		/* skipping more than usable stack trace */
> +		return -EFAULT;
> +
> +	trace_nr -= skip;
> +	trace_len = trace_nr * sizeof(u64);
> +	ips = trace->ip + skip + init_nr;
> +	hash = jhash2((u32 *)ips, trace_len / sizeof(u32), 0);
> +	id = hash & (smap->n_buckets - 1);

Its not at all clear where the corresponding rcu_read_lock() is at.

> +	bucket = rcu_dereference(smap->buckets[id]);
> +
> +	if (bucket && bucket->hash == hash) {
> +		if (flags & BPF_F_FAST_STACK_CMP)
> +			return id;
> +		if (bucket->nr == trace_nr &&
> +		    memcmp(bucket->ip, ips, trace_len) == 0)
> +			return id;
> +	}
> +
> +	/* this call stack is not in the map, try to add it */
> +	if (bucket && !(flags & BPF_F_REUSE_STACKID))
> +		return -EEXIST;
> +
> +	new_bucket = kmalloc(sizeof(struct stack_map_bucket) + map->value_size,
> +			     GFP_ATOMIC | __GFP_NOWARN);
> +	if (unlikely(!new_bucket))
> +		return -ENOMEM;
> +
> +	memcpy(new_bucket->ip, ips, trace_len);
> +	memset(new_bucket->ip + trace_len / 8, 0, map->value_size - trace_len);
> +	new_bucket->hash = hash;
> +	new_bucket->nr = trace_nr;
> +
> +	old_bucket = xchg(&smap->buckets[id], new_bucket);
> +	if (old_bucket)
> +		kfree_rcu(old_bucket, rcu);
> +	return id;
> +}
