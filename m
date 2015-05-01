From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH linux v1 net-next 2/4] bonding: Allow userspace to set actors' macaddr in an AD-system.
Date: Fri,  1 May 2015 10:24:35 -0700
Message-ID: <93009dd60167e1cef580679767a8c2b00a9f94de.1430498637.git.jtoppins@cumulusnetworks.com>
References: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
Cc: Mahesh Bandewar <maheshb@google.com>
To: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:32769 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbEARY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 13:24:56 -0400
Received: by pdbnk13 with SMTP id nk13so97733529pdb.0
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 10:24:55 -0700 (PDT)
In-Reply-To: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
In-Reply-To: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
References: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

In an AD system, the communication between actor and partner is the
business between these two entities. In the current setup anyone on the
same L2 can "guess" the LACPDU contents and then possibly send the
spoofed LACPDUs and trick the partner causing connectivity issues for
the AD system. This patch allows to use a random mac-address obscuring
it's identity making it harder for someone in the L2 is do the same thing.

This patch allows user-space to choose the mac-address for the AD-system.
This mac-address can not be NULL or a Multicast. If the mac-address is set
from user-space; kernel will honor it and will not overwrite it. In the
absence (value from user space); the logic will default to using the
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
Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
[jt: fixed up style issues reported by checkpatch, also changed
  bond_option_ad_actor_system_set to assume a binary mac so it can
  be reused in the netlink option set case]
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 Documentation/networking/bonding.txt |   12 +++++++++++
 drivers/net/bonding/bond_3ad.c       |    7 +++++-
 drivers/net/bonding/bond_main.c      |    1 +
 drivers/net/bonding/bond_options.c   |   21 ++++++++++++++++++
 drivers/net/bonding/bond_procfs.c    |    6 ++++++
 drivers/net/bonding/bond_sysfs.c     |   39 ++++++++++++++++++++++++++++++++++
 include/net/bond_options.h           |    1 +
 include/net/bonding.h                |    1 +
 8 files changed, 87 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 3494611..2c197b6 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -187,6 +187,18 @@ ad_actor_sys_prio
 	This parameter has effect only in 802.3ad mode and is available through
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
+	This parameter has effect only in 802.3ad mode and is available through
+	SysFs interface.
+
 ad_select
 
 	Specifies the 802.3ad aggregation selection logic to use.  The
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 4c003bc..012f7bc 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1910,7 +1910,12 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
 
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
index e5bf232..a0de085 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4476,6 +4476,7 @@ static int bond_check_params(struct bond_params *params)
 	params->packets_per_slave = packets_per_slave;
 	params->tlb_dynamic_lb = 1; /* Default value */
 	params->ad_actor_sys_prio = ad_actor_sys_prio;
+	eth_zero_addr(params->ad_actor_system);
 	if (packets_per_slave > 0) {
 		params->reciprocal_packets_per_slave =
 			reciprocal_value(packets_per_slave);
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index d2b47e5..978a46a 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -72,6 +72,8 @@ static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 				  const struct bond_opt_value *newval);
 static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 					     const struct bond_opt_value *newval);
+static int bond_option_ad_actor_system_set(struct bonding *bond,
+					   const struct bond_opt_value *newval);
 
 
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
@@ -1375,3 +1384,15 @@ static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 	bond->params.ad_actor_sys_prio = newval->value;
 	return 0;
 }
+
+static int bond_option_ad_actor_system_set(struct bonding *bond,
+					   const struct bond_opt_value *newval)
+{
+	if (!is_valid_ether_addr(newval->string)) {
+		netdev_err(bond->dev, "Invalid MAC address.\n");
+		return -EINVAL;
+	}
+
+	ether_addr_copy(bond->params.ad_actor_system, newval->string);
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 1136929..e7f3047 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -137,6 +137,8 @@ static void bond_info_show_master(struct seq_file *seq)
 			   optval->string);
 		seq_printf(seq, "System priority: %d\n",
 			   BOND_AD_INFO(bond).system.sys_priority);
+		seq_printf(seq, "System MAC address: %pM\n",
+			   &BOND_AD_INFO(bond).system.sys_mac_addr);
 
 		if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 			seq_printf(seq, "bond %s has no active aggregator\n",
@@ -200,6 +202,8 @@ static void bond_info_show_slave(struct seq_file *seq,
 			seq_puts(seq, "details actor lacp pdu:\n");
 			seq_printf(seq, "    system priority: %d\n",
 				   port->actor_system_priority);
+			seq_printf(seq, "    system mac address: %pM\n",
+				   &port->actor_system);
 			seq_printf(seq, "    port key: %d\n",
 				   port->actor_oper_port_key);
 			seq_printf(seq, "    port priority: %d\n",
@@ -212,6 +216,8 @@ static void bond_info_show_slave(struct seq_file *seq,
 			seq_puts(seq, "details partner lacp pdu:\n");
 			seq_printf(seq, "    system priority: %d\n",
 				   port->partner_oper.system_priority);
+			seq_printf(seq, "    system mac address: %pM\n",
+				   &port->partner_oper.system);
 			seq_printf(seq, "    oper key: %d\n",
 				   port->partner_oper.key);
 			seq_printf(seq, "    port priority: %d\n",
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 4a76266..5e4c2ea 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -706,6 +706,44 @@ static ssize_t bonding_show_ad_actor_sys_prio(struct device *d,
 static DEVICE_ATTR(ad_actor_sys_prio, S_IRUGO | S_IWUSR,
 		   bonding_show_ad_actor_sys_prio, bonding_sysfs_store_option);
 
+static ssize_t bonding_show_ad_actor_system(struct device *d,
+					    struct device_attribute *attr,
+					    char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+		return sprintf(buf, "%pM\n", bond->params.ad_actor_system);
+
+	return 0;
+}
+
+static ssize_t bonding_store_ad_actor_system(struct device *d,
+					     struct device_attribute *attr,
+					     const char *buffer, size_t count)
+{
+	struct bonding *bond = to_bond(d);
+	u8 macaddr[ETH_ALEN];
+	int ret;
+
+	ret = sscanf(buffer, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+		     &macaddr[0], &macaddr[1], &macaddr[2],
+		     &macaddr[3], &macaddr[4], &macaddr[5]);
+	if (ret != ETH_ALEN) {
+		netdev_err(bond->dev, "Invalid MAC address.\n");
+		return -EINVAL;
+	}
+
+	ret = bond_opt_tryset_rtnl(bond, BOND_OPT_AD_ACTOR_SYSTEM, macaddr);
+	if (!ret)
+		ret = count;
+
+	return ret;
+}
+
+static DEVICE_ATTR(ad_actor_system, S_IRUGO | S_IWUSR,
+		   bonding_show_ad_actor_system, bonding_store_ad_actor_system);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -740,6 +778,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_packets_per_slave.attr,
 	&dev_attr_tlb_dynamic_lb.attr,
 	&dev_attr_ad_actor_sys_prio.attr,
+	&dev_attr_ad_actor_system.attr,
 	NULL,
 };
 
diff --git a/include/net/bond_options.h b/include/net/bond_options.h
index 894002a..eeeefa1 100644
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
index 405cf87..650f386 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -137,6 +137,7 @@ struct bond_params {
 	int tlb_dynamic_lb;
 	struct reciprocal_value reciprocal_packets_per_slave;
 	u16 ad_actor_sys_prio;
+	u8 ad_actor_system[ETH_ALEN];
 };
 
 struct bond_parm_tbl {
-- 
1.7.10.4
