From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Wed, 25 Jan 2017 12:45:31 -0500 (EST)
Message-ID: <20170125.124531.1891159189679013370.davem@davemloft.net>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdAYRpc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 12:45:32 -0500
In-Reply-To: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 24 Jan 2017 08:11:49 -0800

> @@ -2685,21 +2685,22 @@ static inline int dev_parse_header(const struct sk_buff *skb,
>  }
>  
>  /* ll_header must have at least hard_header_len allocated */
> -static inline bool dev_validate_header(const struct net_device *dev,
> +static inline int dev_validate_header(const struct net_device *dev,
>  				       char *ll_header, int len)
>  {
>  	if (likely(len >= dev->hard_header_len))
> -		return true;
> +		return len;
>  
>  	if (capable(CAP_SYS_RAWIO)) {
>  		memset(ll_header + len, 0, dev->hard_header_len - len);
> -		return true;
> +		return dev->hard_header_len;
>  	}
>  
>  	if (dev->header_ops && dev->header_ops->validate)
> -		return dev->header_ops->validate(ll_header, len);
> +		if (!dev->header_ops->validate(ll_header, len))
> +			return -1;
>  
> -	return false;
> +	return dev->hard_header_len;
>  }
>  
>  typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);

This mostly looks good.  But I'm not so sure you handle the variable length header
case properly.  That's why we have the header_ops->validate() callback, to accomodate
that.

In the variable length case, you'll end up having to return something other than
just hard_header_len.  Probably you'll need to make header_ops->validate() return
that length.
