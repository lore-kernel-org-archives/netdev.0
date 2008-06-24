From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3]: netdev: Add netdev->addr_list_lock protection.
Date: Mon, 23 Jun 2008 20:54:19 -0700 (PDT)
Message-ID: <20080623.205419.179592881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41041
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754104AbYFXDyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 23:54:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0ADDEC8C1B6
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 20:54:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netdev: Add netdev->addr_list_lock protection.

Add netif_addr_{lock,unlock}{,_bh}() helpers.

Use them to protect operations that operate on or read
the network device unicast and multicast address lists.

Also use them in cases where the code simply wants to
block calls into the driver's ->set_rx_mode() and
->set_multicast_list() methods.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    2 ++
 drivers/media/dvb/dvb-core/dvb_net.c           |    2 ++
 drivers/net/bonding/bond_main.c                |    8 ++++++++
 drivers/net/forcedeth.c                        |   16 ++++++++++++++++
 drivers/net/hamradio/6pack.c                   |    2 ++
 drivers/net/hamradio/mkiss.c                   |    2 ++
 drivers/net/ibm_newemac/core.c                 |    4 ++++
 drivers/net/sfc/efx.c                          |    2 ++
 drivers/net/tun.c                              |    4 ++++
 drivers/net/wireless/libertas/main.c           |    2 ++
 include/linux/netdevice.h                      |   20 ++++++++++++++++++++
 net/core/dev.c                                 |   14 ++++++++++++++
 net/core/dev_mcast.c                           |   12 ++++++++++++
 net/mac80211/main.c                            |    4 ++++
 net/mac80211/mlme.c                            |    4 ++++
 15 files changed, 98 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 3f663fb..261ab71 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -775,6 +775,7 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 
 	local_irq_save(flags);
 	netif_tx_lock(dev);
+	netif_addr_lock(dev);
 	spin_lock(&priv->lock);
 
 	/*
@@ -851,6 +852,7 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 	}
 
 	spin_unlock(&priv->lock);
+	netif_addr_unlock(dev);
 	netif_tx_unlock(dev);
 	local_irq_restore(flags);
 
diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index c2334ae..809d18c 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -1134,6 +1134,7 @@ static void wq_set_multicast_list (struct work_struct *work)
 	dvb_net_feed_stop(dev);
 	priv->rx_mode = RX_MODE_UNI;
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 
 	if (dev->flags & IFF_PROMISC) {
 		dprintk("%s: promiscuous mode\n", dev->name);
@@ -1158,6 +1159,7 @@ static void wq_set_multicast_list (struct work_struct *work)
 		}
 	}
 
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 	dvb_net_feed_start(dev);
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d57b65d..6601ffc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1553,10 +1553,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 
 		netif_tx_lock_bh(bond_dev);
+		netif_addr_lock(bond_dev);
 		/* upload master's mc_list to new slave */
 		for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
 			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
+		netif_addr_unlock(bond_dev);
 		netif_tx_unlock_bh(bond_dev);
 	}
 
@@ -1922,7 +1924,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 
 		/* flush master's mc_list from slave */
 		netif_tx_lock_bh(bond_dev);
+		netif_addr_lock(bond_dev);
 		bond_mc_list_flush(bond_dev, slave_dev);
+		netif_addr_unlock(bond_dev);
 		netif_tx_unlock_bh(bond_dev);
 	}
 
@@ -2045,7 +2049,9 @@ static int bond_release_all(struct net_device *bond_dev)
 
 			/* flush master's mc_list from slave */
 			netif_tx_lock_bh(bond_dev);
+			netif_addr_lock(bond_dev);
 			bond_mc_list_flush(bond_dev, slave_dev);
+			netif_addr_unlock(bond_dev);
 			netif_tx_unlock_bh(bond_dev);
 		}
 
@@ -4651,7 +4657,9 @@ static void bond_free_all(void)
 
 		bond_work_cancel_all(bond);
 		netif_tx_lock_bh(bond_dev);
+		netif_addr_lock(bond_dev);
 		bond_mc_list_destroy(bond);
+		netif_addr_unlock(bond_dev);
 		netif_tx_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index c980ce9..f5591cf 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2831,6 +2831,7 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		 */
 		nv_disable_irq(dev);
 		netif_tx_lock_bh(dev);
+		netif_addr_lock(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
 		nv_stop_rxtx(dev);
@@ -2855,6 +2856,7 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		/* restart rx engine */
 		nv_start_rxtx(dev);
 		spin_unlock(&np->lock);
+		netif_addr_unlock(dev);
 		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
 	}
@@ -2891,6 +2893,7 @@ static int nv_set_mac_address(struct net_device *dev, void *addr)
 
 	if (netif_running(dev)) {
 		netif_tx_lock_bh(dev);
+		netif_addr_lock(dev);
 		spin_lock_irq(&np->lock);
 
 		/* stop rx engine */
@@ -2902,6 +2905,7 @@ static int nv_set_mac_address(struct net_device *dev, void *addr)
 		/* restart rx engine */
 		nv_start_rx(dev);
 		spin_unlock_irq(&np->lock);
+		netif_addr_unlock(dev);
 		netif_tx_unlock_bh(dev);
 	} else {
 		nv_copy_mac_to_hw(dev);
@@ -3971,6 +3975,7 @@ static void nv_do_nic_poll(unsigned long data)
 		printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
 		if (netif_running(dev)) {
 			netif_tx_lock_bh(dev);
+			netif_addr_lock(dev);
 			spin_lock(&np->lock);
 			/* stop engines */
 			nv_stop_rxtx(dev);
@@ -3995,6 +4000,7 @@ static void nv_do_nic_poll(unsigned long data)
 			/* restart rx engine */
 			nv_start_rxtx(dev);
 			spin_unlock(&np->lock);
+			netif_addr_unlock(dev);
 			netif_tx_unlock_bh(dev);
 		}
 	}
@@ -4200,10 +4206,12 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
 		netif_tx_lock_bh(dev);
+		netif_addr_lock(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
 		nv_stop_rxtx(dev);
 		spin_unlock(&np->lock);
+		netif_addr_unlock(dev);
 		netif_tx_unlock_bh(dev);
 	}
 
@@ -4349,10 +4357,12 @@ static int nv_nway_reset(struct net_device *dev)
 		if (netif_running(dev)) {
 			nv_disable_irq(dev);
 			netif_tx_lock_bh(dev);
+			netif_addr_lock(dev);
 			spin_lock(&np->lock);
 			/* stop engines */
 			nv_stop_rxtx(dev);
 			spin_unlock(&np->lock);
+			netif_addr_unlock(dev);
 			netif_tx_unlock_bh(dev);
 			printk(KERN_INFO "%s: link down.\n", dev->name);
 		}
@@ -4460,6 +4470,7 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
 		netif_tx_lock_bh(dev);
+		netif_addr_lock(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
 		nv_stop_rxtx(dev);
@@ -4508,6 +4519,7 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 		/* restart engines */
 		nv_start_rxtx(dev);
 		spin_unlock(&np->lock);
+		netif_addr_unlock(dev);
 		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
 	}
@@ -4545,10 +4557,12 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
 		netif_tx_lock_bh(dev);
+		netif_addr_lock(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
 		nv_stop_rxtx(dev);
 		spin_unlock(&np->lock);
+		netif_addr_unlock(dev);
 		netif_tx_unlock_bh(dev);
 	}
 
@@ -4935,6 +4949,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			napi_disable(&np->napi);
 #endif
 			netif_tx_lock_bh(dev);
+			netif_addr_lock(dev);
 			spin_lock_irq(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
 			if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
@@ -4948,6 +4963,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			/* drain rx queue */
 			nv_drain_rxtx(dev);
 			spin_unlock_irq(&np->lock);
+			netif_addr_unlock(dev);
 			netif_tx_unlock_bh(dev);
 		}
 
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 06ad9f3..ffc937f 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -300,7 +300,9 @@ static int sp_set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr_ax25 *sa = addr;
 
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	memcpy(dev->dev_addr, &sa->sax25_call, AX25_ADDR_LEN);
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 
 	return 0;
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 6516603..b8740e6 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -356,7 +356,9 @@ static int ax_set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr_ax25 *sa = addr;
 
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	memcpy(dev->dev_addr, &sa->sax25_call, AX25_ADDR_LEN);
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 
 	return 0;
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 5d2108c..03fcd30 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -295,7 +295,9 @@ static void emac_rx_disable(struct emac_instance *dev)
 static inline void emac_netif_stop(struct emac_instance *dev)
 {
 	netif_tx_lock_bh(dev->ndev);
+	netif_addr_lock(dev->ndev);
 	dev->no_mcast = 1;
+	netif_addr_unlock(dev->ndev);
 	netif_tx_unlock_bh(dev->ndev);
 	dev->ndev->trans_start = jiffies;	/* prevent tx timeout */
 	mal_poll_disable(dev->mal, &dev->commac);
@@ -305,9 +307,11 @@ static inline void emac_netif_stop(struct emac_instance *dev)
 static inline void emac_netif_start(struct emac_instance *dev)
 {
 	netif_tx_lock_bh(dev->ndev);
+	netif_addr_lock(dev->ndev);
 	dev->no_mcast = 0;
 	if (dev->mcast_pending && netif_running(dev->ndev))
 		__emac_set_multicast_list(dev);
+	netif_addr_unlock(dev->ndev);
 	netif_tx_unlock_bh(dev->ndev);
 
 	netif_wake_queue(dev->ndev);
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 74265d8..e1257e5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -697,6 +697,8 @@ static void efx_stop_port(struct efx_nic *efx)
 	/* Serialise against efx_set_multicast_list() */
 	if (efx_dev_registered(efx)) {
 		netif_tx_lock_bh(efx->net_dev);
+		netif_addr_lock(efx->net_dev);
+		netif_addr_unlock(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
 }
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7ab94c8..87eb4e1 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -758,7 +758,9 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		 * list. */
 		rtnl_lock();
 		netif_tx_lock_bh(tun->dev);
+		netif_addr_lock(tun->dev);
 		add_multi(tun->chr_filter, ifr.ifr_hwaddr.sa_data);
+		netif_addr_unlock(tun->dev);
 		netif_tx_unlock_bh(tun->dev);
 		rtnl_unlock();
 
@@ -771,7 +773,9 @@ static int tun_chr_ioctl(struct inode *inode, struct file *file,
 		 * filter list. */
 		rtnl_lock();
 		netif_tx_lock_bh(tun->dev);
+		netif_addr_lock(tun->dev);
 		del_multi(tun->chr_filter, ifr.ifr_hwaddr.sa_data);
+		netif_addr_unlock(tun->dev);
 		netif_tx_unlock_bh(tun->dev);
 		rtnl_unlock();
 
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index abd6d9e..42e9b27 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -594,6 +594,7 @@ static int lbs_add_mcast_addrs(struct cmd_ds_mac_multicast_adr *cmd,
 		return nr_addrs;
 
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	for (mc_list = dev->mc_list; mc_list; mc_list = mc_list->next) {
 		if (mac_in_list(cmd->maclist, nr_addrs, mc_list->dmi_addr)) {
 			lbs_deb_net("mcast address %s:%s skipped\n", dev->name,
@@ -608,6 +609,7 @@ static int lbs_add_mcast_addrs(struct cmd_ds_mac_multicast_adr *cmd,
 			    print_mac(mac, mc_list->dmi_addr));
 		i++;
 	}
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 	if (mc_list)
 		return -EOVERFLOW;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fb5a0ec..199d1cc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1451,6 +1451,26 @@ static inline void netif_tx_disable(struct net_device *dev)
 	netif_tx_unlock_bh(dev);
 }
 
+static inline void netif_addr_lock(struct net_device *dev)
+{
+	spin_lock(&dev->addr_list_lock);
+}
+
+static inline void netif_addr_lock_bh(struct net_device *dev)
+{
+	spin_lock_bh(&dev->addr_list_lock);
+}
+
+static inline void netif_addr_unlock(struct net_device *dev)
+{
+	spin_unlock(&dev->addr_list_lock);
+}
+
+static inline void netif_addr_unlock_bh(struct net_device *dev)
+{
+	spin_unlock_bh(&dev->addr_list_lock);
+}
+
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
 
 extern void		ether_setup(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 7b50e8d..5f43ae0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2943,7 +2943,9 @@ void __dev_set_rx_mode(struct net_device *dev)
 void dev_set_rx_mode(struct net_device *dev)
 {
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	__dev_set_rx_mode(dev);
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 }
 
@@ -3023,9 +3025,11 @@ int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
 	ASSERT_RTNL();
 
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	err = __dev_addr_delete(&dev->uc_list, &dev->uc_count, addr, alen, 0);
 	if (!err)
 		__dev_set_rx_mode(dev);
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 	return err;
 }
@@ -3049,9 +3053,11 @@ int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 	ASSERT_RTNL();
 
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	err = __dev_addr_add(&dev->uc_list, &dev->uc_count, addr, alen, 0);
 	if (!err)
 		__dev_set_rx_mode(dev);
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 	return err;
 }
@@ -3120,10 +3126,12 @@ int dev_unicast_sync(struct net_device *to, struct net_device *from)
 	int err = 0;
 
 	netif_tx_lock_bh(to);
+	netif_addr_lock(to);
 	err = __dev_addr_sync(&to->uc_list, &to->uc_count,
 			      &from->uc_list, &from->uc_count);
 	if (!err)
 		__dev_set_rx_mode(to);
+	netif_addr_unlock(to);
 	netif_tx_unlock_bh(to);
 	return err;
 }
@@ -3141,13 +3149,17 @@ EXPORT_SYMBOL(dev_unicast_sync);
 void dev_unicast_unsync(struct net_device *to, struct net_device *from)
 {
 	netif_tx_lock_bh(from);
+	netif_addr_lock(from);
 	netif_tx_lock_bh(to);
+	netif_addr_lock(to);
 
 	__dev_addr_unsync(&to->uc_list, &to->uc_count,
 			  &from->uc_list, &from->uc_count);
 	__dev_set_rx_mode(to);
 
+	netif_addr_unlock(to);
 	netif_tx_unlock_bh(to);
+	netif_addr_unlock(from);
 	netif_tx_unlock_bh(from);
 }
 EXPORT_SYMBOL(dev_unicast_unsync);
@@ -3169,6 +3181,7 @@ static void __dev_addr_discard(struct dev_addr_list **list)
 static void dev_addr_discard(struct net_device *dev)
 {
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 
 	__dev_addr_discard(&dev->uc_list);
 	dev->uc_count = 0;
@@ -3176,6 +3189,7 @@ static void dev_addr_discard(struct net_device *dev)
 	__dev_addr_discard(&dev->mc_list);
 	dev->mc_count = 0;
 
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 }
 
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index f8a3455..b6b2a12 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -73,6 +73,7 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 	int err;
 
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	err = __dev_addr_delete(&dev->mc_list, &dev->mc_count,
 				addr, alen, glbl);
 	if (!err) {
@@ -83,6 +84,7 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 
 		__dev_set_rx_mode(dev);
 	}
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 	return err;
 }
@@ -96,9 +98,11 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 	int err;
 
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
 	if (!err)
 		__dev_set_rx_mode(dev);
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 	return err;
 }
@@ -120,10 +124,12 @@ int dev_mc_sync(struct net_device *to, struct net_device *from)
 	int err = 0;
 
 	netif_tx_lock_bh(to);
+	netif_addr_lock(to);
 	err = __dev_addr_sync(&to->mc_list, &to->mc_count,
 			      &from->mc_list, &from->mc_count);
 	if (!err)
 		__dev_set_rx_mode(to);
+	netif_addr_unlock(to);
 	netif_tx_unlock_bh(to);
 
 	return err;
@@ -144,13 +150,17 @@ EXPORT_SYMBOL(dev_mc_sync);
 void dev_mc_unsync(struct net_device *to, struct net_device *from)
 {
 	netif_tx_lock_bh(from);
+	netif_addr_lock(from);
 	netif_tx_lock_bh(to);
+	netif_addr_lock(to);
 
 	__dev_addr_unsync(&to->mc_list, &to->mc_count,
 			  &from->mc_list, &from->mc_count);
 	__dev_set_rx_mode(to);
 
+	netif_addr_unlock(to);
 	netif_tx_unlock_bh(to);
+	netif_addr_unlock(from);
 	netif_tx_unlock_bh(from);
 }
 EXPORT_SYMBOL(dev_mc_unsync);
@@ -165,6 +175,7 @@ static int dev_mc_seq_show(struct seq_file *seq, void *v)
 		return 0;
 
 	netif_tx_lock_bh(dev);
+	netif_addr_lock(dev);
 	for (m = dev->mc_list; m; m = m->next) {
 		int i;
 
@@ -176,6 +187,7 @@ static int dev_mc_seq_show(struct seq_file *seq, void *v)
 
 		seq_putc(seq, '\n');
 	}
+	netif_addr_unlock(dev);
 	netif_tx_unlock_bh(dev);
 	return 0;
 }
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 5c5396e..59fec7e 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -315,7 +315,9 @@ static int ieee80211_open(struct net_device *dev)
 			local->fif_other_bss++;
 
 		netif_tx_lock_bh(local->mdev);
+		netif_addr_lock(local->mdev);
 		ieee80211_configure_filter(local);
+		netif_addr_unlock(local->mdev);
 		netif_tx_unlock_bh(local->mdev);
 		break;
 	case IEEE80211_IF_TYPE_STA:
@@ -509,7 +511,9 @@ static int ieee80211_stop(struct net_device *dev)
 			local->fif_other_bss--;
 
 		netif_tx_lock_bh(local->mdev);
+		netif_addr_lock(local->mdev);
 		ieee80211_configure_filter(local);
+		netif_addr_unlock(local->mdev);
 		netif_tx_unlock_bh(local->mdev);
 		break;
 	case IEEE80211_IF_TYPE_MESH_POINT:
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 55659a7..92d7b46 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3841,6 +3841,7 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 
 
 	netif_tx_lock_bh(local->mdev);
+	netif_addr_lock(local->mdev);
 	local->filter_flags &= ~FIF_BCN_PRBRESP_PROMISC;
 	local->ops->configure_filter(local_to_hw(local),
 				     FIF_BCN_PRBRESP_PROMISC,
@@ -3848,6 +3849,7 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 				     local->mdev->mc_count,
 				     local->mdev->mc_list);
 
+	netif_addr_unlock(local->mdev);
 	netif_tx_unlock_bh(local->mdev);
 
 	rcu_read_lock();
@@ -4046,12 +4048,14 @@ static int ieee80211_sta_start_scan(struct net_device *dev,
 	local->scan_dev = dev;
 
 	netif_tx_lock_bh(local->mdev);
+	netif_addr_lock(local->mdev);
 	local->filter_flags |= FIF_BCN_PRBRESP_PROMISC;
 	local->ops->configure_filter(local_to_hw(local),
 				     FIF_BCN_PRBRESP_PROMISC,
 				     &local->filter_flags,
 				     local->mdev->mc_count,
 				     local->mdev->mc_list);
+	netif_addr_unlock(local->mdev);
 	netif_tx_unlock_bh(local->mdev);
 
 	/* TODO: start scan as soon as all nullfunc frames are ACKed */
-- 
1.5.6

