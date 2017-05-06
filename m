From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH] bonding: make multi if nla_put_failure check into one
Date: Sat,  6 May 2017 11:17:52 +0800
Message-ID: <1494040672-13934-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36827 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdEFDSO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 23:18:14 -0400
Received: by mail-pg0-f68.google.com with SMTP id 12so2874360pgc.3
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 20:18:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 drivers/net/bonding/bond_netlink.c | 148 +++++++++++++------------------------
 1 file changed, 52 insertions(+), 96 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 47a8103..e745ca3 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -39,21 +39,13 @@ static int bond_fill_slave_info(struct sk_buff *skb,
 {
 	struct slave *slave = bond_slave_get_rtnl(slave_dev);
 
-	if (nla_put_u8(skb, IFLA_BOND_SLAVE_STATE, bond_slave_state(slave)))
-		goto nla_put_failure;
-
-	if (nla_put_u8(skb, IFLA_BOND_SLAVE_MII_STATUS, slave->link))
-		goto nla_put_failure;
-
-	if (nla_put_u32(skb, IFLA_BOND_SLAVE_LINK_FAILURE_COUNT,
-			slave->link_failure_count))
-		goto nla_put_failure;
-
-	if (nla_put(skb, IFLA_BOND_SLAVE_PERM_HWADDR,
-		    slave_dev->addr_len, slave->perm_hwaddr))
-		goto nla_put_failure;
-
-	if (nla_put_u16(skb, IFLA_BOND_SLAVE_QUEUE_ID, slave->queue_id))
+	if (nla_put_u8(skb, IFLA_BOND_SLAVE_STATE, bond_slave_state(slave)) ||
+	    nla_put_u8(skb, IFLA_BOND_SLAVE_MII_STATUS, slave->link) ||
+	    nla_put_u32(skb, IFLA_BOND_SLAVE_LINK_FAILURE_COUNT,
+			slave->link_failure_count) ||
+	    nla_put(skb, IFLA_BOND_SLAVE_PERM_HWADDR,
+		    slave_dev->addr_len, slave->perm_hwaddr) ||
+	    nla_put_u16(skb, IFLA_BOND_SLAVE_QUEUE_ID, slave->queue_id))
 		goto nla_put_failure;
 
 	if (BOND_MODE(slave->bond) == BOND_MODE_8023AD) {
@@ -64,13 +56,11 @@ static int bond_fill_slave_info(struct sk_buff *skb,
 		agg = SLAVE_AD_INFO(slave)->port.aggregator;
 		if (agg) {
 			if (nla_put_u16(skb, IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
-					agg->aggregator_identifier))
-				goto nla_put_failure;
-			if (nla_put_u8(skb,
+					agg->aggregator_identifier) ||
+			    nla_put_u8(skb,
 				       IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE,
-				       ad_port->actor_oper_port_state))
-				goto nla_put_failure;
-			if (nla_put_u16(skb,
+				       ad_port->actor_oper_port_state) ||
+			    nla_put_u16(skb,
 					IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE,
 					ad_port->partner_oper.port_state))
 				goto nla_put_failure;
@@ -525,21 +515,14 @@ static int bond_fill_info(struct sk_buff *skb,
 	if (ifindex && nla_put_u32(skb, IFLA_BOND_ACTIVE_SLAVE, ifindex))
 		goto nla_put_failure;
 
-	if (nla_put_u32(skb, IFLA_BOND_MIIMON, bond->params.miimon))
-		goto nla_put_failure;
-
-	if (nla_put_u32(skb, IFLA_BOND_UPDELAY,
-			bond->params.updelay * bond->params.miimon))
-		goto nla_put_failure;
-
-	if (nla_put_u32(skb, IFLA_BOND_DOWNDELAY,
-			bond->params.downdelay * bond->params.miimon))
-		goto nla_put_failure;
-
-	if (nla_put_u8(skb, IFLA_BOND_USE_CARRIER, bond->params.use_carrier))
-		goto nla_put_failure;
-
-	if (nla_put_u32(skb, IFLA_BOND_ARP_INTERVAL, bond->params.arp_interval))
+	if (nla_put_u32(skb, IFLA_BOND_MIIMON, bond->params.miimon) ||
+	    nla_put_u32(skb, IFLA_BOND_UPDELAY,
+			bond->params.updelay * bond->params.miimon) ||
+	    nla_put_u32(skb, IFLA_BOND_DOWNDELAY,
+			bond->params.downdelay * bond->params.miimon) ||
+	    nla_put_u8(skb, IFLA_BOND_USE_CARRIER, bond->params.use_carrier) ||
+	    nla_put_u32(skb, IFLA_BOND_ARP_INTERVAL,
+		        bond->params.arp_interval))
 		goto nla_put_failure;
 
 	targets = nla_nest_start(skb, IFLA_BOND_ARP_IP_TARGET);
@@ -560,10 +543,9 @@ static int bond_fill_info(struct sk_buff *skb,
 	else
 		nla_nest_cancel(skb, targets);
 
-	if (nla_put_u32(skb, IFLA_BOND_ARP_VALIDATE, bond->params.arp_validate))
-		goto nla_put_failure;
-
-	if (nla_put_u32(skb, IFLA_BOND_ARP_ALL_TARGETS,
+	if (nla_put_u32(skb, IFLA_BOND_ARP_VALIDATE,
+			bond->params.arp_validate) ||
+	    nla_put_u32(skb, IFLA_BOND_ARP_ALL_TARGETS,
 			bond->params.arp_all_targets))
 		goto nla_put_failure;
 
@@ -573,34 +555,20 @@ static int bond_fill_info(struct sk_buff *skb,
 		goto nla_put_failure;
 
 	if (nla_put_u8(skb, IFLA_BOND_PRIMARY_RESELECT,
-		       bond->params.primary_reselect))
-		goto nla_put_failure;
-
-	if (nla_put_u8(skb, IFLA_BOND_FAIL_OVER_MAC,
-		       bond->params.fail_over_mac))
-		goto nla_put_failure;
-
-	if (nla_put_u8(skb, IFLA_BOND_XMIT_HASH_POLICY,
-		       bond->params.xmit_policy))
-		goto nla_put_failure;
-
-	if (nla_put_u32(skb, IFLA_BOND_RESEND_IGMP,
-		        bond->params.resend_igmp))
-		goto nla_put_failure;
-
-	if (nla_put_u8(skb, IFLA_BOND_NUM_PEER_NOTIF,
-		       bond->params.num_peer_notif))
-		goto nla_put_failure;
-
-	if (nla_put_u8(skb, IFLA_BOND_ALL_SLAVES_ACTIVE,
-		       bond->params.all_slaves_active))
-		goto nla_put_failure;
-
-	if (nla_put_u32(skb, IFLA_BOND_MIN_LINKS,
-			bond->params.min_links))
-		goto nla_put_failure;
-
-	if (nla_put_u32(skb, IFLA_BOND_LP_INTERVAL,
+		       bond->params.primary_reselect) ||
+	    nla_put_u8(skb, IFLA_BOND_FAIL_OVER_MAC,
+		       bond->params.fail_over_mac) ||
+	    nla_put_u8(skb, IFLA_BOND_XMIT_HASH_POLICY,
+		       bond->params.xmit_policy) ||
+	    nla_put_u32(skb, IFLA_BOND_RESEND_IGMP,
+		        bond->params.resend_igmp) ||
+	    nla_put_u8(skb, IFLA_BOND_NUM_PEER_NOTIF,
+		       bond->params.num_peer_notif) ||
+	    nla_put_u8(skb, IFLA_BOND_ALL_SLAVES_ACTIVE,
+		       bond->params.all_slaves_active) ||
+	    nla_put_u32(skb, IFLA_BOND_MIN_LINKS,
+			bond->params.min_links) ||
+	    nla_put_u32(skb, IFLA_BOND_LP_INTERVAL,
 			bond->params.lp_interval))
 		goto nla_put_failure;
 
@@ -610,14 +578,10 @@ static int bond_fill_info(struct sk_buff *skb,
 		goto nla_put_failure;
 
 	if (nla_put_u8(skb, IFLA_BOND_AD_LACP_RATE,
-		       bond->params.lacp_fast))
-		goto nla_put_failure;
-
-	if (nla_put_u8(skb, IFLA_BOND_AD_SELECT,
-		       bond->params.ad_select))
-		goto nla_put_failure;
-
-	if (nla_put_u8(skb, IFLA_BOND_TLB_DYNAMIC_LB,
+		       bond->params.lacp_fast) ||
+	    nla_put_u8(skb, IFLA_BOND_AD_SELECT,
+		       bond->params.ad_select) ||
+	    nla_put_u8(skb, IFLA_BOND_TLB_DYNAMIC_LB,
 		       bond->params.tlb_dynamic_lb))
 		goto nla_put_failure;
 
@@ -626,14 +590,10 @@ static int bond_fill_info(struct sk_buff *skb,
 
 		if (capable(CAP_NET_ADMIN)) {
 			if (nla_put_u16(skb, IFLA_BOND_AD_ACTOR_SYS_PRIO,
-					bond->params.ad_actor_sys_prio))
-				goto nla_put_failure;
-
-			if (nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
-					bond->params.ad_user_port_key))
-				goto nla_put_failure;
-
-			if (nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
+					bond->params.ad_actor_sys_prio) ||
+			    nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
+					bond->params.ad_user_port_key) ||
+			    nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
 				    sizeof(bond->params.ad_actor_system),
 				    &bond->params.ad_actor_system))
 				goto nla_put_failure;
@@ -646,18 +606,14 @@ static int bond_fill_info(struct sk_buff *skb,
 				goto nla_put_failure;
 
 			if (nla_put_u16(skb, IFLA_BOND_AD_INFO_AGGREGATOR,
-					info.aggregator_id))
-				goto nla_put_failure;
-			if (nla_put_u16(skb, IFLA_BOND_AD_INFO_NUM_PORTS,
-					info.ports))
-				goto nla_put_failure;
-			if (nla_put_u16(skb, IFLA_BOND_AD_INFO_ACTOR_KEY,
-					info.actor_key))
-				goto nla_put_failure;
-			if (nla_put_u16(skb, IFLA_BOND_AD_INFO_PARTNER_KEY,
-					info.partner_key))
-				goto nla_put_failure;
-			if (nla_put(skb, IFLA_BOND_AD_INFO_PARTNER_MAC,
+					info.aggregator_id) ||
+			    nla_put_u16(skb, IFLA_BOND_AD_INFO_NUM_PORTS,
+					info.ports) ||
+			    nla_put_u16(skb, IFLA_BOND_AD_INFO_ACTOR_KEY,
+					info.actor_key) ||
+			    nla_put_u16(skb, IFLA_BOND_AD_INFO_PARTNER_KEY,
+					info.partner_key) ||
+			    nla_put(skb, IFLA_BOND_AD_INFO_PARTNER_MAC,
 				    sizeof(info.partner_system),
 				    &info.partner_system))
 				goto nla_put_failure;
-- 
2.5.5
