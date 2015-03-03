From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC 4/4] cxgb4: drop __GFP_NOFAIL allocation
Date: Tue, 3 Mar 2015 21:22:22 +0900
Message-ID: <201503032122.HJD73998.OFFMQFLHtJOSOV@I-love.SAKURA.ne.jp>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
	<1425304483-7987-5-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org,
	rientjes@google.com, david@fromorbit.com, tytso@mit.edu,
	mgorman@suse.de, sparclinux@vger.kernel.org, vipul@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mhocko@suse.cz, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425304483-7987-5-git-send-email-mhocko@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Hocko wrote:
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index ccf3436024bc..f351920fc293 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -1220,6 +1220,10 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
>  	struct fw_filter_wr *fwr;
>  	unsigned int ftid;
>  
> +	skb = alloc_skb(sizeof(*fwr), GFP_KERNEL);
> +	if (!skb)
> +		return -ENOMEM;
> +
>  	/* If the new filter requires loopback Destination MAC and/or VLAN
>  	 * rewriting then we need to allocate a Layer 2 Table (L2T) entry for
>  	 * the filter.
> @@ -1227,19 +1231,21 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
>  	if (f->fs.newdmac || f->fs.newvlan) {
>  		/* allocate L2T entry for new filter */
>  		f->l2t = t4_l2t_alloc_switching(adapter->l2t);
> -		if (f->l2t == NULL)
> +		if (f->l2t == NULL) {
> +			kfree(skb);

I think we need to use kfree_skb() than kfree() for memory allocated by alloc_skb().

>  			return -EAGAIN;
> +		}
>  		if (t4_l2t_set_switching(adapter, f->l2t, f->fs.vlan,
>  					f->fs.eport, f->fs.dmac)) {
>  			cxgb4_l2t_release(f->l2t);
>  			f->l2t = NULL;
> +			kfree(skb);

Ditto.

>  			return -ENOMEM;
>  		}
>  	}
>  
>  	ftid = adapter->tids.ftid_base + fidx;
>  
> -	skb = alloc_skb(sizeof(*fwr), GFP_KERNEL | __GFP_NOFAIL);
>  	fwr = (struct fw_filter_wr *)__skb_put(skb, sizeof(*fwr));
>  	memset(fwr, 0, sizeof(*fwr));
>  
