From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv9] macvlan: add source mode
Date: Fri, 14 Mar 2014 05:42:18 -0700
Message-ID: <1394800938.21721.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394797786-27420-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	projekt-wlan@fem.tu-ilmenau.de, Stefan Gula <steweg@gmail.com>
To: Michael Braun <michael-dev@fami-braun.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:44544 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbaCNMmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 08:42:18 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so2492372pdi.16
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 05:42:18 -0700 (PDT)
In-Reply-To: <1394797786-27420-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-14 at 12:49 +0100, Michael Braun wrote:
> This patch adds a new mode of operation to macvlan, called "source".
> It allows one to set a list of allowed mac address, which is used
> to match against source mac address from received frames on underlying
> interface.
> This enables creating mac based VLAN associations, instead of standard
> port or tag based. The feature is useful to deploy 802.1x mac based
> behavior, where drivers of underlying interfaces doesn't allows that.
> 
> Configuration is done through the netlink interface using e.g.:
>  ip link add link eth0 name macvlan0 type macvlan mode source
>  ip link add link eth0 name macvlan1 type macvlan mode source
>  ip link set link macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>  ip link set link macvlan0 type macvlan macaddr add 00:22:22:22:22:22
>  ip link set link macvlan0 type macvlan macaddr add 00:33:33:33:33:33
>  ip link set link macvlan1 type macvlan macaddr add 00:33:33:33:33:33
>  ip link set link macvlan1 type macvlan macaddr add 00:44:44:44:44:44
> 
> This allows clients with MAC addresses 00:11:11:11:11:11,
> 00:22:22:22:22:22 to be part of only VLAN associated with macvlan0
> interface. Clients with MAC addresses 00:44:44:44:44:44 with only VLAN
> associated with macvlan1 interface. And client with MAC address
> 00:33:33:33:33:33 to be associated with both VLANs.
> 
> Based on work of Stefan Gula <steweg@gmail.com>
> 
> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
> Cc: <netdev@vger.kernel.org>
> Cc: <projekt-wlan@fem.tu-ilmenau.de>
> Cc: Stefan Gula <steweg@gmail.com>
> 
> v8: last version of Stefan Gula for Kernel 3.2.1
> v9: rework onto linux-next 2014-03-12 by Michael Braun
> v9: add MACADDR_SET command
> v9: enable to configure mac for source mode while creating interface
> 
> ---
>  drivers/net/macvlan.c        | 274 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/if_macvlan.h   |   1 +
>  include/uapi/linux/if_link.h |  12 ++
>  3 files changed, 287 insertions(+)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index c683ac2..a4268d0 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -42,6 +42,14 @@ struct macvlan_port {
>  	struct rcu_head		rcu;
>  	bool 			passthru;
>  	int			count;
> +	struct hlist_head	vlan_source_hash[MACVLAN_HASH_SIZE];
> +};
> +
> +struct macvlan_source_list {

This is a strange name.
Its not a list but an elem that will be part of a list ?

> +	struct hlist_node	hlist;
> +	struct macvlan_dev	*vlan;
> +	unsigned char		addr[ETH_ALEN];
> +	struct rcu_head		rcu;
>  };
>  
>  static void macvlan_port_destroy(struct net_device *dev);
> @@ -70,6 +78,21 @@ static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
>  	return NULL;
>  }
>  
> +static struct macvlan_source_list *macvlan_hash_lookup_sources_list(
> +	const struct macvlan_dev *vlan,
> +	const unsigned char *addr)
> +{
> +	struct macvlan_source_list *list;
> +	struct hlist_head *h = &vlan->port->vlan_source_hash[addr[5]];
> +
> +	hlist_for_each_entry_rcu(list, h, hlist) {
> +		if (ether_addr_equal_unaligned(list->addr, addr) &&
> +		    list->vlan == vlan)
> +			return list;
> +	}
> +	return NULL;
> +}
> +
>  static void macvlan_hash_add(struct macvlan_dev *vlan)
>  {
>  	struct macvlan_port *port = vlan->port;
> @@ -78,6 +101,29 @@ static void macvlan_hash_add(struct macvlan_dev *vlan)
>  	hlist_add_head_rcu(&vlan->hlist, &port->vlan_hash[addr[5]]);
>  }
>  
> +static int macvlan_hash_add_sources(struct macvlan_dev *vlan,
> +				    const unsigned char *addr)
> +{
> +	struct macvlan_port *port = vlan->port;
> +	struct macvlan_source_list *list;
> +	struct hlist_head *h;
> +
> +	list = macvlan_hash_lookup_sources_list(vlan, addr);
> +	if (!list) {
> +		list = kmalloc(sizeof(*list), GFP_KERNEL);
> +		if (list) {
> +			ether_addr_copy(list->addr, addr);
> +			list->vlan = vlan;
> +			h = &port->vlan_source_hash[addr[5]];
> +			hlist_add_head_rcu(&list->hlist, h);
> +			vlan->macaddr_count++;
> +		} else {
> +			return -ENOMEM;
> +		}

Nit: You can avoid this extra indentation level and brackets with :
	list = kmalloc(...);
	if (!list)
		return -ENOMEM;
	ether_addr_copy(list->addr, addr);
	...
	vlan->macaddr_count++;


Then again, @list is a strange name, it should be something else.

> +	}
> +	return 0;
> +}
> +
