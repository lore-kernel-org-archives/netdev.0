From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 5/6] bpf: hash: avoid to call kmalloc() in eBPF prog
Date: Tue, 15 Dec 2015 15:10:58 -0800
Message-ID: <20151215231057.GB67370@ast-mbp.thefacebook.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
 <1450178464-27721-6-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450178464-27721-6-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2015 at 07:21:03PM +0800, Ming Lei wrote:
> kmalloc() is often a bit time-consuming, also
> one atomic counter has to be used to track the total
> allocated elements, which is also not good.
> 
> This patch pre-allocates element pool in htab_map_alloc(),
> then use percpu_ida to allocate one slot from the pool,
> then the runtime allocation/freeing cost can be decreased.
> 
> From my test, at least 10% fio throughput is improved in block
> I/O test when tools/biolatency of bcc(iovisor) is running.
> 
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

Looks very intersting as well.
Approach looks good.
If you can make a common allocation helper for this map and
for blk-mq would be even better.

> -	htab->elem_size = sizeof(struct htab_elem) +
> -			  round_up(htab->map.key_size, 8) +
> -			  htab->map.value_size;
> +	htab->elem_size = round_up(sizeof(struct htab_elem) +
> +				   round_up(htab->map.key_size, 8) +
> +				   htab->map.value_size,
> +				   cache_line_size());

this rounding to cache line is great for performance, but it's extra
memory upfront which may not be needed. The per-allocation is a classic
performance vs memory trade-off. In other cases it may hurt.
So could you change the patch to do pre-allocation only when
requested by user space via extra flag for hash map or via
new BPF_MAP_TYPE_HASH_PREALLOC type? Not sure yet whether flag or
new type is better. I guess implementation will dictate.

PS
Glad that you found iovisor/tools/biolatency useful.
It's indeed pretty helpful to analyze real-time block io latency.
