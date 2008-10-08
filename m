From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 14:15:06 -0400
Message-ID: <48ECF8AA.2020205@hp.com>
References: <48EC091D.7080207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:1266 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639AbYJHSPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 14:15:10 -0400
In-Reply-To: <48EC091D.7080207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brian

A few comments.

>
> diff --git a/Documentation/networking/bonding.txt
b/Documentation/networking/bonding.txt
> index 688dfe1..4025565 100644
> --- a/Documentation/networking/bonding.txt
> +++ b/Documentation/networking/bonding.txt
> @@ -551,6 +551,16 @@ num_grat_arp
>  	affects only the active-backup mode.  This option was added for
>  	bonding version 3.3.0.
>
> +num_unsol_na
> +
> +	Specifies the number of unsolicited IPv6 Neighbor Advertisements
> +	to be issued after a failover event.  One unsolicited NA is issued
> +	immediately after the failover.
> +
> +	The valid range is 0 - 255; the default value is 1.  This option
> +	affects only the active-backup mode.  This option was added for
> +	bonding version 3.4.0.
> +
>  primary
>
>  	A string (eth0, eth2, etc) specifying which slave is the
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 2d6a060..37f55e1 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -61,6 +61,7 @@ config DUMMY
>  config BONDING
>  	tristate "Bonding driver support"
>  	depends on INET
> +	depends on IPV6 || IPV6=n
>  	---help---
>  	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
>  	  Channels together. This is called 'Etherchannel' by Cisco,
> diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
> index 5cdae2b..6f9c6fa 100644
> --- a/drivers/net/bonding/Makefile
> +++ b/drivers/net/bonding/Makefile
> @@ -6,3 +6,6 @@ obj-$(CONFIG_BONDING) += bonding.o
>
>  bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
>
> +ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
> +bonding-objs += $(ipv6-y)
> +
> diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
> new file mode 100644
> index 0000000..b6b0351
> --- /dev/null
> +++ b/drivers/net/bonding/bond_ipv6.c
> @@ -0,0 +1,208 @@
> +/*
> + * Copyright(c) 2008 Hewlett-Packard Development Company, L.P.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the
> + * Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
> + * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
> + * for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + *
> + * The full GNU General Public License is included in this distribution in the
> + * file called LICENSE.
> + *
> + */
> +
> +//#define BONDING_DEBUG 1
> +
> +#include <linux/types.h>
> +#include <linux/if_vlan.h>
> +#include <net/ipv6.h>
> +#include <net/ndisc.h>
> +#include <net/addrconf.h>
> +#include "bonding.h"
> +
> +/*
> + * Assign bond->master_ipv6 to the next IPv6 address in the list, or
> + * zero it out if there are none.
> + */
> +static void bond_glean_dev_ipv6(struct net_device *dev, struct in6_addr *addr)
> +{
> +	struct inet6_dev *idev;
> +	struct inet6_ifaddr *ifa;
> +
> +	if (!dev)
> +		return;
> +
> +	idev = in6_dev_get(dev);
> +	if (!idev)
> +		return;
> +
> +	ifa = idev->addr_list;
> +	if (ifa)
> +		ipv6_addr_copy(addr, &ifa->addr);
> +	else
> +		ipv6_addr_set(addr, 0, 0, 0, 0);
> +
> +	in6_dev_put(idev);
> +}
> +
> +static void bond_na_send(struct net_device *slave_dev,
> +			 struct in6_addr *daddr,
> +			 int router,
> +			 unsigned short vlan_id)
> +{
> +	struct in6_addr mcaddr;
> +	struct icmp6hdr icmp6h = {
> +		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
> +	};
> +	struct sk_buff *skb;
> +
> +	icmp6h.icmp6_router = router;
> +	icmp6h.icmp6_solicited = 0;
> +	icmp6h.icmp6_override = 1;
> +
> +	addrconf_addr_solict_mult(daddr, &mcaddr);
> +
> +	dprintk("ipv6 na on slave %s: dest %s, src %s\n" NIP6_FMT NIP6_FMT,
> +	       slave->name, NIP6(&mcaddr), NIP6(daddr));
> +
> +	skb = ndisc_build_skb(slave_dev, &mcaddr, daddr, &icmp6h, daddr,
> +			      ND_OPT_TARGET_LL_ADDR);
> +
> +	if (!skb) {
> +		printk(KERN_ERR DRV_NAME ": NA packet allocation failed\n");
> +		return;
> +	}
> +
> +	if (vlan_id) {
> +		skb = vlan_put_tag(skb, vlan_id);
> +		if (!skb) {
> +			printk(KERN_ERR DRV_NAME ": failed to insert VLAN tag\n");
> +			return;
> +		}
> +	}
> +
> +	ndisc_send_skb(skb, slave_dev, NULL, &mcaddr, daddr, &icmp6h);
> +}
> +
> +/*
> + * Kick out an unsolicited Neighbor Advertisement for an IPv6 address on
> + * the bonding master.  This will help the switch learn our address
> + * if in active-backup mode.
> + *
> + * Caller must hold curr_slave_lock for read or better
> + */
> +void bond_send_unsolicited_na(struct bonding *bond)
> +{
> +	struct slave *slave = bond->curr_active_slave;
> +	struct vlan_entry *vlan;
> +	struct inet6_dev *idev;
> +	int is_router;
> +
> +	dprintk("bond_send_unsol_na: bond %s slave %s\n", bond->dev->name,
> +				slave ? slave->dev->name : "NULL");
> +
> +	if (!slave || !bond->send_unsol_na ||
> +	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
> +		return;
> +
> +	bond->send_unsol_na--;
> +
> +	idev = in6_dev_get(bond->dev);
> +	if (!idev)
> +		return;
> +
> +	is_router = !!idev->cnf.forwarding;
> +
> +	in6_dev_put(idev);
> +
> +	if (!ipv6_addr_any(&bond->master_ipv6))
> +		bond_na_send(slave->dev, &bond->master_ipv6, is_router, 0);
> +
> +	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
> +		if (!ipv6_addr_any(&vlan->vlan_ipv6)) {
> +			bond_na_send(slave->dev, &vlan->vlan_ipv6, is_router,
> +				     vlan->vlan_id);
> +		}
> +	}
> +}
> +
> +/*
> + * bond_inet6addr_event: handle inet6addr notifier chain events.
> + *
> + * We keep track of device IPv6 addresses primarily to use as source
> + * addresses in NS probes.
> + *
> + * We track one IPv6 for the main device (if it has one).
> + */
> +static int bond_inet6addr_event(struct notifier_block *this,
> +				unsigned long event,
> +				void *ptr)
> +{
> +	struct inet6_ifaddr *ifa = ptr;
> +	struct net_device *vlan_dev, *event_dev = ifa->idev->dev;
> +	struct bonding *bond;
> +	struct vlan_entry *vlan;
> +
> +	if (dev_net(event_dev) != &init_net)
> +		return NOTIFY_DONE;
> +
> +	list_for_each_entry(bond, &bond_dev_list, bond_list) {
> +		if (bond->dev == event_dev) {
> +			switch (event) {
> +			case NETDEV_UP:
> +				ipv6_addr_copy(&bond->master_ipv6, &ifa->addr);
> +				return NOTIFY_OK;

I think you want to store the first address configured on the device (most
likely link-local), and not overwrite it every time  a new address is
configured.  Since new addresses can be configured rather often (think
temporary, new RAs, etc) we really want the most stable address we can have.
Also, since ND is a link protocol, link-local is sufficient.

> +			case NETDEV_DOWN:
> +				bond_glean_dev_ipv6(bond->dev,
> +						    &bond->master_ipv6);
> +				return NOTIFY_OK;

Here you may want to compare the address being removed with the address stored,
and glean the new address only if you are removing the stored address.

> +			default:
> +				return NOTIFY_DONE;
> +			}
> +		}
> +
> +		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
> +			vlan_dev = vlan_group_get_device(bond->vlgrp,
> +							 vlan->vlan_id);
> +			if (vlan_dev == event_dev) {
> +				switch (event) {
> +				case NETDEV_UP:
> +					ipv6_addr_copy(&vlan->vlan_ipv6,
> +						       &ifa->addr);
> +					return NOTIFY_OK;

Same as above.

> +				case NETDEV_DOWN:
> +					bond_glean_dev_ipv6(vlan_dev,
> +							    &vlan->vlan_ipv6);
> +					return NOTIFY_OK;

Same as above.

> +				default:
> +					return NOTIFY_DONE;
> +				}
> +			}
> +		}
> +	}
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block bond_inet6addr_notifier = {
> +	.notifier_call = bond_inet6addr_event,
> +};
> +
> +void bond_register_ipv6_notifier(void)
> +{
> +	register_inet6addr_notifier(&bond_inet6addr_notifier);
> +}
> +
> +void bond_unregister_ipv6_notifier(void)
> +{
> +	unregister_inet6addr_notifier(&bond_inet6addr_notifier);
> +}
> +

The reset looks good.  I still need to play with it to see what happens to the
MLD traffic.

-vlad
