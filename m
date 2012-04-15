From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH v2] bonding: start slaves with link down for ARP monitor
Date: Sun, 15 Apr 2012 00:21:53 -0300
Message-ID: <20120415002153.4c4e152a@asterix.rh>
References: <20120414220617.DA8BE45BA2@lion.mk-sys.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2832 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756726Ab2DODWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 23:22:23 -0400
In-Reply-To: <20120414220617.DA8BE45BA2@lion.mk-sys.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Apr 2012 22:16:16 +0200
Michal Kubecek <mkubecek@suse.cz> wrote:

> Initialize slave device link state as down if ARP monitor is
> active and net_carrier_ok() returns zero. Also shift initial
> value of its last_arp_tx so that it doesn't immediately cause
> fake detection of "up" state.
> 
> When ARP monitoring is used, initializing the slave device with
> up link state can cause ARP monitor to detect link failure
> before the device is really up (with igb driver, this can take
> more than two seconds).
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  drivers/net/bonding/bond_main.c |   34 +++++++++++++++++++++-------------
>  1 files changed, 21 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 62d2409..6a79ee3 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1726,7 +1726,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  
>  	read_lock(&bond->lock);
>  
> -	new_slave->last_arp_rx = jiffies;
> +	new_slave->last_arp_rx = jiffies -
> +		(msecs_to_jiffies(bond->params.arp_interval) + 1);
>  
>  	if (bond->params.miimon && !bond->params.use_carrier) {
>  		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
> @@ -1751,21 +1752,28 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  	}
>  
>  	/* check for initial state */
> -	if (!bond->params.miimon ||
> -	    (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS)) {
> -		if (bond->params.updelay) {
> -			pr_debug("Initial state of slave_dev is BOND_LINK_BACK\n");
> -			new_slave->link  = BOND_LINK_BACK;
> -			new_slave->delay = bond->params.updelay;
> +	if (bond->params.miimon) {
> +		if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
> +			if (bond->params.updelay) {
> +				new_slave->link = BOND_LINK_BACK;
> +				new_slave->delay = bond->params.updelay;
> +			} else {
> +				new_slave->link = BOND_LINK_UP;
> +			}
>  		} else {
> -			pr_debug("Initial state of slave_dev is BOND_LINK_UP\n");
> -			new_slave->link  = BOND_LINK_UP;
> +			new_slave->link = BOND_LINK_DOWN;
>  		}
> +	} else if (bond->params.arp_interval) {
> +		new_slave->link = (netif_carrier_ok(slave_dev) ?
> +			BOND_LINK_UP : BOND_LINK_DOWN);

The interface would have to negotiate the link and report back
very very fast because the dev_open(slave) was just called and
most drivers initialize the state as DOWN and then wait either
for an interrupt or a watchdog to update the link status.

Therefore, the practical final result for most cards (if not all)
is new_slave->link = BOND_LINK_DOWN and forced to wait for an
ARP monitor cycle before going link up according to ARP monitor.

This will change the current behavior which is faster and good
enough for most cases.  What about a new option to decide that?
For instance, arp_init_slave=UP/DOWN/MII with default to UP.

Jay? Andy? :)


> +	} else
> +		new_slave->link = BOND_LINK_UP;
> +
> +	if (new_slave->link != BOND_LINK_DOWN)
>  		new_slave->jiffies = jiffies;
> -	} else {
> -		pr_debug("Initial state of slave_dev is BOND_LINK_DOWN\n");
> -		new_slave->link  = BOND_LINK_DOWN;
> -	}
> +	pr_debug("Initial state of slave_dev is BOND_LINK_%s\n",
> +		new_slave->link == BOND_LINK_DOWN ? "DOWN" :
> +			(new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));

The above seems to have missed a 'space' and the alignment of
the next line:
+	pr_debug("Initial state of slave_dev is BOND_LINK_%s\n",
+		 new_slave->link == BOND_LINK_DOWN ? "DOWN" :
+		 (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));

fbl
