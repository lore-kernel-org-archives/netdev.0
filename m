From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH linux v1 net-next 4/4] bonding: add netlink support for sys prio, actor sys mac, and port key
Date: Fri,  1 May 2015 10:24:37 -0700
Message-ID: <73eb78d846c220d223f68a3b29f42eff011795fd.1430498637.git.jtoppins@cumulusnetworks.com>
References: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36325 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbbEARY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 13:24:58 -0400
Received: by pabsx10 with SMTP id sx10so96174230pab.3
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 10:24:58 -0700 (PDT)
In-Reply-To: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
In-Reply-To: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
References: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
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
 drivers/net/bonding/bond_netlink.c |   50 ++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h       |    3 +++
 2 files changed, 53 insertions(+)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 7b11243..d98f770 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -94,6 +94,10 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_AD_LACP_RATE]	= { .type = NLA_U8 },
 	[IFLA_BOND_AD_SELECT]		= { .type = NLA_U8 },
 	[IFLA_BOND_AD_INFO]		= { .type = NLA_NESTED },
+	[IFLA_BOND_AD_ACTOR_SYS_PRIO]	= { .type = NLA_U16 },
+	[IFLA_BOND_AD_USER_PORT_KEY]	= { .type = NLA_U16 },
+	[IFLA_BOND_AD_ACTOR_SYSTEM]	= { .type = NLA_BINARY,
+					    .len = MAX_ADDR_LEN },
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
+		bond_opt_initstr(&newval,
+				 nla_data(data[IFLA_BOND_AD_ACTOR_SYSTEM]));
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
 
@@ -548,6 +585,19 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.ad_select))
 		goto nla_put_failure;
 
+	if (nla_put_u16(skb, IFLA_BOND_AD_ACTOR_SYS_PRIO,
+			bond->params.ad_actor_sys_prio))
+		goto nla_put_failure;
+
+	if (nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
+			bond->params.ad_user_port_key))
+		goto nla_put_failure;
+
+	if (nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
+		    sizeof(bond->params.ad_actor_system),
+		    &bond->params.ad_actor_system))
+		goto nla_put_failure;
+
 	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info info;
 
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
