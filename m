From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bonding: add tlb_dynamic_lb netlink support
Date: Fri, 31 Jul 2015 16:49:43 +0200
Message-ID: <1438354183-1907-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38801 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbbGaOtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 10:49:50 -0400
Received: by wibxm9 with SMTP id xm9so35297849wib.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 07:49:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

tlb_dynamic_lb could be set only via sysfs, this patch allows it to be
set via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
As usual if accepted I'll post the corresponding iproute2 patch that adds
support for setting tlb_dynamic_lb.

 drivers/net/bonding/bond_netlink.c | 17 +++++++++++++++--
 include/uapi/linux/if_link.h       |  1 +
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 1bda29249d12..db760e84119f 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -111,6 +111,7 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_AD_USER_PORT_KEY]	= { .type = NLA_U16 },
 	[IFLA_BOND_AD_ACTOR_SYSTEM]	= { .type = NLA_BINARY,
 					    .len  = ETH_ALEN },
+	[IFLA_BOND_TLB_DYNAMIC_LB]	= { .type = NLA_U8 },
 };
 
 static const struct nla_policy bond_slave_policy[IFLA_BOND_SLAVE_MAX + 1] = {
@@ -405,7 +406,6 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
-
 	if (data[IFLA_BOND_AD_USER_PORT_KEY]) {
 		int port_key =
 			nla_get_u16(data[IFLA_BOND_AD_USER_PORT_KEY]);
@@ -415,7 +415,6 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
-
 	if (data[IFLA_BOND_AD_ACTOR_SYSTEM]) {
 		if (nla_len(data[IFLA_BOND_AD_ACTOR_SYSTEM]) != ETH_ALEN)
 			return -EINVAL;
@@ -426,6 +425,15 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data[IFLA_BOND_TLB_DYNAMIC_LB]) {
+		int dynamic_lb = nla_get_u8(data[IFLA_BOND_TLB_DYNAMIC_LB]);
+
+		bond_opt_initval(&newval, dynamic_lb);
+		err = __bond_opt_set(bond, BOND_OPT_TLB_DYNAMIC_LB, &newval);
+		if (err)
+			return err;
+	}
+
 	return 0;
 }
 
@@ -476,6 +484,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_ACTOR_SYS_PRIO */
 		nla_total_size(sizeof(u16)) + /* IFLA_BOND_AD_USER_PORT_KEY */
 		nla_total_size(ETH_ALEN) + /* IFLA_BOND_AD_ACTOR_SYSTEM */
+		nla_total_size(sizeof(u8)) + /* IFLA_BOND_TLB_DYNAMIC_LB */
 		0;
 }
 
@@ -598,6 +607,10 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.ad_select))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, IFLA_BOND_TLB_DYNAMIC_LB,
+		       bond->params.tlb_dynamic_lb))
+		goto nla_put_failure;
+
 	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info info;
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9eeb5d9cf8f0..999b9b348fbb 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -433,6 +433,7 @@ enum {
 	IFLA_BOND_AD_ACTOR_SYS_PRIO,
 	IFLA_BOND_AD_USER_PORT_KEY,
 	IFLA_BOND_AD_ACTOR_SYSTEM,
+	IFLA_BOND_TLB_DYNAMIC_LB,
 	__IFLA_BOND_MAX,
 };
 
-- 
2.4.3
