From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 2/5] Fix deadlock in bonding driver resulting from internal
 locking when using netpoll
Date: Wed, 13 Oct 2010 10:44:55 +0800
Message-ID: <4CB51D27.8030703@redhat.com>
References: <1286920552-2173-1-git-send-email-nhorman@tuxdriver.com> <1286920552-2173-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, davem@davemloft.net, andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919Ab0JMCkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 22:40:37 -0400
In-Reply-To: <1286920552-2173-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/10 05:55, nhorman@tuxdriver.com wrote:
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -76,6 +76,7 @@
>   #include<linux/if_vlan.h>
>   #include<linux/if_bonding.h>
>   #include<linux/jiffies.h>
> +#include<linux/preempt.h>
>   #include<net/route.h>
>   #include<net/net_namespace.h>
>   #include<net/netns/generic.h>
> @@ -169,6 +170,35 @@ MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link
>
>   /*----------------------------- Global variables ----------------------------*/
>
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static cpumask_var_t netpoll_block_tx;
> +
> +static inline void block_netpoll_tx(void
> +{
> +	preempt_disable();
> +	BUG_ON(cpumask_test_and_set_cpu(smp_processor_id(),
> +					netpoll_block_tx));
> +}
> +
> +static inline void unblock_netpoll_tx(void)
> +{
> +	BUG_ON(!cpumask_test_and_clear_cpu(smp_processor_id(),
> +					  netpoll_block_tx));
> +	preempt_enable();
> +}
> +
> +static inline int is_netpoll_tx_blocked(struct net_device *dev)
> +{
> +	if (unlikely(dev->priv_flags&  IFF_IN_NETPOLL))
> +		return cpumask_test_cpu(smp_processor_id(), netpoll_block_tx);
> +	return 0;
> +}
> +#else
> +#define block_netpoll_tx()
> +#define unblock_netpoll_tx()
> +#define is_netpoll_tx_blocked(dev)
> +#endif
> +

These should go to netpoll.h, IMHO.
