From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Fri, 14 Jan 2011 22:07:14 +0300
Message-ID: <20110114190714.GA11655@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:48346 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362Ab1ANTPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 14:15:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch introduces new hashing policy for 802.3ad bonding mode.
This hashing policy can be used(was tested) only for round-robin
balancing of ISCSI traffic(single TCP session is balanced (per-packet)
over all slave interfaces. 
General requirements for this hashing policy usage are:
1) switch must be configured with src-dst-mac or src-mac hashing policy 
2) number of bond slaves on sending and receiving machine should be equal
and preferrably even; or simply even, otherwise you may get asymmetric 
load on receiving machine
3) hashing policy must not be used when round trip time between source 
and destination machines for slaves in same bond is expected to be 
significanly different (it works fine when all slaves are plugged into
single switch)

Signed-off-by: Oleg V. Ukhno <olegu@yandex-team.ru>
---

 Documentation/networking/bonding.txt |   27 +++++++++++++++++++++++++++
 drivers/net/bonding/bond_3ad.c       |    6 ++++++
 drivers/net/bonding/bond_main.c      |   18 +++++++++++++++++-
 include/linux/if_bonding.h           |    1 +
 4 files changed, 51 insertions(+), 1 deletion(-)

diff -uprN -X linux-2.6.37-vanilla/Documentation/dontdiff linux-2.6.37-vanilla/Documentation/networking/bonding.txt linux-2.6.37.my/Documentation/networking/bonding.txt
--- linux-2.6.37-vanilla/Documentation/networking/bonding.txt	2011-01-05 03:50:19.000000000 +0300
+++ linux-2.6.37.my/Documentation/networking/bonding.txt	2011-01-14 21:34:46.635268000 +0300
@@ -759,6 +759,33 @@ xmit_hash_policy
 		most UDP traffic is not involved in extended
 		conversations.  Other implementations of 802.3ad may
 		or may not tolerate this noncompliance.
+
+	simple-rr or 3
+		This policy simply sends every next packet via "next"
+		slave interface. When sending, it resets mac-address
+		within packet to real mac-address of the slave interface.
+
+		When switch is configured properly, and receiving machine
+		has even and equal number of interfaces, this guarantees
+		quite precise rx/tx load balancing for any single TCP
+		session. Typical use-case for this mode is ISCSI(and patch was
+		developed for), because it ises single TCP session to
+		transmit data.
+
+		It is important to remember, that all slaves should be
+		plugged into single switch to avoid out-of-order packets
+		It is recommended to have equal and even number of slave
+		interfaces in sending and receviving machines bond's,
+		otherwise you will get asymmetric load on receiving host.
+		Another caveat is that hashing policy must not be used when
+		round trip time between source and destination machines for
+		slaves in same bond is expected to be significanly different
+		(it works fine when all slaves are plugged into single switch)
+
+		For correct load baalncing on the receiving side you must
+		configure switch for using src-dst-mac or src-mac hashing
+		mode.
+
 
 	The default value is layer2.  This option was added in bonding
 	version 2.6.3.  In earlier versions of bonding, this parameter
diff -uprN -X linux-2.6.37-vanilla/Documentation/dontdiff linux-2.6.37-vanilla/drivers/net/bonding/bond_3ad.c linux-2.6.37.my/drivers/net/bonding/bond_3ad.c
--- linux-2.6.37-vanilla/drivers/net/bonding/bond_3ad.c	2011-01-14 19:39:05.575268000 +0300
+++ linux-2.6.37.my/drivers/net/bonding/bond_3ad.c	2011-01-14 19:47:03.815268000 +0300
@@ -2395,6 +2395,7 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 	int i;
 	struct ad_info ad_info;
 	int res = 1;
+	struct ethhdr *eth_data;
 
 	/* make sure that the slaves list will
 	 * not change during tx
@@ -2447,6 +2448,11 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 			slave_agg_id = agg->aggregator_identifier;
 
 		if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
+			if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYERRR && ntohs(skb->protocol) == ETH_P_IP) {
+				skb_reset_mac_header(skb);
+				eth_data = eth_hdr(skb);
+				memcpy(eth_data->h_source, slave->perm_hwaddr, ETH_ALEN);
+			}
 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
 			break;
 		}
diff -uprN -X linux-2.6.37-vanilla/Documentation/dontdiff linux-2.6.37-vanilla/drivers/net/bonding/bond_main.c linux-2.6.37.my/drivers/net/bonding/bond_main.c
--- linux-2.6.37-vanilla/drivers/net/bonding/bond_main.c	2011-01-14 19:39:05.575268000 +0300
+++ linux-2.6.37.my/drivers/net/bonding/bond_main.c	2011-01-14 19:47:55.835268001 +0300
@@ -152,7 +152,9 @@ module_param(ad_select, charp, 0);
 MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
 module_param(xmit_hash_policy, charp, 0);
 MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
-				   ", 1 for layer 3+4");
+				   ", 1 for layer 3+4"
+				   ", 2 for layer 2+3"
+				   ", 3 for round-robin");
 module_param(arp_interval, int, 0);
 MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
 module_param_array(arp_ip_target, charp, NULL, 0);
@@ -206,6 +208,7 @@ const struct bond_parm_tbl xmit_hashtype
 {	"layer2",		BOND_XMIT_POLICY_LAYER2},
 {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
 {	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
+{	"simple-rr",		BOND_XMIT_POLICY_LAYERRR},
 {	NULL,			-1},
 };
 
@@ -3762,6 +3765,16 @@ static int bond_xmit_hash_policy_l2(stru
 	return (data->h_dest[5] ^ data->h_source[5]) % count;
 }
 
+/*
+ * simply round robin
+ */
+static int bond_xmit_hash_policy_rr(struct sk_buff *skb,
+				   struct net_device *bond_dev, int count)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	return bond->rr_tx_counter++ % count;
+}
+
 /*-------------------------- Device entry points ----------------------------*/
 
 static int bond_open(struct net_device *bond_dev)
@@ -4482,6 +4495,9 @@ out:
 static void bond_set_xmit_hash_policy(struct bonding *bond)
 {
 	switch (bond->params.xmit_policy) {
+	case BOND_XMIT_POLICY_LAYERRR:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_rr;
+		break;
 	case BOND_XMIT_POLICY_LAYER23:
 		bond->xmit_hash_policy = bond_xmit_hash_policy_l23;
 		break;
diff -uprN -X linux-2.6.37-vanilla/Documentation/dontdiff linux-2.6.37-vanilla/include/linux/if_bonding.h linux-2.6.37.my/include/linux/if_bonding.h
--- linux-2.6.37-vanilla/include/linux/if_bonding.h	2011-01-05 03:50:19.000000000 +0300
+++ linux-2.6.37.my/include/linux/if_bonding.h	2011-01-14 19:34:29.755268001 +0300
@@ -91,6 +91,7 @@
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
 #define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ (TCP || UDP)) */
 #define BOND_XMIT_POLICY_LAYER23	2 /* layer 2+3 (IP ^ MAC) */
+#define BOND_XMIT_POLICY_LAYERRR	3 /* round-robin */
 
 typedef struct ifbond {
 	__s32 bond_mode;
