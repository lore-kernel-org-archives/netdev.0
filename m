From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v3 net-next 3/3] bonding: fix __get_active_agg() RCU logic
Date: Fri, 10 Jan 2014 18:48:22 +0800
Message-ID: <52CFCFF6.6040303@huawei.com>
References: <1389345523-5497-1-git-send-email-vfalico@redhat.com> <1389345523-5497-4-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:55221 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbaAJKsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 05:48:42 -0500
In-Reply-To: <1389345523-5497-4-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/10 17:18, Veaceslav Falico wrote:
> Currently, the implementation is meaningless - once again, we take the
> slave structure and use it after we've exited RCU critical section.
> 
> Fix this by removing the rcu_read_lock() from __get_active_agg(), and
> ensuring that all its callers are holding RCU.
> 
> Fixes: be79bd048 ("bonding: add RCU for bond_3ad_state_machine_handler()")
> CC: dingtianhong@huawei.com
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
> 
> Notes:
>     v2 -> v3:
>     Use the RCU primitives.
>     
>     v1 -> v2:
>     Don't use RCU primitives as we can hold RTNL.
> 
>  drivers/net/bonding/bond_3ad.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 27dac0e..112afa8 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -674,6 +674,8 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
>  /**
>   * __get_active_agg - get the current active aggregator
>   * @aggregator: the aggregator we're looking at
> + *
> + * Caller must hold RCU lock.
>   */
>  static struct aggregator *__get_active_agg(struct aggregator *aggregator)
>  {
> @@ -681,13 +683,9 @@ static struct aggregator *__get_active_agg(struct aggregator *aggregator)
>  	struct list_head *iter;
>  	struct slave *slave;
>  
> -	rcu_read_lock();
>  	bond_for_each_slave_rcu(bond, slave, iter)
> -		if (SLAVE_AD_INFO(slave).aggregator.is_active) {
> -			rcu_read_unlock();
> +		if (SLAVE_AD_INFO(slave).aggregator.is_active)
>  			return &(SLAVE_AD_INFO(slave).aggregator);
> -		}
> -	rcu_read_unlock();
>  
>  	return NULL;
>  }
> @@ -1495,11 +1493,11 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>  	struct slave *slave;
>  	struct port *port;
>  
> +	rcu_read_lock();
>  	origin = agg;
>  	active = __get_active_agg(agg);
>  	best = (active && agg_device_up(active)) ? active : NULL;
>  
> -	rcu_read_lock();
>  	bond_for_each_slave_rcu(bond, slave, iter) {
>  		agg = &(SLAVE_AD_INFO(slave).aggregator);
>  
> 
Great.

Acked-by: Ding Tianhong <dingtianhong@huawei.com>
