From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/2] mpls: packet stats
Date: Sat, 6 Feb 2016 11:58:43 +0100
Message-ID: <20160206105843.GA27535@electric-eye.fr.zoreil.com>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
 <1454700472-13543-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34762 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbcBFK6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 05:58:53 -0500
Content-Disposition: inline
In-Reply-To: <1454700472-13543-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> :
[...]
> diff --git a/net/mpls/Makefile b/net/mpls/Makefile
> index 9ca923625016..6fdd61b9eae3 100644
> --- a/net/mpls/Makefile
> +++ b/net/mpls/Makefile
[...]
> @@ -98,6 +94,29 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
>  }
>  EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
>  
> +void mpls_stats_inc_outucastpkts(struct net_device *dev,
> +				 const struct sk_buff *skb)
> +{
> +	struct mpls_dev *mdev;
> +	struct inet6_dev *in6dev;

Nit: the scope can be reduced for both variables.

> +
> +	if (skb->protocol == htons(ETH_P_MPLS_UC)) {
> +		mdev = mpls_dev_get(dev);
> +		if (mdev)
> +			MPLS_INC_STATS_LEN(mdev, skb->len,
> +					   MPLS_IFSTATS_MIB_OUTUCASTPKTS,
> +					   MPLS_IFSTATS_MIB_OUTOCTETS);
> +	} else if (skb->protocol == htons(ETH_P_IP)) {
> +		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
> +	} else if (skb->protocol == htons(ETH_P_IPV6)) {
> +		in6dev = __in6_dev_get(dev);
> +		if (in6dev)
> +			IP6_UPD_PO_STATS(dev_net(dev), in6dev,
> +					 IPSTATS_MIB_OUT, skb->len);
> +	}
> +}
[...]
> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
> index 732a5c17e986..b39770ff2307 100644
> --- a/net/mpls/internal.h
> +++ b/net/mpls/internal.h
[...]
> +#define MPLS_INC_STATS(mdev, field)					\
> +	do {								\
> +		__typeof__(*(mdev)->stats) *ptr =			\
> +			raw_cpu_ptr((mdev)->stats);			\
> +		local_bh_disable();					\
> +		u64_stats_update_begin(&ptr->syncp);			\
> +		ptr->mib[field]++;					\
> +		u64_stats_update_end(&ptr->syncp);			\
> +		local_bh_enable();					\
> +	} while (0)

I don't get the point of the local_bh_{disable / enable}.

Which kind of locally enabled bh code section do you anticipate these
helpers to run under ?

-- 
Ueimor
