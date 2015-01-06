From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/5] rhashtable: introduce
 rhashtable_wakeup_worker helper function
Date: Tue, 6 Jan 2015 09:29:48 +0000
Message-ID: <20150106092948.GB12468@casper.infradead.org>
References: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
 <1420529003-22244-3-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52948 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbbAFJ3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 04:29:50 -0500
Content-Disposition: inline
In-Reply-To: <1420529003-22244-3-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/15 at 03:23pm, Ying Xue wrote:
> Introduce rhashtable_wakeup_worker() helper function to reduce
> duplicated code where to wake up worker.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> ---
>  lib/rhashtable.c |   20 +++++++++++++-------
>  1 file changed, 13 insertions(+), 7 deletions(-)
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index f2fdd7a..6eda22f 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -492,6 +492,17 @@ static void rht_deferred_worker(struct work_struct *work)
>  	mutex_unlock(&ht->mutex);
>  }
>  
> +static void rhashtable_wakeup_worker(struct rhashtable *ht)
> +{
> +	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
> +	struct bucket_table *new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
> +
> +	if (ht->tbl != ht->future_tbl &&

I just noticed that this is a bug in the original code. It should be

	if (ht->tbl == ht->future_tbl &&

Do you want to fix this in this series?


> +	    ((ht->p.grow_decision && ht->p.grow_decision(ht, new_tbl->size)) ||
> +	    (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))))

Indent to inner brakcet

> +		schedule_delayed_work(&ht->run_work, 0);
> +}
> +
>  /**
>   * rhashtable_insert - insert object into hash hash table
>   * @ht:		hash table
> @@ -533,9 +544,7 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
>  	atomic_inc(&ht->nelems);
>  
>  	/* Only grow the table if no resizing is currently in progress. */

This comment should be moved to the function as well.
