From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Sat, 12 Jul 2014 10:49:01 +0200
Message-ID: <1405154941.3515.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405113030-28877-1-git-send-email-maheshb@google.com>
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
Received: from mail-wi0-f177.google.com ([209.85.212.177]:49477 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbaGLItI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jul 2014 04:49:08 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so327369wib.10
        for <netdev@vger.kernel.org>; Sat, 12 Jul 2014 01:49:06 -0700 (PDT)
In-Reply-To: <1405113030-28877-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-07-11 at 14:10 -0700, Mahesh Bandewar wrote:
...
> This patch fixes these issues and distributes flows across the
> UP links only. Also the array construction of links which are
> capable of sending packets happen in the control path leaving
> only link-selection during the data-path.
...
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
...
>  
> +static int bond_tlb_update_slave_arr(struct bonding *bond)
> +{
> +	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> +	struct slave *tx_slave;
> +	struct list_head *iter;
> +	struct tlb_up_slave *new_arr, *old_arr;
> +
> +	new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
> +			  GFP_KERNEL);
> +	if (!new_arr)
> +		return -ENOMEM;
> +
> +	bond_for_each_slave(bond, tx_slave, iter) {
> +		if (bond_slave_can_tx(tx_slave))
> +			new_arr->arr[new_arr->count++] = tx_slave;
> +	}
> +
> +	old_arr = bond_info->slave_arr;

Check your patch with :

CONFIG_SPARSE_RCU_POINTER=y
make C=2 drivers/net/bonding/bond_alb.o

Hint : You need here to use

	old_arr = rtnl_dereference(bond_info->slave_arr);
	

> +	rcu_assign_pointer(bond_info->slave_arr, new_arr);
> +	if (old_arr)
> +		kfree_rcu(old_arr, rcu);
> +
> +	return 0;
> +}
> +
