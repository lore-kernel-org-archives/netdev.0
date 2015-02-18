From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v4 4/6] bonding: Allow userspace to set actors' system_priority in AD system
Date: Tue, 17 Feb 2015 23:17:54 -0800
Message-ID: <1424243874-27109-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:60191 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbbBRHR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 02:17:58 -0500
Received: by mail-ob0-f201.google.com with SMTP id wo20so14231831obc.0
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 23:17:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows user to randomize the system-priority in an ad-system.
The allowed range is 1 - 0xFFFF while default value is 0xFFFF. If user
does not specify this value, the system defaults to 0xFFFF, which is
what it was before this patch.

Following example code could set the value -
    # modprobe bonding mode=4
    # sys_prio=$(( 1 + RANDOM + RANDOM ))
    # echo $sys_prio > /sys/class/net/bond0/bonding/ad_actor_sys_prio
    # echo +eth1 > /sys/class/net/bond0/bonding/slaves
    ...
    # ip link set bond0 up

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1:
  Initial version
v2:
  Rename ad_actor_system_priority to ad_actor_sys_prio
v3-v4:
  Rebase

 Documentation/networking/bonding.txt |  9 +++++++++
 drivers/net/bonding/bond_3ad.c       |  5 ++++-
 drivers/net/bonding/bond_main.c      | 14 ++++++++++++++
 drivers/net/bonding/bond_options.c   | 29 ++++++++++++++++++++++++++++-
 drivers/net/bonding/bond_procfs.c    |  2 ++
 drivers/net/bonding/bond_sysfs.c     | 15 +++++++++++++++
 include/net/bond_options.h           |  1 +
 include/net/bonding.h                |  1 +
 8 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 83bf4986baea..f19d888651b8 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -178,6 +178,15 @@ active_slave
 	active slave, or the empty string if there is no active slave or
 	the current mode does not use an active slave.
 
+ad_actor_sys_prio
+
+	In an AD system, this specifies the system priority. The allowed range
+	is 1 - 65535. If the value is not specified, it takes 65535 as the
+	default value.
+
+	This paramter has effect only in 802.3ad mode and is available through
+	SysFs interface.
+
 ad_select
 
 	Specifies the 802.3ad aggregation selection logic to use.  The
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c728ece78154..d847e6951e71 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1912,7 +1912,8 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
 
 		BOND_AD_INFO(bond).aggregator_identifier = 0;
 
-		BOND_AD_INFO(bond).system.sys_priority = 0xFFFF;
+		BOND_AD_INFO(bond).system.sys_priority =
+			bond->params.ad_actor_sys_prio;
 		BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
 
 		/* initialize how many times this module is called in one
@@ -1963,6 +1964,8 @@ void bond_3ad_bind_slave(struct slave *slave)
 			port->sm_vars &= ~AD_PORT_LACP_ENABLED;
 		/* actor system is the bond's system */
 		port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
+		port->actor_system_priority =
+		    BOND_AD_INFO(bond).system.sys_priority;
 		/* tx timer(to verify that no more than MAX_TX_IN_SECOND
 		 * lacpdu's are sent in one second)
 		 */
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f6bdaae7519d..c7aa1e4d5ccc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4136,6 +4136,7 @@ static int bond_check_params(struct bond_params *params)
 	struct bond_opt_value newval;
 	const struct bond_opt_value *valptr;
 	int arp_all_targets_value;
+	u16 ad_actor_sys_prio = 0;
 
 	/* Convert string parameters. */
 	if (mode) {
@@ -4430,6 +4431,18 @@ static int bond_check_params(struct bond_params *params)
 		fail_over_mac_value = BOND_FOM_NONE;
 	}
 
+	if (bond_mode == BOND_MODE_8023AD) {
+		bond_opt_initstr(&newval, "default");
+		valptr = bond_opt_parse(
+				bond_opt_get(BOND_OPT_AD_ACTOR_SYS_PRIO),
+					     &newval);
+		if (!valptr) {
+			pr_err("Error: No ad_actor_sys_prio default value");
+			return -EINVAL;
+		}
+		ad_actor_sys_prio = valptr->value;
+	}
+
 	if (lp_interval == 0) {
 		pr_warn("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
 			INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
@@ -4458,6 +4471,7 @@ static int bond_check_params(struct bond_params *params)
 	params->lp_interval = lp_interval;
 	params->packets_per_slave = packets_per_slave;
 	params->tlb_dynamic_lb = 1; /* Default value */
+	params->ad_actor_sys_prio = ad_actor_sys_prio;
 	if (packets_per_slave > 0) {
 		params->reciprocal_packets_per_slave =
 			reciprocal_value(packets_per_slave);
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 4df28943d222..05d5e735eaec 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -70,6 +70,8 @@ static int bond_option_slaves_set(struct bonding *bond,
 				  const struct bond_opt_value *newval);
 static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 				  const struct bond_opt_value *newval);
+static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
+				  const struct bond_opt_value *newval);
 
 
 static const struct bond_opt_value bond_mode_tbl[] = {
@@ -186,6 +188,12 @@ static const struct bond_opt_value bond_tlb_dynamic_lb_tbl[] = {
 	{ NULL,  -1, 0}
 };
 
+static const struct bond_opt_value bond_ad_actor_sys_prio_tbl[] = {
+	{ "minval",  1,     BOND_VALFLAG_MIN},
+	{ "maxval",  65535, BOND_VALFLAG_MAX | BOND_VALFLAG_DEFAULT},
+	{ NULL,      -1,    0},
+};
+
 static const struct bond_option bond_opts[BOND_OPT_LAST] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -379,7 +387,15 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
 		.values = bond_tlb_dynamic_lb_tbl,
 		.flags = BOND_OPTFLAG_IFDOWN,
 		.set = bond_option_tlb_dynamic_lb_set,
-	}
+	},
+	[BOND_OPT_AD_ACTOR_SYS_PRIO] = {
+		.id = BOND_OPT_AD_ACTOR_SYS_PRIO,
+		.name = "ad_actor_sys_prio",
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
+		.flags = BOND_OPTFLAG_IFDOWN,
+		.values = bond_ad_actor_sys_prio_tbl,
+		.set = bond_option_ad_actor_sys_prio_set,
+	},
 };
 
 /* Searches for an option by name */
@@ -1349,3 +1365,14 @@ static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 
 	return 0;
 }
+
+
+static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
+					    const struct bond_opt_value *newval)
+{
+	netdev_info(bond->dev, "Setting ad_actor_sys_prio to (%llu)\n",
+		    newval->value);
+
+	bond->params.ad_actor_sys_prio = newval->value;
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 83095a0b4b90..9e33c48886ef 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -134,6 +134,8 @@ static void bond_info_show_master(struct seq_file *seq)
 					  bond->params.ad_select);
 		seq_printf(seq, "Aggregator selection policy (ad_select): %s\n",
 			   optval->string);
+		seq_printf(seq, "System priority: %d\n",
+				BOND_AD_INFO(bond).system.sys_priority);
 
 		if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7e9e151d4d61..1a4a591a58c9 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -692,6 +692,20 @@ static ssize_t bonding_show_packets_per_slave(struct device *d,
 static DEVICE_ATTR(packets_per_slave, S_IRUGO | S_IWUSR,
 		   bonding_show_packets_per_slave, bonding_sysfs_store_option);
 
+static ssize_t bonding_show_ad_actor_sys_prio(struct device *d,
+					     struct device_attribute *attr,
+					     char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+		return sprintf(buf, "%hu\n", bond->params.ad_actor_sys_prio);
+
+	return 0;
+}
+static DEVICE_ATTR(ad_actor_sys_prio, S_IRUGO | S_IWUSR,
+		   bonding_show_ad_actor_sys_prio, bonding_sysfs_store_option);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -725,6 +739,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_lp_interval.attr,
 	&dev_attr_packets_per_slave.attr,
 	&dev_attr_tlb_dynamic_lb.attr,
+	&dev_attr_ad_actor_sys_prio.attr,
 	NULL,
 };
 
diff --git a/include/net/bond_options.h b/include/net/bond_options.h
index ea6546d2c946..894002a2620f 100644
--- a/include/net/bond_options.h
+++ b/include/net/bond_options.h
@@ -63,6 +63,7 @@ enum {
 	BOND_OPT_LP_INTERVAL,
 	BOND_OPT_SLAVES,
 	BOND_OPT_TLB_DYNAMIC_LB,
+	BOND_OPT_AD_ACTOR_SYS_PRIO,
 	BOND_OPT_LAST
 };
 
diff --git a/include/net/bonding.h b/include/net/bonding.h
index fda6feeb6c1f..cb4587f6516e 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -143,6 +143,7 @@ struct bond_params {
 	int packets_per_slave;
 	int tlb_dynamic_lb;
 	struct reciprocal_value reciprocal_packets_per_slave;
+	u16 ad_actor_sys_prio;
 };
 
 struct bond_parm_tbl {
-- 
2.2.0.rc0.207.ga3a616c
