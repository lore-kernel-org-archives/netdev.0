From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next V7] net: introduce ethernet teaming device
Date: Fri, 11 Nov 2011 16:04:41 -0200
Message-ID: <20111111160441.5ab366cc@asterix.rh>
References: <1320939698-1062-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484Ab1KKSyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Nov 2011 13:54:01 -0500
In-Reply-To: <1320939698-1062-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Nov 2011 16:41:38 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> This patch introduces new network device called team. It supposes to be
> very fast, simple, userspace-driven alternative to existing bonding
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
> Python binding of libteam was recently introduced.
> Daemon providing arpmon/miimon active-backup functionality will be
> introduced shortly. All what's necessary is already implemented in
> kernel team driver.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> v6->v7:
> 	- transmit and receive functions are not checked in hot paths.
> 	  That also resolves memory leak on transmit when no port is
> 	  present
> 

You're right. No need to patch those function names if we use libnl
from git.

[...]
> +static void team_vlan_rx_add_vid(struct net_device *dev, uint16_t vid)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		const struct net_device_ops *ops = port->dev->netdev_ops;
> +
> +		ops->ndo_vlan_rx_add_vid(port->dev, vid);

This causes a oops when enslaving a tg3 device because there is
no ndo_vlan_rx_add_vid().


> +	}
> +	rcu_read_unlock();
> +}
> +
> +static void team_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct team_port *port;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		const struct net_device_ops *ops = port->dev->netdev_ops;
> +
> +		ops->ndo_vlan_rx_kill_vid(port->dev, vid);

Well, probably here too, though you can't reach this point without
crashing at team_vlan_rx_add_vid() first.

fbl
