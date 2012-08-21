From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] netfilter: replace list_for_each_continue_rcu with
 new interface
Date: Mon, 20 Aug 2012 17:02:55 -0700
Message-ID: <20120821000254.GP2435@linux.vnet.ibm.com>
References: <502CB939.3050008@linux.vnet.ibm.com>
 <502DC9A3.2070703@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <502DC9A3.2070703@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 17, 2012 at 12:33:39PM +0800, Michael Wang wrote:
> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> This patch replaces list_for_each_continue_rcu() with
> list_for_each_entry_continue_rcu() to allow removing
> list_for_each_continue_rcu().
> 
> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  net/netfilter/core.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index e19f365..50225bd 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -131,14 +131,14 @@ unsigned int nf_iterate(struct list_head *head,
>  			int hook_thresh)
>  {
>  	unsigned int verdict;
> +	struct nf_hook_ops *elem = list_entry_rcu(*i,
> +						struct nf_hook_ops, list);
> 
>  	/*
>  	 * The caller must not block between calls to this
>  	 * function because of risk of continuing from deleted element.
>  	 */
> -	list_for_each_continue_rcu(*i, head) {
> -		struct nf_hook_ops *elem = (struct nf_hook_ops *)*i;
> -
> +	list_for_each_entry_continue_rcu(elem, head, list) {
>  		if (hook_thresh > elem->priority)
>  			continue;
> 
> @@ -155,11 +155,14 @@ repeat:
>  				continue;
>  			}
>  #endif
> -			if (verdict != NF_REPEAT)
> +			if (verdict != NF_REPEAT) {
> +				*i = &elem->list;
>  				return verdict;
> +			}
>  			goto repeat;
>  		}
>  	}
> +	*i = &elem->list;
>  	return NF_ACCEPT;
>  }
> 
> -- 
> 1.7.4.1
> 
> 

