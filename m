From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v3 5/6] bonding: Allow userspace to set actors' macaddr in an AD-system.
Date: Wed, 11 Feb 2015 20:28:48 -0800
Message-ID: <1423715328-9924-1-git-send-email-maheshb@google.com>
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
Received: from mail-we0-f201.google.com ([74.125.82.201]:35359 "EHLO
	mail-we0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532AbbBLE3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 23:29:00 -0500
Received: by mail-we0-f201.google.com with SMTP id k11so951597wes.0
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 20:28:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In an AD system, the communication between actor and partner is the
business between these two entiries. In the current setup anyone on the
same L2 can "guess" the LACPDU contents and then possibly send the
spoofed LACPDUs and trick the partner causing connectivity issues for
the AD system. This patch allows to use a random mac-address obscuring
it's identity making it harder for someone in the L2 is do the same thing.

This patch allows user-space to choose the mac-address for the AD-system.
This mac-address can not be NULL or a Multicast. If the mac-address is set
from user-space; kernel will honor it and will not overwrite it. In the
absense (value from user space); the logic will default to using the
masters' mac as the mac-address for the AD-system.

It can be set using example code below -

   # modprobe bonding mode=4
   # sys_mac_addr=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
                    $(( (RANDOM & 0xFE) | 0x02 )) \
                    $(( RANDOM & 0xFF )) \
                    $(( RANDOM & 0xFF )) \
                    $(( RANDOM & 0xFF )) \
                    $(( RANDOM & 0xFF )) \
                    $(( RANDOM & 0xFF )))
   # echo $sys_mac_addr > /sys/class/net/bond0/bonding/ad_actor_system
   # echo +eth1 > /sys/class/net/bond0/bonding/slaves
   ...
   # ip link set bond0 up

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1:
  Initial version
v2:
  Renamed ad_actor_system_mac_address to ad_actor_system
v3:
  Fixed commit message.

 Documentation/networking/bonding.txt | 12 ++++++++++++
 drivers/net/bonding/bond_3ad.c       |  7 ++++++-
 drivers/net/bonding/bond_main.c      |  1 +
 drivers/net/bonding/bond_options.c   | 29 +++++++++++++++++++++++++++++
 drivers/net/bonding/bond_procfs.c    |  6 ++++++
 drivers/net/bonding/bond_sysfs.c     | 15 +++++++++++++++
 include/net/bond_options.h           |  1 +
 include/net/bonding.h                |  1 +
 8 files changed, 71 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index f19d888651b8..f0d93c58cdb0 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -187,6 +187,18 @@ ad_actor_sys_prio
 	This paramter has effect only in 802.3ad mode and is available through
 	SysFs interface.
 
+ad_actor_system
+
+	In an AD system, this specifies the mac-address for the actor in
+	protocol packet exchanges (LACPDUs). The value cannot be NULL or
+	multicast. It is preferred to have the local-admin bit set for this
+	mac but driver does not enforce it. If the value is not given then
+	system defaults to using the masters' mac address as actors' system
+	address.
+
+	This paramter has effect only in 802.3ad mode and is available through
+	SysFs interface.
+
 ad_select
 
 	Specifies the 802.3ad aggregation selection logic to use.  The
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 46aa847a0132..4b28d8cc0e84 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1914,7 +1914,12 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
 
 		BOND_AD_INFO(bond).system.sys_priority =
 			bond->params.ad_actor_sys_prio;
-		BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
+		if (is_zero_ether_addr(bond->params.ad_actor_system))
+			BOND_AD_INFO(bond).system.sys_mac_addr =
+			    *((struct mac_addr *)bond->dev->dev_addr);
+		else
+			BOND_AD_INFO(bond).system.sys_mac_addr =
+			    *((struct mac_addr *)bond->params.ad_actor_system);
 
 		/* initialize how many times this module is called in one
 		 * second (should be about every 100ms)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f8f6a80231b6..f899f3053e82 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4474,6 +4474,7 @@ static int bond_check_params(struct bond_params *params)
 	params->packets_per_slave = packets_per_slave;
 	params->tlb_dynamic_lb = 1; /* Default value */
 	params->ad_actor_sys_prio = ad_actor_sys_prio;
+	eth_zero_addr(params->ad_actor_system);
 	if (packets_per_slave > 0) {
 		params->reciprocal_packets_per_slave =
 			reciprocal_value(packets_per_slave);
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 05d5e735eaec..f2c011b3ea33 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -72,6 +72,8 @@ static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 				  const struct bond_opt_value *newval);
 static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 				  const struct bond_opt_value *newval);
+static int bond_option_ad_actor_system_set(struct bonding *bond,
+				  const struct bond_opt_value *newval);
 
 
 static const struct bond_opt_value bond_mode_tbl[] = {
@@ -396,6 +398,13 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
 		.values = bond_ad_actor_sys_prio_tbl,
 		.set = bond_option_ad_actor_sys_prio_set,
 	},
+	[BOND_OPT_AD_ACTOR_SYSTEM] = {
+		.id = BOND_OPT_AD_ACTOR_SYSTEM,
+		.name = "ad_actor_system",
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
+		.flags = BOND_OPTFLAG_RAWVAL | BOND_OPTFLAG_IFDOWN,
+		.set = bond_option_ad_actor_system_set,
+	},
 };
 
 /* Searches for an option by name */
@@ -1376,3 +1385,23 @@ static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 	bond->params.ad_actor_sys_prio = newval->value;
 	return 0;
 }
+
+static int bond_option_ad_actor_system_set(struct bonding *bond,
+					    const struct bond_opt_value *newval)
+{
+	u8 macaddr[ETH_ALEN];
+	int i;
+
+	i = sscanf(newval->string, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+		   &macaddr[0], &macaddr[1], &macaddr[2],
+		   &macaddr[3], &macaddr[4], &macaddr[5]);
+
+	if (i != ETH_ALEN || !is_valid_ether_addr(macaddr)) {
+		netdev_err(bond->dev, "Invalid MAC address.\n");
+		return -EINVAL;
+	}
+
+	ether_addr_copy(bond->params.ad_actor_system, macaddr);
+
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 9e33c48886ef..81452ced852f 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -136,6 +136,8 @@ static void bond_info_show_master(struct seq_file *seq)
 			   optval->string);
 		seq_printf(seq, "System priority: %d\n",
 				BOND_AD_INFO(bond).system.sys_priority);
+		seq_printf(seq, "System MAC address: %pM\n",
+				&BOND_AD_INFO(bond).system.sys_mac_addr);
 
 		if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
@@ -198,6 +200,8 @@ static void bond_info_show_slave(struct seq_file *seq,
 			seq_puts(seq, "details actor lacp pdu:\n");
 			seq_printf(seq, "    system priority: %d\n",
 				   port->actor_system_priority);
+			seq_printf(seq, "    system mac address: %pM\n",
+				   &port->actor_system);
 			seq_printf(seq, "    port key: %d\n",
 				   port->actor_oper_port_key);
 			seq_printf(seq, "    port priority: %d\n",
@@ -210,6 +214,8 @@ static void bond_info_show_slave(struct seq_file *seq,
 			seq_puts(seq, "details partner lacp pdu:\n");
 			seq_printf(seq, "    system priority: %d\n",
 				   port->partner_oper.system_priority);
+			seq_printf(seq, "    system mac address: %pM\n",
+				   &port->partner_oper.system);
 			seq_printf(seq, "    oper key: %d\n",
 				   port->partner_oper.key);
 			seq_printf(seq, "    port priority: %d\n",
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1a4a591a58c9..efa994243a2d 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -706,6 +706,20 @@ static ssize_t bonding_show_ad_actor_sys_prio(struct device *d,
 static DEVICE_ATTR(ad_actor_sys_prio, S_IRUGO | S_IWUSR,
 		   bonding_show_ad_actor_sys_prio, bonding_sysfs_store_option);
 
+static ssize_t bonding_show_ad_actor_system(struct device *d,
+						 struct device_attribute *attr,
+						 char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+		return sprintf(buf, "%pM\n", bond->params.ad_actor_system);
+
+	return 0;
+}
+static DEVICE_ATTR(ad_actor_system, S_IRUGO | S_IWUSR,
+		   bonding_show_ad_actor_system, bonding_sysfs_store_option);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -740,6 +754,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_packets_per_slave.attr,
 	&dev_attr_tlb_dynamic_lb.attr,
 	&dev_attr_ad_actor_sys_prio.attr,
+	&dev_attr_ad_actor_system.attr,
 	NULL,
 };
 
diff --git a/include/net/bond_options.h b/include/net/bond_options.h
index 894002a2620f..eeeefa1d3cd8 100644
--- a/include/net/bond_options.h
+++ b/include/net/bond_options.h
@@ -64,6 +64,7 @@ enum {
 	BOND_OPT_SLAVES,
 	BOND_OPT_TLB_DYNAMIC_LB,
 	BOND_OPT_AD_ACTOR_SYS_PRIO,
+	BOND_OPT_AD_ACTOR_SYSTEM,
 	BOND_OPT_LAST
 };
 
diff --git a/include/net/bonding.h b/include/net/bonding.h
index cb4587f6516e..f24f9862cea9 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -144,6 +144,7 @@ struct bond_params {
 	int tlb_dynamic_lb;
 	struct reciprocal_value reciprocal_packets_per_slave;
 	u16 ad_actor_sys_prio;
+	u8 ad_actor_system[ETH_ALEN];
 };
 
 struct bond_parm_tbl {
-- 
2.2.0.rc0.207.ga3a616c
