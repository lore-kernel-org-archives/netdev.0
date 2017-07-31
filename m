From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] net ipv6: convert fib6_table rwlock to a percpu
 lock
Date: Mon, 31 Jul 2017 11:30:53 -0700
Message-ID: <1501525853.1876.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1a5ad2f0585aa66496b27e123d1c38b75552df4c.1501520674.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>, Wei Wang <weiwan@google.com>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34631 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdGaSa5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 14:30:57 -0400
Received: by mail-wm0-f68.google.com with SMTP id x64so12676566wmg.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 11:30:56 -0700 (PDT)
In-Reply-To: <1a5ad2f0585aa66496b27e123d1c38b75552df4c.1501520674.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-31 at 10:18 -0700, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> In a syn flooding test, the fib6_table rwlock is a significant
> bottleneck. While converting the rwlock to rcu sounds straighforward,
> but is very challenging if it's possible. A percpu spinlock is quite
> trival for this problem since updating the routing table is a rare
> event. In my test, the server receives around 1.5 Mpps in syn flooding
> test without the patch in a dual sockets and 56-CPU system. With the
> patch, the server receives around 3.8Mpps, and perf report doesn't show
> the locking issue.
> 

> +static inline void fib6_table_write_lock_bh(struct fib6_table *table)
> +{
> +	int i;
> +
> +	spin_lock_bh(per_cpu_ptr(table->percpu_tb6_lock, 0));
> +	for_each_possible_cpu(i) {
> +		if (i == 0)
> +			continue;
> +		spin_lock_nest_lock(per_cpu_ptr(table->percpu_tb6_lock, i),
> +			per_cpu_ptr(table->percpu_tb6_lock, 0));
> +	}
> +}

Your code assumes that cpu 0 is valid.

I would rather not hard code this knowledge.

Also this is not clear why you need the nested thing.
