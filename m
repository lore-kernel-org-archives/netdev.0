From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Fri, 21 Oct 2011 16:18:14 +0200
Message-ID: <20111021141812.GA10076@minipsycho>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
 <20111021140005.GA29815@synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	fbl@redhat.com, jzupka@redhat.com
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754529Ab1JUOSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 10:18:48 -0400
Content-Disposition: inline
In-Reply-To: <20111021140005.GA29815@synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Oct 21, 2011 at 04:00:05PM CEST, benjamin.poirier@gmail.com wrote:
>On 11/10/21 14:39, Jiri Pirko wrote:
>> This patch introduces new network device called team. It supposes to be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>> 
>> Userspace library called libteam with couple of demo apps is available
>> here:
>> https://github.com/jpirko/libteam
>> Note it's still in its dipers atm.
>> 
>> team<->libteam use generic netlink for communication. That and rtnl
>> suppose to be the only way to configure team device, no sysfs etc.
>> 
>> Python binding basis for libteam was recently introduced (some need
>> still need to be done on it though). Daemon providing arpmon/miimon
>> active-backup functionality will be introduced shortly.
>> All what's necessary is already implemented in kernel team driver.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> 
>> v1->v2:
>> 	- modes are made as modules. Makes team more modular and
>> 	  extendable.
>> 	- several commenters' nitpicks found on v1 were fixed
>> 	- several other bugs were fixed.
>> 	- note I ignored Eric's comment about roundrobin port selector
>> 	  as Eric's way may be easily implemented as another mode (mode
>> 	  "random") in future.
>> ---
>>  Documentation/networking/team.txt         |    2 +
>>  MAINTAINERS                               |    7 +
>>  drivers/net/Kconfig                       |    2 +
>>  drivers/net/Makefile                      |    1 +
>>  drivers/net/team/Kconfig                  |   38 +
>>  drivers/net/team/Makefile                 |    7 +
>>  drivers/net/team/team.c                   | 1593 +++++++++++++++++++++++++++++
>>  drivers/net/team/team_mode_activebackup.c |  152 +++
>>  drivers/net/team/team_mode_roundrobin.c   |  107 ++
>>  include/linux/Kbuild                      |    1 +
>>  include/linux/if.h                        |    1 +
>>  include/linux/if_team.h                   |  233 +++++
>>  12 files changed, 2144 insertions(+), 0 deletions(-)
>>  create mode 100644 Documentation/networking/team.txt
>>  create mode 100644 drivers/net/team/Kconfig
>>  create mode 100644 drivers/net/team/Makefile
>>  create mode 100644 drivers/net/team/team.c
>>  create mode 100644 drivers/net/team/team_mode_activebackup.c
>>  create mode 100644 drivers/net/team/team_mode_roundrobin.c
>>  create mode 100644 include/linux/if_team.h
>> 
>> diff --git a/Documentation/networking/team.txt b/Documentation/networking/team.txt
>> new file mode 100644
>> index 0000000..5a01368
>> --- /dev/null
>> +++ b/Documentation/networking/team.txt
>> @@ -0,0 +1,2 @@
>> +Team devices are driven from userspace via libteam library which is here:
>> +	https://github.com/jpirko/libteam
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 5008b08..c33400d 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -6372,6 +6372,13 @@ W:	http://tcp-lp-mod.sourceforge.net/
>>  S:	Maintained
>>  F:	net/ipv4/tcp_lp.c
>>  
>> +TEAM DRIVER
>> +M:	Jiri Pirko <jpirko@redhat.com>
>> +L:	netdev@vger.kernel.org
>> +S:	Supported
>> +F:	drivers/net/team/
>> +F:	include/linux/if_team.h
>> +
>>  TEGRA SUPPORT
>>  M:	Colin Cross <ccross@android.com>
>>  M:	Erik Gilling <konkers@android.com>
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index 583f66c..b3020be 100644
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
>> @@ -125,6 +125,8 @@ config IFB
>>  	  'ifb1' etc.
>>  	  Look at the iproute2 documentation directory for usage etc
>>  
>> +source "drivers/net/team/Kconfig"
>> +
>>  config MACVLAN
>>  	tristate "MAC-VLAN support (EXPERIMENTAL)"
>>  	depends on EXPERIMENTAL
>> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
>> index fa877cd..4e4ebfe 100644
>> --- a/drivers/net/Makefile
>> +++ b/drivers/net/Makefile
>> @@ -17,6 +17,7 @@ obj-$(CONFIG_NET) += Space.o loopback.o
>>  obj-$(CONFIG_NETCONSOLE) += netconsole.o
>>  obj-$(CONFIG_PHYLIB) += phy/
>>  obj-$(CONFIG_RIONET) += rionet.o
>> +obj-$(CONFIG_NET_TEAM) += team/
>>  obj-$(CONFIG_TUN) += tun.o
>>  obj-$(CONFIG_VETH) += veth.o
>>  obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
>> diff --git a/drivers/net/team/Kconfig b/drivers/net/team/Kconfig
>> new file mode 100644
>> index 0000000..70a43a6
>> --- /dev/null
>> +++ b/drivers/net/team/Kconfig
>> @@ -0,0 +1,38 @@
>> +menuconfig NET_TEAM
>> +	tristate "Ethernet team driver support (EXPERIMENTAL)"
>> +	depends on EXPERIMENTAL
>> +	---help---
>> +	  This allows one to create virtual interfaces that teams together
>> +	  multiple ethernet devices.
>> +
>> +	  Team devices can be added using the "ip" command from the
>> +	  iproute2 package:
>> +
>> +	  "ip link add link [ address MAC ] [ NAME ] type team"
>> +
>> +	  To compile this driver as a module, choose M here: the module
>> +	  will be called team.
>> +
>> +if NET_TEAM
>> +
>> +config NET_TEAM_MODE_ROUNDROBIN
>> +	tristate "Round-robin mode support"
>> +	depends on NET_TEAM
>> +	---help---
>> +	  Basic mode where port used for transmitting packets is selected in
>> +	  round-robin fashion using packet counter.
>> +
>> +	  To compile this team mode as a module, choose M here: the module
>> +	  will be called team_mode_roundrobin.
>> +
>> +config NET_TEAM_MODE_ACTIVEBACKUP
>> +	tristate "Active-backup mode support"
>> +	depends on NET_TEAM
>> +	---help---
>> +	  Only one port is active at a time and the rest of ports are used
>> +	  for backup.
>> +
>> +	  To compile this team mode as a module, choose M here: the module
>> +	  will be called team_mode_activebackup.
>> +
>> +endif # NET_TEAM
>> diff --git a/drivers/net/team/Makefile b/drivers/net/team/Makefile
>> new file mode 100644
>> index 0000000..85f2028
>> --- /dev/null
>> +++ b/drivers/net/team/Makefile
>> @@ -0,0 +1,7 @@
>> +#
>> +# Makefile for the network team driver
>> +#
>> +
>> +obj-$(CONFIG_NET_TEAM) += team.o
>> +obj-$(CONFIG_NET_TEAM_MODE_ROUNDROBIN) += team_mode_roundrobin.o
>> +obj-$(CONFIG_NET_TEAM_MODE_ACTIVEBACKUP) += team_mode_activebackup.o
>> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>> new file mode 100644
>> index 0000000..398be58
>> --- /dev/null
>> +++ b/drivers/net/team/team.c
>> @@ -0,0 +1,1593 @@
>> +/*
>> + * net/drivers/team/team.c - Network team device driver
>> + * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License as published by
>> + * the Free Software Foundation; either version 2 of the License, or
>> + * (at your option) any later version.
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/types.h>
>> +#include <linux/module.h>
>> +#include <linux/init.h>
>> +#include <linux/slab.h>
>> +#include <linux/rcupdate.h>
>> +#include <linux/errno.h>
>> +#include <linux/ctype.h>
>> +#include <linux/notifier.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/if_arp.h>
>> +#include <linux/socket.h>
>> +#include <linux/etherdevice.h>
>> +#include <linux/rtnetlink.h>
>> +#include <net/rtnetlink.h>
>> +#include <net/genetlink.h>
>> +#include <net/netlink.h>
>> +#include <linux/if_team.h>
>> +
>> +#define DRV_NAME "team"
>> +
>> +
>> +/**********
>> + * Helpers
>> + **********/
>> +
>> +#define team_port_exists(dev) (dev->priv_flags & IFF_TEAM_PORT)
>> +
>> +static struct team_port *team_port_get_rcu(const struct net_device *dev)
>> +{
>> +	struct team_port *port = rcu_dereference(dev->rx_handler_data);
>> +
>> +	return team_port_exists(dev) ? port : NULL;
>> +}
>> +
>> +static struct team_port *team_port_get_rtnl(const struct net_device *dev)
>> +{
>> +	struct team_port *port = rtnl_dereference(dev->rx_handler_data);
>> +
>> +	return team_port_exists(dev) ? port : NULL;
>> +}
>> +
>> +/*
>> + * Since the ability to change mac address for open port device is tested in
>> + * team_port_add, this function can be called without control of return value
>> + */
>> +static int __set_port_mac(struct net_device *port_dev,
>> +			  const unsigned char *dev_addr)
>> +{
>> +	struct sockaddr addr;
>> +
>> +	memcpy(addr.sa_data, dev_addr, ETH_ALEN);
>> +	addr.sa_family = ARPHRD_ETHER;
>> +	return dev_set_mac_address(port_dev, &addr);
>> +}
>> +
>> +int team_port_set_orig_mac(struct team_port *port)
>> +{
>> +	return __set_port_mac(port->dev, port->orig.dev_addr);
>> +}
>> +EXPORT_SYMBOL(team_port_set_orig_mac);
>> +
>> +int team_port_set_team_mac(struct team_port *port)
>> +{
>> +	return __set_port_mac(port->dev, port->team->dev->dev_addr);
>> +}
>> +EXPORT_SYMBOL(team_port_set_team_mac);
>> +
>> +
>> +/*******************
>> + * Options handling
>> + *******************/
>> +
>> +void team_options_register(struct team *team, struct team_option *option,
>> +			   size_t option_count)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < option_count; i++, option++)
>> +		list_add_tail(&option->list, &team->option_list);
>> +}
>> +EXPORT_SYMBOL(team_options_register);
>> +
>> +static void __team_options_change_check(struct team *team,
>> +					struct team_option *changed_option);
>> +
>> +static void __team_options_unregister(struct team *team,
>> +				      struct team_option *option,
>> +				      size_t option_count)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < option_count; i++, option++)
>> +		list_del(&option->list);
>> +}
>> +
>> +void team_options_unregister(struct team *team, struct team_option *option,
>> +			     size_t option_count)
>> +{
>> +	__team_options_unregister(team, option, option_count);
>> +	__team_options_change_check(team, NULL);
>> +}
>> +EXPORT_SYMBOL(team_options_unregister);
>> +
>> +static int team_option_get(struct team *team, struct team_option *option,
>> +			   void *arg)
>> +{
>> +	return option->getter(team, arg);
>> +}
>> +
>> +static int team_option_set(struct team *team, struct team_option *option,
>> +			   void *arg)
>> +{
>> +	int err;
>> +
>> +	err = option->setter(team, arg);
>> +	if (err)
>> +		return err;
>> +
>> +	__team_options_change_check(team, option);
>> +	return err;
>> +}
>> +
>> +/****************
>> + * Mode handling
>> + ****************/
>> +
>> +static LIST_HEAD(mode_list);
>> +static DEFINE_SPINLOCK(mode_list_lock);
>> +
>> +static struct team_mode *__find_mode(const char *kind)
>> +{
>> +	struct team_mode *mode;
>> +
>> +	list_for_each_entry(mode, &mode_list, list) {
>> +		if (strcmp(mode->kind, kind) == 0)
>> +			return mode;
>> +	}
>> +	return NULL;
>> +}
>> +
>> +static bool is_good_mode_name(const char *name)
>> +{
>> +	while (*name != '\0') {
>> +		if (!isalpha(*name) && !isdigit(*name) && *name != '_')
>> +			return false;
>> +		name++;
>> +	}
>> +	return true;
>> +}
>> +
>> +int team_mode_register(struct team_mode *mode)
>> +{
>> +	int err = 0;
>> +
>> +	if (!is_good_mode_name(mode->kind) ||
>> +	    mode->priv_size > TEAM_MODE_PRIV_SIZE)
>> +		return -EINVAL;
>> +	spin_lock(&mode_list_lock);
>> +	if (__find_mode(mode->kind)) {
>> +		err = -EEXIST;
>> +		goto unlock;
>> +	}
>> +	list_add_tail(&mode->list, &mode_list);
>> +unlock:
>> +	spin_unlock(&mode_list_lock);
>> +	return err;
>> +}
>> +EXPORT_SYMBOL(team_mode_register);
>> +
>> +int team_mode_unregister(struct team_mode *mode)
>> +{
>> +	spin_lock(&mode_list_lock);
>> +	list_del_init(&mode->list);
>> +	spin_unlock(&mode_list_lock);
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(team_mode_unregister);
>> +
>> +static struct team_mode *team_mode_get(const char *kind)
>> +{
>> +	struct team_mode *mode;
>> +
>> +	spin_lock(&mode_list_lock);
>> +	mode = __find_mode(kind);
>> +	if (!mode) {
>> +		spin_unlock(&mode_list_lock);
>> +		request_module("team-mode-%s", kind);
>> +		spin_lock(&mode_list_lock);
>> +		mode = __find_mode(kind);
>> +	}
>> +	if (mode)
>> +		if (!try_module_get(mode->owner))
>> +			mode = NULL;
>> +
>> +	spin_unlock(&mode_list_lock);
>> +	return mode;
>> +}
>> +
>> +static void team_mode_put(const char *kind)
>> +{
>> +	struct team_mode *mode;
>> +
>> +	spin_lock(&mode_list_lock);
>> +	mode = __find_mode(kind);
>> +	BUG_ON(!mode);
>> +	module_put(mode->owner);
>> +	spin_unlock(&mode_list_lock);
>> +}
>> +
>> +/*
>> + * We can benefit from the fact that it's ensured no port is present
>> + * at the time of mode change.
>> + */
>> +static int __team_change_mode(struct team *team,
>> +			      const struct team_mode *new_mode)
>> +{
>> +	/* Check if mode was previously set and do cleanup if so */
>> +	if (team->mode_kind) {
>> +		void (*exit_op)(struct team *team) = team->mode_ops.exit;
>> +
>> +		/* Clear ops area so no callback is called any longer */
>> +		memset(&team->mode_ops, 0, sizeof(struct team_mode_ops));
>> +
>> +		synchronize_rcu();
>> +
>> +		if (exit_op)
>> +			exit_op(team);
>> +		team_mode_put(team->mode_kind);
>> +		team->mode_kind = NULL;
>> +		/* zero private data area */
>> +		memset(&team->mode_priv, 0,
>> +		       sizeof(struct team) - offsetof(struct team, mode_priv));
>> +	}
>> +
>> +	if (!new_mode)
>> +		return 0;
>> +
>> +	if (new_mode->ops->init) {
>> +		int err;
>> +
>> +		err = new_mode->ops->init(team);
>> +		if (err)
>> +			return err;
>> +	}
>> +
>> +	team->mode_kind = new_mode->kind;
>> +	memcpy(&team->mode_ops, new_mode->ops, sizeof(struct team_mode_ops));
>> +
>> +	return 0;
>> +}
>> +
>> +static int team_change_mode(struct team *team, const char *kind)
>> +{
>> +	struct team_mode *new_mode;
>> +	struct net_device *dev = team->dev;
>> +	int err;
>> +
>> +	if (!list_empty(&team->port_list)) {
>> +		netdev_err(dev, "No ports can be present during mode change\n");
>> +		return -EBUSY;
>> +	}
>> +
>> +	if (team->mode_kind && strcmp(team->mode_kind, kind) == 0) {
>> +		netdev_err(dev, "Unable to change to the same mode the team is in\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	new_mode = team_mode_get(kind);
>> +	if (!new_mode) {
>> +		netdev_err(dev, "Mode \"%s\" not found\n", kind);
>> +		return -EINVAL;
>> +	}
>> +
>> +	err = __team_change_mode(team, new_mode);
>> +	if (err) {
>> +		netdev_err(dev, "Failed to change to mode \"%s\"\n", kind);
>> +		team_mode_put(kind);
>> +		return err;
>> +	}
>> +
>> +	netdev_info(dev, "Mode changed to \"%s\"\n", kind);
>> +	return 0;
>> +}
>> +
>> +
>> +/************************
>> + * Rx path frame handler
>> + ************************/
>> +
>> +/* note: already called with rcu_read_lock */
>> +static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
>> +{
>> +	struct sk_buff *skb = *pskb;
>> +	struct team_port *port;
>> +	struct team *team;
>> +	rx_handler_result_t res = RX_HANDLER_ANOTHER;
>> +
>> +	skb = skb_share_check(skb, GFP_ATOMIC);
>> +	if (!skb)
>> +		return RX_HANDLER_CONSUMED;
>> +
>> +	*pskb = skb;
>> +
>> +	port = team_port_get_rcu(skb->dev);
>> +	team = port->team;
>> +
>> +	if (team->mode_ops.receive)
>> +		res = team->mode_ops.receive(team, port, skb);
>> +
>> +	if (res == RX_HANDLER_ANOTHER) {
>> +		struct team_pcpu_stats *pcpu_stats;
>> +
>> +		pcpu_stats = this_cpu_ptr(team->pcpu_stats);
>> +		u64_stats_update_begin(&pcpu_stats->syncp);
>> +		pcpu_stats->rx_packets++;
>> +		pcpu_stats->rx_bytes += skb->len;
>> +		if (skb->pkt_type == PACKET_MULTICAST)
>> +			pcpu_stats->rx_multicast++;
>> +		u64_stats_update_end(&pcpu_stats->syncp);
>> +
>> +		skb->dev = team->dev;
>> +	} else {
>> +		this_cpu_inc(team->pcpu_stats->rx_dropped);
>> +	}
>> +
>> +	return res;
>> +}
>> +
>> +
>> +/****************
>> + * Port handling
>> + ****************/
>> +
>> +static bool team_port_find(const struct team *team,
>> +			   const struct team_port *port)
>> +{
>> +	struct team_port *cur;
>> +
>> +	list_for_each_entry(cur, &team->port_list, list)
>> +		if (cur == port)
>> +			return true;
>> +	return false;
>> +}
>> +
>> +static int team_port_list_init(struct team *team)
>> +{
>> +	int i;
>> +	struct hlist_head *hash;
>> +
>> +	hash = kmalloc(sizeof(*hash) * TEAM_PORT_HASHENTRIES, GFP_KERNEL);
>> +	if (!hash)
>> +		return -ENOMEM;
>> +
>> +	for (i = 0; i < TEAM_PORT_HASHENTRIES; i++)
>> +		INIT_HLIST_HEAD(&hash[i]);
>> +	team->port_hlist = hash;
>> +	INIT_LIST_HEAD(&team->port_list);
>> +	return 0;
>> +}
>> +
>> +static void team_port_list_fini(struct team *team)
>> +{
>> +	kfree(team->port_hlist);
>> +}
>> +
>> +/*
>> + * Add/delete port to the team port list. Write guarded by rtnl_lock.
>> + * Takes care of correct port->index setup (might be racy).
>> + */
>> +static void team_port_list_add_port(struct team *team,
>> +				    struct team_port *port)
>> +{
>> +	port->index = team->port_count++;
>> +	hlist_add_head_rcu(&port->hlist,
>> +			   team_port_index_hash(team, port->index));
>> +	list_add_tail_rcu(&port->list, &team->port_list);
>> +}
>> +
>> +static void __reconstruct_port_hlist(struct team *team, int rm_index)
>> +{
>> +	int i;
>> +	struct team_port *port;
>> +
>> +	for (i = rm_index + 1; i < team->port_count; i++) {
>> +		port = team_get_port_by_index_rcu(team, i);
>> +		hlist_del_rcu(&port->hlist);
>> +		port->index--;
>> +		hlist_add_head_rcu(&port->hlist,
>> +				   team_port_index_hash(team, port->index));
>> +	}
>> +}
>> +
>> +static void team_port_list_del_port(struct team *team,
>> +				   struct team_port *port)
>> +{
>> +	int rm_index = port->index;
>> +
>> +	hlist_del_rcu(&port->hlist);
>> +	list_del_rcu(&port->list);
>> +	__reconstruct_port_hlist(team, rm_index);
>> +	team->port_count--;
>> +}
>> +
>> +#define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
>> +			    NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
>> +			    NETIF_F_HIGHDMA | NETIF_F_LRO)
>> +
>> +static void __team_compute_features(struct team *team)
>> +{
>> +	struct team_port *port;
>> +	u32 vlan_features = TEAM_VLAN_FEATURES;
>> +	unsigned short max_hard_header_len = ETH_HLEN;
>> +
>> +	list_for_each_entry(port, &team->port_list, list) {
>> +		vlan_features = netdev_increment_features(vlan_features,
>> +					port->dev->vlan_features,
>> +					TEAM_VLAN_FEATURES);
>> +
>> +		if (port->dev->hard_header_len > max_hard_header_len)
>> +			max_hard_header_len = port->dev->hard_header_len;
>> +	}
>> +
>> +	team->dev->vlan_features = vlan_features;
>> +	team->dev->hard_header_len = max_hard_header_len;
>> +
>> +	netdev_change_features(team->dev);
>> +}
>> +
>> +static void team_compute_features(struct team *team)
>> +{
>> +	spin_lock(&team->lock);
>> +	__team_compute_features(team);
>> +	spin_unlock(&team->lock);
>> +}
>> +
>> +static int team_port_enter(struct team *team, struct team_port *port)
>> +{
>> +	int err = 0;
>> +
>> +	dev_hold(team->dev);
>> +	port->dev->priv_flags |= IFF_TEAM_PORT;
>> +	if (team->mode_ops.port_enter) {
>> +		err = team->mode_ops.port_enter(team, port);
>> +		if (err)
>> +			netdev_err(team->dev, "Device %s failed to enter team mode\n",
>> +				   port->dev->name);
>> +	}
>> +	return err;
>> +}
>> +
>> +static void team_port_leave(struct team *team, struct team_port *port)
>> +{
>> +	if (team->mode_ops.port_leave)
>> +		team->mode_ops.port_leave(team, port);
>> +	port->dev->priv_flags &= ~IFF_TEAM_PORT;
>> +	dev_put(team->dev);
>> +}
>> +
>> +static void __team_port_change_check(struct team_port *port, bool linkup);
>> +
>> +static int team_port_add(struct team *team, struct net_device *port_dev)
>> +{
>> +	struct net_device *dev = team->dev;
>> +	struct team_port *port;
>> +	char *portname = port_dev->name;
>> +	char tmp_addr[ETH_ALEN];
>> +	int err;
>> +
>> +	if (port_dev->flags & IFF_LOOPBACK ||
>> +	    port_dev->type != ARPHRD_ETHER) {
>> +		netdev_err(dev, "Device %s is of an unsupported type\n",
>> +			   portname);
>> +		return -EINVAL;
>> +	}
>> +
>> +	if (team_port_exists(port_dev)) {
>> +		netdev_err(dev, "Device %s is already a port "
>> +				"of a team device\n", portname);
>> +		return -EBUSY;
>> +	}
>> +
>> +	if (port_dev->flags & IFF_UP) {
>> +		netdev_err(dev, "Device %s is up. Set it down before adding it as a team port\n",
>> +			   portname);
>> +		return -EBUSY;
>> +	}
>> +
>> +	port = kzalloc(sizeof(struct team_port), GFP_KERNEL);
>> +	if (!port)
>> +		return -ENOMEM;
>> +
>> +	port->dev = port_dev;
>> +	port->team = team;
>> +
>> +	port->orig.mtu = port_dev->mtu;
>> +	err = dev_set_mtu(port_dev, dev->mtu);
>> +	if (err) {
>> +		netdev_dbg(dev, "Error %d calling dev_set_mtu\n", err);
>> +		goto err_set_mtu;
>> +	}
>> +
>> +	memcpy(port->orig.dev_addr, port_dev->dev_addr, ETH_ALEN);
>> +	random_ether_addr(tmp_addr);
>> +	err = __set_port_mac(port_dev, tmp_addr);
>> +	if (err) {
>> +		netdev_dbg(dev, "Device %s mac addr set failed\n",
>> +			   portname);
>> +		goto err_set_mac_rand;
>> +	}
>> +
>> +	err = dev_open(port_dev);
>> +	if (err) {
>> +		netdev_dbg(dev, "Device %s opening failed\n",
>> +			   portname);
>> +		goto err_dev_open;
>> +	}
>> +
>> +	err = team_port_set_orig_mac(port);
>> +	if (err) {
>> +		netdev_dbg(dev, "Device %s mac addr set failed - Device does not support addr change when it's opened\n",
>> +			   portname);
>> +		goto err_set_mac_opened;
>> +	}
>> +
>> +	err = team_port_enter(team, port);
>> +	if (err) {
>> +		netdev_err(dev, "Device %s failed to enter team mode\n",
>> +			   portname);
>> +		goto err_port_enter;
>> +	}
>> +
>> +	err = netdev_set_master(port_dev, dev);
>> +	if (err) {
>> +		netdev_err(dev, "Device %s failed to set master\n", portname);
>> +		goto err_set_master;
>> +	}
>> +
>> +	err = netdev_rx_handler_register(port_dev, team_handle_frame,
>> +					 port);
>> +	if (err) {
>> +		netdev_err(dev, "Device %s failed to register rx_handler\n",
>> +			   portname);
>> +		goto err_handler_register;
>> +	}
>> +
>> +	team_port_list_add_port(team, port);
>> +	__team_compute_features(team);
>> +	__team_port_change_check(port, !!netif_carrier_ok(port_dev));
>> +
>> +	netdev_info(dev, "Port device %s added\n", portname);
>> +
>> +	return 0;
>> +
>> +err_handler_register:
>> +	netdev_set_master(port_dev, NULL);
>> +
>> +err_set_master:
>> +	team_port_leave(team, port);
>> +
>> +err_port_enter:
>> +err_set_mac_opened:
>> +	dev_close(port_dev);
>> +
>> +err_dev_open:
>> +	team_port_set_orig_mac(port);
>> +
>> +err_set_mac_rand:
>> +	dev_set_mtu(port_dev, port->orig.mtu);
>> +
>> +err_set_mtu:
>> +	kfree(port);
>> +
>> +	return err;
>> +}
>> +
>> +static int team_port_del(struct team *team, struct net_device *port_dev)
>> +{
>> +	struct net_device *dev = team->dev;
>> +	struct team_port *port;
>> +	char *portname = port_dev->name;
>> +
>> +	port = team_port_get_rtnl(port_dev);
>> +	if (!port || !team_port_find(team, port)) {
>> +		netdev_err(dev, "Device %s does not act as a port of this team\n",
>> +			   portname);
>> +		return -ENOENT;
>> +	}
>> +
>> +	__team_port_change_check(port, false);
>> +	team_port_list_del_port(team, port);
>> +	netdev_rx_handler_unregister(port_dev);
>> +	netdev_set_master(port_dev, NULL);
>> +	team_port_leave(team, port);
>> +	dev_close(port_dev);
>> +	team_port_set_orig_mac(port);
>> +	dev_set_mtu(port_dev, port->orig.mtu);
>> +	synchronize_rcu();
>> +	kfree(port);
>> +	netdev_info(dev, "Port device %s removed\n", portname);
>> +	__team_compute_features(team);
>> +
>> +	return 0;
>> +}
>> +
>> +
>> +/*****************
>> + * Net device ops
>> + *****************/
>> +
>> +static const char team_no_mode_kind[] = "*NOMODE*";
>> +
>> +static int team_mode_option_get(struct team *team, void *arg)
>> +{
>> +	const char **str = arg;
>> +
>> +	*str = team->mode_kind ? team->mode_kind : team_no_mode_kind;
>> +	return 0;
>> +}
>> +
>> +static int team_mode_option_set(struct team *team, void *arg)
>> +{
>> +	const char **str = arg;
>> +
>> +	return team_change_mode(team, *str);
>> +}
>> +
>> +static struct team_option team_options[] = {
>> +	{
>> +		.name = "mode",
>> +		.type = TEAM_OPTION_TYPE_STRING,
>> +		.getter = team_mode_option_get,
>> +		.setter = team_mode_option_set,
>> +	},
>> +};
>> +
>> +static int team_init(struct net_device *dev)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	int err;
>> +
>> +	team->dev = dev;
>> +	spin_lock_init(&team->lock);
>> +
>> +	team->pcpu_stats = alloc_percpu(struct team_pcpu_stats);
>> +	if (!team->pcpu_stats)
>> +		return -ENOMEM;
>> +
>> +	err = team_port_list_init(team);
>> +	if (err)
>> +		goto err_port_list_init;
>> +
>> +	INIT_LIST_HEAD(&team->option_list);
>> +	team_options_register(team, team_options, ARRAY_SIZE(team_options));
>> +	netif_carrier_off(dev);
>> +
>> +	return 0;
>> +
>> +err_port_list_init:
>> +
>> +	free_percpu(team->pcpu_stats);
>> +
>> +	return err;
>> +}
>> +
>> +static void team_uninit(struct net_device *dev)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +	struct team_port *tmp;
>> +
>> +	spin_lock(&team->lock);
>> +	list_for_each_entry_safe(port, tmp, &team->port_list, list)
>> +		team_port_del(team, port->dev);
>> +
>> +	__team_change_mode(team, NULL); /* cleanup */
>> +	__team_options_unregister(team, team_options, ARRAY_SIZE(team_options));
>> +	spin_unlock(&team->lock);
>> +}
>> +
>> +static void team_destructor(struct net_device *dev)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +
>> +	team_port_list_fini(team);
>> +	free_percpu(team->pcpu_stats);
>> +	free_netdev(dev);
>> +}
>> +
>> +static int team_open(struct net_device *dev)
>> +{
>> +	netif_carrier_on(dev);
>> +	return 0;
>> +}
>> +
>> +static int team_close(struct net_device *dev)
>> +{
>> +	netif_carrier_off(dev);
>> +	return 0;
>> +}
>> +
>> +/*
>> + * note: already called with rcu_read_lock
>> + */
>> +static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_device *dev)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	bool tx_success = false;
>> +	unsigned int len = skb->len;
>> +
>> +	/*
>> +	 * Ensure transmit function is called only in case there is at least
>> +	 * one port present.
>> +	 */
>> +	if (likely(!list_empty(&team->port_list) && team->mode_ops.transmit))
>> +		tx_success = team->mode_ops.transmit(team, skb);
>> +	if (tx_success) {
>> +		struct team_pcpu_stats *pcpu_stats;
>> +
>> +		pcpu_stats = this_cpu_ptr(team->pcpu_stats);
>> +		u64_stats_update_begin(&pcpu_stats->syncp);
>> +		pcpu_stats->tx_packets++;
>> +		pcpu_stats->tx_bytes += len;
>> +		u64_stats_update_end(&pcpu_stats->syncp);
>> +	} else {
>> +		this_cpu_inc(team->pcpu_stats->tx_dropped);
>> +	}
>> +
>> +	return NETDEV_TX_OK;
>> +}
>> +
>> +static void team_change_rx_flags(struct net_device *dev, int change)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +	int inc;
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(port, &team->port_list, list) {
>> +		if (change & IFF_PROMISC) {
>> +			inc = dev->flags & IFF_PROMISC ? 1 : -1;
>> +			dev_set_promiscuity(port->dev, inc);
>> +		}
>> +		if (change & IFF_ALLMULTI) {
>> +			inc = dev->flags & IFF_ALLMULTI ? 1 : -1;
>> +			dev_set_allmulti(port->dev, inc);
>> +		}
>> +	}
>> +	rcu_read_unlock();
>> +}
>> +
>> +static void team_set_rx_mode(struct net_device *dev)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(port, &team->port_list, list) {
>> +		dev_uc_sync(port->dev, dev);
>> +		dev_mc_sync(port->dev, dev);
>> +	}
>> +	rcu_read_unlock();
>> +}
>> +
>> +static int team_set_mac_address(struct net_device *dev, void *p)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +	struct sockaddr *addr = p;
>> +
>> +	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(port, &team->port_list, list)
>> +		if (team->mode_ops.port_change_mac)
>> +			team->mode_ops.port_change_mac(team, port);
>> +	rcu_read_unlock();
>> +	return 0;
>> +}
>> +
>> +static int team_change_mtu(struct net_device *dev, int new_mtu)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +	int err;
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(port, &team->port_list, list) {
>> +		err = dev_set_mtu(port->dev, new_mtu);
>> +		if (err) {
>> +			netdev_err(dev, "Device %s failed to change mtu",
>> +				   port->dev->name);
>> +			goto unwind;
>> +		}
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	dev->mtu = new_mtu;
>> +
>> +	return 0;
>> +
>> +unwind:
>> +	list_for_each_entry_continue_reverse(port, &team->port_list, list)
>> +		dev_set_mtu(port->dev, dev->mtu);
>
>It may be worth noting that backwards list traversal is not rcu safe.
>Under rcu_read_lock() list elements will not be freed but the list may
>be modified. Moreover, list_del_rcu() poisons ->prev pointers.
>
>In this case it doesn't really matter though. As Eric pointed out
>previously, we are under rtnl protection and no rcu is needed. Perhaps
>all the extra rcu locking should be removed?

Thanks for catching this. I will perhaps fix this in incremental patch
(in case there will be no more problems with this one).
list_for_each_entry_continue_reverse_rcu needs to be added ro rculist.h

And regarding rtnl. As I stated in v1 of this patch I do not want to
depend on rtnl. Team has spinlock to protect multiple writer access and
in this case, team_change_mtu code is reader.

Thanks.
Jirka


>
>-Ben
>
>> +
>> +	rcu_read_unlock();
>> +	return err;
>> +}
>> +
