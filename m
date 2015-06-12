From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v1] bonding: Display LACP info only to CAP_NET_ADMIN capable user
Date: Fri, 12 Jun 2015 12:24:47 -0700
Message-ID: <1434137087-10555-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37278 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbbFLTYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 15:24:54 -0400
Received: by igbsb11 with SMTP id sb11so16995649igb.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 12:24:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actor and Partner details can be accessed via proc-fs and sys-fs
entries. These interfaces are world readable at this moment. The
earlier patch-series made the LACP communication secure to avoid
nuisance attack from within the same L2 domain but it did not
prevent "someone unprivileged" looking at that information on host
and perform the same act.

This patch essentially avoids spitting those entries if the user
in question does not have enough privileges.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_procfs.c | 101 ++++++++++++++++++++------------------
 drivers/net/bonding/bond_sysfs.c  |  12 ++---
 2 files changed, 59 insertions(+), 54 deletions(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index e7f3047a26df..f514fe5e80a5 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -135,27 +135,30 @@ static void bond_info_show_master(struct seq_file *seq)
 					  bond->params.ad_select);
 		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
 			   optval->string);
-		seq_printf(seq, "System priority: %d\n",
-			   BOND_AD_INFO(bond).system.sys_priority);
-		seq_printf(seq, "System MAC address: %pM\n",
-			   &BOND_AD_INFO(bond).system.sys_mac_addr);
-
-		if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
-			seq_printf(seq, "bond %s has no active aggregator\n",
-				   bond->dev->name);
-		} else {
-			seq_printf(seq, "Active Aggregator Info:\n");
-
-			seq_printf(seq, "\tAggregator ID: %d\n",
-				   ad_info.aggregator_id);
-			seq_printf(seq, "\tNumber of ports: %d\n",
-				   ad_info.ports);
-			seq_printf(seq, "\tActor Key: %d\n",
-				   ad_info.actor_key);
-			seq_printf(seq, "\tPartner Key: %d\n",
-				   ad_info.partner_key);
-			seq_printf(seq, "\tPartner Mac Address: %pM\n",
-				   ad_info.partner_system);
+		if (capable(CAP_NET_ADMIN)) {
+			seq_printf(seq, "System priority: %d\n",
+				   BOND_AD_INFO(bond).system.sys_priority);
+			seq_printf(seq, "System MAC address: %pM\n",
+				   &BOND_AD_INFO(bond).system.sys_mac_addr);
+
+			if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
+				seq_printf(seq,
+					   "bond %s has no active aggregator\n",
+					   bond->dev->name);
+			} else {
+				seq_printf(seq, "Active Aggregator Info:\n");
+
+				seq_printf(seq, "\tAggregator ID: %d\n",
+					   ad_info.aggregator_id);
+				seq_printf(seq, "\tNumber of ports: %d\n",
+					   ad_info.ports);
+				seq_printf(seq, "\tActor Key: %d\n",
+					   ad_info.actor_key);
+				seq_printf(seq, "\tPartner Key: %d\n",
+					   ad_info.partner_key);
+				seq_printf(seq, "\tPartner Mac Address: %pM\n",
+					   ad_info.partner_system);
+			}
 		}
 	}
 }
@@ -199,33 +202,35 @@ static void bond_info_show_slave(struct seq_file *seq,
 			seq_printf(seq, "Partner Churned Count: %d\n",
 				   port->churn_partner_count);
 
-			seq_puts(seq, "details actor lacp pdu:\n");
-			seq_printf(seq, "    system priority: %d\n",
-				   port->actor_system_priority);
-			seq_printf(seq, "    system mac address: %pM\n",
-				   &port->actor_system);
-			seq_printf(seq, "    port key: %d\n",
-				   port->actor_oper_port_key);
-			seq_printf(seq, "    port priority: %d\n",
-				   port->actor_port_priority);
-			seq_printf(seq, "    port number: %d\n",
-				   port->actor_port_number);
-			seq_printf(seq, "    port state: %d\n",
-				   port->actor_oper_port_state);
-
-			seq_puts(seq, "details partner lacp pdu:\n");
-			seq_printf(seq, "    system priority: %d\n",
-				   port->partner_oper.system_priority);
-			seq_printf(seq, "    system mac address: %pM\n",
-				   &port->partner_oper.system);
-			seq_printf(seq, "    oper key: %d\n",
-				   port->partner_oper.key);
-			seq_printf(seq, "    port priority: %d\n",
-				   port->partner_oper.port_priority);
-			seq_printf(seq, "    port number: %d\n",
-				   port->partner_oper.port_number);
-			seq_printf(seq, "    port state: %d\n",
-				   port->partner_oper.port_state);
+			if (capable(CAP_NET_ADMIN)) {
+				seq_puts(seq, "details actor lacp pdu:\n");
+				seq_printf(seq, "    system priority: %d\n",
+					   port->actor_system_priority);
+				seq_printf(seq, "    system mac address: %pM\n",
+					   &port->actor_system);
+				seq_printf(seq, "    port key: %d\n",
+					   port->actor_oper_port_key);
+				seq_printf(seq, "    port priority: %d\n",
+					   port->actor_port_priority);
+				seq_printf(seq, "    port number: %d\n",
+					   port->actor_port_number);
+				seq_printf(seq, "    port state: %d\n",
+					   port->actor_oper_port_state);
+
+				seq_puts(seq, "details partner lacp pdu:\n");
+				seq_printf(seq, "    system priority: %d\n",
+					   port->partner_oper.system_priority);
+				seq_printf(seq, "    system mac address: %pM\n",
+					   &port->partner_oper.system);
+				seq_printf(seq, "    oper key: %d\n",
+					   port->partner_oper.key);
+				seq_printf(seq, "    port priority: %d\n",
+					   port->partner_oper.port_priority);
+				seq_printf(seq, "    port number: %d\n",
+					   port->partner_oper.port_number);
+				seq_printf(seq, "    port state: %d\n",
+					   port->partner_oper.port_state);
+			}
 		} else {
 			seq_puts(seq, "Aggregator ID: N/A\n");
 		}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 143a2abd1c1c..31835a4dab57 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -549,7 +549,7 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
 	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD && capable(CAP_NET_ADMIN)) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
 				bond_3ad_get_active_agg_info(bond, &ad_info)
@@ -569,7 +569,7 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
 	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD && capable(CAP_NET_ADMIN)) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
 				bond_3ad_get_active_agg_info(bond, &ad_info)
@@ -589,7 +589,7 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD && capable(CAP_NET_ADMIN)) {
 		struct ad_info ad_info;
 		if (!bond_3ad_get_active_agg_info(bond, &ad_info))
 			count = sprintf(buf, "%pM\n", ad_info.partner_system);
@@ -698,7 +698,7 @@ static ssize_t bonding_show_ad_actor_sys_prio(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+	if (BOND_MODE(bond) == BOND_MODE_8023AD && capable(CAP_NET_ADMIN))
 		return sprintf(buf, "%hu\n", bond->params.ad_actor_sys_prio);
 
 	return 0;
@@ -712,7 +712,7 @@ static ssize_t bonding_show_ad_actor_system(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+	if (BOND_MODE(bond) == BOND_MODE_8023AD && capable(CAP_NET_ADMIN))
 		return sprintf(buf, "%pM\n", bond->params.ad_actor_system);
 
 	return 0;
@@ -727,7 +727,7 @@ static ssize_t bonding_show_ad_user_port_key(struct device *d,
 {
 	struct bonding *bond = to_bond(d);
 
-	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+	if (BOND_MODE(bond) == BOND_MODE_8023AD && capable(CAP_NET_ADMIN))
 		return sprintf(buf, "%hu\n", bond->params.ad_user_port_key);
 
 	return 0;
-- 
2.2.0.rc0.207.ga3a616c
