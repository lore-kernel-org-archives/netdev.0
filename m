From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 01/11] netlink: add reference of module in
 netlink_dump_start
Date: Wed, 26 Sep 2012 07:41:03 +0200
Message-ID: <20120926054102.GD4221@secunet.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, pablo@netfilter.org,
	linux-crypto@vger.kernel.org, jengelh@inai.de,
	stephen.hemminger@vyatta.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47105 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752352Ab2IZFlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 01:41:06 -0400
Content-Disposition: inline
In-Reply-To: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 26, 2012 at 12:52:10PM +0800, Gao feng wrote:
> +
>  int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
>  		       const struct nlmsghdr *nlh,
>  		       struct netlink_dump_control *control)
> @@ -1786,6 +1794,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
>  	cb->done = control->done;
>  	cb->nlh = nlh;
>  	cb->data = control->data;
> +	cb->module = control->module;
>  	cb->min_dump_alloc = control->min_dump_alloc;
>  	atomic_inc(&skb->users);
>  	cb->skb = skb;
> @@ -1796,19 +1805,27 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
>  		return -ECONNREFUSED;
>  	}
>  	nlk = nlk_sk(sk);
> -	/* A dump is in progress... */
> +
>  	mutex_lock(nlk->cb_mutex);
> +	/* A dump is in progress... */
>  	if (nlk->cb) {
>  		mutex_unlock(nlk->cb_mutex);
>  		netlink_destroy_callback(cb);
> -		sock_put(sk);
> -		return -EBUSY;
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +	/* add reference of module witch cb->dump belone to */
> +	if (cb->module && !try_module_get(cb->module)) {
> +		mutex_unlock(nlk->cb_mutex);
> +		ret = -EPROTONOSUPPORT;
> +		goto out;

Looks like you leak the allocated netlink_callback here.
You should call netlink_destroy_callback() before you exit.

>  	}
> +
>  	nlk->cb = cb;
>  	mutex_unlock(nlk->cb_mutex);
>  
>  	ret = netlink_dump(sk);
> -
> +out:
>  	sock_put(sk);
>  
>  	if (ret)
> -- 
