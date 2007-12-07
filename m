From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 7/8] bonding: Add new layer2+3 hash for xor/802.3ad modes
Date: Thu,  6 Dec 2007 23:40:34 -0800
Message-ID: <1197013239283-git-send-email-fubar@us.ibm.com>
References: <11970132353950-git-send-email-fubar@us.ibm.com>
 <11970132363756-git-send-email-fubar@us.ibm.com>
 <11970132372293-git-send-email-fubar@us.ibm.com>
 <1197013237259-git-send-email-fubar@us.ibm.com>
 <11970132382296-git-send-email-fubar@us.ibm.com>
 <11970132381345-git-send-email-fubar@us.ibm.com>
 <11970132394126-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, "Glenn Griffin" <ggriffin.kernel@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:43189 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbXLGHkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 02:40:47 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB77efv5000960
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 02:40:41 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB77efAc120800
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:41 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB77eePf018160
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:40 -0700
In-Reply-To: <11970132394126-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 	Add new hash for balance-xor and 802.3ad modes.  Originally
 submitted by "Glenn Griffin" <ggriffin.kernel@gmail.com>; modified by
 Jay Vosburgh to move setting of hash policy out of line, tweak the
 documentation update and add version update to 3.2.2.

	Glenn's original comment follows:

Included is a patch for a new xmit_hash_policy for the bonding driver
that selects slaves based on MAC and IP information.  This is a middle
ground between what currently exists in the layer2 only policy and the
layer3+4 policy.  This policy strives to be fully 802.3ad compliant by
transmitting every packet of any particular flow over the same link.
As documented the layer3+4 policy is not fully compliant for extreme
cases such as ip fragmentation, so this policy is a nice compromise
for environments that require full compliance but desire more than the
layer2 only policy.

Signed-off-by: "Glenn Griffin" <ggriffin.kernel@gmail.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 Documentation/networking/bonding.txt |   29 +++++++++++++++++++-
 drivers/net/bonding/bond_main.c      |   48 ++++++++++++++++++++++++++-------
 drivers/net/bonding/bonding.h        |    4 +-
 include/linux/if_bonding.h           |    3 +-
 4 files changed, 69 insertions(+), 15 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index eda0f06..a0cda06 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -559,6 +559,30 @@ xmit_hash_policy
 
 		This algorithm is 802.3ad compliant.
 
+	layer2+3
+
+		This policy uses a combination of layer2 and layer3
+		protocol information to generate the hash.
+
+		Uses XOR of hardware MAC addresses and IP addresses to
+		generate the hash.  The formula is
+
+		(((source IP XOR dest IP) AND 0xffff) XOR
+			( source MAC XOR destination MAC ))
+				modulo slave count
+
+		This algorithm will place all traffic to a particular
+		network peer on the same slave.  For non-IP traffic,
+		the formula is the same as for the layer2 transmit
+		hash policy.
+
+		This policy is intended to provide a more balanced
+		distribution of traffic than layer2 alone, especially
+		in environments where a layer3 gateway device is
+		required to reach most destinations.
+
+		This algorithm is 802.3ad complient.
+
 	layer3+4
 
 		This policy uses upper layer protocol information,
@@ -594,8 +618,9 @@ xmit_hash_policy
 		or may not tolerate this noncompliance.
 
 	The default value is layer2.  This option was added in bonding
-version 2.6.3.  In earlier versions of bonding, this parameter does
-not exist, and the layer2 policy is the only policy.
+	version 2.6.3.  In earlier versions of bonding, this parameter
+	does not exist, and the layer2 policy is the only policy.  The
+	layer2+3 value was added for bonding version 3.2.2.
 
 
 3. Configuring Bonding Devices
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e4a4714..08879d5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -175,6 +175,7 @@ struct bond_parm_tbl bond_mode_tbl[] = {
 struct bond_parm_tbl xmit_hashtype_tbl[] = {
 {	"layer2",		BOND_XMIT_POLICY_LAYER2},
 {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
+{	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
 {	NULL,			-1},
 };
 
@@ -3605,6 +3606,24 @@ void bond_unregister_arp(struct bonding *bond)
 /*---------------------------- Hashing Policies -----------------------------*/
 
 /*
+ * Hash for the output device based upon layer 2 and layer 3 data. If
+ * the packet is not IP mimic bond_xmit_hash_policy_l2()
+ */
+static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
+				     struct net_device *bond_dev, int count)
+{
+	struct ethhdr *data = (struct ethhdr *)skb->data;
+	struct iphdr *iph = ip_hdr(skb);
+
+	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
+			(data->h_dest[5] ^ bond_dev->dev_addr[5])) % count;
+	}
+
+	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
+}
+
+/*
  * Hash for the output device based upon layer 3 and layer 4 data. If
  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
  * altogether not IP, mimic bond_xmit_hash_policy_l2()
@@ -4306,6 +4325,22 @@ out:
 
 /*------------------------- Device initialization ---------------------------*/
 
+static void bond_set_xmit_hash_policy(struct bonding *bond)
+{
+	switch (bond->params.xmit_policy) {
+	case BOND_XMIT_POLICY_LAYER23:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_l23;
+		break;
+	case BOND_XMIT_POLICY_LAYER34:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
+		break;
+	case BOND_XMIT_POLICY_LAYER2:
+	default:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
+		break;
+	}
+}
+
 /*
  * set bond mode specific net device operations
  */
@@ -4322,10 +4357,7 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 		break;
 	case BOND_MODE_XOR:
 		bond_dev->hard_start_xmit = bond_xmit_xor;
-		if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34)
-			bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
-		else
-			bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
+		bond_set_xmit_hash_policy(bond);
 		break;
 	case BOND_MODE_BROADCAST:
 		bond_dev->hard_start_xmit = bond_xmit_broadcast;
@@ -4333,10 +4365,7 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 	case BOND_MODE_8023AD:
 		bond_set_master_3ad_flags(bond);
 		bond_dev->hard_start_xmit = bond_3ad_xmit_xor;
-		if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34)
-			bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
-		else
-			bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
+		bond_set_xmit_hash_policy(bond);
 		break;
 	case BOND_MODE_ALB:
 		bond_set_master_alb_flags(bond);
@@ -4498,8 +4527,7 @@ int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl)
 	for (i = 0; tbl[i].modename; i++) {
 		if ((isdigit(*mode_arg) &&
 		     tbl[i].mode == simple_strtol(mode_arg, NULL, 0)) ||
-		    (strncmp(mode_arg, tbl[i].modename,
-			     strlen(tbl[i].modename)) == 0)) {
+		    (strcmp(mode_arg, tbl[i].modename) == 0)) {
 			return tbl[i].mode;
 		}
 	}
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 61c1b45..ccafc74 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.1"
-#define DRV_RELDATE	"October 15, 2007"
+#define DRV_VERSION	"3.2.2"
+#define DRV_RELDATE	"December 6, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index 84598fa..65c2d24 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -85,7 +85,8 @@
 
 /* hashing types */
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
-#define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ MAC) */
+#define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ (TCP || UDP)) */
+#define BOND_XMIT_POLICY_LAYER23	2 /* layer 2+3 (IP ^ MAC) */
 
 typedef struct ifbond {
 	__s32 bond_mode;
-- 
1.5.3.4.206.g58ba4-dirty

