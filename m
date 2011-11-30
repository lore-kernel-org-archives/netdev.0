From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: only use primary address for ARP
Date: Wed, 30 Nov 2011 17:07:10 -0500
Message-ID: <20111130220709.GI25132@gospo.rdu.redhat.com>
References: <20111124093715.GA25365@as68121.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: Henrik Saavedra Persson <henrik.e.persson@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6098 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628Ab1K3WHP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 17:07:15 -0500
Content-Disposition: inline
In-Reply-To: <20111124093715.GA25365@as68121.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2011 at 10:37:15AM +0100, Henrik Saavedra Persson wrote:
> Only use the primary address of the bond device
> for master_ip. This will prevent changing the ARP source
> address in Active-Backup mode whenever a secondry address
> is added to the bond device.
> 
> Signed-off-by: Henrik Saavedra Persson <henrik.e.persson@ericsson.com>
> ---
>  drivers/net/bonding/bond_main.c |   33 ++++++---------------------------
>  1 files changed, 6 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 6191e63..ec293b3 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2551,30 +2551,6 @@ out:
>  	}
>  }
>  
> -static __be32 bond_glean_dev_ip(struct net_device *dev)
> -{
> -	struct in_device *idev;
> -	struct in_ifaddr *ifa;
> -	__be32 addr = 0;
> -
> -	if (!dev)
> -		return 0;
> -
> -	rcu_read_lock();
> -	idev = __in_dev_get_rcu(dev);
> -	if (!idev)
> -		goto out;
> -
> -	ifa = idev->ifa_list;
> -	if (!ifa)
> -		goto out;
> -
> -	addr = ifa->ifa_local;
> -out:
> -	rcu_read_unlock();
> -	return addr;
> -}
> -
>  static int bond_has_this_ip(struct bonding *bond, __be32 ip)
>  {
>  	struct vlan_entry *vlan;
> @@ -3316,6 +3292,10 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
>  	struct bonding *bond;
>  	struct vlan_entry *vlan;
>  
> +	/* we only care about primary address */
> +	if(ifa->ifa_flags & IFA_F_SECONDARY)
> +		return NOTIFY_DONE;
> +

This change is good.  We need to stop overwriting bond->master_ip when
secondary addresses are added.

>  	list_for_each_entry(bond, &bn->dev_list, bond_list) {
>  		if (bond->dev == event_dev) {
>  			switch (event) {
> @@ -3323,7 +3303,7 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
>  				bond->master_ip = ifa->ifa_local;
>  				return NOTIFY_OK;
>  			case NETDEV_DOWN:
> -				bond->master_ip = bond_glean_dev_ip(bond->dev);
> +				bond->master_ip = 0;
>  				return NOTIFY_OK;
>  			default:
>  				return NOTIFY_DONE;
> @@ -3339,8 +3319,7 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
>  					vlan->vlan_ip = ifa->ifa_local;
>  					return NOTIFY_OK;
>  				case NETDEV_DOWN:
> -					vlan->vlan_ip =
> -						bond_glean_dev_ip(vlan_dev);
> +					vlan->vlan_ip = 0;
>  					return NOTIFY_OK;
>  				default:
>  					return NOTIFY_DONE;

Inspection indicates this is safe too.  The only code that appears to
check against master_up and vlan_ip appears to be in ARP monitoring code
and it does not make much sense to use ARP monitoring when your host does
not have an IP address.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
