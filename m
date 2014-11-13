From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next v2] net: generic dev_disable_lro() stacked
 device handling
Date: Thu, 13 Nov 2014 08:15:55 +0100
Message-ID: <20141113071555.GA28547@raspberrypi>
References: <20141111.214752.266800170368088905.davem@davemloft.net>
 <20141113065450.1645FA0BEF@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141113065450.1645FA0BEF@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 13, 2014 at 07:54:50AM +0100, Michal Kubecek wrote:
>Large receive offloading is known to cause problems if received packets
>are passed to other host. Therefore the kernel disables it by calling
>dev_disable_lro() whenever a network device is enslaved in a bridge or
>forwarding is enabled for it (or globally). For virtual devices we need
>to disable LRO on the underlying physical device (which is actually
>receiving the packets).
>
>Current dev_disable_lro() code handles this  propagation for a vlan
>(including 802.1ad nested vlan), macvlan or a vlan on top of a macvlan.
>It doesn't handle other stacked devices and their combinations, in
>particular propagation from a bond to its slaves which often causes
>problems in virtualization setups.
>
>As we now have generic data structures describing the upper-lower device
>relationship, dev_disable_lro() can be generalized to disable LRO also
>for all lower devices (if any) once it is disabled for the device
>itself.
>
>For bonding and teaming devices, it is necessary to disable LRO not only
>on current slaves at the moment when dev_disable_lro() is called but
>also on any slave (port) added later.
>
>v2: use lower device links for all devices (including vlan and macvlan)
>
>Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Seems ok to me.

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>---
> drivers/net/bonding/bond_main.c |  3 +++
> drivers/net/team/team.c         |  3 +++
> net/core/dev.c                  | 15 +++++----------
> 3 files changed, 11 insertions(+), 10 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index b9b3456..8575fee 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1526,6 +1526,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 	}
> #endif
>
>+	if (!(bond_dev->features & NETIF_F_LRO))
>+		dev_disable_lro(slave_dev);
>+
> 	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
> 					 new_slave);
> 	if (res) {
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 2368395..93e2242 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1179,6 +1179,9 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
> 		goto err_enable_netpoll;
> 	}
>
>+	if (!(dev->features & NETIF_F_LRO))
>+		dev_disable_lro(port_dev);
>+
> 	err = netdev_rx_handler_register(port_dev, team_handle_frame,
> 					 port);
> 	if (err) {
>diff --git a/net/core/dev.c b/net/core/dev.c
>index bb09b03..1ab168e 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -1437,22 +1437,17 @@ EXPORT_SYMBOL(dev_close);
>  */
> void dev_disable_lro(struct net_device *dev)
> {
>-	/*
>-	 * If we're trying to disable lro on a vlan device
>-	 * use the underlying physical device instead
>-	 */
>-	if (is_vlan_dev(dev))
>-		dev = vlan_dev_real_dev(dev);
>-
>-	/* the same for macvlan devices */
>-	if (netif_is_macvlan(dev))
>-		dev = macvlan_dev_real_dev(dev);
>+	struct net_device *lower_dev;
>+	struct list_head *iter;
>
> 	dev->wanted_features &= ~NETIF_F_LRO;
> 	netdev_update_features(dev);
>
> 	if (unlikely(dev->features & NETIF_F_LRO))
> 		netdev_WARN(dev, "failed to disable LRO!\n");
>+
>+	netdev_for_each_lower_dev(dev, lower_dev, iter)
>+		dev_disable_lro(lower_dev);
> }
> EXPORT_SYMBOL(dev_disable_lro);
>
>-- 
>1.8.4.5
>
