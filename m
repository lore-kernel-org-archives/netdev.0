From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: use safer way to lock all
 buckets
Date: Sun, 10 Jan 2016 02:06:37 +0100
Message-ID: <20160110010637.GA22861@breakpoint.cc>
References: <1451960746-28915-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1451960746-28915-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sasha Levin <sasha.levin@oracle.com> wrote:
> When we need to lock all buckets in the connection hashtable we'd attempt to
> lock 1024 spinlocks, which is way more preemption levels than supported by
> the kernel.

You're right.

> Fix this by using a global lock and synchronize all buckets on it when we
> need to lock them all. This is pretty heavyweight, but is only done when we
> need to resize the hashtable, and that doesn't happen often enough (or at all).

> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 3cb3cb8..3c008ce 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -66,6 +66,32 @@ EXPORT_SYMBOL_GPL(nf_conntrack_locks);
>  __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
>  EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
>  
> +spinlock_t nf_conntrack_locks_all_lock;
> +bool nf_conntrack_locks_all;

Seems both of these can be static and __read_mostly too --
as you already note resizing virtually never happens.

Otherwise:
Reviewed-by: Florian Westphal <fw@strlen.de>
