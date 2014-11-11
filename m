From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next 3/3] net: propagate LRO disabling to bond and team
 slaves
Date: Tue, 11 Nov 2014 09:22:00 +0100 (CET)
Message-ID: <cc53d655bc743bfdb790dfcd8880338d1c4b4c91.1415692212.git.mkubecek@suse.cz>
References: <cover.1415692212.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1415692212.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As LRO doesn't work correctly if incoming packets are passed to other
hosts, it needs to be disabled if a device is enslaved into a bridge or
forwarding is enabled for it.

For a bond/team master, LRO needs to be disabled for all its slaves as
they are actually receiving the packets. Once LRO is disabled for
a bond/team master, we also need to make sure to disable it for newly
added slaves.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 drivers/net/bonding/bond_main.c | 3 +++
 drivers/net/team/team.c         | 3 +++
 net/core/dev.c                  | 8 ++++++++
 3 files changed, 14 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b9b3456..8575fee 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1526,6 +1526,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 #endif
 
+	if (!(bond_dev->features & NETIF_F_LRO))
+		dev_disable_lro(slave_dev);
+
 	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
 					 new_slave);
 	if (res) {
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index e1e2b85..217b973 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1179,6 +1179,9 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_enable_netpoll;
 	}
 
+	if (!(dev->features & NETIF_F_LRO))
+		dev_disable_lro(port_dev);
+
 	err = netdev_rx_handler_register(port_dev, team_handle_frame,
 					 port);
 	if (err) {
diff --git a/net/core/dev.c b/net/core/dev.c
index ebcd308..b132f44 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1438,6 +1438,8 @@ EXPORT_SYMBOL(dev_close);
 void dev_disable_lro(struct net_device *dev)
 {
 	struct net_device *prev_dev;
+	struct net_device *lower_dev;
+	struct list_head *iter;
 
 	do {
 		prev_dev = dev;
@@ -1458,6 +1460,12 @@ void dev_disable_lro(struct net_device *dev)
 
 	if (unlikely(dev->features & NETIF_F_LRO))
 		netdev_WARN(dev, "failed to disable LRO!\n");
+
+	/* if dev is a bond/team master, disable LRO for all its slaves */
+	if (netif_is_bond_master(dev) || netif_is_team_master(dev)) {
+		netdev_for_each_lower_dev(dev, lower_dev, iter)
+			dev_disable_lro(lower_dev);
+	}
 }
 EXPORT_SYMBOL(dev_disable_lro);
 
-- 
1.8.4.5
