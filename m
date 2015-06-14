From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/2] bonding: export slave's partner_oper_port_state via sysfs and netlink
Date: Sun, 14 Jun 2015 16:36:35 +0300
Message-ID: <1434288995-25457-3-git-send-email-razor@blackwall.org>
References: <1434288995-25457-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, gospo@cumulusnetworks.com,
	j.vosburgh@gmail.com, vfalico@gmail.com,
	Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:36794 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbbFNNgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 09:36:48 -0400
Received: by wgzl5 with SMTP id l5so25998443wgz.3
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 06:36:47 -0700 (PDT)
In-Reply-To: <1434288995-25457-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export the partner_oper_port_state of each port via sysfs and netlink.
In 802.3ad mode it is valuable for the user to be able to check the
partner_oper state, it is already exported via bond's proc entry.

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
---
Note: There's one line that's > 80 chars, but it's an IFLA name and can't
      be broken in a sane way.

 drivers/net/bonding/bond_netlink.c     |  5 +++++
 drivers/net/bonding/bond_sysfs_slave.c | 16 ++++++++++++++++
 include/uapi/linux/if_link.h           |  1 +
 3 files changed, 22 insertions(+)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index a0e600db4236..5580fcde738f 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -29,6 +29,7 @@ static size_t bond_get_slave_size(const struct net_device *bond_dev,
 		nla_total_size(sizeof(u16)) +	/* IFLA_BOND_SLAVE_QUEUE_ID */
 		nla_total_size(sizeof(u16)) +	/* IFLA_BOND_SLAVE_AD_AGGREGATOR_ID */
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE */
+		nla_total_size(sizeof(u16)) +	/* IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE */
 		0;
 }
 
@@ -69,6 +70,10 @@ static int bond_fill_slave_info(struct sk_buff *skb,
 				       IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE,
 				       ad_port->actor_oper_port_state))
 				goto nla_put_failure;
+			if (nla_put_u16(skb,
+					IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE,
+					ad_port->partner_oper.port_state))
+				goto nla_put_failure;
 		}
 	}
 
diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bonding/bond_sysfs_slave.c
index f6c197cee669..7d16c51e6913 100644
--- a/drivers/net/bonding/bond_sysfs_slave.c
+++ b/drivers/net/bonding/bond_sysfs_slave.c
@@ -95,6 +95,21 @@ static ssize_t ad_actor_oper_port_state_show(struct slave *slave, char *buf)
 }
 static SLAVE_ATTR_RO(ad_actor_oper_port_state);
 
+static ssize_t ad_partner_oper_port_state_show(struct slave *slave, char *buf)
+{
+	const struct port *ad_port;
+
+	if (BOND_MODE(slave->bond) == BOND_MODE_8023AD) {
+		ad_port = &SLAVE_AD_INFO(slave)->port;
+		if (ad_port->aggregator)
+			return sprintf(buf, "%u\n",
+				       ad_port->partner_oper.port_state);
+	}
+
+	return sprintf(buf, "N/A\n");
+}
+static SLAVE_ATTR_RO(ad_partner_oper_port_state);
+
 static const struct slave_attribute *slave_attrs[] = {
 	&slave_attr_state,
 	&slave_attr_mii_status,
@@ -103,6 +118,7 @@ static const struct slave_attribute *slave_attrs[] = {
 	&slave_attr_queue_id,
 	&slave_attr_ad_aggregator_id,
 	&slave_attr_ad_actor_oper_port_state,
+	&slave_attr_ad_partner_oper_port_state,
 	NULL
 };
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 1b3e357223f2..510efb360580 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -457,6 +457,7 @@ enum {
 	IFLA_BOND_SLAVE_QUEUE_ID,
 	IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
 	IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE,
+	IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE,
 	__IFLA_BOND_SLAVE_MAX,
 };
 
-- 
2.4.3
