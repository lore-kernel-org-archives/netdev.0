From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: call dev_alloc_name from register_netdevice
Date: Sat, 30 Apr 2011 13:21:32 +0200
Message-ID: <1304162492-6606-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, mirqus@gmail.com,
	xemul@openvz.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824Ab1D3LVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2011 07:21:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Force dev_alloc_name() to be called from register_netdevice() by
dev_get_valid_name(). That allows to remove multiple explicit
dev_alloc_name() calls.

The possibility to call dev_alloc_name in advance remains.

This also fixes veth creation regresion caused by
84c49d8c3e4abefb0a41a77b25aa37ebe8d6b743

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/ieee802154/fakehard.c             |   10 ----------
 drivers/net/bonding/bond_main.c           |   21 +++------------------
 drivers/net/dummy.c                       |    4 ----
 drivers/net/hamradio/bpqether.c           |    4 ----
 drivers/net/ifb.c                         |    4 ----
 drivers/net/tun.c                         |    6 ------
 drivers/net/wan/dlci.c                    |    4 ----
 drivers/net/wan/hdlc_fr.c                 |    9 +--------
 drivers/net/wan/lapbether.c               |    4 ----
 drivers/net/wireless/hostap/hostap_main.c |    7 +------
 drivers/net/wireless/mac80211_hwsim.c     |   11 +----------
 drivers/net/wireless/mwifiex/main.c       |    4 ----
 drivers/s390/net/netiucv.c                |    2 --
 net/core/dev.c                            |   24 ++++++------------------
 net/core/rtnetlink.c                      |    8 --------
 net/ipv4/ip_gre.c                         |    5 -----
 net/ipv4/ipip.c                           |    5 -----
 net/ipv6/ip6_tunnel.c                     |    5 -----
 net/ipv6/sit.c                            |    5 -----
 net/mac80211/iface.c                      |    4 ----
 20 files changed, 12 insertions(+), 134 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index d9d0e13..a5a49a1 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -393,16 +393,6 @@ static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 	priv = netdev_priv(dev);
 	priv->phy = phy;
 
-	/*
-	 * If the name is a format string the caller wants us to do a
-	 * name allocation.
-	 */
-	if (strchr(dev->name, '%')) {
-		err = dev_alloc_name(dev, dev->name);
-		if (err < 0)
-			goto out;
-	}
-
 	wpan_phy_set_dev(phy, &pdev->dev);
 	SET_NETDEV_DEV(dev, &phy->dev);
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 66d9dc6..fa5382e0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4858,8 +4858,9 @@ int bond_create(struct net *net, const char *name)
 
 	rtnl_lock();
 
-	bond_dev = alloc_netdev_mq(sizeof(struct bonding), name ? name : "",
-				bond_setup, tx_queues);
+	bond_dev = alloc_netdev_mq(sizeof(struct bonding),
+				   name ? name : "bond%d",
+				   bond_setup, tx_queues);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
 		rtnl_unlock();
@@ -4869,26 +4870,10 @@ int bond_create(struct net *net, const char *name)
 	dev_net_set(bond_dev, net);
 	bond_dev->rtnl_link_ops = &bond_link_ops;
 
-	if (!name) {
-		res = dev_alloc_name(bond_dev, "bond%d");
-		if (res < 0)
-			goto out;
-	} else {
-		/*
-		 * If we're given a name to register
-		 * we need to ensure that its not already
-		 * registered
-		 */
-		res = -EEXIST;
-		if (__dev_get_by_name(net, name) != NULL)
-			goto out;
-	}
-
 	res = register_netdevice(bond_dev);
 
 	netif_carrier_off(bond_dev);
 
-out:
 	rtnl_unlock();
 	if (res < 0)
 		bond_destructor(bond_dev);
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index ff2d29b..39cf9b9 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -168,10 +168,6 @@ static int __init dummy_init_one(void)
 	if (!dev_dummy)
 		return -ENOMEM;
 
-	err = dev_alloc_name(dev_dummy, dev_dummy->name);
-	if (err < 0)
-		goto err;
-
 	dev_dummy->rtnl_link_ops = &dummy_link_ops;
 	err = register_netdevice(dev_dummy);
 	if (err < 0)
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 8931168..18d8aff 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -516,10 +516,6 @@ static int bpq_new_device(struct net_device *edev)
 	memcpy(bpq->dest_addr, bcast_addr, sizeof(bpq_eth_addr));
 	memcpy(bpq->acpt_addr, bcast_addr, sizeof(bpq_eth_addr));
 
-	err = dev_alloc_name(ndev, ndev->name);
-	if (err < 0) 
-		goto error;
-
 	err = register_netdevice(ndev);
 	if (err)
 		goto error;
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index e07d487..4fecaed 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -233,10 +233,6 @@ static int __init ifb_init_one(int index)
 	if (!dev_ifb)
 		return -ENOMEM;
 
-	err = dev_alloc_name(dev_ifb, dev_ifb->name);
-	if (err < 0)
-		goto err;
-
 	dev_ifb->rtnl_link_ops = &ifb_link_ops;
 	err = register_netdevice(dev_ifb);
 	if (err < 0)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ade3cf9..334b5ad 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1099,12 +1099,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		tun_net_init(dev);
 
-		if (strchr(dev->name, '%')) {
-			err = dev_alloc_name(dev, dev->name);
-			if (err < 0)
-				goto err_free_sk;
-		}
-
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
 			TUN_USER_FEATURES;
 		dev->features = dev->hw_features;
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 1481a44..21b104d 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -341,10 +341,6 @@ static int dlci_add(struct dlci_add *dlci)
 		}
 	}
 
-	err = dev_alloc_name(master, master->name);
-	if (err < 0)
-		goto err2;
-
 	*(short *)(master->dev_addr) = dlci->dlci;
 
 	dlp = netdev_priv(master);
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 0edb535..fc433f2 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1070,7 +1070,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	hdlc_device *hdlc = dev_to_hdlc(frad);
 	pvc_device *pvc;
 	struct net_device *dev;
-	int result, used;
+	int used;
 
 	if ((pvc = add_pvc(frad, dlci)) == NULL) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_add_pvc()\n",
@@ -1106,13 +1106,6 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	dev->tx_queue_len = 0;
 	dev->ml_priv = pvc;
 
-	result = dev_alloc_name(dev, dev->name);
-	if (result < 0) {
-		free_netdev(dev);
-		delete_unused_pvcs(hdlc);
-		return result;
-	}
-
 	if (register_netdevice(dev) != 0) {
 		free_netdev(dev);
 		delete_unused_pvcs(hdlc);
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 7f5bb91..eec463f 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -338,10 +338,6 @@ static int lapbeth_new_device(struct net_device *dev)
 	dev_hold(dev);
 	lapbeth->ethdev = dev;
 
-	rc = dev_alloc_name(ndev, ndev->name);
-	if (rc < 0) 
-		goto fail;
-
 	rc = -EIO;
 	if (register_netdevice(ndev))
 		goto fail;
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 1d9aed6..d508482 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -79,13 +79,8 @@ struct net_device * hostap_add_interface(struct local_info *local,
 	if (!rtnl_locked)
 		rtnl_lock();
 
-	ret = 0;
-	if (strchr(dev->name, '%'))
-		ret = dev_alloc_name(dev, dev->name);
-
 	SET_NETDEV_DEV(dev, mdev->dev.parent);
-	if (ret >= 0)
-		ret = register_netdevice(dev);
+	ret = register_netdevice(dev);
 
 	if (!rtnl_locked)
 		rtnl_unlock();
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index f4f4257..9d4a40e 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1515,19 +1515,10 @@ static int __init init_mac80211_hwsim(void)
 	if (hwsim_mon == NULL)
 		goto failed;
 
-	rtnl_lock();
-
-	err = dev_alloc_name(hwsim_mon, hwsim_mon->name);
+	err = register_netdev(hwsim_mon);
 	if (err < 0)
 		goto failed_mon;
 
-
-	err = register_netdevice(hwsim_mon);
-	if (err < 0)
-		goto failed_mon;
-
-	rtnl_unlock();
-
 	return 0;
 
 failed_mon:
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index c597188..d16cea7 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -706,10 +706,6 @@ static struct mwifiex_private *mwifiex_add_interface(
 		dev_err(adapter->dev, "no memory available for netdevice\n");
 		goto error;
 	}
-	if (dev_alloc_name(dev, dev->name)) {
-		dev_err(adapter->dev, "unable to alloc name for netdevice\n");
-		goto error;
-	}
 
 	if (mwifiex_register_cfg80211(dev, adapter->priv[bss_index]->curr_addr,
 				      adapter->priv[bss_index]) != 0) {
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index b6a6356..3251333 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1994,8 +1994,6 @@ static struct net_device *netiucv_init_netdevice(char *username)
 			   netiucv_setup_netdevice);
 	if (!dev)
 		return NULL;
-	if (dev_alloc_name(dev, dev->name) < 0)
-		goto out_netdev;
 
 	privptr = netdev_priv(dev);
 	privptr->fsm = init_fsm("netiucvdev", dev_state_names,
diff --git a/net/core/dev.c b/net/core/dev.c
index 7db99b5..992574a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -948,7 +948,7 @@ int dev_alloc_name(struct net_device *dev, const char *name)
 }
 EXPORT_SYMBOL(dev_alloc_name);
 
-static int dev_get_valid_name(struct net_device *dev, const char *name, bool fmt)
+static int dev_get_valid_name(struct net_device *dev, const char *name)
 {
 	struct net *net;
 
@@ -958,7 +958,7 @@ static int dev_get_valid_name(struct net_device *dev, const char *name, bool fmt
 	if (!dev_valid_name(name))
 		return -EINVAL;
 
-	if (fmt && strchr(name, '%'))
+	if (strchr(name, '%'))
 		return dev_alloc_name(dev, name);
 	else if (__dev_get_by_name(net, name))
 		return -EEXIST;
@@ -995,7 +995,7 @@ int dev_change_name(struct net_device *dev, const char *newname)
 
 	memcpy(oldname, dev->name, IFNAMSIZ);
 
-	err = dev_get_valid_name(dev, newname, 1);
+	err = dev_get_valid_name(dev, newname);
 	if (err < 0)
 		return err;
 
@@ -5396,8 +5396,8 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	ret = dev_get_valid_name(dev, dev->name, 0);
-	if (ret)
+	ret = dev_get_valid_name(dev, dev->name);
+	if (ret < 0)
 		goto err_uninit;
 
 	dev->ifindex = dev_new_index(net);
@@ -5538,19 +5538,7 @@ int register_netdev(struct net_device *dev)
 	int err;
 
 	rtnl_lock();
-
-	/*
-	 * If the name is a format string the caller wants us to do a
-	 * name allocation.
-	 */
-	if (strchr(dev->name, '%')) {
-		err = dev_alloc_name(dev, dev->name);
-		if (err < 0)
-			goto out;
-	}
-
 	err = register_netdevice(dev);
-out:
 	rtnl_unlock();
 	return err;
 }
@@ -6032,7 +6020,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 		/* We get here if we can't use the current device name */
 		if (!pat)
 			goto out;
-		if (dev_get_valid_name(dev, pat, 1))
+		if (dev_get_valid_name(dev, pat) < 0)
 			goto out;
 	}
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d7c4bb4..d4dec8c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1570,12 +1570,6 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 	dev->rtnl_link_state = RTNL_LINK_INITIALIZING;
 	dev->real_num_tx_queues = real_num_queues;
 
-	if (strchr(dev->name, '%')) {
-		err = dev_alloc_name(dev, dev->name);
-		if (err < 0)
-			goto err_free;
-	}
-
 	if (tb[IFLA_MTU])
 		dev->mtu = nla_get_u32(tb[IFLA_MTU]);
 	if (tb[IFLA_ADDRESS])
@@ -1595,8 +1589,6 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 
 	return dev;
 
-err_free:
-	free_netdev(dev);
 err:
 	return ERR_PTR(err);
 }
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 24efd35..0d536f2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -413,11 +413,6 @@ static struct ip_tunnel *ipgre_tunnel_locate(struct net *net,
 
 	dev_net_set(dev, net);
 
-	if (strchr(name, '%')) {
-		if (dev_alloc_name(dev, name) < 0)
-			goto failed_free;
-	}
-
 	nt = netdev_priv(dev);
 	nt->parms = *parms;
 	dev->rtnl_link_ops = &ipgre_link_ops;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index ef16377..f0e0fb2 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -276,11 +276,6 @@ static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
 
 	dev_net_set(dev, net);
 
-	if (strchr(name, '%')) {
-		if (dev_alloc_name(dev, name) < 0)
-			goto failed_free;
-	}
-
 	nt = netdev_priv(dev);
 	nt->parms = *parms;
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9dd0e96..ae244d3 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -280,11 +280,6 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
 
 	dev_net_set(dev, net);
 
-	if (strchr(name, '%')) {
-		if (dev_alloc_name(dev, name) < 0)
-			goto failed_free;
-	}
-
 	t = netdev_priv(dev);
 	t->parms = *p;
 	err = ip6_tnl_dev_init(dev);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 34d8964..87a547e 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -250,11 +250,6 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 
 	dev_net_set(dev, net);
 
-	if (strchr(name, '%')) {
-		if (dev_alloc_name(dev, name) < 0)
-			goto failed_free;
-	}
-
 	nt = netdev_priv(dev);
 
 	nt->parms = *parms;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 4054399..80c29d6 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1144,10 +1144,6 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 				+ IEEE80211_ENCRYPT_HEADROOM;
 	ndev->needed_tailroom = IEEE80211_ENCRYPT_TAILROOM;
 
-	ret = dev_alloc_name(ndev, ndev->name);
-	if (ret < 0)
-		goto fail;
-
 	ieee80211_assign_perm_addr(local, ndev, type);
 	memcpy(ndev->dev_addr, ndev->perm_addr, ETH_ALEN);
 	SET_NETDEV_DEV(ndev, wiphy_dev(local->hw.wiphy));
-- 
1.7.4.2

