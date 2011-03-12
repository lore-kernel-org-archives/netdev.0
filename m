From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 2/6] bonding: register slave pointer for rx_handler
Date: Sat, 12 Mar 2011 14:14:35 +0100
Message-ID: <1299935679-18135-3-git-send-email-jpirko@redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23193 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab1CLNOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 08:14:51 -0500
In-Reply-To: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register slave pointer as rx_handler data. That would eventually preven=
t
need to loop over slave devices to find the right slave.

Use synchronize_net to ensure that bond_handle_frame does not get slave
structure freed when working with that.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Reviewed-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 drivers/net/bonding/bond_main.c |   17 +++++++++++------
 drivers/net/bonding/bonding.h   |    3 +++
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 68a5ce0..29f69da 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1482,21 +1482,22 @@ static bool bond_should_deliver_exact_match(str=
uct sk_buff *skb,
=20
 static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 {
-	struct net_device *slave_dev;
+	struct slave *slave;
 	struct net_device *bond_dev;
=20
 	skb =3D skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
 		return NULL;
-	slave_dev =3D skb->dev;
-	bond_dev =3D ACCESS_ONCE(slave_dev->master);
+
+	slave =3D bond_slave_get_rcu(skb->dev);
+	bond_dev =3D ACCESS_ONCE(slave->dev->master);
 	if (unlikely(!bond_dev))
 		return skb;
=20
 	if (bond_dev->priv_flags & IFF_MASTER_ARPMON)
-		slave_dev->last_rx =3D jiffies;
+		slave->dev->last_rx =3D jiffies;
=20
-	if (bond_should_deliver_exact_match(skb, slave_dev, bond_dev)) {
+	if (bond_should_deliver_exact_match(skb, slave->dev, bond_dev)) {
 		skb->deliver_no_wcard =3D 1;
 		return skb;
 	}
@@ -1694,7 +1695,8 @@ int bond_enslave(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 		pr_debug("Error %d calling netdev_set_bond_master\n", res);
 		goto err_restore_mac;
 	}
-	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame, NULL=
);
+	res =3D netdev_rx_handler_register(slave_dev, bond_handle_frame,
+					 new_slave);
 	if (res) {
 		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
 		goto err_unset_master;
@@ -1916,6 +1918,7 @@ err_close:
=20
 err_unreg_rxhandler:
 	netdev_rx_handler_unregister(slave_dev);
+	synchronize_net();
=20
 err_unset_master:
 	netdev_set_bond_master(slave_dev, NULL);
@@ -2099,6 +2102,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	}
=20
 	netdev_rx_handler_unregister(slave_dev);
+	synchronize_net();
 	netdev_set_bond_master(slave_dev, NULL);
=20
 	slave_disable_netpoll(slave);
@@ -2213,6 +2217,7 @@ static int bond_release_all(struct net_device *bo=
nd_dev)
 		}
=20
 		netdev_rx_handler_unregister(slave_dev);
+		synchronize_net();
 		netdev_set_bond_master(slave_dev, NULL);
=20
 		slave_disable_netpoll(slave);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index c4e2343..ff9af31 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -266,6 +266,9 @@ struct bonding {
 #endif /* CONFIG_DEBUG_FS */
 };
=20
+#define bond_slave_get_rcu(dev) \
+	((struct slave *) rcu_dereference(dev->rx_handler_data))
+
 /**
  * Returns NULL if the net_device does not belong to any of the bond's=
 slaves
  *
--=20
1.7.4

