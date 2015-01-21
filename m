From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] rhashtable:
 rhashtable_remove() must unlink in both tbl and future_tbl
Date: Wed, 21 Jan 2015 16:39:30 +0800
Message-ID: <54BF65C2.9010404@windriver.com>
References: <54BCBA35.2080103@windriver.com>
	<20150119125928.GB7672@casper.infradead.org>
	<54BDC30D.5000606@windriver.com>
	<20150120165826.GK20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>, <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20150120165826.GK20315@casper.infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01/21/2015 12:58 AM, Thomas Graf wrote:
> As removals can occur during resizes, entries may be referred to from
> both tbl and future_tbl when the removal is requested. Therefore
> rhashtable_remove() must unlink the entry in both tables if this is
> the case. The existing code did search both tables but stopped when it
> hit the first match.
> 
> Failing to do so resulted in use after remove.
> 
> Fixes: 97defe1 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Reported-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> 
> Ying: This should fix the panic that was at the end of your TIPC
>       related boot log. I'm still working on the use after free.
> 

Your below changes are reasonable for me. But after I applied the patch,
my reported two issues still happened :( And failure logs are completely
same before.

Regards,
Ying

>  lib/rhashtable.c | 24 +++++++++++++++---------
>  1 file changed, 15 insertions(+), 9 deletions(-)
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index a4449c4..b1aa10e 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -592,6 +592,7 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
>  	struct rhash_head *he;
>  	spinlock_t *lock;
>  	unsigned int hash;
> +	bool ret = false;
>  
>  	rcu_read_lock();
>  	tbl = rht_dereference_rcu(ht->tbl, ht);
> @@ -609,17 +610,16 @@ restart:
>  		}
>  
>  		rcu_assign_pointer(*pprev, obj->next);
> -		atomic_dec(&ht->nelems);
> -
> -		spin_unlock_bh(lock);
> -
> -		rhashtable_wakeup_worker(ht);
> -
> -		rcu_read_unlock();
>  
> -		return true;
> +		ret = true;
> +		break;
>  	}
>  
> +	/* The entry may be linked in either 'tbl', 'future_tbl', or both.
> +	 * 'future_tbl' only exists for a short period of time during
> +	 * resizing. Thus traversing both is fine and the added cost is
> +	 * very rare.
> +	 */
>  	if (tbl != rht_dereference_rcu(ht->future_tbl, ht)) {
>  		spin_unlock_bh(lock);
>  
> @@ -632,9 +632,15 @@ restart:
>  	}
>  
>  	spin_unlock_bh(lock);
> +
> +	if (ret) {
> +		atomic_dec(&ht->nelems);
> +		rhashtable_wakeup_worker(ht);
> +	}
> +
>  	rcu_read_unlock();
>  
> -	return false;
> +	return ret;
>  }
>  EXPORT_SYMBOL_GPL(rhashtable_remove);
>  
> 


------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
