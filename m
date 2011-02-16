From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: [PATCH] bonding: added 802.3ad round-robin hashing policy and
 source mac selection mode
Date: Wed, 16 Feb 2011 22:13:41 +0300
Message-ID: <20110216191341.GA14920@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:37544 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504Ab1BPTNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 14:13:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch introduces two new (related) features to bonding module.
First feature is round-robin hashing policy, which is primarily
intended for use with 802.3ad mode, and puts every next IPv4 and
IPv6 packet into  next availables slave without taling into account
which layer3 and above protocol is used.
Second feature makes possible choosing which MAC-address will be set
in the transmitted packet - when set to src-mac it will force setting
slave's interface real MAC address as source MAC address in every
packet, sent via this slave interface.
Main goal of this patch is to make possible single TCP stream 
equally striped for both transmitted and received packets over all
available slaves.
This operating mode is not fully 802.3ad compliant, and will cause
some packet reordering in TCP stream, to some kernel tuning may be
required.
For correct working enabling round-robin hashing policy plus using
real slave's MAC addresses as source MAC addresses in transmitted 
packets requires specific switch setting)hashing mode for port-channel
("etherchannel) should be set to src-mac or src-dst-mac to get
correct load-striping on the receiving host's etherchannel.
General requirements for using bonding in this operating mode are:
- even and preferrably equal number of slaves on sending and receiving 
hosts;
- equal RTT between sending and receiving hosts on all slaves;
- switch capable of doing etherchannels and using src-mac or src-dst-mac
hashing policy for egress load striping

Signed-off-by: Oleg V. Ukhno <olegu@yandex-team.ru>
---

 Documentation/networking/bonding.txt |   65 +++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_3ad.c       |    2 -
 drivers/net/bonding/bond_main.c      |   60 +++++++++++++++++++++++++++++---
 drivers/net/bonding/bond_sysfs.c     |   50 ++++++++++++++++++++++++++
 drivers/net/bonding/bonding.h        |    7 +++
 include/linux/if_bonding.h           |    1 
 6 files changed, 178 insertions(+), 7 deletions(-)

diff -uprN -X linux-2.6/Documentation/dontdiff linux-2.6/Documentation/networking/bonding.txt linux-2.6.p/Documentation/networking/bonding.txt
--- linux-2.6/Documentation/networking/bonding.txt	2011-02-08 16:03:01.290281998 +0300
+++ linux-2.6.p/Documentation/networking/bonding.txt	2011-02-16 22:03:09.650281997 +0300
@@ -83,6 +83,7 @@ Table of Contents
 12. Configuring Bonding for Maximum Throughput
 12.1	Maximum Throughput in a Single Switch Topology
 12.1.1		MT Bonding Mode Selection for Single Switch Topology
+12.1.1.1 		Maximizing TCP Throughput for RX/TX for Single Switch Topology using layer2 mechanisms
 12.1.2		MT Link Monitoring for Single Switch Topology
 12.2	Maximum Throughput in a Multiple Switch Topology
 12.2.1		MT Bonding Mode Selection for Multiple Switch Topology
@@ -761,6 +762,34 @@ xmit_hash_policy
 		conversations.  Other implementations of 802.3ad may
 		or may not tolerate this noncompliance.
 
+	round-robin
+
+		This policy simply puts every next packet into next
+		slave interfaces, providing round-robin load striping
+		for transmitted data. This policy can be enabled with
+		any mode which supports choosing alternate hash policy,
+		but was initially done for 802.3ad mode.
+
+		Main goal for this policy is to stripe TX load without
+		taking into account which layer3 protocol is used, and
+		can be used for single TCP connection load striping. When
+		enabled, it will round-robin packets for IPv4 and IPv6
+		only.
+
+		There is also src_mac_select option, which can be used
+		to configure RX load-striping using switch hashing
+		algorhytms on the receiving side. See detailed description
+		below.
+
+		It is important to understand, that this hashing policy
+		will possibly cause TCP out-of-order packets when enabled
+		and must not be used when slaves have different bandwidth
+		and/or RTT in receiver's direction. This algorithm is not
+		fully 802.3ad compliant. Some implementations of 802.3ad
+		may or may not tolerate this noncompliance.
+
+		Hashing formula is transmitted packet number % slave count.
+
 	The default value is layer2.  This option was added in bonding
 	version 2.6.3.  In earlier versions of bonding, this parameter
 	does not exist, and the layer2 policy is the only policy.  The
@@ -2190,6 +2219,42 @@ balance-alb: This mode is everything tha
 	device driver must support changing the hardware address while
 	the device is open.
 
+12.1.1.1 Maximizing TCP Throughput for RX/TX for Single Switch Topology
+         using layer2 mechanisms
+----------------------------------------------------------------------
+	Besides of methods of load striping and configuring HA, mentioned
+above, you can use round-robin hashing policy and src_mac_select "slave-src"
+setting to stripe TCP load near-equally over even number of slaves. Please
+note, that enabling round-robin policy for balance-xor mode should turn it
+into mode similar to balance-rr mode.
+	There is also specific switch configuration required to use all
+benefits of both round-robin hashing policy and src_mac_select "slave-src"
+setting.
+        When you enable round-robin xmit hashing policy plus set
+src_mac_select to slave-src mode, you will get every next packet
+transmitted over a new slave with every's packet source MAC address set
+to real MAC address of the according slave interface, not the aggregate
+interface.
+        Imagine, that you have two hosts(let's say A and B), each connected
+using 2 slave interfaces to switch with appropriate port-channels configured
+("etherchannels"). After you start transmitting TCP data from A to B, and
+round-robin hashing policy is enabled, you will see that TX load is equally
+striped over host A slaves, but all this traffic is received with only one
+machine's B slave.
+        Now, you set src_mac_select parameter to "slave-src" and
+configure switch for src-mac hashing for "outqoing" etherchannel load
+striping. Now every packet sent from host A has slave's MAC as source MAC
+address, and switch will send every packet from host A into receiving
+port-channel of host B taking into account source MAC address of packet being
+put into, so you will get near-equal RX load striping, which does not depend
+on layer3 and above protocols used for data transmission.
+        It is important to understand, that this load striping mode
+will only work correctly if number of slaves on each side is at least
+even, and preferrably equal and even.
+        This load striping mode also can cause TCP out-of-order packets,
+so you may need to tune your kernel for handling increased number of
+reordered packets.
+
 12.1.2 MT Link Monitoring for Single Switch Topology
 ----------------------------------------------------
 
diff -uprN -X linux-2.6/Documentation/dontdiff linux-2.6/drivers/net/bonding/bond_3ad.c linux-2.6.p/drivers/net/bonding/bond_3ad.c
--- linux-2.6/drivers/net/bonding/bond_3ad.c	2011-02-16 00:59:18.710282002 +0300
+++ linux-2.6.p/drivers/net/bonding/bond_3ad.c	2011-02-16 01:30:47.770281998 +0300
@@ -2419,7 +2419,7 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 		goto out;
 	}
 
-	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
+	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg, bond->rr_tx_counter++);
 
 	bond_for_each_slave(bond, slave, i) {
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
diff -uprN -X linux-2.6/Documentation/dontdiff linux-2.6/drivers/net/bonding/bonding.h linux-2.6.p/drivers/net/bonding/bonding.h
--- linux-2.6/drivers/net/bonding/bonding.h	2011-02-16 00:59:18.720282002 +0300
+++ linux-2.6.p/drivers/net/bonding/bonding.h	2011-02-16 01:33:11.610282004 +0300
@@ -162,6 +162,7 @@ struct bond_params {
 	int tx_queues;
 	int all_slaves_active;
 	int resend_igmp;
+	int src_mac_select;
 };
 
 struct bond_parm_tbl {
@@ -235,7 +236,7 @@ struct bonding {
 #endif /* CONFIG_PROC_FS */
 	struct   list_head bond_list;
 	struct   netdev_hw_addr_list mc_list;
-	int      (*xmit_hash_policy)(struct sk_buff *, int);
+	int      (*xmit_hash_policy)(struct sk_buff *, int, int);
 	__be32   master_ip;
 	u16      flags;
 	u16      rr_tx_counter;
@@ -308,6 +309,9 @@ static inline bool bond_is_lb(const stru
 #define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
 					 BOND_ARP_VALIDATE_BACKUP)
 
+#define BOND_MAC_SRC_DEFAULT		0
+#define BOND_MAC_SRC_SLAVE		1
+
 static inline int slave_do_arp_validate(struct bonding *bond,
 					struct slave *slave)
 {
@@ -402,6 +406,7 @@ extern const struct bond_parm_tbl arp_va
 extern const struct bond_parm_tbl fail_over_mac_tbl[];
 extern const struct bond_parm_tbl pri_reselect_tbl[];
 extern struct bond_parm_tbl ad_select_tbl[];
+extern const struct bond_parm_tbl src_mac_select_tbl[];
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 void bond_send_unsolicited_na(struct bonding *bond);
diff -uprN -X linux-2.6/Documentation/dontdiff linux-2.6/drivers/net/bonding/bond_main.c linux-2.6.p/drivers/net/bonding/bond_main.c
--- linux-2.6/drivers/net/bonding/bond_main.c	2011-02-16 00:59:18.720282002 +0300
+++ linux-2.6.p/drivers/net/bonding/bond_main.c	2011-02-16 22:08:22.650281997 +0300
@@ -111,6 +111,7 @@ static char *fail_over_mac;
 static int all_slaves_active = 0;
 static struct bond_params bonding_defaults;
 static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
+static char *src_mac_select;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -152,7 +153,7 @@ module_param(ad_select, charp, 0);
 MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
 module_param(xmit_hash_policy, charp, 0);
 MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
-				   ", 1 for layer 3+4");
+				   ", 1 for layer 3+4, 3 for round-robin");
 module_param(arp_interval, int, 0);
 MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
 module_param_array(arp_ip_target, charp, NULL, 0);
@@ -167,6 +168,9 @@ MODULE_PARM_DESC(all_slaves_active, "Kee
 				     "0 for never (default), 1 for always.");
 module_param(resend_igmp, int, 0);
 MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link failure");
+module_param(src_mac_select, charp, 0);
+MODULE_PARM_DESC(src_mac_select, "Source MAC selection mode: 0  or default (default),"
+				 "1 or slave-src to use slave's MAC as packet's src MAC");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -206,6 +210,7 @@ const struct bond_parm_tbl xmit_hashtype
 {	"layer2",		BOND_XMIT_POLICY_LAYER2},
 {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
 {	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
+{	"round-robin",		BOND_XMIT_POLICY_LAYERRR},
 {	NULL,			-1},
 };
 
@@ -238,6 +243,12 @@ struct bond_parm_tbl ad_select_tbl[] = {
 {	NULL,		-1},
 };
 
+const struct bond_parm_tbl src_mac_select_tbl[] = {
+{	"default",	BOND_MAC_SRC_DEFAULT},
+{	"slave-src",	BOND_MAC_SRC_SLAVE},
+{	NULL,		-1},
+};
+
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
@@ -422,6 +433,7 @@ struct vlan_entry *bond_next_vlan(struct
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 			struct net_device *slave_dev)
 {
+	struct ethhdr *eth_data;
 	skb->dev = slave_dev;
 	skb->priority = 1;
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -433,6 +445,15 @@ int bond_dev_queue_xmit(struct bonding *
 		slave_dev->priv_flags &= ~IFF_IN_NETPOLL;
 	} else
 #endif
+		if (bond->params.src_mac_select == BOND_MAC_SRC_SLAVE &&
+		   (skb->protocol == htons(ETH_P_IP) ||
+		   skb->protocol == htons(ETH_P_IPV6))) {
+			skb_reset_mac_header(skb);
+			eth_data = eth_hdr(skb);
+			memcpy(eth_data->h_source, slave_dev->perm_addr,
+				ETH_ALEN);
+		}
+
 		dev_queue_xmit(skb);
 
 	return 0;
@@ -3261,6 +3282,13 @@ static void bond_info_show_master(struct
 			bond->params.xmit_policy);
 	}
 
+	if (bond->params.src_mac_select == BOND_MAC_SRC_DEFAULT ||
+		bond->params.src_mac_select == BOND_MAC_SRC_DEFAULT) {
+		seq_printf(seq, "Source MAC select is: %s (%d)\n",
+			src_mac_select_tbl[bond->params.src_mac_select].modename,
+			bond->params.src_mac_select);
+	}
+
 	if (USES_PRIMARY(bond->params.mode)) {
 		seq_printf(seq, "Primary Slave: %s",
 			   (bond->primary_slave) ?
@@ -3717,7 +3745,8 @@ void bond_unregister_arp(struct bonding
  * Hash for the output device based upon layer 2 and layer 3 data. If
  * the packet is not IP mimic bond_xmit_hash_policy_l2()
  */
-static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
+static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count,
+					int pktcount)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 	struct iphdr *iph = ip_hdr(skb);
@@ -3735,7 +3764,8 @@ static int bond_xmit_hash_policy_l23(str
  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
  * altogether not IP, mimic bond_xmit_hash_policy_l2()
  */
-static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
+static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count,
+					int pktcount)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 	struct iphdr *iph = ip_hdr(skb);
@@ -3759,13 +3789,29 @@ static int bond_xmit_hash_policy_l34(str
 /*
  * Hash for the output device based upon layer 2 data
  */
-static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
+static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count,
+					int pktcount)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 
 	return (data->h_dest[5] ^ data->h_source[5]) % count;
 }
 
+/*
+ * Round-robin over all active slaves(one packet per slave) for IP and IPv6,
+ * otherwise mimic bond_xmit_hash_policy_l2()
+ */
+static int bond_xmit_hash_policy_rr(struct sk_buff *skb, int count,
+					int pktcount)
+{
+	struct ethhdr *data = (struct ethhdr *)skb->data;
+	if (skb->protocol == htons(ETH_P_IP)
+		|| skb->protocol == htons(ETH_P_IPV6)) {
+			return pktcount % count;
+	}
+	return (data->h_dest[5] ^ data->h_source[5]) % count;
+}
+
 /*-------------------------- Device entry points ----------------------------*/
 
 static int bond_open(struct net_device *bond_dev)
@@ -4395,7 +4441,8 @@ static int bond_xmit_xor(struct sk_buff
 	if (!BOND_IS_OK(bond))
 		goto out;
 
-	slave_no = bond->xmit_hash_policy(skb, bond->slave_cnt);
+	slave_no = bond->xmit_hash_policy(skb, bond->slave_cnt,
+					bond->rr_tx_counter++);
 
 	bond_for_each_slave(bond, slave, i) {
 		slave_no--;
@@ -4492,6 +4539,9 @@ static void bond_set_xmit_hash_policy(st
 	case BOND_XMIT_POLICY_LAYER34:
 		bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
 		break;
+	case BOND_XMIT_POLICY_LAYERRR:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_rr;
+		break;
 	case BOND_XMIT_POLICY_LAYER2:
 	default:
 		bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
diff -uprN -X linux-2.6/Documentation/dontdiff linux-2.6/drivers/net/bonding/bond_sysfs.c linux-2.6.p/drivers/net/bonding/bond_sysfs.c
--- linux-2.6/drivers/net/bonding/bond_sysfs.c	2011-02-08 16:03:02.950282003 +0300
+++ linux-2.6.p/drivers/net/bonding/bond_sysfs.c	2011-02-16 02:05:58.650281999 +0300
@@ -1643,6 +1643,55 @@ out:
 static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
 		   bonding_show_resend_igmp, bonding_store_resend_igmp);
 
+/*
+ * Show and set the bonding src_mac_select param.
+ */
+
+static ssize_t bonding_show_src_mac_select(struct device *d,
+					struct device_attribute *attr,
+					char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%s %d\n",
+			src_mac_select_tbl[bond->params.src_mac_select].modename,
+			bond->params.src_mac_select);
+}
+
+static ssize_t bonding_store_src_mac_select(struct device *d,
+					struct device_attribute *attr,
+					const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (bond->dev->flags & IFF_UP) {
+		pr_err("%s: Interface is up. Unable to update src mac select policy.\n",
+			bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	new_value = bond_parse_parm(buf, src_mac_select_tbl);
+	if (new_value < 0)  {
+		pr_err("%s: Ignoring invalid src mac select policy value %.*s.\n",
+			bond->dev->name,
+			(int)strlen(buf) - 1, buf);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		bond->params.src_mac_select = new_value;
+		pr_info("%s: setting src mac select policy to %s (%d).\n",
+			bond->dev->name,
+			src_mac_select_tbl[new_value].modename, new_value);
+	}
+out:
+	return ret;
+}
+
+static DEVICE_ATTR(src_mac_select, S_IRUGO | S_IWUSR,
+		bonding_show_src_mac_select, bonding_store_src_mac_select);
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -1671,6 +1720,7 @@ static struct attribute *per_bond_attrs[
 	&dev_attr_queue_id.attr,
 	&dev_attr_all_slaves_active.attr,
 	&dev_attr_resend_igmp.attr,
+	&dev_attr_src_mac_select.attr,
 	NULL,
 };
 
diff -uprN -X linux-2.6/Documentation/dontdiff linux-2.6/include/linux/if_bonding.h linux-2.6.p/include/linux/if_bonding.h
--- linux-2.6/include/linux/if_bonding.h	2011-02-16 00:59:18.720282002 +0300
+++ linux-2.6.p/include/linux/if_bonding.h	2011-02-16 01:23:38.660282000 +0300
@@ -91,6 +91,7 @@
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
 #define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ (TCP || UDP)) */
 #define BOND_XMIT_POLICY_LAYER23	2 /* layer 2+3 (IP ^ MAC) */
+#define BOND_XMIT_POLICY_LAYERRR	3 /* round-robin mode */
 
 typedef struct ifbond {
 	__s32 bond_mode;
