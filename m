From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 4/4] bond: add new multiqueue hash policy
Date: Thu, 04 Feb 2010 09:11:22 -0800
Message-ID: <20100204171241.463222870@vyatta.com>
References: <20100204171118.917737392@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45538 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753989Ab0BDRQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 12:16:40 -0500
Content-Disposition: inline; filename=bond-jhash.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This hash policy just uses existing transmit hash used for
mulitiqueue.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2010-02-04 08:57:52.356755294 -0800
+++ b/drivers/net/bonding/bond_main.c	2010-02-04 08:57:53.036755256 -0800
@@ -190,6 +190,7 @@ const struct bond_parm_tbl xmit_hashtype
 {	"layer2",		BOND_XMIT_POLICY_LAYER2},
 {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
 {	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
+{       "multiqueue",		BOND_XMIT_POLICY_MQ},
 {	NULL,			-1},
 };
 
@@ -3670,6 +3671,13 @@ static u16 bond_xmit_hash_policy_l34(con
 
 }
 
+/*
+ * Hash for the output device based on multiqueue transmit hash policy
+ */
+static u16 bond_xmit_hash_policy_mq(const struct sk_buff *skb)
+{
+	return skb_tx_hash(skb->dev, skb);
+}
 
 /*-------------------------- Device entry points ----------------------------*/
 
@@ -4350,6 +4358,9 @@ out:
 static void bond_set_xmit_hash_policy(struct bonding *bond)
 {
 	switch (bond->params.xmit_policy) {
+	case BOND_XMIT_POLICY_MQ:
+		bond->xmit_hash_policy = bond_xmit_hash_policy_mq;
+		break;
 	case BOND_XMIT_POLICY_LAYER23:
 		bond->xmit_hash_policy = bond_xmit_hash_policy_l23;
 		break;
--- a/include/linux/if_bonding.h	2010-02-04 08:56:35.956131096 -0800
+++ b/include/linux/if_bonding.h	2010-02-04 08:57:53.036755256 -0800
@@ -87,6 +87,7 @@
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
 #define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ (TCP || UDP)) */
 #define BOND_XMIT_POLICY_LAYER23	2 /* layer 2+3 (IP ^ MAC) */
+#define BOND_XMIT_POLICY_MQ             3 /* transmit hash (multiqueue) */
 
 typedef struct ifbond {
 	__s32 bond_mode;

-- 

