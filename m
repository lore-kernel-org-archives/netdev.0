From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 1/5] bonding: make 802.3ad use latest lacp_rate
Date: Thu,  9 Jun 2011 15:03:27 +0800
Message-ID: <c09252c2b9659e7f7dffa89c1967010ff53a3036.1307601948.git.panweiping3@gmail.com>
References: <cover.1307601948.git.panweiping3@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Weiping Pan <panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1307601948.git.panweiping3@gmail.com>
In-Reply-To: <cover.1307601948.git.panweiping3@gmail.com>
References: <cover.1307601948.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is bug that when you modify lacp_rate via sysfs,
802.3ad won't use the new value of lacp_rate to transmit packets.
This is because port->actor_oper_port_state isn't changed.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_3ad.c   |   31 +++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_3ad.h   |    1 +
 drivers/net/bonding/bond_sysfs.c |    1 +
 3 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c7537abc..4512bc4 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2473,3 +2473,34 @@ void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
 	bond_3ad_rx_indication((struct lacpdu *) skb->data, slave, skb->len);
 	read_unlock(&bond->lock);
 }
+
+/*
+ * When modify lacp_rate parameter via sysfs,
+ * update actor_oper_port_state of each port.
+ *
+ * Hold slave->state_machine_lock,
+ * so we can modify port->actor_oper_port_state,
+ * no matter bond is up or down.
+ */
+void bond_3ad_update_lacp_rate(struct bonding *bond)
+{
+	int i;
+	struct slave *slave;
+	struct port *port = NULL;
+	int lacp_fast;
+
+	read_lock(&bond->lock);
+	lacp_fast = bond->params.lacp_fast;
+
+	bond_for_each_slave(bond, slave, i) {
+		port = &(SLAVE_AD_INFO(slave).port);
+		__get_state_machine_lock(port);
+		if (lacp_fast)
+			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
+		else
+			port->actor_oper_port_state &= ~AD_STATE_LACP_TIMEOUT;
+		__release_state_machine_lock(port);
+	}
+
+	read_unlock(&bond->lock);
+}
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 0ee3f16..e466faf 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -282,5 +282,6 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
 void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
 			  struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
+void bond_3ad_update_lacp_rate(struct bonding *bond);
 #endif //__BOND_3AD_H__
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 88fcb25..03d1196 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -804,6 +804,7 @@ static ssize_t bonding_store_lacp(struct device *d,
 
 	if ((new_value == 1) || (new_value == 0)) {
 		bond->params.lacp_fast = new_value;
+		bond_3ad_update_lacp_rate(bond);
 		pr_info("%s: Setting LACP rate to %s (%d).\n",
 			bond->dev->name, bond_lacp_tbl[new_value].modename,
 			new_value);
-- 
1.7.4.4
