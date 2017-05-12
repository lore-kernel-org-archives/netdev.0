From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/6] net/mlx5e: Use a spinlock to synchronize statistics
Date: Fri, 12 May 2017 12:13:54 -0400 (EDT)
Message-ID: <20170512.121354.1583292892374462482.davem@davemloft.net>
References: <20170512115650.11635-1-saeedm@mellanox.com>
        <20170512115650.11635-2-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, galp@mellanox.com, kernel-team@fb.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755960AbdELQN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 12:13:58 -0400
In-Reply-To: <20170512115650.11635-2-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Fri, 12 May 2017 14:56:45 +0300

> From: Gal Pressman <galp@mellanox.com>
> 
> Add a spinlock to prevent races when querying statistics, for example
> querying counters in the middle of a non atomic memcpy() operation in
> mlx5e_update_stats().
> 
> This RW lock should be held when accessing priv->stats, to prevent other
> reads/writes.
> 
> Fixes: 9218b44dcc05 ("net/mlx5e: Statistics handling refactoring")
> Signed-off-by: Gal Pressman <galp@mellanox.com>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: kernel-team@fb.com
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

This is overkill, and that rwlock is going to show up in perf for some
workloads.

Furthermore, two kzalloc()'s for a single state update operation?
That's not reasonable either.

Use a seqlock, which is the primitive for handling this kind of
situation cheaply, and adds no atomics to the read path.

Thank you.
