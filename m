From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH linux v3 net-next 3/4] bonding: Implement user key part of port_key in an AD system.
Date: Sat,  9 May 2015 00:01:57 -0700
Message-ID: <d416635cfbb1a677ac3e5d26777f37dc67318339.1431150701.git.jtoppins@cumulusnetworks.com>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
Cc: Mahesh Bandewar <maheshb@google.com>
To: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	shm@cumulusnetworks.com, razor@blackwall.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34678 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbbEIHCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 03:02:44 -0400
Received: by pacyx8 with SMTP id yx8so67728663pac.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 00:02:44 -0700 (PDT)
In-Reply-To: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
In-Reply-To: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

The port key has three components - user-key, speed-part, and duplex-part.
The LSBit is for the duplex-part, next 5 bits are for the speed while the
remaining 10 bits are the user defined key bits. Get these 10 bits
from the user-space (through the SysFs interface) and use it to form the
admin port-key. Allowed range for the user-key is 0 - 1023 (10 bits). If
it is not provided then use zero for the user-key-bits (default).

It can set using following example code -

   # modprobe bonding mode=4
   # usr_port_key=$(( RANDOM & 0x3FF ))
   # echo $usr_port_key > /sys/class/net/bond0/bonding/ad_user_port_key
   # echo +eth1 > /sys/class/net/bond0/bonding/slaves
   ...
   # ip link set bond0 up

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
[jt: * fixed up style issues reported by checkpatch
     * fixed up context from change in ad_actor_sys_prio patch]
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 v2:
    * rebased
    * fixed up context from change in ad_actor_sys_prio patch
 v3:
    * no change

 Documentation/networking/bonding.txt |   63 ++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_3ad.c       |   14 ++++----
 drivers/net/bonding/bond_main.c      |   10 ++++++
 drivers/net/bonding/bond_options.c   |   26 ++++++++++++++
 drivers/net/bonding/bond_sysfs.c     |   15 ++++++++
 include/net/bond_options.h           |    1 +
 include/net/bonding.h                |    1 +
 7 files changed, 123 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 2c197b6..334b49e 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -51,6 +51,7 @@ Table of Contents
 3.4	Configuring Bonding Manually via Sysfs
 3.5	Configuration with Interfaces Support
 3.6	Overriding Configuration for Special Cases
+3.7 Configuring LACP for 802.3ad mode in a more secure way
 
 4. Querying Bonding Configuration
 4.1	Bonding Configuration
@@ -241,6 +242,21 @@ ad_select
 
 	This option was added in bonding version 3.4.0.
 
+ad_user_port_key
+
+	In an AD system, the port-key has three parts as shown below -
+
+	   Bits   Use
+	   00     Duplex
+	   01-05  Speed
+	   06-15  User-defined
+
+	This defines the upper 10 bits of the port key. The values can be
+	from 0 - 1023. If not given, the system defaults to 0.
+
+	This parameter has effect only in 802.3ad mode and is available through
+	SysFs interface.
+
 all_slaves_active
 
 	Specifies that duplicate frames (received on inactive ports) should be
@@ -1643,6 +1659,53 @@ output port selection.
 This feature first appeared in bonding driver version 3.7.0 and support for
 output slave selection was limited to round-robin and active-backup modes.
 
+3.7 Configuring LACP for 802.3ad mode in a more secure way
+----------------------------------------------------------
+
+When using 802.3ad bonding mode, the Actor (host) and Partner (switch)
+exchange LACPDUs.  These LACPDUs cannot be sniffed, because they are
+destined to link local mac addresses (which switches/bridges are not
+supposed to forward).  However, most of the values are easily predictable
+or are simply the machine's MAC address (which is trivially known to all
+other hosts in the same L2).  This implies that other machines in the L2
+domain can spoof LACPDU packets from other hosts to the switch and potentially
+cause mayhem by joining (from the point of view of the switch) another
+machine's aggregate, thus receiving a portion of that hosts incoming
+traffic and / or spoofing traffic from that machine themselves (potentially
+even successfully terminating some portion of flows). Though this is not
+a likely scenario, one could avoid this possibility by simply configuring
+few bonding parameters:
+
+   (a) ad_actor_system : You can set a random mac-address that can be used for
+       these LACPDU exchanges. The value can not be either NULL or Multicast.
+       Also it's preferable to set the local-admin bit. Following shell code
+       generates a random mac-address as described above.
+
+       # sys_mac_addr=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
+                                $(( (RANDOM & 0xFE) | 0x02 )) \
+                                $(( RANDOM & 0xFF )) \
+                                $(( RANDOM & 0xFF )) \
+                                $(( RANDOM & 0xFF )) \
+                                $(( RANDOM & 0xFF )) \
+                                $(( RANDOM & 0xFF )))
+       # echo $sys_mac_addr > /sys/class/net/bond0/bonding/ad_actor_system
+
+   (b) ad_actor_sys_prio : Randomize the system priority. The default value
+       is 65535, but system can take the value from 1 - 65535. Following shell
+       code generates random priority and sets it.
+
+       # sys_prio=$(( 1 + RANDOM + RANDOM ))
+       # echo $sys_prio > /sys/class/net/bond0/bonding/ad_actor_sys_prio
+
+   (c) ad_user_port_key : Use the user portion of the port-key. The default
+       keeps this empty. These are the upper 10 bits of the port-key and value
+       ranges from 0 - 1023. Following shell code generates these 10 bits and
+       sets it.
+
+       # usr_port_key=$(( RANDOM & 0x3FF ))
+       # echo $usr_port_key > /sys/class/net/bond0/bonding/ad_user_port_key
+
+
 4 Querying Bonding Configuration
 =================================
 
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 012f7bc..7fde4d5 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -75,10 +75,10 @@
 /* Port Key definitions
  * key is determined according to the link speed, duplex and
  * user key (which is yet not supported)
- * --------------------------------------------------------------
- * Port key :	| User key	| Speed		| Duplex	|
- * --------------------------------------------------------------
- * 16		  6		  1		  0
+ *           --------------------------------------------------------------
+ * Port key  | User key (10 bits)           | Speed (5 bits)      | Duplex|
+ *           --------------------------------------------------------------
+ *           |15                           6|5                   1|0
  */
 #define  AD_DUPLEX_KEY_MASKS    0x1
 #define  AD_SPEED_KEY_MASKS     0x3E
@@ -1951,10 +1951,10 @@ void bond_3ad_bind_slave(struct slave *slave)
 
 		port->slave = slave;
 		port->actor_port_number = SLAVE_AD_INFO(slave)->id;
-		/* key is determined according to the link speed, duplex and user key(which
-		 * is yet not supported)
+		/* key is determined according to the link speed, duplex and
+		 * user key
 		 */
-		port->actor_admin_port_key = 0;
+		port->actor_admin_port_key = bond->params.ad_user_port_key << 6;
 		port->actor_admin_port_key |= __get_duplex(port);
 		port->actor_admin_port_key |= (__get_link_speed(port) << 1);
 		port->actor_oper_port_key = port->actor_admin_port_key;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a4e2f27..2ee13be 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4141,6 +4141,7 @@ static int bond_check_params(struct bond_params *params)
 	const struct bond_opt_value *valptr;
 	int arp_all_targets_value;
 	u16 ad_actor_sys_prio = 0;
+	u16 ad_user_port_key = 0;
 
 	/* Convert string parameters. */
 	if (mode) {
@@ -4445,6 +4446,14 @@ static int bond_check_params(struct bond_params *params)
 	}
 	ad_actor_sys_prio = valptr->value;
 
+	valptr = bond_opt_parse(bond_opt_get(BOND_OPT_AD_USER_PORT_KEY),
+				&newval);
+	if (!valptr) {
+		pr_err("Error: No ad_user_port_key default value");
+		return -EINVAL;
+	}
+	ad_user_port_key = valptr->value;
+
 	if (lp_interval == 0) {
 		pr_warn("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
 			INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
@@ -4475,6 +4484,7 @@ static int bond_check_params(struct bond_params *params)
 	params->tlb_dynamic_lb = 1; /* Default value */
 	params->ad_actor_sys_prio = ad_actor_sys_prio;
 	eth_zero_addr(params->ad_actor_system);
+	params->ad_user_port_key = ad_user_port_key;
 	if (packets_per_slave > 0) {
 		params->reciprocal_packets_per_slave =
 			reciprocal_value(packets_per_slave);
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index cdcef21..c85da05 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -74,6 +74,8 @@ static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 					     const struct bond_opt_value *newval);
 static int bond_option_ad_actor_system_set(struct bonding *bond,
 					   const struct bond_opt_value *newval);
+static int bond_option_ad_user_port_key_set(struct bonding *bond,
+					    const struct bond_opt_value *newval);
 
 
 static const struct bond_opt_value bond_mode_tbl[] = {
@@ -196,6 +198,12 @@ static const struct bond_opt_value bond_ad_actor_sys_prio_tbl[] = {
 	{ NULL,      -1,    0},
 };
 
+static const struct bond_opt_value bond_ad_user_port_key_tbl[] = {
+	{ "minval",  0,     BOND_VALFLAG_MIN | BOND_VALFLAG_DEFAULT},
+	{ "maxval",  1023,  BOND_VALFLAG_MAX},
+	{ NULL,      -1,    0},
+};
+
 static const struct bond_option bond_opts[BOND_OPT_LAST] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
@@ -405,6 +413,14 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
 		.flags = BOND_OPTFLAG_RAWVAL | BOND_OPTFLAG_IFDOWN,
 		.set = bond_option_ad_actor_system_set,
 	},
+	[BOND_OPT_AD_USER_PORT_KEY] = {
+		.id = BOND_OPT_AD_USER_PORT_KEY,
+		.name = "ad_user_port_key",
+		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
+		.flags = BOND_OPTFLAG_IFDOWN,
+		.values = bond_ad_user_port_key_tbl,
+		.set = bond_option_ad_user_port_key_set,
+	}
 };
 
 /* Searches for an option by name */
@@ -1402,3 +1418,13 @@ static int bond_option_ad_actor_system_set(struct bonding *bond,
 	ether_addr_copy(bond->params.ad_actor_system, macaddr);
 	return 0;
 }
+
+static int bond_option_ad_user_port_key_set(struct bonding *bond,
+					    const struct bond_opt_value *newval)
+{
+	netdev_info(bond->dev, "Setting ad_user_port_key to (%llu)\n",
+		    newval->value);
+
+	bond->params.ad_user_port_key = newval->value;
+	return 0;
+}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 09fefa5..143a2ab 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -721,6 +721,20 @@ static ssize_t bonding_show_ad_actor_system(struct device *d,
 static DEVICE_ATTR(ad_actor_system, S_IRUGO | S_IWUSR,
 		   bonding_show_ad_actor_system, bonding_sysfs_store_option);
 
+static ssize_t bonding_show_ad_user_port_key(struct device *d,
+					     struct device_attribute *attr,
+					     char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+		return sprintf(buf, "%hu\n", bond->params.ad_user_port_key);
+
+	return 0;
+}
+static DEVICE_ATTR(ad_user_port_key, S_IRUGO | S_IWUSR,
+		   bonding_show_ad_user_port_key, bonding_sysfs_store_option);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -756,6 +770,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_tlb_dynamic_lb.attr,
 	&dev_attr_ad_actor_sys_prio.attr,
 	&dev_attr_ad_actor_system.attr,
+	&dev_attr_ad_user_port_key.attr,
 	NULL,
 };
 
diff --git a/include/net/bond_options.h b/include/net/bond_options.h
index eeeefa1..c28aca2 100644
--- a/include/net/bond_options.h
+++ b/include/net/bond_options.h
@@ -65,6 +65,7 @@ enum {
 	BOND_OPT_TLB_DYNAMIC_LB,
 	BOND_OPT_AD_ACTOR_SYS_PRIO,
 	BOND_OPT_AD_ACTOR_SYSTEM,
+	BOND_OPT_AD_USER_PORT_KEY,
 	BOND_OPT_LAST
 };
 
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 650f386..20defc0 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -137,6 +137,7 @@ struct bond_params {
 	int tlb_dynamic_lb;
 	struct reciprocal_value reciprocal_packets_per_slave;
 	u16 ad_actor_sys_prio;
+	u16 ad_user_port_key;
 	u8 ad_actor_system[ETH_ALEN];
 };
 
-- 
1.7.10.4
