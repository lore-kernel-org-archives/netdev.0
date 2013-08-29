From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 4/5] bonding: restructure and simplify bond_for_each_slave_next()
Date: Thu, 29 Aug 2013 16:25:50 +0200
Message-ID: <521F59EE.1080408@redhat.com>
References: <521D7AC7.6090508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19756 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753106Ab3H2O3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 10:29:40 -0400
In-Reply-To: <521D7AC7.6090508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2013 06:21 AM, Ding Tianhong wrote:
> remove the wordy int and add bond_for_each_slave_next_rcu().
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/bonding/bond_alb.c  |  3 +--
>  drivers/net/bonding/bond_main.c |  6 ++----
>  drivers/net/bonding/bonding.h   | 19 +++++++++++++++----
>  3 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 3a5db7b..d266c56 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -383,7 +383,6 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
>  {
>  	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>  	struct slave *rx_slave, *slave, *start_at;
> -	int i = 0;
>  
>  	if (bond_info->next_rx_slave)
>  		start_at = bond_info->next_rx_slave;
> @@ -392,7 +391,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
>  
>  	rx_slave = NULL;
>  
> -	bond_for_each_slave_from(bond, slave, i, start_at) {
> +	bond_for_each_slave_from(bond, slave, start_at) {
>  		if (SLAVE_IS_OK(slave)) {
>  			if (!rx_slave) {
>  				rx_slave = slave;
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 4264a76..8c9902a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -904,7 +904,6 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
>  	struct slave *new_active, *old_active;
>  	struct slave *bestslave = NULL;
>  	int mintime = bond->params.updelay;
> -	int i;
>  
>  	new_active = bond->curr_active_slave;
>  
> @@ -923,7 +922,7 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
>  	/* remember where to stop iterating over the slaves */
>  	old_active = new_active;
>  
> -	bond_for_each_slave_from(bond, new_active, i, old_active) {
> +	bond_for_each_slave_from(bond, new_active, old_active) {
>  		if (new_active->link == BOND_LINK_UP) {
>  			return new_active;
>  		} else if (new_active->link == BOND_LINK_BACK &&
> @@ -2891,7 +2890,6 @@ do_failover:
>  static void bond_ab_arp_probe(struct bonding *bond)
>  {
>  	struct slave *slave, *next_slave;
> -	int i;
>  
>  	read_lock(&bond->curr_slave_lock);
>  
> @@ -2923,7 +2921,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
>  
>  	/* search for next candidate */
>  	next_slave = bond_next_slave(bond, bond->current_arp_slave);
> -	bond_for_each_slave_from(bond, slave, i, next_slave) {
> +	bond_for_each_slave_from(bond, slave, next_slave) {
>  		if (IS_UP(slave->dev)) {
>  			slave->link = BOND_LINK_BACK;
>  			bond_set_slave_active_flags(slave);
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index ecb5d1d..7670584 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -119,14 +119,25 @@
>   * bond_for_each_slave_from - iterate the slaves list from a starting point
>   * @bond:	the bond holding this list.
>   * @pos:	current slave.
> - * @cnt:	counter for max number of moves
>   * @start:	starting point.
>   *
>   * Caller must hold bond->lock
>   */
> -#define bond_for_each_slave_from(bond, pos, cnt, start) \
> -	for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
> -	     cnt++, pos = bond_next_slave(bond, pos))
> +#define bond_for_each_slave_from(bond, pos, start) \
> +	for (pos = bond_next_slave(bond, start); pos && pos != start; \
> +			pos = bond_next_slave(bond, pos))
> +
> +/**
> + * bond_for_each_slave_from_rcu - iterate the slaves list from a starting point
> + * @bond:	the bond holding this list.
> + * @pos:	current slave.
> + * @start:	starting point.
> + *
> + * Caller must hold rcu_read_lock
> + */
> +#define bond_for_each_slave_from_rcu(bond, pos, start) \
> +	for (pos = bond_next_slave_rcu(bond, start); pos && pos != start; \
> +			pos = bond_next_slave_rcu(bond, pos))
>  
One question here: what if "start" gets deleted while we're traversing the list,
could this lead to an infinite loop ?

>  /**
>   * bond_for_each_slave - iterate over all slaves
> 
