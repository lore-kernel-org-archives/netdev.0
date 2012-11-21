From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: Bonding driver does not consider the
 gso_max_size setting of slaves.
Date: Wed, 21 Nov 2012 06:43:45 -0800
Message-ID: <1353509025.2590.31.camel@edumazet-glaptop>
References: <8814d83f-7213-4a32-91ec-39088a1a60a6@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:33959 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809Ab2KUOns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 09:43:48 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so5074837iay.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 06:43:48 -0800 (PST)
In-Reply-To: <8814d83f-7213-4a32-91ec-39088a1a60a6@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 16:48 +0530, sarveshwar.bandi@emulex.com wrote:
> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> Patch sets the lowest non-zero gso_max_size value of the slaves during enslave
> and detach.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> ---
>  drivers/net/bonding/bond_main.c |   27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b2530b0..5f19d16 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1198,6 +1198,31 @@ static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
>  	bond->slave_cnt++;
>  }
>  
> +static void bond_set_gso_max_size(struct bonding *bond)
> +{
> +	struct slave *slave;
> +	struct net_device *bond_dev = bond->dev;
> +	unsigned int gso_max_size = 0;
> +	bool reset_gso_size = true;
> +	int i;
> +
> +	bond_for_each_slave(bond, slave, i) {
> +		if (!slave->dev->gso_max_size)
> +			continue;
> +
> +		reset_gso_size = false;
> +
> +		if (!gso_max_size ||
> +		    slave->dev->gso_max_size < gso_max_size)
> +			gso_max_size = slave->dev->gso_max_size;
> +	}
> +
> +	if (gso_max_size && gso_max_size < bond_dev->gso_max_size)
> +		netif_set_gso_max_size(bond_dev, gso_max_size);
> +	else if (reset_gso_size)
> +		netif_set_gso_max_size(bond_dev, 0);
> +}
> +

This seems a bit complex, and I have no idea why you call
netif_set_gso_max_size(bond_dev, 0);

Default gso_max_size is GSO_MAX_SIZE, not 0
