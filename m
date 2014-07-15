From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next] bonding: permit enslaving interfaces without
 set_mac support
Date: Tue, 15 Jul 2014 17:15:34 +0530
Message-ID: <53C5145E.5040908@gmail.com>
References: <1405423561-9114-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:48317 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758039AbaGOLqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 07:46:55 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so749194pad.39
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 04:46:54 -0700 (PDT)
In-Reply-To: <1405423561-9114-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 04:56 PM, Veaceslav Falico wrote:
> Currently we exit if the slave isn't the first slave, doesn't support mac
> address setting and fail_over_mac isn't FOM_ACTIVE. It's wrong because we
> only require ndo_set_mac_address in case bonding is in active-backup mode
> and FOM isn't FOM_ACTIVE.
>
> To fix this - only exit with an error if we're in a/b mode and have
> fail_over_mac != FOM_ACTIVE.
>
> Also, maintain current behaviour on the first slave (forcibly change fom to
> FOM_ACTIVE) to not break anyone's configuration.
>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
>   drivers/net/bonding/bond_main.c | 19 ++++++++++---------
>   1 file changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 09dc3ef..e0a33b5 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1298,19 +1298,20 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>   	}
>   
>   	if (slave_ops->ndo_set_mac_address == NULL) {
> -		if (!bond_has_slaves(bond)) {
> -			pr_warn("%s: Warning: The first slave device specified does not support setting the MAC address\n",
> -				bond_dev->name);
> -			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) {
> +		pr_warn("%s: Warning: The slave device specified does not support setting the MAC address\n",
> +			bond_dev->name);

netdev_warn() instead of pr_warn()... We are having net_device object?

> +		if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP &&
> +		    bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
> +			if (!bond_has_slaves(bond)) {
>   				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
>   				pr_warn("%s: Setting fail_over_mac to active for active-backup mode\n",
>   					bond_dev->name);
> +			} else {
> +				pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active\n",
> +				       bond_dev->name);

netdev_err()...?

> +				res = -EOPNOTSUPP;
> +				goto err_undo_flags;
>   			}
> -		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
> -			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active\n",
> -			       bond_dev->name);
> -			res = -EOPNOTSUPP;
> -			goto err_undo_flags;
>   		}
>   	}
>   

-- 
Regards,
Varka Bhadram.
