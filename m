From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/2] bonding: export slave's actor_oper_port_state via sysfs and netlink
Date: Sun, 14 Jun 2015 16:36:34 +0300
Message-ID: <1434288995-25457-2-git-send-email-razor@blackwall.org>
References: <1434288995-25457-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, gospo@cumulusnetworks.com,
	j.vosburgh@gmail.com, vfalico@gmail.com,
	Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36339 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbbFNNgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 09:36:47 -0400
Received: by wigg3 with SMTP id g3so53268864wig.1
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 06:36:45 -0700 (PDT)
In-Reply-To: <1434288995-25457-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export the actor_oper_port_state of each port via sysfs and netlink.
In 802.3ad mode it is valuable for the user to be able to check the
actor_oper state, it is already exported via bond's proc entry.

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
---
 drivers/net/bonding/bond_netlink.c     | 10 +++++++++-
 drivers/net/bonding/bond_sysfs_slave.c | 16 ++++++++++++++++
 include/uapi/linux/if_link.h           |  1 +
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index f7015eb4f8db..a0e600db4236 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -28,6 +28,7 @@ static size_t bond_get_slave_size(const struct net_device *bond_dev,
 		nla_total_size(MAX_ADDR_LEN) +	/* IFLA_BOND_SLAVE_PERM_HWADDR */
 		nla_total_size(sizeof(u16)) +	/* IFLA_BOND_SLAVE_QUEUE_ID */
 		nla_total_size(sizeof(u16)) +	/* IFLA_BOND_SLAVE_AD_AGGREGATOR_ID */
+		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE */
 		0;
 }
 
@@ -56,12 +57,19 @@ static int bond_fill_slave_info(struct sk_buff *skb,
 
 	if (BOND_MODE(slave->bond) == BOND_MODE_8023AD) {
 		const struct aggregator *agg;
+		const struct port *ad_port;
 
+		ad_port = &SLAVE_AD_INFO(slave)->port;
 		agg = SLAVE_AD_INFO(slave)->port.aggregator;
-		if (agg)
+		if (agg) {
 			if (nla_put_u16(skb, IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
 					agg->aggregator_identifier))
 				goto nla_put_failure;
+			if (nla_put_u8(skb,
+				       IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE,
+				       ad_port->actor_oper_port_state))
+				goto nla_put_failure;
+		}
 	}
 
 	return 0;
diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bonding/bond_sysfs_slave.c
index 23618a831612..f6c197cee669 100644
--- a/drivers/net/bonding/bond_sysfs_slave.c
+++ b/drivers/net/bonding/bond_sysfs_slave.c
@@ -80,6 +80,21 @@ static ssize_t ad_aggregator_id_show(struct slave *slave, char *buf)
 }
 static SLAVE_ATTR_RO(ad_aggregator_id);
 
+static ssize_t ad_actor_oper_port_state_show(struct slave *slave, char *buf)
+{
+	const struct port *ad_port;
+
+	if (BOND_MODE(slave->bond) == BOND_MODE_8023AD) {
+		ad_port = &SLAVE_AD_INFO(slave)->port;
+		if (ad_port->aggregator)
+			return sprintf(buf, "%u\n",
+				       ad_port->actor_oper_port_state);
+	}
+
+	return sprintf(buf, "N/A\n");
+}
+static SLAVE_ATTR_RO(ad_actor_oper_port_state);
+
 static const struct slave_attribute *slave_attrs[] = {
 	&slave_attr_state,
 	&slave_attr_mii_status,
@@ -87,6 +102,7 @@ static const struct slave_attribute *slave_attrs[] = {
 	&slave_attr_perm_hwaddr,
 	&slave_attr_queue_id,
 	&slave_attr_ad_aggregator_id,
+	&slave_attr_ad_actor_oper_port_state,
 	NULL
 };
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 1737b7a8272b..1b3e357223f2 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -456,6 +456,7 @@ enum {
 	IFLA_BOND_SLAVE_PERM_HWADDR,
 	IFLA_BOND_SLAVE_QUEUE_ID,
 	IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
+	IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE,
 	__IFLA_BOND_SLAVE_MAX,
 };
 
-- 
2.4.3
