From: "Glenn Griffin" <ggriffin.kernel@gmail.com>
Subject: [RFC][PATCH] bonding layer2+3 xmit_hash_policy
Date: Wed, 21 Nov 2007 22:37:12 -0800
Message-ID: <c9e534200711212237k1fd7a989o2f99a211c86e1bdc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.184]:2963 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbXKVGhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 01:37:15 -0500
Received: by mu-out-0910.google.com with SMTP id i10so2827111mue
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 22:37:13 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I posted this 2 weeks ago on the bonding-devel list, but didn't
receive any feedback so thought I would bring it up to a larger
audience.

Included is a patch for a new xmit_hash_policy for the bonding driver
that selects slaves based on MAC and IP information.  This is a middle
ground between what currently exists in the layer2 only policy and the
layer3+4 policy.  This policy strives to be fully 802.3ad compliant by
transmitting every packet of any particular flow over the same link.
As documented the layer3+4 policy is not fully compliant for extreme
cases such as ip fragmentation, so this policy is a nice compromise
for environments that require full compliance but desire more than the
layer2 only policy.  Comments?

---
 Documentation/networking/bonding.txt |   23 +++++++++++++++++++++++
 drivers/net/bonding/bond_main.c      |   26 ++++++++++++++++++++++++--
 include/linux/if_bonding.h           |    3 ++-
 3 files changed, 49 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/bonding.txt
b/Documentation/networking/bonding.txt
index 1134062..5ac84c0 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -587,6 +587,29 @@ xmit_hash_policy
 		most UDP traffic is not involved in extended
 		conversations.  Other implementations of 802.3ad may
 		or may not tolerate this noncompliance.
+	
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
+		required to reach most destinations. This algorithm is
+		fully 802.3ad complient.

 	The default value is layer2.  This option was added in bonding
 version 2.6.3.  In earlier versions of bonding, this parameter does
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 423298c..a731812 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -174,6 +174,7 @@ struct bond_parm_tbl bond_mode_tbl[] = {
 struct bond_parm_tbl xmit_hashtype_tbl[] = {
 {	"layer2",		BOND_XMIT_POLICY_LAYER2},
 {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
+{	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
 {	NULL,			-1},
 };

@@ -3604,6 +3605,24 @@ void bond_unregister_arp(struct bonding *bond)
 /*---------------------------- Hashing Policies -----------------------------*/

 /*
+ * Hash for the output device based upon layer 2 and layer 3 data. If
+ * the packet is not IP mimic bond_xmit_hash_policy_l2()
+ */
+static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
+				    struct net_device *bond_dev, int count)
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
@@ -4323,6 +4342,8 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 		bond_dev->hard_start_xmit = bond_xmit_xor;
 		if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34)
 			bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
+		else if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER23)
+			bond->xmit_hash_policy = bond_xmit_hash_policy_l23;
 		else
 			bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
 		break;
@@ -4334,6 +4355,8 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 		bond_dev->hard_start_xmit = bond_3ad_xmit_xor;
 		if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34)
 			bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
+		else if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER23)
+			bond->xmit_hash_policy = bond_xmit_hash_policy_l23;
 		else
 			bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
 		break;
@@ -4497,8 +4520,7 @@ int bond_parse_parm(char *mode_arg, struct
bond_parm_tbl *tbl)
 	for (i = 0; tbl[i].modename; i++) {
 		if ((isdigit(*mode_arg) &&
 		     tbl[i].mode == simple_strtol(mode_arg, NULL, 0)) ||
-		    (strncmp(mode_arg, tbl[i].modename,
-			     strlen(tbl[i].modename)) == 0)) {
+		    (strcmp(mode_arg, tbl[i].modename) == 0)) {
 			return tbl[i].mode;
 		}
 	}
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
1.5.2.5
