From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] Fix Kernel Panic in bonding driver debugfs file:
 rlb_hash_table
Date: Wed, 29 Apr 2015 14:51:07 -0400
Message-ID: <20150429185105.GA545@gospo.home.greyhouse.net>
References: <E1YnWel-0004R7-1o@bos-lpqrs.kendall.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pai <vpai@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35941 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbbD2SvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:51:14 -0400
Received: by qku63 with SMTP id 63so20499306qku.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 11:51:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E1YnWel-0004R7-1o@bos-lpqrs.kendall.corp.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 02:24:23PM -0400, Pai wrote:
> This patch fixes a Kernel Panic in bonding driver debugfs file: rlb_hash_table.
> 
> $> modprobe bonding mode=6
> $> cat /sys/kernel/debug/bonding/bond0/rlb_hash_table
> 
> This will crash the kernel. The struct alb_bond_info is initialized only when
> the bonding interface is initialized (ip link set bond0 up) and not at the time
> it is allocated. If we try to read the table before that, it'll result in a 
> kernel panic.

Nice catch!

> 
> The patch applies against both net and net-next
> 
> Signed-off-by: Vishwanath Pai <vpai@akamai.com>

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

>  
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 089a402..806892a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4510,6 +4510,8 @@ unsigned int bond_get_num_tx_queues(void)
>  int bond_create(struct net *net, const char *name)
>  {
>  	struct net_device *bond_dev;
> +	struct bonding *bond;
> +	struct alb_bond_info *bond_info;
>  	int res;
>  
>  	rtnl_lock();
> @@ -4523,6 +4525,14 @@ int bond_create(struct net *net, const char *name)
>  		return -ENOMEM;
>  	}
>  
> +	/*
> +	 * Initialize rx_hashtbl_used_head to RLB_NULL_INDEX.
> +	 * It is set to 0 by default which is wrong.
> +	 */
> +	bond = netdev_priv(bond_dev);
> +	bond_info = &(BOND_ALB_INFO(bond));
> +	bond_info->rx_hashtbl_used_head = RLB_NULL_INDEX;
> +
>  	dev_net_set(bond_dev, net);
>  	bond_dev->rtnl_link_ops = &bond_link_ops;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
