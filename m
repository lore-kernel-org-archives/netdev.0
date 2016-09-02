From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 2 Sep 2016 08:30:11 -0600
Message-ID: <a045ae10-e002-6658-575b-109e66056d5f@cumulusnetworks.com>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36424 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751496AbcIBOaa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 10:30:30 -0400
Received: by mail-pa0-f51.google.com with SMTP id fu3so33149673pad.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 07:30:18 -0700 (PDT)
In-Reply-To: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/1/16 11:18 PM, Mahesh Bandewar wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> 
> Following few steps will crash kernel -
> 
>   (a) Create bonding master
>       > modprobe bonding miimon=50
>   (b) Create macvlan bridge on eth2
>       > ip link add link eth2 dev mvl0 address aa:0:0:0:0:01 \
> 	   type macvlan
>   (c) Now try adding eth2 into the bond
>       > echo +eth2 > /sys/class/net/bond0/bonding/slaves
>       <crash>
> 
> Bonding does lots of things before checking if the device enslaved is
> busy or not.
> 
> In this case when the notifier call-chain sends notifications, the
> bond_netdev_event() assumes that the rx_handler /rx_handler_data is
> registered while the bond_enslave() hasn't progressed far enough to
> register rx_handler for the new slave.
> 
> This patch adds a rx_handler check that can be performed right at the
> beginning of the enslave code to avoid getting into this situation.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_main.c |  7 ++++---
>  include/linux/netdevice.h       |  1 +
>  net/core/dev.c                  | 16 ++++++++++++++++
>  3 files changed, 21 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 217e8da0628c..9599ed6f1213 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1341,9 +1341,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  			    slave_dev->name);
>  	}
>  
> -	/* already enslaved */
> -	if (slave_dev->flags & IFF_SLAVE) {
> -		netdev_dbg(bond_dev, "Error: Device was already enslaved\n");
> +	/* already in-use? */
> +	if (netdev_is_rx_handler_busy(slave_dev)) {
> +		netdev_err(bond_dev,
> +			   "Error: Device is in use and cannot be enslaved\n");
>  		return -EBUSY;
>  	}
>  

This check duplicates what netdev_rx_handler_register does. Why not move the call to netdev_rx_handler_register here and then call unregister on failure paths?
