From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] igmp: hash a hash table to speedup
 ip_check_mc_rcu()
Date: Sat, 8 Jun 2013 04:39:29 +0000 (UTC)
Message-ID: <kouci0$2eu$1@ger.gmane.org>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
 <1370455997.24311.290.camel@edumazet-glaptop>
 <20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
 <1370465535.24311.304.camel@edumazet-glaptop>
 <1370565301.24311.396.camel@edumazet-glaptop>
 <20130607144833.GB2995@sbohrermbp13-local.rgmadvisors.com>
 <1370620137.24311.433.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44120 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab3FHEjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jun 2013 00:39:45 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UlAwK-0004Xi-Lr
	for netdev@vger.kernel.org; Sat, 08 Jun 2013 06:39:44 +0200
Received: from 112.116.154.121 ([112.116.154.121])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 08 Jun 2013 06:39:44 +0200
Received: from xiyou.wangcong by 112.116.154.121 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 08 Jun 2013 06:39:44 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Jun 2013 at 15:48 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> diff --git a/include/linux/igmp.h b/include/linux/igmp.h
> index 7f2bf15..e3362b5 100644
> --- a/include/linux/igmp.h
> +++ b/include/linux/igmp.h
> @@ -84,6 +84,7 @@ struct ip_mc_list {
>  		struct ip_mc_list *next;
>  		struct ip_mc_list __rcu *next_rcu;
>  	};
> +	struct ip_mc_list __rcu *next_hash;


Why not put this into the above union?


> +static void ip_mc_hash_add(struct in_device *in_dev,
> +			   struct ip_mc_list *im)
> +{
> +	struct ip_mc_list __rcu **mc_hash;
> +	u32 hash;
> +
> +	mc_hash = rtnl_dereference(in_dev->mc_hash);
> +	if (mc_hash) {
> +		hash = ip_mc_hash(im);
> +		im->next_hash = rtnl_dereference(mc_hash[hash]);
> +		rcu_assign_pointer(mc_hash[hash], im);
> +		return;
> +	}
> +
> +	/* do not use a hash table for small number of items */
> +	if (in_dev->mc_count < 4)
> +		return;


Can this check be moved to the beginning of this function?


> +
> +	mc_hash = kzalloc(sizeof(struct ip_mc_list *) << MC_HASH_SZ_LOG,
> +			  GFP_KERNEL);
> +	if (!mc_hash)
> +		return;
> +
> +	for_each_pmc_rtnl(in_dev, im) {
> +		hash = ip_mc_hash(im);
> +		im->next_hash = rtnl_dereference(mc_hash[hash]);
> +		RCU_INIT_POINTER(mc_hash[hash], im);
> +	}
> +
> +	rcu_assign_pointer(in_dev->mc_hash, mc_hash);
> +}
> +

Thanks!
