From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2] netfilter: nf_conntrack: use safer way to lock all
 buckets
Date: Thu, 14 Jan 2016 18:25:27 +0100
Message-ID: <20160114172527.GA19589@breakpoint.cc>
References: <1452791036-2161-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452791036-2161-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sasha Levin <sasha.levin@oracle.com> wrote:
> When we need to lock all buckets in the connection hashtable we'd attempt to
> lock 1024 spinlocks, which is way more preemption levels than supported by
> the kernel. Furthermore, this behavior was hidden by checking if lockdep is
> enabled, and if it was - use only 8 buckets(!).
> 
> Fix this by using a global lock and synchronize all buckets on it when we
> need to lock them all. This is pretty heavyweight, but is only done when we
> need to resize the hashtable, and that doesn't happen often enough (or at all).
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 3cb3cb8..4ccf5ad 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -66,6 +66,21 @@ EXPORT_SYMBOL_GPL(nf_conntrack_locks);
>  __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
>  EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
>  
> +spinlock_t nf_conntrack_locks_all_lock;
> +bool nf_conntrack_locks_all;

warning: symbol 'nf_conntrack_locks_all_lock' was not declared. Should it be static?
warning: symbol 'nf_conntrack_locks_all' was not declared.  Should it be static?

> +void nf_conntrack_lock(spinlock_t *lock)

__acquires(lock)

It avoids 'context imbalance in 'nf_conntrack_lock' - wrong count at exit'
sparse error.

Other than that this looks good, thanks.
