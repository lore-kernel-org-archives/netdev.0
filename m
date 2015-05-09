From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH linux v3 net-next 4/4] bonding: add netlink support for sys prio, actor sys mac, and port key
Date: Sat,  9 May 2015 00:01:58 -0700
Message-ID: <c26a9459226784190a8503418c1375bfe1f90cae.1431150701.git.jtoppins@cumulusnetworks.com>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	shm@cumulusnetworks.com, razor@blackwall.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35832 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbbEIHCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 03:02:47 -0400
Received: by pdbqd1 with SMTP id qd1so105323614pdb.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 00:02:46 -0700 (PDT)
In-Reply-To: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
In-Reply-To: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>

Adds netlink support for the following bonding options:
* BOND_OPT_AD_ACTOR_SYS_PRIO
* BOND_OPT_AD_ACTOR_SYSTEM
* BOND_OPT_AD_USER_PORT_KEY

When setting the actor system mac address we assume the netlink message
contains a binary mac and not a string representation of a mac.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
[jt: completed the setting side of the netlink attributes]
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 v2:
    * rebased
 v3:
    * removed parenthesis from around values in the netdev_info calls in
      bond_option_ad_actor_sys_prio_set() and
      bond_option_ad_user_port_key_set()
    * fixed up bond_option_ad_actor_system_set() to support handling both
      string and value setting as Nik suggested

 drivers/net/bonding/bond_netlink.c |   50 ++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_options.c |   30 +++++++++++++++-------
 include/uapi/linux/if_link.h       |    3 +++
 3 files changed, 74 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 7b11243..f7015eb 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -94,6 +94,10 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_AD_LACP_RATE]	= { .type = NLA_U8 },
 	[IFLA_BOND_AD_SELECT]		= { .type = NLA_U8 },
 	[IFLA_BOND_AD_INFO]		= { .type = NLA_NESTED },
+	[IFLA_BOND_AD_ACTOR_SYS_PRIO]	= { .type = NLA_U16 },
+	[IFLA_BOND_AD_USER_PORT_KEY]	= { .type = NLA_U16 },
+	[IFLA_BOND_AD_ACTOR_SYSTEM]	= { .type = NLA_BINARY,
+					    .len  = ETH_ALEN },
 };
 
 static const struct nla_policy bond_slave_policy[IFLA_BOND_SLAVE_MAX + 1] = {
@@ -379,6 +383,36 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_AD_ACTOR_SYS_PRIO]) {
+		int actor_sys_prio =
+			nla_get_u16(data[IFLA_BOND_AD_ACTOR_SYS_PRIO]);
+
+		bond_opt_initval(&newval, actor_sys_prio);
+		err = __bond_opt_set(bond, BOND_OPT_AD_ACTOR_SYS_PRIO, &newval);
+		if (err)
+			return err;
+	}
+
+	if (data[IFLA_BOND_AD_USER_PORT_KEY]) {
+		int port_key =
+			nla_get_u16(data[IFLA_BOND_AD_USER_PORT_KEY]);
+
+		bond_opt_initval(&newval, port_key);
+		err = __bond_opt_set(bond, BOND_OPT_AD_USER_PORT_KEY, &newval);
+		if (err)
+			return err;
+	}
+
+	if (data[IFLA_BOND_AD_ACTOR_SYSTEM]) {
+		if (nla_len(data[IFLA_BOND_AD_ACTOR_SYSTEM]) != ETH_ALEN)
+			return -EINVAL;
+
+		bond_opt_initval(&newval,
+				 nla_get_be64(data[IFLA_BOND_AD_ACTOR_SYSTEM]));
+		err = __bond_opt_set(bond, BOND_OPT_AD_ACTOR_SYSTEM, &newval);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -426,6 +460,9 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_INFO_ACTOR_KEY */
 		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_INFO_PARTNER_KEY*/
 		nla_total_size(ETH_ALEN) +    /* IFLA_BOND_AD_INFO_PARTNER_MAC*/
+		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_ACTOR_SYS_PRIO */
+		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_USER_PORT_KEY */
+		nla_total_size(ETH_ALEN) + /* IFLA_BOND_AD_ACTOR_SYSTEM */
 		0;
 }
 
@@ -551,6 +588,19 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info info;
 
+		if (nla_put_u16(skb, IFLA_BOND_AD_ACTOR_SYS_PRIO,
+				bond->params.ad_actor_sys_prio))
+			goto nla_put_failure;
+
+		if (nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
+				bond->params.ad_user_port_key))
+			goto nla_put_failure;
+
+		if (nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
+			    sizeof(bond->params.ad_actor_system),
+			    &bond->params.ad_actor_system))
+			goto nla_put_failure;
+
 		if (!bond_3ad_get_active_agg_info(bond, &info)) {
 			struct nlattr *nest;
 
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index c85da05..9a32bbd77 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1394,7 +1394,7 @@ static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 					     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ad_actor_sys_prio to (%llu)\n",
+	netdev_info(bond->dev, "Setting ad_actor_sys_prio to %llu\n",
 		    newval->value);
 
 	bond->params.ad_actor_sys_prio = newval->value;
@@ -1405,24 +1405,36 @@ static int bond_option_ad_actor_system_set(struct bonding *bond,
 					   const struct bond_opt_value *newval)
 {
 	u8 macaddr[ETH_ALEN];
+	u8 *mac;
 	int i;
 
-	i = sscanf(newval->string, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
-		   &macaddr[0], &macaddr[1], &macaddr[2],
-		   &macaddr[3], &macaddr[4], &macaddr[5]);
-	if (i != ETH_ALEN || !is_valid_ether_addr(macaddr)) {
-		netdev_err(bond->dev, "Invalid MAC address.\n");
-		return -EINVAL;
+	if (newval->string) {
+		i = sscanf(newval->string, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+			   &macaddr[0], &macaddr[1], &macaddr[2],
+			   &macaddr[3], &macaddr[4], &macaddr[5]);
+		if (i != ETH_ALEN)
+			goto err;
+		mac = macaddr;
+	} else {
+		mac = (u8 *)&newval->value;
 	}
 
-	ether_addr_copy(bond->params.ad_actor_system, macaddr);
+	if (!is_valid_ether_addr(mac))
+		goto err;
+
+	netdev_info(bond->dev, "Setting ad_actor_system to %pM\n", mac);
+	ether_addr_copy(bond->params.ad_actor_system, mac);
 	return 0;
+
+err:
+	netdev_err(bond->dev, "Invalid MAC address.\n");
+	return -EINVAL;
 }
 
 static int bond_option_ad_user_port_key_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ad_user_port_key to (%llu)\n",
+	netdev_info(bond->dev, "Setting ad_user_port_key to %llu\n",
 		    newval->value);
 
 	bond->params.ad_user_port_key = newval->value;
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d9cd192..6d6e502 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -417,6 +417,9 @@ enum {
 	IFLA_BOND_AD_LACP_RATE,
 	IFLA_BOND_AD_SELECT,
 	IFLA_BOND_AD_INFO,
+	IFLA_BOND_AD_ACTOR_SYS_PRIO,
+	IFLA_BOND_AD_USER_PORT_KEY,
+	IFLA_BOND_AD_ACTOR_SYSTEM,
 	__IFLA_BOND_MAX,
 };
 
-- 
1.7.10.4
