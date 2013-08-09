From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v2 net-next 5/6] bonding: convert bond_arp_send_all to
 use bond->dev->vlan_info
Date: Fri, 09 Aug 2013 13:42:39 +0200
Message-ID: <5204D5AF.9080702@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com> <1375981079-2936-6-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967079Ab3HILq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 07:46:26 -0400
In-Reply-To: <1375981079-2936-6-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2013 06:57 PM, Veaceslav Falico wrote:
> RFC -> v1: use the new __vlan_find_dev_next(), also release rcu_read_lock()
> 	   only after we stop using the vlan_dev.
> v1  -> v2: no change.
> 
> Instead of looping through bond->vlan_list, loop through
> bond->dev->vlan_info via __vlan_find_dev_next() under rcu_read_lock().
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c |   29 +++++++++++++----------------
>  1 files changed, 13 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index e52e2d5..f536d05 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2440,11 +2440,10 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
>  
>  static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>  {
> -	int i, vlan_id;
> -	__be32 *targets = bond->params.arp_targets;
> -	struct vlan_entry *vlan;
> -	struct net_device *vlan_dev = NULL;
> +	struct net_device *vlan_dev;
>  	struct rtable *rt;
> +	__be32 *targets = bond->params.arp_targets;
> +	int i;
>  
Style nitpick: maybe move them longest -> shortest.

>  	for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
>  		__be32 addr;
> @@ -2486,28 +2485,26 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>  			continue;
>  		}
>  
> -		vlan_id = 0;
> -		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
> -			rcu_read_lock();
> -			vlan_dev = __vlan_find_dev_deep(bond->dev,
> -							htons(ETH_P_8021Q),
> -							vlan->vlan_id);
> -			rcu_read_unlock();
> +		vlan_dev = NULL;
> +
> +		rcu_read_lock();
> +		while ((vlan_dev = __vlan_find_dev_next(bond->dev, vlan_dev)))
>  			if (vlan_dev == rt->dst.dev) {
> -				vlan_id = vlan->vlan_id;
>  				pr_debug("basa: vlan match on %s %d\n",
> -				       vlan_dev->name, vlan_id);
> +					 vlan_dev->name,
> +					 vlan_dev_vlan_id(vlan_dev));
>  				break;
>  			}
> -		}
>  
> -		if (vlan_id && vlan_dev) {
> +		if (vlan_dev) {
>  			ip_rt_put(rt);
>  			addr = bond_confirm_addr(vlan_dev, targets[i], 0);
>  			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
> -				      addr, vlan_id);
> +				      addr, vlan_dev_vlan_id(vlan_dev));
> +			rcu_read_unlock();
>  			continue;
>  		}
> +		rcu_read_unlock();
>
I think these lines can be re-arranged to something shorter like:

                rcu_read_lock();
                vlan_dev = NULL;
                while ((vlan_dev = __vlan_find_dev_next(bond->dev, vlan_dev)))
                        if (vlan_dev == rt->dst.dev) {
                                pr_debug("basa: vlan match on %s %d\n",
                                         vlan_dev->name,
                                         vlan_dev_vlan_id(vlan_dev));
                                break;
                        }

                if (vlan_dev) {
                        ip_rt_put(rt);
                        addr = bond_confirm_addr(vlan_dev, targets[i], 0);
                        bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
                                      addr, vlan_dev_vlan_id(vlan_dev));
                } else {
			if (net_ratelimit())
                        	pr_warning("%s: no path to arp_ip_target %pI4 via
rt.dev %s\n",
                                	   bond->dev->name, &targets[i],
                                   	rt->dst.dev ? rt->dst.dev->name : "NULL");
	               ip_rt_put(rt);	
                }
                rcu_read_unlock();

But either way is fine, I just think this one is more readable.

Cheers,
 Nik
