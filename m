From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: fix div by zero while enslaving and
 transmitting
Date: Fri, 12 Sep 2014 06:09:41 -0700
Message-ID: <1410527381.7106.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410524556-27128-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:47355 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633AbaILNJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 09:09:43 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so1236708pab.24
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 06:09:42 -0700 (PDT)
In-Reply-To: <1410524556-27128-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 14:22 +0200, Nikolay Aleksandrov wrote:
...
> 
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> Fixes: 5378c2e6ea236d ("bonding: move bond-specific init after enslave happens")
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 57912ee231cb..10ad434ea184 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1552,6 +1552,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		goto err_detach;
>  	}
>  
> +	/* Increment slave_cnt before linking in the slave so we won't end up in
> +	 * bond_start_xmit with bond_has_slaves() true and slave_cnt == 0.
> +	 */
> +	bond->slave_cnt++;

It looks like explicit barriers are missing.

#define bond_has_slaves(bond) !list_empty(bond_slave_list(bond)) 

So your increment into slave_cnt must be committed into memory before
any change to slave_list. But you need to check how removal of a slave
is handled.

Now I wonder why bond_has_slaves(bond) is not a test against
bond->slave_cnt

Note that even if this would be the case, bond xmit seems racy :

if (bond_has_slaves(bond))
	ret = __bond_start_xmit(skb, dev);

As slave_cnt could change (and eventually reach 0) between the two
places.

My feeling is that RCU conversion is not properly done in this driver.

Either bond->slave_cnt should be read _once_ for the whole duration of
bond_start_xmit() call, _OR_, be stored in a real Read Copy structure,
so that struct->slave_cnt _cannot_ change during bond_start_xmit()

>  	res = bond_master_upper_dev_link(bond_dev, slave_dev, new_slave);
>  	if (res) {
>  		netdev_dbg(bond_dev, "Error %d calling bond_master_upper_dev_link\n", res);
> @@ -1564,7 +1568,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		goto err_upper_unlink;
>  	}
>  
> -	bond->slave_cnt++;
>  	bond_compute_features(bond);
>  	bond_set_carrier(bond);
>  
> @@ -1590,6 +1593,7 @@ err_upper_unlink:
>  
>  err_unregister:
>  	netdev_rx_handler_unregister(slave_dev);
> +	bond->slave_cnt--;
>  
>  err_detach:
>  	if (!bond_uses_primary(bond))
