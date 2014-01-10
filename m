From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v3 net-next 2/3] bonding: fix __get_first_agg RCU usage
Date: Fri, 10 Jan 2014 18:43:41 +0800
Message-ID: <52CFCEDD.6030202@huawei.com>
References: <1389345523-5497-1-git-send-email-vfalico@redhat.com> <1389345523-5497-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:30694 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbaAJKnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 05:43:53 -0500
In-Reply-To: <1389345523-5497-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/10 17:18, Veaceslav Falico wrote:
> Currently, the RCU read lock usage is just wrong - it gets the slave struct
> under RCU and continues to use it when RCU lock is released.
> 
> However, it's still safe to do this cause we didn't need the
> rcu_read_lock() initially - all of the __get_first_agg() callers are either
> holding RCU read lock or the RTNL lock, so that we can't sync while in it.
> 
> So, remove the useless rcu locking and add a comment.
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
>     Use the rcu primitives.
>     
>     v1 -> v2:
>     Don't use RCU primitives as we can hold RTNL.
> 
>  drivers/net/bonding/bond_3ad.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 9ff55eb..27dac0e 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -143,6 +143,7 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
>   *
>   * Return the aggregator of the first slave in @bond, or %NULL if it can't be
>   * found.
> + * The caller must hold RCU lock.
>   */
>  static inline struct aggregator *__get_first_agg(struct port *port)
>  {
> @@ -153,9 +154,7 @@ static inline struct aggregator *__get_first_agg(struct port *port)
>  	if (bond == NULL)
>  		return NULL;
>  
> -	rcu_read_lock();
>  	first_slave = bond_first_slave_rcu(bond);
> -	rcu_read_unlock();
>  
I am afraid the lockdep check will calling some warming:
bond_3ad_unbind_slave -> __get_first_agg -> bond_first_slave_rcu -> netdev_lower_get_first_private_rcu -> list_first_or_null_rcu

but the bond_3ad_unbind_slave is not in RCU.

Regards
Ding
>  	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
>  }
> 
