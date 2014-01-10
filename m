From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v3 net-next 1/3] bonding: fix bond_3ad_set_carrier() RCU
 usage
Date: Fri, 10 Jan 2014 18:34:11 +0800
Message-ID: <52CFCCA3.5020606@huawei.com>
References: <1389345523-5497-1-git-send-email-vfalico@redhat.com> <1389345523-5497-2-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:62840 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaAJKel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 05:34:41 -0500
In-Reply-To: <1389345523-5497-2-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/10 17:18, Veaceslav Falico wrote:
> Currently, its usage is just plainly wrong. It first gets a slave under
> RCU, and, after releasing the RCU lock, continues to use it - whilst it can
> be freed.
> 
> Fix this by ensuring that bond_3ad_set_carrier() holds RCU till it uses its
> slave (or its agg).
> 
> Fixes: be79bd048ab ("bonding: add RCU for bond_3ad_state_machine_handler()")
> CC: dingtianhong@huawei.com
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
> 
> Notes:
>     v2 -> v3:
>     Just wrap RCU for the whole usage of our slave.
>     
>     v1 -> v2:
>     Don't use _rcu primitives as we can be called under RTNL too.
>     
>     v1 -> v2:
>     Don't use _rcu primitives as we can be called under RTNL too.
> 
>  drivers/net/bonding/bond_3ad.c | 23 ++++++++++++-----------
>  1 file changed, 12 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 29db1ca..9ff55eb 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2327,32 +2327,33 @@ int bond_3ad_set_carrier(struct bonding *bond)
>  {
>  	struct aggregator *active;
>  	struct slave *first_slave;
> +	int ret = 1;
>  
>  	rcu_read_lock();
>  	first_slave = bond_first_slave_rcu(bond);
> -	rcu_read_unlock();
> -	if (!first_slave)
> -		return 0;
> +	if (!first_slave) {
> +		ret = 0;
> +		goto out;
> +	}
>  	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave).aggregator));
>  	if (active) {
>  		/* are enough slaves available to consider link up? */
>  		if (active->num_of_ports < bond->params.min_links) {
>  			if (netif_carrier_ok(bond->dev)) {
>  				netif_carrier_off(bond->dev);
> -				return 1;
> +				goto out;
>  			}
>  		} else if (!netif_carrier_ok(bond->dev)) {
>  			netif_carrier_on(bond->dev);
> -			return 1;
> +			goto out;
>  		}
> -		return 0;
> -	}
> -
> -	if (netif_carrier_ok(bond->dev)) {
> +	} else if (netif_carrier_ok(bond->dev)) {
>  		netif_carrier_off(bond->dev);
> -		return 1;
> +		goto out;
no need for this line, but it is not a big issue.

Regards
Ding

>  	}
> -	return 0;
> +out:
> +	rcu_read_unlock();
> +	return ret;
>  }
>  
>  /**
> 
