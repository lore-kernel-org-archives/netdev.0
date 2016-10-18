From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] conntrack: perform a full scan in gc
Date: Tue, 18 Oct 2016 10:47:18 +0200
Message-ID: <20161018084718.GB29405@breakpoint.cc>
References: <20161014105327.GA8655@salvia>
 <1476779435-30503-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, fw@strlen.de, davem@davemloft.net,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476779435-30503-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> After commit b87a2f9199ea ("netfilter: conntrack: add gc worker to remove
> timed-out entries"), netlink conntrack deletion events may be sent with a
> huge delay (5 minutes).
> 
> There is two ways to evict conntrack:
>  - during a conntrack lookup;
>  - during a conntrack dump.
> Let's do a full scan of conntrack entries after a period of inactivity
> (no conntrack lookup).
> 
> CC: Florian Westphal <fw@strlen.de>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> Here is another proposal to try to fix the problem.
> Comments are welcomed,
> Nicolas

Hmm, I don't think its good idea in practice.
If goal is to avoid starving arbitrary 'dead' ct for too long,
then simple ping will defeat the logic here, because...

>  net/netfilter/nf_conntrack_core.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index ba6a1d421222..3dbb27bd9582 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -87,6 +87,7 @@ static __read_mostly bool nf_conntrack_locks_all;
>  #define GC_MAX_BUCKETS		8192u
>  #define GC_INTERVAL		(5 * HZ)
>  #define GC_MAX_EVICTS		256u
> +static bool gc_full_scan = true;
>  
>  static struct conntrack_gc_work conntrack_gc_work;
>  
> @@ -511,6 +512,7 @@ ____nf_conntrack_find(struct net *net, const struct nf_conntrack_zone *zone,
>  	unsigned int bucket, hsize;
>  
>  begin:
> +	gc_full_scan = false;

... we do periodic lookup (but always in same slot), so no full scan is
triggered.

If you think its useful, consider sending patch that rescheds worker
instantly in case budget expired, otherwise I will do this later this
week.

[ I am aware doing instant restart might be too late, but at least we
  would then reap more entries once we stumble upon large number of
  expired ones ].

