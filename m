From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 03/11] net: bonding: Flip to the new dev walk API
Date: Fri, 14 Oct 2016 18:28:43 -0700
Message-ID: <1476494931-31813-4-git-send-email-dsa@cumulusnetworks.com>
References: <1476494931-31813-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476494931-31813-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert alb_send_learning_packets and bond_has_this_ip to use the new
netdev_walk_all_upper_dev_rcu API. In both cases this is just a code
conversion; no functional change is intended.

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 drivers/net/bonding/bond_alb.c  | 82 ++++++++++++++++++++++++++---------------
 drivers/net/bonding/bond_main.c | 21 +++++++----
 2 files changed, 65 insertions(+), 38 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 551f0f8dead3..1ddedec61900 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -950,13 +950,61 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
 	dev_queue_xmit(skb);
 }
 
+struct alb_walk_data {
+	struct bonding *bond;
+	struct slave *slave;
+	u8 *mac_addr;
+	bool strict_match;
+};
+
+static int alb_upper_dev_walk(struct net_device *upper, void *data)
+{
+	struct alb_walk_data *_data = (struct alb_walk_data *)data;
+	bool strict_match = _data->strict_match;
+	struct bonding *bond = _data->bond;
+	struct slave *slave = _data->slave;
+	u8 *mac_addr = _data->mac_addr;
+	struct bond_vlan_tag *tags;
+
+	if (is_vlan_dev(upper) && vlan_get_encap_level(upper) == 0) {
+		if (strict_match &&
+		    ether_addr_equal_64bits(mac_addr,
+					    upper->dev_addr)) {
+			alb_send_lp_vid(slave, mac_addr,
+					vlan_dev_vlan_proto(upper),
+					vlan_dev_vlan_id(upper));
+		} else if (!strict_match) {
+			alb_send_lp_vid(slave, upper->dev_addr,
+					vlan_dev_vlan_proto(upper),
+					vlan_dev_vlan_id(upper));
+		}
+	}
+
+	/* If this is a macvlan device, then only send updates
+	 * when strict_match is turned off.
+	 */
+	if (netif_is_macvlan(upper) && !strict_match) {
+		tags = bond_verify_device_path(bond->dev, upper, 0);
+		if (IS_ERR_OR_NULL(tags))
+			BUG();
+		alb_send_lp_vid(slave, upper->dev_addr,
+				tags[0].vlan_proto, tags[0].vlan_id);
+		kfree(tags);
+	}
+
+	return 0;
+}
+
 static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[],
 				      bool strict_match)
 {
 	struct bonding *bond = bond_get_bond_by_slave(slave);
-	struct net_device *upper;
-	struct list_head *iter;
-	struct bond_vlan_tag *tags;
+	struct alb_walk_data data = {
+		.strict_match = strict_match,
+		.mac_addr = mac_addr,
+		.slave = slave,
+		.bond = bond,
+	};
 
 	/* send untagged */
 	alb_send_lp_vid(slave, mac_addr, 0, 0);
@@ -965,33 +1013,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[],
 	 * for that device.
 	 */
 	rcu_read_lock();
-	netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
-		if (is_vlan_dev(upper) && vlan_get_encap_level(upper) == 0) {
-			if (strict_match &&
-			    ether_addr_equal_64bits(mac_addr,
-						    upper->dev_addr)) {
-				alb_send_lp_vid(slave, mac_addr,
-						vlan_dev_vlan_proto(upper),
-						vlan_dev_vlan_id(upper));
-			} else if (!strict_match) {
-				alb_send_lp_vid(slave, upper->dev_addr,
-						vlan_dev_vlan_proto(upper),
-						vlan_dev_vlan_id(upper));
-			}
-		}
-
-		/* If this is a macvlan device, then only send updates
-		 * when strict_match is turned off.
-		 */
-		if (netif_is_macvlan(upper) && !strict_match) {
-			tags = bond_verify_device_path(bond->dev, upper, 0);
-			if (IS_ERR_OR_NULL(tags))
-				BUG();
-			alb_send_lp_vid(slave, upper->dev_addr,
-					tags[0].vlan_proto, tags[0].vlan_id);
-			kfree(tags);
-		}
-	}
+	netdev_walk_all_upper_dev_rcu(bond->dev, alb_upper_dev_walk, &data);
 	rcu_read_unlock();
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5fa36ebc0640..89191b019178 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2270,22 +2270,27 @@ static void bond_mii_monitor(struct work_struct *work)
 	}
 }
 
+static int bond_upper_dev_walk(struct net_device *upper, void *data)
+{
+	__be32 ip = *((__be32 *)data);
+	int ret = 0;
+
+	if (ip == bond_confirm_addr(upper, 0, ip))
+		ret = 1;
+
+	return ret;
+}
+
 static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
 {
-	struct net_device *upper;
-	struct list_head *iter;
 	bool ret = false;
 
 	if (ip == bond_confirm_addr(bond->dev, 0, ip))
 		return true;
 
 	rcu_read_lock();
-	netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
-		if (ip == bond_confirm_addr(upper, 0, ip)) {
-			ret = true;
-			break;
-		}
-	}
+	if (netdev_walk_all_upper_dev_rcu(bond->dev, bond_upper_dev_walk, &ip))
+		ret = true;
 	rcu_read_unlock();
 
 	return ret;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
