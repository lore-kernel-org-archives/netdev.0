From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: make dev->master general
Date: Mon, 14 Feb 2011 10:01:34 +0100
Message-ID: <20110214090133.GB2746@psychotron.redhat.com>
References: <20110212164836.GB12156@psychotron.redhat.com>
 <4D58EC6C.7030005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60319 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556Ab1BNJCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Feb 2011 04:02:04 -0500
Content-Disposition: inline
In-Reply-To: <4D58EC6C.7030005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 14, 2011 at 09:48:44AM CET, nicolas.2p.debian@gmail.com wrote:
>Le 12/02/2011 17:48, Jiri Pirko a =E9crit :
>>dev->master is now tightly connected to bonding driver. This patch ma=
kes
>>this pointer more general and ready to be used by others.
>>
>>  - netdev_set_master() - bond specifics moved to new function
>>    netdev_set_bond_master()
>>  - introduced netif_is_bond_slave() to check if device is a bonding =
slave
>>
>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>
>Hi Jiri,
>
>Even if DaveM already applied your patch, I'm not comfortable with it.
>
>What is the rational behind it? Do you have anything in mind to use
>the now "more general" master field of net_device?
>
>Of course, I won't advocate for every fields having only a single
>possible usage, but, using master for several different things might
>jeopardize our ability to share an interface between several logical
>interface systems:
>
>Due to the current usage of the rx_handler field in net_device, the
>code suggest that an interface cannot be part of a bridge and of a
>macvlan at the same time. Even if bridge provide an hook for ebtables
>to ignore an skb and allow other to get it, macvlan cannot be
>registered on the same lower interface as a bridge, because
>rx_handler can only hold a single value.
>
>By giving master a more general meaning, I think we might face a
>similar problem. It might disallow an interface to be enslaved to
>bonding and part of another logical interface at the same time, if
>such logical interface also use the master field.

That is true. I think that it makes no sense to have iface enslaved in
bond and bridge at the same time. Do you have a scenario where it makes
sense?

>
>It doesn't mean I don't support the general idea, but I would like to
>clearly understand the possible unexpected impact: do we want to stop
>interfaces to be "enslaved" to several logical interface at the same
>time?
>
>>---
>>  drivers/infiniband/hw/nes/nes.c    |    3 +-
>>  drivers/infiniband/hw/nes/nes_cm.c |    2 +-
>>  drivers/net/bonding/bond_main.c    |   10 +++---
>>  drivers/net/cxgb3/cxgb3_offload.c  |    3 +-
>>  include/linux/netdevice.h          |    7 +++++
>>  net/core/dev.c                     |   49 +++++++++++++++++++++++++=
++---------
>>  6 files changed, 54 insertions(+), 20 deletions(-)
>>
>>diff --git a/drivers/infiniband/hw/nes/nes.c b/drivers/infiniband/hw/=
nes/nes.c
>>index 3b4ec32..3d7f366 100644
>>--- a/drivers/infiniband/hw/nes/nes.c
>>+++ b/drivers/infiniband/hw/nes/nes.c
>>@@ -153,7 +153,8 @@ static int nes_inetaddr_event(struct notifier_blo=
ck *notifier,
>>  				nesdev, nesdev->netdev[0]->name);
>>  		netdev =3D nesdev->netdev[0];
>>  		nesvnic =3D netdev_priv(netdev);
>>-		is_bonded =3D (netdev->master =3D=3D event_netdev);
>>+		is_bonded =3D netif_is_bond_slave(netdev)&&
>>+			    (netdev->master =3D=3D event_netdev);
>>  		if ((netdev =3D=3D event_netdev) || is_bonded) {
>>  			if (nesvnic->rdma_enabled =3D=3D 0) {
>>  				nes_debug(NES_DBG_NETDEV, "Returning without processing event f=
or %s since"
>>diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/=
hw/nes/nes_cm.c
>>index 009ec81..ec3aa11 100644
>>--- a/drivers/infiniband/hw/nes/nes_cm.c
>>+++ b/drivers/infiniband/hw/nes/nes_cm.c
>>@@ -1118,7 +1118,7 @@ static int nes_addr_resolve_neigh(struct nes_vn=
ic *nesvnic, u32 dst_ip, int arpi
>>  		return rc;
>>  	}
>>
>>-	if (nesvnic->netdev->master)
>>+	if (netif_is_bond_slave(netdev))
>>  		netdev =3D nesvnic->netdev->master;
>>  	else
>>  		netdev =3D nesvnic->netdev;
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
>>index 1df9f0e..9f87787 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1594,9 +1594,9 @@ int bond_enslave(struct net_device *bond_dev, s=
truct net_device *slave_dev)
>>  		}
>>  	}
>>
>>-	res =3D netdev_set_master(slave_dev, bond_dev);
>>+	res =3D netdev_set_bond_master(slave_dev, bond_dev);
>>  	if (res) {
>>-		pr_debug("Error %d calling netdev_set_master\n", res);
>>+		pr_debug("Error %d calling netdev_set_bond_master\n", res);
>>  		goto err_restore_mac;
>>  	}
>>  	/* open the slave since the application closed it */
>>@@ -1812,7 +1812,7 @@ err_close:
>>  	dev_close(slave_dev);
>>
>>  err_unset_master:
>>-	netdev_set_master(slave_dev, NULL);
>>+	netdev_set_bond_master(slave_dev, NULL);
>>
>>  err_restore_mac:
>>  	if (!bond->params.fail_over_mac) {
>>@@ -1992,7 +1992,7 @@ int bond_release(struct net_device *bond_dev, s=
truct net_device *slave_dev)
>>  		netif_addr_unlock_bh(bond_dev);
>>  	}
>>
>>-	netdev_set_master(slave_dev, NULL);
>>+	netdev_set_bond_master(slave_dev, NULL);
>>
>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>>  	read_lock_bh(&bond->lock);
>>@@ -2114,7 +2114,7 @@ static int bond_release_all(struct net_device *=
bond_dev)
>>  			netif_addr_unlock_bh(bond_dev);
>>  		}
>>
>>-		netdev_set_master(slave_dev, NULL);
>>+		netdev_set_bond_master(slave_dev, NULL);
>>
>>  		/* close slave before restoring its mac address */
>>  		dev_close(slave_dev);
>>diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cx=
gb3_offload.c
>>index 7ea94b5..862804f 100644
>>--- a/drivers/net/cxgb3/cxgb3_offload.c
>>+++ b/drivers/net/cxgb3/cxgb3_offload.c
>>@@ -186,9 +186,10 @@ static struct net_device *get_iff_from_mac(struc=
t adapter *adapter,
>>  				dev =3D NULL;
>>  				if (grp)
>>  					dev =3D vlan_group_get_device(grp, vlan);
>>-			} else
>>+			} else if (netif_is_bond_slave(dev)) {
>>  				while (dev->master)
>>  					dev =3D dev->master;
>
>The while() here suggests that nesting bonding is possible. This is
>not true (even if not enforced yet). And even if it was true, then
>you needed to use netif_is_bond_slave(dev) inside the while() loop,
>to be consistent.
>
>>+			}
>>  			return dev;
>>  		}
>>  	}
>>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>index 5a5baea..5a42b10 100644
>>--- a/include/linux/netdevice.h
>>+++ b/include/linux/netdevice.h
>>@@ -2377,6 +2377,8 @@ extern int		netdev_max_backlog;
>>  extern int		netdev_tstamp_prequeue;
>>  extern int		weight_p;
>>  extern int		netdev_set_master(struct net_device *dev, struct net_de=
vice *master);
>>+extern int netdev_set_bond_master(struct net_device *dev,
>>+				  struct net_device *master);
>>  extern int skb_checksum_help(struct sk_buff *skb);
>>  extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 fea=
tures);
>>  #ifdef CONFIG_BUG
>>@@ -2437,6 +2439,11 @@ static inline void netif_set_gso_max_size(stru=
ct net_device *dev,
>>  	dev->gso_max_size =3D size;
>>  }
>>
>>+static inline int netif_is_bond_slave(struct net_device *dev)
>>+{
>>+	return dev->flags&  IFF_SLAVE&&  dev->priv_flags&  IFF_BONDING;
>>+}
>>+
>
>Does this means you also consider IFF_SLAVE as a "more general" flag
>now? Wasn't IFF_SLAVE a sufficient evidence of the interface being
>enslaved to a bonding interface, before?
>
>>  extern struct pernet_operations __net_initdata loopback_net_ops;
>>
>>  static inline int dev_ethtool_get_settings(struct net_device *dev,
>>diff --git a/net/core/dev.c b/net/core/dev.c
>>index d874fd1..a413276 100644
>>--- a/net/core/dev.c
>>+++ b/net/core/dev.c
>>@@ -3146,7 +3146,6 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>>  	struct packet_type *ptype, *pt_prev;
>>  	rx_handler_func_t *rx_handler;
>>  	struct net_device *orig_dev;
>>-	struct net_device *master;
>>  	struct net_device *null_or_orig;
>>  	struct net_device *orig_or_bond;
>>  	int ret =3D NET_RX_DROP;
>>@@ -3173,15 +3172,19 @@ static int __netif_receive_skb(struct sk_buff=
 *skb)
>>  	 */
>>  	null_or_orig =3D NULL;
>>  	orig_dev =3D skb->dev;
>>-	master =3D ACCESS_ONCE(orig_dev->master);
>>  	if (skb->deliver_no_wcard)
>>  		null_or_orig =3D orig_dev;
>>-	else if (master) {
>>-		if (__skb_bond_should_drop(skb, master)) {
>>-			skb->deliver_no_wcard =3D 1;
>>-			null_or_orig =3D orig_dev; /* deliver only exact match */
>>-		} else
>>-			skb->dev =3D master;
>>+	else if (netif_is_bond_slave(orig_dev)) {
>>+		struct net_device *bond_master =3D ACCESS_ONCE(orig_dev->master);
>>+
>>+		if (likely(bond_master)) {
>>+			if (__skb_bond_should_drop(skb, bond_master)) {
>>+				skb->deliver_no_wcard =3D 1;
>>+				/* deliver only exact match */
>>+				null_or_orig =3D orig_dev;
>>+			} else
>>+				skb->dev =3D bond_master;
>>+		}
>
>I think we need an "else" here. If orig_dev->master is NULL, while
>netif_is_bond_slave(orig_dev) is TRUE, we apparently face an
>unexpected situation and we should at least issue a warning.
>
>>  	}
>>
>>  	__this_cpu_inc(softnet_data.processed);
>>@@ -4346,15 +4349,14 @@ static int __init dev_proc_init(void)
>>
>>
>>  /**
>>- *	netdev_set_master	-	set up master/slave pair
>>+ *	netdev_set_master	-	set up master pointer
>>   *	@slave: slave device
>>   *	@master: new master device
>>   *
>>   *	Changes the master device of the slave. Pass %NULL to break the
>>   *	bonding. The caller must hold the RTNL semaphore. On a failure
>>   *	a negative errno code is returned. On success the reference coun=
ts
>>- *	are adjusted, %RTM_NEWLINK is sent to the routing socket and the
>>- *	function returns zero.
>>+ *	are adjusted and the function returns zero.
>>   */
>>  int netdev_set_master(struct net_device *slave, struct net_device *=
master)
>>  {
>>@@ -4374,6 +4376,29 @@ int netdev_set_master(struct net_device *slave=
, struct net_device *master)
>>  		synchronize_net();
>>  		dev_put(old);
>>  	}
>>+	return 0;
>>+}
>>+EXPORT_SYMBOL(netdev_set_master);
>>+
>>+/**
>>+ *	netdev_set_bond_master	-	set up bonding master/slave pair
>>+ *	@slave: slave device
>>+ *	@master: new master device
>>+ *
>>+ *	Changes the master device of the slave. Pass %NULL to break the
>>+ *	bonding. The caller must hold the RTNL semaphore. On a failure
>>+ *	a negative errno code is returned. On success %RTM_NEWLINK is sen=
t
>>+ *	to the routing socket and the function returns zero.
>>+ */
>>+int netdev_set_bond_master(struct net_device *slave, struct net_devi=
ce *master)
>>+{
>>+	int err;
>>+
>>+	ASSERT_RTNL();
>>+
>>+	err =3D netdev_set_master(slave, master);
>>+	if (err)
>>+		return err;
>>  	if (master)
>>  		slave->flags |=3D IFF_SLAVE;
>>  	else
>>@@ -4382,7 +4407,7 @@ int netdev_set_master(struct net_device *slave,=
 struct net_device *master)
>>  	rtmsg_ifinfo(RTM_NEWLINK, slave, IFF_SLAVE);
>>  	return 0;
>>  }
>>-EXPORT_SYMBOL(netdev_set_master);
>>+EXPORT_SYMBOL(netdev_set_bond_master);
>>
>>  static void dev_change_rx_flags(struct net_device *dev, int flags)
>>  {
>
