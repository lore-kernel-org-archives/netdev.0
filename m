From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rhashtable: avoid large lock-array allocations
Date: Sun, 14 Aug 2016 21:13:18 -0700 (PDT)
Message-ID: <20160814.211318.898694274813674125.davem@davemloft.net>
References: <1470968023-14338-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbcHOENX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 00:13:23 -0400
In-Reply-To: <1470968023-14338-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 12 Aug 2016 04:13:43 +0200

> Sander reports following splat after netfilter nat bysrc table got
> converted to rhashtable:
> 
> swapper/0: page allocation failure: order:3, mode:0x2084020(GFP_ATOMIC|__GFP_COMP)
>  CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.8.0-rc1 [..]
>  [<ffffffff811633ed>] warn_alloc_failed+0xdd/0x140
>  [<ffffffff811638b1>] __alloc_pages_nodemask+0x3e1/0xcf0
>  [<ffffffff811a72ed>] alloc_pages_current+0x8d/0x110
>  [<ffffffff8117cb7f>] kmalloc_order+0x1f/0x70
>  [<ffffffff811aec19>] __kmalloc+0x129/0x140
>  [<ffffffff8146d561>] bucket_table_alloc+0xc1/0x1d0
>  [<ffffffff8146da1d>] rhashtable_insert_rehash+0x5d/0xe0
>  [<ffffffff819fcfff>] nf_nat_setup_info+0x2ef/0x400
> 
> The failure happens when allocating the spinlock array.
> Even with GFP_KERNEL its unlikely for such a large allocation
> to succeed.
> 
> Thomas Graf pointed me at inet_ehash_locks_alloc(), so in addition
> to adding NOWARN for atomic allocations this also makes the bucket-array
> sizing more conservative.
> 
> In commit 095dc8e0c3686 ("tcp: fix/cleanup inet_ehash_locks_alloc()"),
> Eric Dumazet says: "Budget 2 cache lines per cpu worth of 'spinlocks'".
> IOW, consider size needed by a single spinlock when determining
> number of locks per cpu.
> 
> Currently, rhashtable just allocates 128 locks per cpu which gives
> factor of 4 more than what inet hashtable uses with same number of
> cpus.
> 
> For LOCKDEP, we now allocate a lot less locks than before (1 per cpu on
> my test box) so we no longer need to pretend we only have two cpus.
> 
> Some sizes (64 byte L1 cache, 4 byte per spinlock, numbers in bytes):
> 
> cpus:    1   2   4    8   16    32   64
> old:    1k  1k  4k   8k  16k   16k  16k
> new:   128 256 512   1k   2k    4k   8k
> 
> With 72-byte spinlock (LOCKDEP):
> cpus :   1   2   4    8   16    32   64
> old:    9k 18k 18k  18k  18k   18k  18k
> new:    72 144 288  575  ~1k ~2.3k  ~4k
> 
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Suggested-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
