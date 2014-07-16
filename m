From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 16 Jul 2014 08:43:25 +0200
Message-ID: <1405493005.10255.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405467125-26822-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:41274 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934806AbaGPGnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 02:43:31 -0400
Received: by mail-wg0-f46.google.com with SMTP id m15so401401wgh.29
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 23:43:29 -0700 (PDT)
In-Reply-To: <1405467125-26822-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-15 at 16:32 -0700, Mahesh Bandewar wrote:
> In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
> group are selected based on the hash distribution. This does not
> exclude dead links which are part of the bond. Also if there is a
> temporary link event which brings down the interface, packets
> hashed on that interface would be dropped too.
> 
> This patch fixes these issues and distributes flows across the
> UP links only. Also the array construction of links which are
> capable of sending packets happen in the control path leaving
> only link-selection during the data-path.
> 
> One possible side effect of this is - at a link event; all
> flows will be shuffled to get good distribution. But impact of
> this should be minimum with the assumption that a member or
> members of the bond group are not available is a very temporary
> situation.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_alb.c | 57 ++++++++++++++++++++++++++++++++++++++----
>  drivers/net/bonding/bond_alb.h |  8 ++++++
>  drivers/net/bonding/bonding.h  |  6 +++++
>  3 files changed, 66 insertions(+), 5 deletions(-)
> 
> [v1]
>   * Initial patch
> [v2]
>   * Removed spinlock protection
>   * Removed explicit rcu_read_(un)lock() calls since Xmit fn run in RCU
>   * Updated condition during bond-dismantle to check for only arrays' existance.
> [v3]
>   * Correct RCU annotation during dismantle
>   * Alloc changed from GFP_KERNEL to GFP_ATOMIC
>   * Added another call during alb_deinit_slave() to update array.
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 76c0dade233f..55ff399a16f4 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -209,6 +209,13 @@ static void tlb_deinitialize(struct bonding *bond)
>  	bond_info->tx_hashtbl = NULL;
>  
>  	_unlock_tx_hashtbl_bh(bond);
> +
> +	if (bond_info->slave_arr) {
> +		struct tlb_up_slave *arr;
> +
> +		arr = rtnl_dereference(bond_info->slave_arr);
> +		kfree_rcu(arr, rcu);
> +	}

This is very dubious and bad habit.

In fact you need to use correct rcu dereference every time you access
slave_arr, even if sparse allows this construct without a warning.

To be obviously correct here, slave_arr should be read once.

arr = rtnl_dereference(bond_info->slave_arr);
if (arr)
    kfree_rcu(arr, rcu);

Using this is also better, because LOCKDEP will perform its check (about
RTNL being held) even if slave_arr is NULL, so we get better coverage.


>  }
>  
>  static long long compute_gap(struct slave *slave)
> @@ -1406,9 +1413,39 @@ out:
>  	return NETDEV_TX_OK;
>  }
>  
> +static int bond_tlb_update_slave_arr(struct bonding *bond,
> +				     struct slave *skipslave)
> +{
> +	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> +	struct slave *tx_slave;
> +	struct list_head *iter;
> +	struct tlb_up_slave *new_arr, *old_arr;
> +
> +	new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
> +			  GFP_ATOMIC);
> +	if (!new_arr)
> +		return -ENOMEM;
> +
> +	bond_for_each_slave(bond, tx_slave, iter) {
> +		if (!bond_slave_can_tx(tx_slave))
> +			continue;
> +		if (skipslave && skipslave == tx_slave)
> +			continue;

Here, tx_slave is not NULL, so the whole condition can be reduced to :

		if (tx_slave == skipslave)
			continue;

> +		new_arr->arr[new_arr->count++] = tx_slave;
> +	}
> +
> +	old_arr = bond_info->slave_arr;

Same here. You need some correct rcu accessor, to clearly express what
protects you here, as I already pointed to you in a previous feedback.

	old_arr = rtnl_dereference(bond_info->slave_arr);


> +	rcu_assign_pointer(bond_info->slave_arr, new_arr);
> +	if (old_arr)
> +		kfree_rcu(old_arr, rcu);
> +
> +	return 0;
> +}
> +
