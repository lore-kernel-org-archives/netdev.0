From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next-2.6] net: introduce ethernet teaming device
Date: Tue, 4 Oct 2011 11:53:44 -0300
Message-ID: <20111004115344.0aca0fa1@asterix.rh>
References: <1317737703-19457-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932141Ab1JDOyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Oct 2011 10:54:16 -0400
In-Reply-To: <1317737703-19457-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue,  4 Oct 2011 16:15:03 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> This patch introduces new network device called team. It supposes to
> be very fast, simple, userspace-driven alternative to existing bonding
> driver.
> 
> Userspace library called libteam with couple of demo apps is available
> here:
> https://github.com/jpirko/libteam
> Note it's still in its dipers atm.
> 
> team<->libteam use generic netlink for communication. That and rtnl
> suppose to be the only way to configure team device, no sysfs etc.
> 
> In near future python binding for libteam will be introduced. Also
> daemon providing arpmon/miimon active-backup functionality will
> be introduced. All what's necessary is already implemented in kernel
> team driver.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  Documentation/networking/team.txt |    2 +
>  MAINTAINERS                       |    7 +
>  drivers/net/Kconfig               |   15 +
>  drivers/net/Makefile              |    1 +
>  drivers/net/team.c                | 1819
> +++++++++++++++++++++++++++++++++++++
> include/linux/Kbuild              |    1 +
> include/linux/if.h                |    1 +
> include/linux/if_team.h           |  126 +++ 8 files changed, 1972
> insertions(+), 0 deletions(-) create mode 100644
> Documentation/networking/team.txt create mode 100644
> drivers/net/team.c create mode 100644 include/linux/if_team.h
> 
> diff --git a/Documentation/networking/team.txt
> b/Documentation/networking/team.txt new file mode 100644
> index 0000000..5a01368
> --- /dev/null
> +++ b/Documentation/networking/team.txt
> @@ -0,0 +1,2 @@
> +Team devices are driven from userspace via libteam library which is
> here:
> +	https://github.com/jpirko/libteam
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 65ca7ea..f846c6b 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6372,6 +6372,13 @@ W:	http://tcp-lp-mod.sourceforge.net/
>  S:	Maintained
>  F:	net/ipv4/tcp_lp.c
>  
> +TEAM DRIVER
> +M:	Jiri Pirko <jpirko@redhat.com>
> +L:	netdev@vger.kernel.org
> +S:	Supported
> +F:	drivers/net/team.c
> +F:	include/linux/team.h
> +
>  TEGRA SUPPORT
>  M:	Colin Cross <ccross@android.com>
>  M:	Erik Gilling <konkers@android.com>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 583f66c..0d74e9d 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -125,6 +125,21 @@ config IFB
>  	  'ifb1' etc.
>  	  Look at the iproute2 documentation directory for usage etc
>  
> +config NET_TEAM
> +	tristate "Ethernet teaming support (EXPERIMENTAL)"
> +	depends on EXPERIMENTAL
> +	---help---
> +	  This allows one to create virtual interfaces that teams
> together
> +	  multiple ethernet devices.
> +
> +	  Team devices can be added using the "ip" command from the
> +	  iproute2 package:
> +
> +	  "ip link add link [ address MAC ] [ NAME ] type team"
> +
> +	  To compile this driver as a module, choose M here: the
> module
> +	  will be called team.
> +
>  config MACVLAN
>  	tristate "MAC-VLAN support (EXPERIMENTAL)"
>  	depends on EXPERIMENTAL
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index fa877cd..e3d3e81 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -17,6 +17,7 @@ obj-$(CONFIG_NET) += Space.o loopback.o
>  obj-$(CONFIG_NETCONSOLE) += netconsole.o
>  obj-$(CONFIG_PHYLIB) += phy/
>  obj-$(CONFIG_RIONET) += rionet.o
> +obj-$(CONFIG_NET_TEAM) += team.o
>  obj-$(CONFIG_TUN) += tun.o
>  obj-$(CONFIG_VETH) += veth.o
>  obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
> diff --git a/drivers/net/team.c b/drivers/net/team.c
> new file mode 100644
> index 0000000..c9ae388
> --- /dev/null
> +++ b/drivers/net/team.c
> @@ -0,0 +1,1819 @@
> +/*
> + * net/drivers/team.c - Network team device driver
> + * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
> + *
> + * This program is free software; you can redistribute it and/or
> modify
> + * it under the terms of the GNU General Public License as published
> by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/slab.h>
> +#include <linux/rcupdate.h>
> +#include <linux/errno.h>
> +#include <linux/notifier.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_arp.h>
> +#include <linux/socket.h>
> +#include <linux/etherdevice.h>
> +#include <linux/rtnetlink.h>
> +#include <net/rtnetlink.h>
> +#include <net/genetlink.h>
> +#include <net/netlink.h>
> +#include <linux/if_team.h>
> +
> +#define DRV_NAME "team"
> +
> +
> +/*************************************
> + * Structures and helpers definitions
> + *************************************/
> +
> +struct team;
> +
> +struct team_port {
> +	struct net_device *dev;
> +	struct hlist_node hlist; /* node in hash list */
> +	struct list_head list; /* node in ordinary list */
> +	struct team *team;
> +	int index;
> +
> +	/*
> +	 * A place for storing original values of the device before
> it
> +	 * become a port.
> +	 */
> +	struct {
> +		unsigned char dev_addr[MAX_ADDR_LEN];
> +		unsigned int mtu;
> +	} orig;
> +
> +	bool linkup;
> +	u32 speed;
> +	u8 duplex;
> +
> +	struct rcu_head rcu;
> +};
> +
> +struct team_mode_ops {
> +	int (*init)(struct team *team);
> +	void (*exit)(struct team *team);
> +	rx_handler_result_t (*receive)(struct team *team,
> +				       struct team_port *port,
> +				       struct sk_buff *skb);

nitpick:
As it doesn't have any other type of results, I would suggest
to rename rx_handler_result_t be to shorter, i.e. rx_result_t.


> +	bool (*transmit)(struct team *team, struct sk_buff *skb);
> +	int (*port_enter)(struct team *team, struct team_port *port);

Perhaps instead of 'port_enter', use 'port_join'.


> +	void (*port_leave)(struct team *team, struct team_port
> *port);
> +	void (*port_change_mac)(struct team *team, struct team_port
> *port); +};
> +
> +enum team_option_type {
> +	TEAM_OPTION_TYPE_U32,
> +	TEAM_OPTION_TYPE_STRING,
> +};
> +
> +struct team_option {
> +	struct list_head list;
> +	const char *name;
> +	enum team_option_type type;
> +	int (*getter)(struct team *team, void *arg);
> +	int (*setter)(struct team *team, void *arg);

What means getter and setter?

> +};
> +
> +struct team_mode {
> +	const char *kind;
> +	const struct team_mode_ops *ops;
> +};
> +
> +struct rr_priv {
> +	unsigned int sent_packets;
> +};
> +
> +struct ab_priv {
> +	struct team_port __rcu *active_port;
> +};
> +
> +struct team {
> +	struct net_device *dev; /* associated netdevice */
> +	spinlock_t lock; /* used for overall locking, e.g. port
> lists write */ +
> +	/*
> +	 * port lists with port count
> +	 */
> +	int port_count;
> +	struct hlist_head *port_hlist;
> +	struct list_head port_list;
> +
> +	struct list_head option_list;
> +
> +	const char *mode_kind;
> +	struct team_mode_ops mode_ops;
> +	union {
> +		char priv_first_byte;
> +		struct ab_priv ab_priv;
> +		struct rr_priv rr_priv;
> +	};

I think the union should be a pointer or work in the same
way as netdev_priv() does.

> +};
> +
> +#define TEAM_PORT_HASHBITS 4
> +#define TEAM_PORT_HASHENTRIES (1 << TEAM_PORT_HASHBITS)
> +
> +static struct hlist_head *team_port_index_hash(const struct team
> *team,
> +					       int port_index)
> +{
> +	return &team->port_hlist[port_index & (TEAM_PORT_HASHENTRIES
> - 1)]; +}
> +
> +static struct team_port *team_get_port_by_index_rcu(const struct
> team *team,
> +						    int port_index)
> +{
> +	struct hlist_node *p;
> +	struct team_port *port;
> +	struct hlist_head *head = team_port_index_hash(team,
> port_index); +
> +	hlist_for_each_entry_rcu(port, p, head, hlist)
> +		if (port->index == port_index)
> +			return port;
> +	return NULL;
> +}
> +
> +static bool team_port_find(const struct team *team,
> +			   const struct team_port *port)
> +{
> +	struct team_port *cur;
> +
> +	list_for_each_entry(cur, &team->port_list, list)
> +		if (cur == port)
> +			return true;
> +	return false;
> +}
> +
> +#define team_port_exists(dev) (dev->priv_flags & IFF_TEAM_PORT)
> +
> +static struct team_port *team_port_get_rcu(const struct net_device
> *dev) +{
> +	struct team_port *port =
> rcu_dereference(dev->rx_handler_data); +
> +	return team_port_exists(dev) ? port : NULL;
> +}
> +
> +static struct team_port *team_port_get_rtnl(const struct net_device
> *dev) +{
> +	struct team_port *port =
> rtnl_dereference(dev->rx_handler_data); +
> +	return team_port_exists(dev) ? port : NULL;
> +}
> +
> +/*
> + * Since the ability to change mac address for open port device is
> tested in
> + * team_port_add, this function can be called without control of
> return value
> + */
> +static int __set_port_mac(struct net_device *port_dev,
> +			  const unsigned char *dev_addr)
> +{
> +	struct sockaddr addr;
> +
> +	memcpy(addr.sa_data, dev_addr, ETH_ALEN);
> +	addr.sa_family = ARPHRD_ETHER;
> +	return dev_set_mac_address(port_dev, &addr);
> +}
> +
> +static int team_port_set_orig_mac(struct team_port *port)
> +{
> +	return __set_port_mac(port->dev, port->orig.dev_addr);
> +}
> +
> +static int team_port_set_team_mac(struct team_port *port)
> +{
> +	return __set_port_mac(port->dev, port->team->dev->dev_addr);
> +}
> +
> +
> +/*******************
> + * Options handling
> + *******************/
> +
> +static void team_options_register(struct team *team,
> +				  struct team_option *option,
> +				  size_t option_count)
> +{
> +	int i;
> +
> +	for (i = 0; i < option_count; i++, option++)
> +		list_add_tail(&option->list, &team->option_list);
> +}
> +
> +static void __team_options_change_check(struct team *team,
> +					struct team_option
> *changed_option); +
> +static void __team_options_unregister(struct team *team,
> +				      struct team_option *option,
> +				      size_t option_count)
> +{
> +	int i;
> +
> +	for (i = 0; i < option_count; i++, option++)
> +		list_del(&option->list);
> +}
> +
> +static void team_options_unregister(struct team *team,
> +				    struct team_option *option,
> +				    size_t option_count)
> +{
> +	__team_options_unregister(team, option, option_count);
> +	__team_options_change_check(team, NULL);
> +}
> +
> +static int team_option_get(struct team *team, struct team_option
> *option,
> +			   void *arg)
> +{
> +	return option->getter(team, arg);
> +}
> +
> +static int team_option_set(struct team *team, struct team_option
> *option,
> +			   void *arg)
> +{
> +	int err;
> +
> +	err = option->setter(team, arg);
> +	if (err)
> +		return err;
> +
> +	__team_options_change_check(team, option);
> +	return err;
> +}
> +
> +/******************************
> + * Round-robin mode definition
> + ******************************/
> +
> +static struct team_port *__get_first_port_up(struct team *team,
> +					     struct team_port *port)
> +{
> +	struct team_port *cur;
> +
> +	if (port->linkup)
> +		return port;
> +	cur = port;
> +	list_for_each_entry_continue_rcu(cur, &team->port_list, list)
> +		if (cur->linkup)
> +			return cur;
> +	list_for_each_entry_rcu(cur, &team->port_list, list) {
> +		if (cur == port)
> +			break;
> +		if (cur->linkup)
> +			return cur;
> +	}
> +	return NULL;
> +}
> +
> +static bool rr_transmit(struct team *team, struct sk_buff *skb)
> +{
> +	struct team_port *port;
> +	int port_index;
> +
> +	port_index = team->rr_priv.sent_packets++ % team->port_count;
> +	port = team_get_port_by_index_rcu(team, port_index);
> +	port = __get_first_port_up(team, port);

Well, __get_first_port_up() will frequently just do:

	if (port->linkup)
		return port;

so, as it is in the hot TX path, can this be modified to be something
like below to avoid one function call?

        port = team_get_port_by_index_rcu(team, port_index);
        if (unlikely(port->linkup))
            port = __get_first_port_up(team, port);

> +	if (unlikely(!port))
> +		goto drop;
> +	skb->dev = port->dev;
> +	if (dev_queue_xmit(skb))
> +		goto drop;
> +
> +	return true;
> +
> +drop:
> +	dev_kfree_skb(skb);
> +	return false;
> +}
> +
> +static int rr_port_enter(struct team *team, struct team_port *port)
> +{
> +	return team_port_set_team_mac(port);
> +}
> +
> +static void rr_port_change_mac(struct team *team, struct team_port
> *port) +{
> +	team_port_set_team_mac(port);
> +}
> +
> +static const struct team_mode_ops rr_mode_ops = {
> +	.transmit		= rr_transmit,
> +	.port_enter		= rr_port_enter,
> +	.port_change_mac	= rr_port_change_mac,
> +};
> +
> +static const struct team_mode rr_mode = {
> +	.kind		= "roundrobin",
> +	.ops		= &rr_mode_ops,
> +};
> +
> +
> +/********************************
> + * Active-backup mode definition
> + ********************************/
> +
> +static rx_handler_result_t ab_receive(struct team *team, struct
> team_port *port,
> +				      struct sk_buff *skb) {
> +	struct team_port *active_port;
> +
> +	active_port = rcu_dereference(team->ab_priv.active_port);
> +	if (active_port != port)
> +		return RX_HANDLER_EXACT;
> +	return RX_HANDLER_ANOTHER;
> +}
> +
> +static bool ab_transmit(struct team *team, struct sk_buff *skb)
> +{
> +	struct team_port *active_port;
> +
> +	active_port = rcu_dereference(team->ab_priv.active_port);
> +	if (unlikely(!active_port))
> +		goto drop;
> +	skb->dev = active_port->dev;
> +	if (dev_queue_xmit(skb))
> +		goto drop;
> +	return true;
> +
> +drop:
> +	dev_kfree_skb(skb);
> +	return false;
> +}
> +
> +static void ab_port_leave(struct team *team, struct team_port *port)
> +{
> +	if (team->ab_priv.active_port == port)
> +		rcu_assign_pointer(team->ab_priv.active_port, NULL);
> +}
> +
> +static void ab_port_change_mac(struct team *team, struct team_port
> *port) +{
> +	if (team->ab_priv.active_port == port)
> +		team_port_set_team_mac(port);
> +}
> +
> +static int ab_active_port_get(struct team *team, void *arg)
> +{
> +	u32 *ifindex = arg;
> +
> +	*ifindex = 0;
> +	if (team->ab_priv.active_port)
> +		*ifindex = team->ab_priv.active_port->dev->ifindex;
> +	return 0;
> +}
> +
> +static int ab_active_port_set(struct team *team, void *arg)
> +{
> +	u32 *ifindex = arg;
> +	struct team_port *port;
> +
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		if (port->dev->ifindex == *ifindex) {
> +			struct team_port *ac_port =
> team->ab_priv.active_port; +
> +			/* rtnl_lock needs to be held when setting
> macs */
> +			rtnl_lock();
> +			if (ac_port)
> +				team_port_set_orig_mac(ac_port);
> +
> rcu_assign_pointer(team->ab_priv.active_port, port);
> +			team_port_set_team_mac(port);
> +			rtnl_unlock();
> +			return 0;
> +		}
> +	}
> +	return -ENOENT;
> +}
> +
> +static struct team_option ab_options[] = {
> +	{
> +		.name = "activeport",
> +		.type = TEAM_OPTION_TYPE_U32,
> +		.getter = ab_active_port_get,
> +		.setter = ab_active_port_set,
> +	},
> +};
> +
> +int ab_init(struct team *team)
> +{
> +	team_options_register(team, ab_options,
> ARRAY_SIZE(ab_options));
> +	return 0;
> +}
> +
> +void ab_exit(struct team *team)
> +{
> +	team_options_unregister(team, ab_options,
> ARRAY_SIZE(ab_options)); +}
> +
> +static const struct team_mode_ops ab_mode_ops = {
> +	.init			= ab_init,
> +	.exit			= ab_exit,
> +	.receive		= ab_receive,
> +	.transmit		= ab_transmit,
> +	.port_leave		= ab_port_leave,
> +	.port_change_mac	= ab_port_change_mac,
> +};
> +
> +static const struct team_mode ab_mode = {
> +	.kind		= "activebackup",
> +	.ops		= &ab_mode_ops,
> +};
> +

I would suggest to move each of the ab and rr specifics
to their own module.  The idea is to have the team module
as a generic module as possible and every mode on its module.
Not sure what your plans are for this.


> +/****************
> + * Mode handling
> + ****************/
> +
> +static const struct team_mode *team_modes[] = {
> +	&rr_mode,
> +	&ab_mode,
> +};

Following the above suggestion, this would require
register/unregister ops.


> +
> +static const int team_mode_count = ARRAY_SIZE(team_modes);
> +
> +static int team_find_mode(const char *kind)
> +{
> +	int i;
> +
> +	for (i = 0; i < team_mode_count; i++) {
> +		const struct team_mode *mode = team_modes[i];
> +
> +		if (strcmp(mode->kind, kind) == 0)
> +			return i;
> +	}
> +	return -ENOENT;
> +}
> +
> +/*
> + * We can benefit from the fact that it's ensured no port is present
> + * at the time of mode change.
> + */
> +static void __team_change_mode(struct team *team, const int
> mode_index) +{
> +	const struct team_mode *mode = team_modes[mode_index];
> +
> +	if (team->mode_ops.exit)
> +		team->mode_ops.exit(team);
> +
> +	if (mode_index < 0)
> +		return;
> +
> +	memcpy(&team->mode_ops, mode->ops, sizeof(struct
> team_mode_ops)); +
> +	/* zero private data area */
> +	memset(&team->priv_first_byte, 0,
> +	       sizeof(struct team) - offsetof(struct team,
> priv_first_byte)); +
> +	team->mode_kind = mode->kind;
> +	if (team->mode_ops.init)
> +		team->mode_ops.init(team);
> +
> +	return;
> +}
> +
> +static int team_change_mode(struct team *team, const char *kind)
> +{
> +	int mode_index;
> +	struct net_device *dev = team->dev;
> +
> +	if (!list_empty(&team->port_list)) {
> +		netdev_err(dev, "No ports can be present during "
> +				"mode change\n");
> +		return -EBUSY;
> +	}
> +
> +	if (strcmp(team->mode_kind, kind) == 0) {
> +		netdev_err(dev, "Unable to change to the same mode "
> +				"the team is in\n");
> +		return -EINVAL;
> +	}
> +
> +	mode_index = team_find_mode(kind);
> +	if (mode_index < 0) {
> +		netdev_err(dev, "Mode \"%s\" is not loaded\n", kind);
> +		return -EINVAL;
> +	}
> +
> +	__team_change_mode(team, mode_index);
> +
> +	netdev_info(dev, "Mode changed to \"%s\"\n", kind);
> +	return 0;
> +}
> +
> +
> +/************************
> + * Rx path frame handler
> + ************************/
> +
> +/* note: already called with rcu_read_lock */
> +static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
> +{
> +	struct sk_buff *skb = *pskb;
> +	struct team_port *port;
> +	struct team *team;
> +	rx_handler_result_t res = RX_HANDLER_ANOTHER;
> +
> +	skb = skb_share_check(skb, GFP_ATOMIC);
> +	if (!skb)
> +		return RX_HANDLER_CONSUMED;
> +
> +	*pskb = skb;
> +
> +	port = team_port_get_rcu(skb->dev);
> +	team = port->team;
> +
> +	if (team->mode_ops.receive)
> +		 res = team->mode_ops.receive(team, port, skb);
> +
> +	if (res == RX_HANDLER_ANOTHER)
> +		skb->dev = team->dev;
> +
> +	return res;
> +}
> +
> +
> +/****************
> + * Port handling
> + ****************/
> +
> +static int team_port_list_init(struct team *team)
> +{
> +	int i;
> +	struct hlist_head *hash;
> +
> +	hash = kmalloc(sizeof(*hash) * TEAM_PORT_HASHENTRIES,
> GFP_KERNEL);
> +	if (hash != NULL) {
> +		for (i = 0; i < TEAM_PORT_HASHENTRIES; i++)
> +			INIT_HLIST_HEAD(&hash[i]);
> +	} else {
> +		return -ENOMEM;
> +	}
> +	team->port_hlist = hash;
> +	INIT_LIST_HEAD(&team->port_list);
> +	return 0;
> +}
> +
> +static void team_port_list_fini(struct team *team)
> +{
> +	kfree(team->port_hlist);
> +}
> +
> +/*
> + * Add/delete port to the team port list. Write guarded by rtnl_lock.
> + * Takes care of correct port->index setup (might be racy).
> + */
> +static void team_port_list_add_port(struct team *team,
> +				    struct team_port *port)
> +{
> +	port->index = team->port_count++;
> +	hlist_add_head_rcu(&port->hlist,
> +			   team_port_index_hash(team, port->index));
> +	list_add_tail_rcu(&port->list, &team->port_list);
> +}
> +
> +static void __reconstruct_port_hlist(struct team *team, int rm_index)
> +{
> +	int i;
> +	struct team_port *port;
> +
> +	for (i = rm_index + 1; i < team->port_count; i++) {
> +		port = team_get_port_by_index_rcu(team, i);
> +		hlist_del_rcu(&port->hlist);
> +		port->index--;
> +		hlist_add_head_rcu(&port->hlist,
> +				   team_port_index_hash(team,
> port->index));
> +	}
> +}
> +
> +static void team_port_list_del_port(struct team *team,
> +				   struct team_port *port)
> +{
> +	int rm_index = port->index;
> +
> +	hlist_del_rcu(&port->hlist);
> +	list_del_rcu(&port->list);
> +	__reconstruct_port_hlist(team, rm_index);
> +	team->port_count--;
> +}
> +
> +#define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
> +			    NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
> +			    NETIF_F_HIGHDMA | NETIF_F_LRO)
> +
> +static void __team_compute_features(struct team *team)
> +{
> +	struct team_port *port;
> +	u32 vlan_features = TEAM_VLAN_FEATURES;
> +	unsigned short max_hard_header_len = ETH_HLEN;
> +
> +	list_for_each_entry(port, &team->port_list, list) {
> +		vlan_features =
> netdev_increment_features(vlan_features,
> +					port->dev->vlan_features,
> +					TEAM_VLAN_FEATURES);
> +
> +		if (port->dev->hard_header_len > max_hard_header_len)
> +			max_hard_header_len =
> port->dev->hard_header_len;
> +	}
> +
> +	team->dev->vlan_features = vlan_features;
> +	team->dev->hard_header_len = max_hard_header_len;
> +
> +	netdev_change_features(team->dev);
> +}
> +
> +static void team_compute_features(struct team *team)
> +{
> +	spin_lock(&team->lock);
> +	__team_compute_features(team);
> +	spin_unlock(&team->lock);
> +}
> +
> +static int team_port_enter(struct team *team, struct team_port *port)
> +{
> +	int err = 0;
> +
> +	dev_hold(team->dev);
> +	port->dev->priv_flags |= IFF_TEAM_PORT;
> +	if (team->mode_ops.port_enter) {
> +		err = team->mode_ops.port_enter(team, port);
> +		if (err)
> +			netdev_err(team->dev, "Device %s failed to "
> +					      "enter team mode\n",
> +				   port->dev->name);
> +	}
> +	return err;
> +}

s/port_enter/port_join/ 


> +
> +static void team_port_leave(struct team *team, struct team_port
> *port) +{
> +	if (team->mode_ops.port_leave)
> +		team->mode_ops.port_leave(team, port);
> +	port->dev->priv_flags &= ~IFF_TEAM_PORT;
> +	dev_put(team->dev);
> +}
> +
> +static void __team_port_change_check(struct team_port *port, bool
> linkup); +
> +static int team_port_add(struct team *team, struct net_device
> *port_dev) +{
> +	struct net_device *dev = team->dev;
> +	struct team_port *port;
> +	char *portname = port_dev->name;
> +	char tmp_addr[ETH_ALEN];
> +	int err;
> +
> +	if (port_dev->flags & IFF_LOOPBACK ||
> +	    port_dev->type != ARPHRD_ETHER) {
> +		netdev_err(dev, "Device %s is of an unsupported
> type\n",
> +			   portname);
> +		return -EINVAL;
> +	}
> +
> +	if (team_port_exists(port_dev)) {
> +		netdev_err(dev, "Device %s is already a port "
> +				"of a team device\n", portname);
> +		return -EBUSY;
> +	}
> +
> +	if (port_dev->flags & IFF_UP) {
> +		netdev_err(dev, "Device %s is up. Set it down before
> "
> +				"adding it as a team port\n",
> portname);
> +		return -EBUSY;
> +	}
> +
> +	port = kzalloc(sizeof(struct team_port), GFP_KERNEL);
> +	if (!port)
> +		return -ENOMEM;
> +
> +	port->dev = port_dev;
> +	port->team = team;
> +
> +	port->orig.mtu = port_dev->mtu;
> +	err = dev_set_mtu(port_dev, dev->mtu);
> +	if (err) {
> +		netdev_dbg(dev, "Error %d calling dev_set_mtu\n",
> err);
> +		goto err_set_mtu;
> +	}
> +
> +	memcpy(port->orig.dev_addr, port_dev->dev_addr, ETH_ALEN);
> +	random_ether_addr(tmp_addr);
> +	err = __set_port_mac(port_dev, tmp_addr);
> +	if (err) {
> +		netdev_dbg(dev, "Device %s mac addr set failed\n",
> +			   portname);
> +		goto err_set_mac_rand;
> +	}
> +
> +	err = dev_open(port_dev);
> +	if (err) {
> +		netdev_dbg(dev, "Device %s opening failed\n",
> +			   portname);
> +		goto err_dev_open;
> +	}
> +
> +	err = team_port_set_orig_mac(port);
> +	if (err) {
> +		netdev_dbg(dev, "Device %s mac addr set failed -
> Device does "
> +				"not support addr change when it's
> opened\n",
> +			   portname);
> +		goto err_set_mac_opened;
> +	}
> +
> +	err = team_port_enter(team, port);
> +	if (err) {
> +		netdev_err(dev, "Device %s failed to enter team
> mode\n",
> +			   portname);
> +		goto err_port_enter;
> +	}
> +
> +	err = netdev_set_master(port_dev, dev);
> +	if (err) {
> +		netdev_err(dev, "Device %s failed to set "
> +				"master\n", portname);
> +		goto err_set_master;
> +	}
> +
> +	err = netdev_rx_handler_register(port_dev, team_handle_frame,
> +					 port);
> +	if (err) {
> +		netdev_err(dev, "Device %s failed to register "
> +				"rx_handler\n", portname);
> +		goto err_handler_register;
> +	}
> +
> +	team_port_list_add_port(team, port);
> +	__team_compute_features(team);
> +	__team_port_change_check(port, !!netif_carrier_ok(port_dev));
> +
> +	netdev_info(dev, "Port device %s added\n", portname);
> +
> +	return 0;
> +
> +err_handler_register:
> +	netdev_set_master(port_dev, NULL);
> +
> +err_set_master:
> +	team_port_leave(team, port);
> +
> +err_port_enter:
> +err_set_mac_opened:
> +	dev_close(port_dev);
> +
> +err_dev_open:
> +	team_port_set_orig_mac(port);
> +
> +err_set_mac_rand:
> +	dev_set_mtu(port_dev, port->orig.mtu);
> +
> +err_set_mtu:
> +	kfree(port);
> +
> +	return err;
> +}
> +
> +static int team_port_del(struct team *team, struct net_device
> *port_dev) +{
> +	struct net_device *dev = team->dev;
> +	struct team_port *port;
> +	char *portname = port_dev->name;
> +
> +	port = team_port_get_rtnl(port_dev);
> +	if (!port || !team_port_find(team, port)) {
> +		netdev_err(dev, "Device %s does not act as a port "
> +				"of this team\n", portname);
> +		return -ENOENT;
> +	}
> +
> +	__team_port_change_check(port, false);
> +	team_port_list_del_port(team, port);
> +	netdev_rx_handler_unregister(port_dev);
> +	netdev_set_master(port_dev, NULL);
> +	team_port_leave(team, port);
> +	dev_close(port_dev);
> +	team_port_set_orig_mac(port);
> +	dev_set_mtu(port_dev, port->orig.mtu);
> +	synchronize_rcu();
> +	kfree(port);
> +	netdev_info(dev, "Port device %s removed\n", portname);
> +	__team_compute_features(team);
> +
> +	return 0;
> +}
> +
> +
> +/*****************
> + * Net device ops
> + ****************/
> +
> +static int team_mode_option_get(struct team *team, void *arg)
> +{
> +	const char **str = arg;
> +
> +	*str = team->mode_kind;
> +	return 0;
> +}
> +
> +static int team_mode_option_set(struct team *team, void *arg)
> +{
> +	const char **str = arg;
> +
> +	return team_change_mode(team, *str);
> +}
> +
> +static struct team_option team_options[] = {
> +	{
> +		.name = "mode",
> +		.type = TEAM_OPTION_TYPE_STRING,
> +		.getter = team_mode_option_get,
> +		.setter = team_mode_option_set,
> +	},
> +};
> +
> +static int team_init(struct net_device *dev)
> +{
> +	struct team *team = netdev_priv(dev);
> +	int err;
> +
> +	team->dev = dev;
> +	spin_lock_init(&team->lock);
> +
> +	err = team_port_list_init(team);
> +	if (err)
> +		return err;
> +
> +	INIT_LIST_HEAD(&team->option_list);
> +	team_options_register(team, team_options,
> ARRAY_SIZE(team_options));
> +	__team_change_mode(team, 0); /* set default mode */
> +	netif_carrier_off(dev);
> +
> +	return 0;
> +}
> +
> +static void team_uninit(struct net_device *dev)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +	struct team_port *tmp;
> +
> +	spin_lock(&team->lock);
> +	list_for_each_entry_safe(port, tmp, &team->port_list, list)
> +		team_port_del(team, port->dev);
> +
> +	__team_change_mode(team, -1); /* cleanup */
> +	__team_options_unregister(team, team_options,
> ARRAY_SIZE(team_options));
> +	spin_unlock(&team->lock);
> +}
> +
> +static void team_destructor(struct net_device *dev)
> +{
> +	struct team *team = netdev_priv(dev);
> +
> +	team_port_list_fini(team);
> +	free_netdev(dev);
> +}
> +
> +static int team_open(struct net_device *dev)
> +{
> +	netif_carrier_on(dev);
> +	return 0;
> +}
> +
> +static int team_close(struct net_device *dev)
> +{
> +	netif_carrier_off(dev);
> +	return 0;
> +}
> +
> +/*
> + * note: already called with rcu_read_lock
> + */
> +static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_device
> *dev) +{
> +	struct team *team = netdev_priv(dev);
> +
> +	/*
> +	 * Ensure transmit function is called only in case there is
> at least
> +	 * one port present.
> +	 */
> +	if (likely(!list_empty(&team->port_list)))
> +		team->mode_ops.transmit(team, skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static void team_change_rx_flags(struct net_device *dev, int change)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +	int inc;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		if (change & IFF_PROMISC) {
> +			inc = dev->flags & IFF_PROMISC ? 1 : -1;
> +			dev_set_promiscuity(port->dev, inc);
> +		}
> +		if (change & IFF_ALLMULTI) {
> +			inc = dev->flags & IFF_ALLMULTI ? 1 : -1;
> +			dev_set_allmulti(port->dev, inc);
> +		}
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static void team_set_rx_mode(struct net_device *dev)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		dev_uc_sync(port->dev, dev);
> +		dev_mc_sync(port->dev, dev);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static int team_set_mac_address(struct net_device *dev, void *p)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +	struct sockaddr *addr = p;
> +
> +	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list)
> +		if (team->mode_ops.port_change_mac)
> +			team->mode_ops.port_change_mac(team, port);
> +	rcu_read_unlock();
> +	return 0;
> +}
> +
> +static int team_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +	int err;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		err = dev_set_mtu(port->dev, new_mtu);
> +		if (err) {
> +			netdev_err(dev, "Device %s failed to change
> mtu",
> +				   port->dev->name);
> +			goto unwind;
> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	dev->mtu = new_mtu;
> +
> +	return 0;
> +
> +unwind:
> +	list_for_each_entry_continue_reverse(port, &team->port_list,
> list)
> +		dev_set_mtu(port->dev, dev->mtu);
> +
> +	rcu_read_unlock();
> +	return err;
> +}
> +
> +static struct rtnl_link_stats64 *team_get_stats(struct net_device
> *dev,
> +						struct
> rtnl_link_stats64 *stats) +{
> +	struct team *team = netdev_priv(dev);
> +	struct rtnl_link_stats64 temp;
> +	struct team_port *port;
> +
> +	memset(stats, 0, sizeof(*stats));
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		const struct rtnl_link_stats64 *pstats;
> +
> +		pstats = dev_get_stats(port->dev, &temp);
> +
> +		stats->rx_packets += pstats->rx_packets;
> +		stats->rx_bytes += pstats->rx_bytes;
> +		stats->rx_errors += pstats->rx_errors;
> +		stats->rx_dropped += pstats->rx_dropped;
> +
> +		stats->tx_packets += pstats->tx_packets;
> +		stats->tx_bytes += pstats->tx_bytes;
> +		stats->tx_errors += pstats->tx_errors;
> +		stats->tx_dropped += pstats->tx_dropped;
> +
> +		stats->multicast += pstats->multicast;
> +		stats->collisions += pstats->collisions;
> +
> +		stats->rx_length_errors += pstats->rx_length_errors;
> +		stats->rx_over_errors += pstats->rx_over_errors;
> +		stats->rx_crc_errors += pstats->rx_crc_errors;
> +		stats->rx_frame_errors += pstats->rx_frame_errors;
> +		stats->rx_fifo_errors += pstats->rx_fifo_errors;
> +		stats->rx_missed_errors += pstats->rx_missed_errors;
> +
> +		stats->tx_aborted_errors +=
> pstats->tx_aborted_errors;
> +		stats->tx_carrier_errors +=
> pstats->tx_carrier_errors;
> +		stats->tx_fifo_errors += pstats->tx_fifo_errors;
> +		stats->tx_heartbeat_errors +=
> pstats->tx_heartbeat_errors;
> +		stats->tx_window_errors += pstats->tx_window_errors;
> +	}
> +	rcu_read_unlock();
> +
> +	return stats;
> +}

I don't think computing stats like that is useful.  We can do
that in userlevel with ethtool -S on each slave and sum all them.
I think it would be better to have the errors computed based on
events that happens inside of Team driver, so we can really see if
something is happening inside of the Team driver or on its slaves.


> +
> +static void team_vlan_rx_add_vid(struct net_device *dev, uint16_t
> vid) +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		const struct net_device_ops *ops =
> port->dev->netdev_ops; +
> +		ops->ndo_vlan_rx_add_vid(port->dev, vid);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static void team_vlan_rx_kill_vid(struct net_device *dev, uint16_t
> vid) +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		const struct net_device_ops *ops =
> port->dev->netdev_ops; +
> +		ops->ndo_vlan_rx_kill_vid(port->dev, vid);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static int team_add_slave(struct net_device *dev, struct net_device
> *port_dev) +{
> +	struct team *team = netdev_priv(dev);
> +	int err;
> +
> +	spin_lock(&team->lock);
> +	err = team_port_add(team, port_dev);
> +	spin_unlock(&team->lock);
> +	return err;
> +}

I am not seeing any difference between slave and port, so why not stick
with just one?


> +
> +static int team_del_slave(struct net_device *dev, struct net_device
> *port_dev) +{
> +	struct team *team = netdev_priv(dev);
> +	int err;
> +
> +	spin_lock(&team->lock);
> +	err = team_port_del(team, port_dev);
> +	spin_unlock(&team->lock);
> +	return err;
> +}
> +
> +static const struct net_device_ops team_netdev_ops = {
> +	.ndo_init		= team_init,
> +	.ndo_uninit		= team_uninit,
> +	.ndo_open		= team_open,
> +	.ndo_stop		= team_close,
> +	.ndo_start_xmit		= team_xmit,
> +	.ndo_change_rx_flags	= team_change_rx_flags,
> +	.ndo_set_rx_mode	= team_set_rx_mode,
> +	.ndo_set_mac_address	= team_set_mac_address,
> +	.ndo_change_mtu		= team_change_mtu,
> +	.ndo_get_stats64	= team_get_stats,
> +	.ndo_vlan_rx_add_vid	= team_vlan_rx_add_vid,
> +	.ndo_vlan_rx_kill_vid	= team_vlan_rx_kill_vid,
> +	.ndo_add_slave		= team_add_slave,
> +	.ndo_del_slave		= team_del_slave,
> +};
> +
> +
> +/***********************
> + * rt netlink interface
> + ***********************/
> +
> +static void team_setup(struct net_device *dev)
> +{
> +	ether_setup(dev);
> +
> +	dev->netdev_ops = &team_netdev_ops;
> +	dev->destructor	= team_destructor;
> +	dev->tx_queue_len = 0;
> +	dev->flags |= IFF_MULTICAST;
> +	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE |
> IFF_TX_SKB_SHARING); +
> +	/*
> +	 * Indicate we support unicast address filtering. That way
> core won't
> +	 * bring us to promisc mode in case a unicast addr is added.
> +	 * Let this up to underlay drivers.
> +	 */
> +	dev->priv_flags |= IFF_UNICAST_FLT;
> +
> +	dev->features |= NETIF_F_LLTX;
> +	dev->features |= NETIF_F_GRO;
> +	dev->hw_features = NETIF_F_HW_VLAN_TX |
> +			   NETIF_F_HW_VLAN_RX |
> +			   NETIF_F_HW_VLAN_FILTER;
> +
> +	dev->features |= dev->hw_features;
> +}
> +
> +static int team_newlink(struct net *src_net, struct net_device *dev,
> +			struct nlattr *tb[], struct nlattr *data[])
> +{
> +	int err;
> +
> +	if (tb[IFLA_ADDRESS] == NULL)
> +		random_ether_addr(dev->dev_addr);
> +
> +	err = register_netdevice(dev);
> +	if (err)
> +		return err;
> +
> +	return 0;
> +}
> +
> +static int team_validate(struct nlattr *tb[], struct nlattr *data[])
> +{
> +	if (tb[IFLA_ADDRESS]) {
> +		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
> +			return -EINVAL;
> +		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
> +			return -EADDRNOTAVAIL;
> +	}
> +	return 0;
> +}
> +
> +static struct rtnl_link_ops team_link_ops __read_mostly = {
> +	.kind		= DRV_NAME,
> +	.priv_size	= sizeof(struct team),
> +	.setup		= team_setup,
> +	.newlink	= team_newlink,
> +	.validate	= team_validate,
> +};
> +
> +
> +/***********************************
> + * Generic netlink custom interface
> + ***********************************/
> +
> +static struct genl_family team_nl_family = {
> +	.id		= GENL_ID_GENERATE,
> +	.name		= TEAM_GENL_NAME,
> +	.version	= TEAM_GENL_VERSION,
> +	.maxattr	= TEAM_ATTR_MAX,
> +	.netnsok	= true,
> +};
> +
> +static const struct nla_policy team_nl_policy[TEAM_ATTR_MAX + 1] = {
> +	[TEAM_ATTR_UNSPEC]			= { .type =
> NLA_UNSPEC, },
> +	[TEAM_ATTR_TEAM_IFINDEX]		= { .type =
> NLA_U32 },
> +	[TEAM_ATTR_LIST_OPTION]			= { .type =
> NLA_NESTED },
> +	[TEAM_ATTR_LIST_MODE]			= { .type =
> NLA_NESTED },
> +	[TEAM_ATTR_LIST_PORT]			= { .type =
> NLA_NESTED }, +};
> +
> +static const struct nla_policy
> team_nl_option_policy[TEAM_ATTR_OPTION_MAX + 1] = {
> +	[TEAM_ATTR_OPTION_UNSPEC]		= { .type =
> NLA_UNSPEC, },
> +	[TEAM_ATTR_OPTION_NAME] = {
> +		.type = NLA_STRING,
> +		.len = TEAM_STRING_MAX_LEN,
> +	},
> +	[TEAM_ATTR_OPTION_CHANGED]		= { .type =
> NLA_FLAG },
> +	[TEAM_ATTR_OPTION_TYPE]			= { .type =
> NLA_U8 },
> +	[TEAM_ATTR_OPTION_DATA] = {
> +		.type = NLA_BINARY,
> +		.len = TEAM_STRING_MAX_LEN,
> +	},
> +};
> +
> +static int team_nl_cmd_noop(struct sk_buff *skb, struct genl_info
> *info) +{
> +	struct sk_buff *msg;
> +	void *hdr;
> +	int err;
> +
> +	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> +	if (!msg)
> +		return -ENOMEM;
> +
> +	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
> +			  &team_nl_family, 0, TEAM_CMD_NOOP);
> +	if (IS_ERR(hdr)) {
> +		err = PTR_ERR(hdr);
> +		goto err_msg_put;
> +	}
> +
> +	genlmsg_end(msg, hdr);
> +
> +	return genlmsg_unicast(genl_info_net(info), msg,
> info->snd_pid); +
> +err_msg_put:
> +	nlmsg_free(msg);
> +
> +	return err;
> +}
> +
> +/*
> + * Netlink cmd functions should be locked by following two functions.
> + * To ensure team_uninit would not be called in between, hold
> rcu_read_lock
> + * all the time.
> + */
> +static struct team *team_nl_team_get(struct genl_info *info)
> +{
> +	struct net *net = genl_info_net(info);
> +	int ifindex;
> +	struct net_device *dev;
> +	struct team *team;
> +
> +	if (!info->attrs[TEAM_ATTR_TEAM_IFINDEX])
> +		return NULL;
> +
> +	ifindex = nla_get_u32(info->attrs[TEAM_ATTR_TEAM_IFINDEX]);
> +	rcu_read_lock();
> +	dev = dev_get_by_index_rcu(net, ifindex);
> +	if (!dev || dev->netdev_ops != &team_netdev_ops) {
> +		rcu_read_unlock();
> +		return NULL;
> +	}
> +
> +	team = netdev_priv(dev);
> +	spin_lock(&team->lock);
> +	return team;
> +}
> +
> +static void team_nl_team_put(struct team *team)
> +{
> +	spin_unlock(&team->lock);
> +	rcu_read_unlock();
> +}
> +
> +static int team_nl_send_generic(struct genl_info *info, struct team
> *team,
> +				int (*fill_func)(struct sk_buff *skb,
> +						 struct genl_info
> *info,
> +						 int flags, struct
> team *team)) +{
> +	struct sk_buff *skb;
> +	int err;
> +
> +	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	err = fill_func(skb, info, NLM_F_ACK, team);
> +	if (err < 0)
> +		goto err_fill;
> +
> +	err = genlmsg_unicast(genl_info_net(info), skb,
> info->snd_pid);
> +	return err;
> +
> +err_fill:
> +	nlmsg_free(skb);
> +	return err;
> +}
> +
> +static int team_nl_fill_options_get_changed(struct sk_buff *skb,
> +					    u32 pid, u32 seq, int
> flags,
> +					    struct team *team,
> +					    struct team_option
> *changed_option) +{
> +	struct nlattr *option_list;
> +	void *hdr;
> +	struct team_option *option;
> +
> +	hdr = genlmsg_put(skb, pid, seq, &team_nl_family, flags,
> +			  TEAM_CMD_OPTIONS_GET);
> +	if (IS_ERR(hdr))
> +		return PTR_ERR(hdr);
> +
> +	NLA_PUT_U32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex);
> +	option_list = nla_nest_start(skb, TEAM_ATTR_LIST_OPTION);
> +	if (!option_list)
> +		return -EMSGSIZE;
> +
> +	list_for_each_entry(option, &team->option_list, list) {
> +		struct nlattr *option_item;
> +		long arg;
> +
> +		option_item = nla_nest_start(skb,
> TEAM_ATTR_ITEM_OPTION);
> +		if (!option_item)
> +			goto nla_put_failure;
> +		NLA_PUT_STRING(skb, TEAM_ATTR_OPTION_NAME,
> option->name);
> +		if (option == changed_option)
> +			NLA_PUT_FLAG(skb, TEAM_ATTR_OPTION_CHANGED);
> +		switch (option->type) {
> +		case TEAM_OPTION_TYPE_U32:
> +			NLA_PUT_U8(skb, TEAM_ATTR_OPTION_TYPE,
> NLA_U32);
> +			team_option_get(team, option, &arg);
> +			NLA_PUT_U32(skb, TEAM_ATTR_OPTION_DATA, arg);
> +			break;
> +		case TEAM_OPTION_TYPE_STRING:
> +			NLA_PUT_U8(skb, TEAM_ATTR_OPTION_TYPE,
> NLA_STRING);
> +			team_option_get(team, option, &arg);
> +			NLA_PUT_STRING(skb, TEAM_ATTR_OPTION_DATA,
> (char *) arg);
> +			break;
> +		default:
> +			BUG();
> +		}
> +		nla_nest_end(skb, option_item);
> +	}
> +
> +	nla_nest_end(skb, option_list);
> +	return genlmsg_end(skb, hdr);
> +
> +nla_put_failure:
> +	genlmsg_cancel(skb, hdr);
> +	return -EMSGSIZE;
> +}
> +
> +static int team_nl_fill_options_get(struct sk_buff *skb,
> +				    struct genl_info *info, int
> flags,
> +				    struct team *team)
> +{
> +	return team_nl_fill_options_get_changed(skb, info->snd_pid,
> +						info->snd_seq,
> NLM_F_ACK,
> +						team, NULL);
> +}
> +
> +static int team_nl_cmd_options_get(struct sk_buff *skb, struct
> genl_info *info) +{
> +	struct team *team;
> +	int err;
> +
> +	team = team_nl_team_get(info);
> +	if (!team)
> +		return -EINVAL;
> +
> +	err = team_nl_send_generic(info, team,
> team_nl_fill_options_get); +
> +	team_nl_team_put(team);
> +
> +	return err;
> +}
> +
> +static int team_nl_cmd_options_set(struct sk_buff *skb, struct
> genl_info *info) +{
> +	struct team *team;
> +	int err = 0;
> +	int i;
> +	struct nlattr *nl_option;
> +
> +	team = team_nl_team_get(info);
> +	if (!team)
> +		return -EINVAL;
> +
> +	err = -EINVAL;
> +	if (!info->attrs[TEAM_ATTR_LIST_OPTION]) {
> +		err = -EINVAL;
> +		goto team_put;
> +	}
> +
> +	nla_for_each_nested(nl_option,
> info->attrs[TEAM_ATTR_LIST_OPTION], i) {
> +		struct nlattr *mode_attrs[TEAM_ATTR_OPTION_MAX + 1];
> +		enum team_option_type opt_type;
> +		struct team_option *option;
> +		char *opt_name;
> +
> +		if (nla_type(nl_option) != TEAM_ATTR_ITEM_OPTION) {
> +			err = -EINVAL;
> +			goto team_put;
> +		}
> +		err = nla_parse_nested(mode_attrs,
> TEAM_ATTR_OPTION_MAX,
> +				       nl_option,
> team_nl_option_policy);
> +		if (err)
> +			goto team_put;
> +		if (!mode_attrs[TEAM_ATTR_OPTION_NAME] ||
> +		    !mode_attrs[TEAM_ATTR_OPTION_TYPE] ||
> +		    !mode_attrs[TEAM_ATTR_OPTION_DATA]) {
> +			err = -EINVAL;
> +			goto team_put;
> +		}
> +		switch
> (nla_get_u8(mode_attrs[TEAM_ATTR_OPTION_TYPE])) {
> +		case NLA_U32:
> +			opt_type = TEAM_OPTION_TYPE_U32;
> +			break;
> +		case NLA_STRING:
> +			opt_type = TEAM_OPTION_TYPE_STRING;
> +			break;
> +		default:
> +			goto team_put;
> +		}
> +
> +		opt_name =
> nla_data(mode_attrs[TEAM_ATTR_OPTION_NAME]);
> +		list_for_each_entry(option, &team->option_list,
> list) {
> +			long arg;
> +
> +			if (option->type != opt_type ||
> +			    strcmp(option->name, opt_name))
> +				continue;
> +			switch (opt_type) {
> +			case TEAM_OPTION_TYPE_U32:
> +				arg =
> nla_get_u32(mode_attrs[TEAM_ATTR_OPTION_DATA]);
> +				break;
> +			case TEAM_OPTION_TYPE_STRING:
> +				arg = (long)
> nla_data(mode_attrs[TEAM_ATTR_OPTION_DATA]);
> +				break;
> +			default:
> +				BUG();
> +			}
> +			err = team_option_set(team, option, &arg);
> +			if (err)
> +				goto team_put;
> +		}
> +	}
> +
> +team_put:
> +	team_nl_team_put(team);
> +
> +	return err;
> +}
> +
> +static int team_nl_fill_mode_list_get(struct sk_buff *skb,
> +				      struct genl_info *info, int
> flags,
> +				      struct team *team)
> +{
> +	struct nlattr *mode_list;
> +	void *hdr;
> +	int i;
> +
> +	hdr = genlmsg_put(skb, info->snd_pid, info->snd_seq,
> +			  &team_nl_family, flags,
> TEAM_CMD_MODE_LIST_GET);
> +	if (IS_ERR(hdr))
> +		return PTR_ERR(hdr);
> +
> +	NLA_PUT_U32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex);
> +	mode_list = nla_nest_start(skb, TEAM_ATTR_LIST_MODE);
> +	if (!mode_list)
> +		return -EMSGSIZE;
> +
> +	for (i = 0; i < team_mode_count; i++) {
> +		const struct team_mode *mode  = team_modes[i];
> +		struct nlattr *mode_item;
> +
> +		mode_item = nla_nest_start(skb, TEAM_ATTR_ITEM_MODE);
> +		if (!mode_item)
> +			goto nla_put_failure;
> +		NLA_PUT_STRING(skb, TEAM_ATTR_MODE_NAME, mode->kind);
> +		nla_nest_end(skb, mode_item);
> +	}
> +
> +	nla_nest_end(skb, mode_list);
> +	return genlmsg_end(skb, hdr);
> +
> +nla_put_failure:
> +	genlmsg_cancel(skb, hdr);
> +	return -EMSGSIZE;
> +}
> +
> +static int team_nl_cmd_mode_list_get(struct sk_buff *skb,
> +				     struct genl_info *info)
> +{
> +	struct team *team;
> +	int err;
> +
> +	team = team_nl_team_get(info);
> +	if (!team)
> +		return -EINVAL;
> +
> +	err = team_nl_send_generic(info, team,
> team_nl_fill_mode_list_get); +
> +	team_nl_team_put(team);
> +
> +	return err;
> +}
> +
> +static int team_nl_fill_port_list_get_changed(struct sk_buff *skb,
> +					      u32 pid, u32 seq, int
> flags,
> +					      struct team *team,
> +					      struct team_port
> *changed_port) +{
> +	struct nlattr *port_list;
> +	void *hdr;
> +	struct team_port *port;
> +
> +	hdr = genlmsg_put(skb, pid, seq, &team_nl_family, flags,
> +			  TEAM_CMD_PORT_LIST_GET);
> +	if (IS_ERR(hdr))
> +		return PTR_ERR(hdr);
> +
> +	NLA_PUT_U32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex);
> +	port_list = nla_nest_start(skb, TEAM_ATTR_LIST_PORT);
> +	if (!port_list)
> +		return -EMSGSIZE;
> +
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		struct nlattr *port_item;
> +
> +		port_item = nla_nest_start(skb, TEAM_ATTR_ITEM_MODE);
> +		if (!port_item)
> +			goto nla_put_failure;
> +		NLA_PUT_U32(skb, TEAM_ATTR_PORT_IFINDEX,
> port->dev->ifindex);
> +		if (port == changed_port)
> +			NLA_PUT_FLAG(skb, TEAM_ATTR_PORT_CHANGED);
> +		if (port->linkup)
> +			NLA_PUT_FLAG(skb, TEAM_ATTR_PORT_LINKUP);
> +		NLA_PUT_U32(skb, TEAM_ATTR_PORT_SPEED, port->speed);
> +		NLA_PUT_U8(skb, TEAM_ATTR_PORT_DUPLEX, port->duplex);
> +		nla_nest_end(skb, port_item);
> +	}
> +
> +	nla_nest_end(skb, port_list);
> +	return genlmsg_end(skb, hdr);
> +
> +nla_put_failure:
> +	genlmsg_cancel(skb, hdr);
> +	return -EMSGSIZE;
> +}
> +
> +static int team_nl_fill_port_list_get(struct sk_buff *skb,
> +				      struct genl_info *info, int
> flags,
> +				      struct team *team)
> +{
> +	return team_nl_fill_port_list_get_changed(skb, info->snd_pid,
> +						  info->snd_seq,
> NLM_F_ACK,
> +						  team, NULL);
> +}
> +
> +static int team_nl_cmd_port_list_get(struct sk_buff *skb,
> +				     struct genl_info *info)
> +{
> +	struct team *team;
> +	int err;
> +
> +	team = team_nl_team_get(info);
> +	if (!team)
> +		return -EINVAL;
> +
> +	err = team_nl_send_generic(info, team,
> team_nl_fill_port_list_get); +
> +	team_nl_team_put(team);
> +
> +	return err;
> +}
> +
> +static struct genl_ops team_nl_ops[] = {
> +	{
> +		.cmd = TEAM_CMD_NOOP,
> +		.doit = team_nl_cmd_noop,
> +		.policy = team_nl_policy,
> +	},
> +	{
> +		.cmd = TEAM_CMD_OPTIONS_SET,
> +		.doit = team_nl_cmd_options_set,
> +		.policy = team_nl_policy,
> +		.flags = GENL_ADMIN_PERM,
> +	},
> +	{
> +		.cmd = TEAM_CMD_OPTIONS_GET,
> +		.doit = team_nl_cmd_options_get,
> +		.policy = team_nl_policy,
> +		.flags = GENL_ADMIN_PERM,
> +	},
> +	{
> +		.cmd = TEAM_CMD_MODE_LIST_GET,
> +		.doit = team_nl_cmd_mode_list_get,
> +		.policy = team_nl_policy,
> +		.flags = GENL_ADMIN_PERM,
> +	},
> +	{
> +		.cmd = TEAM_CMD_PORT_LIST_GET,
> +		.doit = team_nl_cmd_port_list_get,
> +		.policy = team_nl_policy,
> +		.flags = GENL_ADMIN_PERM,
> +	},
> +};
> +
> +static struct genl_multicast_group team_change_event_mcgrp = {
> +	.name = TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME,
> +};
> +
> +static int team_nl_send_event_options_get(struct team *team,
> +					  struct team_option
> *changed_option) +{
> +	struct sk_buff *skb;
> +	int err;
> +	struct net *net = dev_net(team->dev);
> +
> +	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	err = team_nl_fill_options_get_changed(skb, 0, 0, 0, team,
> +					       changed_option);
> +	if (err < 0)
> +		goto err_fill;
> +
> +	err = genlmsg_multicast_netns(net, skb, 0,
> team_change_event_mcgrp.id,
> +				      GFP_KERNEL);
> +	return err;
> +
> +err_fill:
> +	nlmsg_free(skb);
> +	return err;
> +}
> +
> +static int team_nl_send_event_port_list_get(struct team_port *port)
> +{
> +	struct sk_buff *skb;
> +	int err;
> +	struct net *net = dev_net(port->team->dev);
> +
> +	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	err = team_nl_fill_port_list_get_changed(skb, 0, 0, 0,
> +						 port->team, port);
> +	if (err < 0)
> +		goto err_fill;
> +
> +	err = genlmsg_multicast_netns(net, skb, 0,
> team_change_event_mcgrp.id,
> +				      GFP_KERNEL);
> +	return err;
> +
> +err_fill:
> +	nlmsg_free(skb);
> +	return err;
> +}
> +
> +static int team_nl_init(void)
> +{
> +	int err;
> +
> +	err = genl_register_family_with_ops(&team_nl_family,
> team_nl_ops,
> +					    ARRAY_SIZE(team_nl_ops));
> +	if (err)
> +		return err;
> +
> +	err = genl_register_mc_group(&team_nl_family,
> &team_change_event_mcgrp);
> +	if (err)
> +		goto err_change_event_grp_reg;
> +
> +	return 0;
> +
> +err_change_event_grp_reg:
> +	genl_unregister_family(&team_nl_family);
> +
> +	return err;
> +}
> +
> +static void team_nl_fini(void)
> +{
> +	genl_unregister_family(&team_nl_family);
> +}
> +
> +
> +/******************
> + * Change checkers
> + ******************/
> +
> +static void __team_options_change_check(struct team *team,
> +					struct team_option
> *changed_option) +{
> +	int err;
> +
> +	err = team_nl_send_event_options_get(team, changed_option);
> +	if (err)
> +		netdev_warn(team->dev, "Failed to send options
> change "
> +				       "via netlink\n");
> +}
> +
> +/* rtnl lock is held */
> +static void __team_port_change_check(struct team_port *port, bool
> linkup) +{
> +	int err;
> +
> +	if (port->linkup == linkup)
> +		return;
> +
> +	port->linkup = linkup;
> +	if (linkup) {
> +		struct ethtool_cmd ecmd;
> +
> +		err = __ethtool_get_settings(port->dev, &ecmd);
> +		if (!err) {
> +			port->speed = ethtool_cmd_speed(&ecmd);
> +			port->duplex = ecmd.duplex;
> +			goto send_event;
> +		}
> +	}
> +	port->speed = 0;
> +	port->duplex = 0;
> +
> +send_event:
> +	err = team_nl_send_event_port_list_get(port);
> +	if (err)
> +		netdev_warn(port->team->dev, "Failed to send port
> change of "
> +					     "device %s via
> netlink\n",
> +			    port->dev->name);
> +
> +}
> +
> +static void team_port_change_check(struct team_port *port, bool
> linkup) +{
> +	struct team *team = port->team;
> +
> +	spin_lock(&team->lock);
> +	__team_port_change_check(port, linkup);
> +	spin_unlock(&team->lock);
> +}
> +
> +/************************************
> + * Net device notifier event handler
> + ************************************/
> +
> +static int team_device_event(struct notifier_block *unused,
> +			     unsigned long event, void *ptr)
> +{
> +	struct net_device *dev = (struct net_device *) ptr;
> +	struct team_port *port;
> +
> +	port = team_port_get_rtnl(dev);
> +	if (!port)
> +		return NOTIFY_DONE;
> +
> +	switch (event) {
> +	case NETDEV_UP:
> +		if (netif_carrier_ok(dev));
> +			team_port_change_check(port, true);
> +	case NETDEV_DOWN:
> +		team_port_change_check(port, false);
> +	case NETDEV_CHANGE:
> +		if (netif_running(port->dev))
> +			team_port_change_check(port,
> +					       !!netif_carrier_ok(port->dev));
> +		break;
> +	case NETDEV_UNREGISTER:
> +		team_del_slave(port->team->dev, dev);
> +		break;
> +	case NETDEV_FEAT_CHANGE:
> +		team_compute_features(port->team);
> +		break;
> +	case NETDEV_CHANGEMTU:
> +		/* Forbid to change mtu of underlaying device */
> +		return NOTIFY_BAD;
> +	case NETDEV_CHANGEADDR:
> +		/* Forbid to change addr of underlaying device */
> +		return NOTIFY_BAD;
> +	case NETDEV_PRE_TYPE_CHANGE:
> +		/* Forbid to change type of underlaying device */
> +		return NOTIFY_BAD;
> +	}
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block team_notifier_block __read_mostly = {
> +	.notifier_call = team_device_event,
> +};
> +
> +
> +/***********************
> + * Module init and exit
> + ***********************/
> +
> +static int __init team_module_init(void)
> +{
> +	int err;
> +
> +	register_netdevice_notifier(&team_notifier_block);
> +
> +	err = rtnl_link_register(&team_link_ops);
> +	if (err)
> +		goto err_rtln_reg;
> +
> +	err = team_nl_init();
> +	if (err)
> +		goto err_nl_init;
> +
> +	return 0;
> +
> +err_nl_init:
> +	rtnl_link_unregister(&team_link_ops);
> +
> +err_rtln_reg:
> +	unregister_netdevice_notifier(&team_notifier_block);
> +
> +	return err;
> +}
> +
> +static void __exit team_module_exit(void)
> +{
> +	team_nl_fini();
> +	rtnl_link_unregister(&team_link_ops);
> +	unregister_netdevice_notifier(&team_notifier_block);
> +}
> +
> +module_init(team_module_init);
> +module_exit(team_module_exit);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
> +MODULE_DESCRIPTION("Ethernet team device driver");
> +MODULE_ALIAS_RTNL_LINK(DRV_NAME);
> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index 619b565..0b091b3 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -185,6 +185,7 @@ header-y += if_pppol2tp.h
>  header-y += if_pppox.h
>  header-y += if_slip.h
>  header-y += if_strip.h
> +header-y += if_team.h
>  header-y += if_tr.h
>  header-y += if_tun.h
>  header-y += if_tunnel.h
> diff --git a/include/linux/if.h b/include/linux/if.h
> index db20bd4..e98f39d 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -79,6 +79,7 @@
>  #define IFF_TX_SKB_SHARING	0x10000	/* The interface
> supports sharing
>  					 * skbs on transmit */
>  #define IFF_UNICAST_FLT	0x20000		/* Supports
> unicast filtering	*/ +#define IFF_TEAM_PORT
> 0x40000		/* device used as teaming port */ 
>  #define IF_GET_IFACE	0x0001		/* for querying
> only */ #define IF_GET_PROTO	0x0002
> diff --git a/include/linux/if_team.h b/include/linux/if_team.h
> new file mode 100644
> index 0000000..b451c9e
> --- /dev/null
> +++ b/include/linux/if_team.h
> @@ -0,0 +1,126 @@
> +/*
> + * include/linux/if_team.h - Network team device driver header
> + * Copyright (c) 2011 Jiri Pirko <jpirko@redhat.com>
> + *
> + * This program is free software; you can redistribute it and/or
> modify
> + * it under the terms of the GNU General Public License as published
> by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#ifndef _LINUX_IF_TEAM_H_
> +#define _LINUX_IF_TEAM_H_
> +
> +#define TEAM_STRING_MAX_LEN 32
> +
> +/**********************************
> + * NETLINK_GENERIC netlink family.
> + **********************************/
> +
> +enum {
> +	TEAM_CMD_NOOP,
> +	TEAM_CMD_OPTIONS_SET,
> +	TEAM_CMD_OPTIONS_GET,
> +	TEAM_CMD_MODE_LIST_GET,
> +	TEAM_CMD_PORT_LIST_GET,
> +
> +	__TEAM_CMD_MAX,
> +	TEAM_CMD_MAX = (__TEAM_CMD_MAX - 1),
> +};
> +
> +enum {
> +	TEAM_ATTR_UNSPEC,
> +	TEAM_ATTR_TEAM_IFINDEX,		/* u32 */
> +	TEAM_ATTR_LIST_OPTION,		/* nest */
> +	TEAM_ATTR_LIST_MODE,		/* nest */
> +	TEAM_ATTR_LIST_PORT,		/* nest */
> +
> +	__TEAM_ATTR_MAX,
> +	TEAM_ATTR_MAX = __TEAM_ATTR_MAX - 1,
> +};
> +
> +/* Nested layout of get/set msg:
> + *
> + *	[TEAM_ATTR_LIST_OPTION]
> + *		[TEAM_ATTR_ITEM_OPTION]
> + *			[TEAM_ATTR_OPTION_*], ...
> + *		[TEAM_ATTR_ITEM_OPTION]
> + *			[TEAM_ATTR_OPTION_*], ...
> + *		...
> + *	[TEAM_ATTR_LIST_MODE]
> + *		[TEAM_ATTR_ITEM_MODE]
> + *			[TEAM_ATTR_MODE_*], ...
> + *		[TEAM_ATTR_ITEM_MODE]
> + *			[TEAM_ATTR_MODE_*], ...
> + *		...
> + *	[TEAM_ATTR_LIST_PORT]
> + *		[TEAM_ATTR_ITEM_PORT]
> + *			[TEAM_ATTR_PORT_*], ...
> + *		[TEAM_ATTR_ITEM_PORT]
> + *			[TEAM_ATTR_PORT_*], ...
> + *		...
> + */
> +
> +enum {
> +	TEAM_ATTR_ITEM_OPTION_UNSPEC,
> +	TEAM_ATTR_ITEM_OPTION,		/* nest */
> +
> +	__TEAM_ATTR_ITEM_OPTION_MAX,
> +	TEAM_ATTR_ITEM_OPTION_MAX = __TEAM_ATTR_ITEM_OPTION_MAX - 1,
> +};
> +
> +enum {
> +	TEAM_ATTR_OPTION_UNSPEC,
> +	TEAM_ATTR_OPTION_NAME,		/* string */
> +	TEAM_ATTR_OPTION_CHANGED,	/* flag */
> +	TEAM_ATTR_OPTION_TYPE,		/* u8 */
> +	TEAM_ATTR_OPTION_DATA,		/* dynamic */
> +
> +	__TEAM_ATTR_OPTION_MAX,
> +	TEAM_ATTR_OPTION_MAX = __TEAM_ATTR_OPTION_MAX - 1,
> +};
> +
> +enum {
> +	TEAM_ATTR_ITEM_MODE_UNSPEC,
> +	TEAM_ATTR_ITEM_MODE,		/* nest */
> +
> +	__TEAM_ATTR_ITEM_MODE_MAX,
> +	TEAM_ATTR_ITEM_MODE_MAX = __TEAM_ATTR_ITEM_MODE_MAX - 1,
> +};
> +
> +enum {
> +	TEAM_ATTR_MODE_UNSPEC,
> +	TEAM_ATTR_MODE_NAME,		/* string */
> +
> +	__TEAM_ATTR_MODE_MAX,
> +	TEAM_ATTR_MODE_MAX = __TEAM_ATTR_MODE_MAX - 1,
> +};
> +
> +enum {
> +	TEAM_ATTR_ITEM_PORT_UNSPEC,
> +	TEAM_ATTR_ITEM_PORT,		/* nest */
> +
> +	__TEAM_ATTR_ITEM_PORT_MAX,
> +	TEAM_ATTR_ITEM_PORT_MAX = __TEAM_ATTR_ITEM_PORT_MAX - 1,
> +};
> +
> +enum {
> +	TEAM_ATTR_PORT_UNSPEC,
> +	TEAM_ATTR_PORT_IFINDEX,		/* u32 */
> +	TEAM_ATTR_PORT_CHANGED,		/* flag */
> +	TEAM_ATTR_PORT_LINKUP,		/* flag */
> +	TEAM_ATTR_PORT_SPEED,		/* u32 */
> +	TEAM_ATTR_PORT_DUPLEX,		/* u8 */
> +
> +	__TEAM_ATTR_PORT_MAX,
> +	TEAM_ATTR_PORT_MAX = __TEAM_ATTR_PORT_MAX - 1,
> +};
> +
> +/*
> + * NETLINK_GENERIC related info
> + */
> +#define TEAM_GENL_NAME "team"
> +#define TEAM_GENL_VERSION 0x1
> +#define TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME "change_event"
> +
> +#endif


fbl
