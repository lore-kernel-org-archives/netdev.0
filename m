From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2] netfilter: nf_conntrack: use safer way to lock all
 buckets
Date: Fri, 15 Jan 2016 08:06:53 +0100
Message-ID: <20160115080653.137e0ad6@redhat.com>
References: <1452791036-2161-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452791036-2161-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Jan 2016 12:03:56 -0500
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
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

[...]
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

You forgot to mark these static and __read_mostly as Florian pointed out...

After that you can add my:
 Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
