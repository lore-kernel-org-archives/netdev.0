From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 1/4] bond: cleanup transmit hash policy interface
Date: Thu, 04 Feb 2010 09:11:19 -0800
Message-ID: <20100204171241.249024503@vyatta.com>
References: <20100204171118.917737392@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45521 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758467Ab0BDRP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 12:15:59 -0500
Content-Disposition: inline; filename=bond-hash1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor cleanups of hash policy with no change in resulting
interface.
  1. Do modulus operation in caller rather than policy
  2. Pass skb as constant pointer
  3. Use common code for layer 2 policy hash

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_3ad.c	2010-02-04 08:56:36.106130909 -0800
+++ b/drivers/net/bonding/bond_3ad.c	2010-02-04 08:57:46.736130667 -0800
@@ -2413,7 +2413,7 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 		goto out;
 	}
 
-	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
+	slave_agg_no = bond->xmit_hash_policy(skb) % slaves_in_agg;
 
 	bond_for_each_slave(bond, slave, i) {
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
--- a/drivers/net/bonding/bond_main.c	2010-02-04 08:56:56.015821641 -0800
+++ b/drivers/net/bonding/bond_main.c	2010-02-04 08:57:46.736130667 -0800
@@ -3584,20 +3584,30 @@ void bond_unregister_arp(struct bonding 
 /*---------------------------- Hashing Policies -----------------------------*/
 
 /*
+ * Hash for the output device based upon layer 2 data
+ */
+static u16 bond_xmit_hash_policy_l2(const struct sk_buff *skb)
+{
+	const struct ethhdr *data = eth_hdr(skb);
+
+	return data->h_dest[5] ^ data->h_source[5];
+}
+
+/*
  * Hash for the output device based upon layer 2 and layer 3 data. If
  * the packet is not IP mimic bond_xmit_hash_policy_l2()
  */
-static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
+static u16 bond_xmit_hash_policy_l23(const struct sk_buff *skb)
 {
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
+	const struct ethhdr *data = eth_hdr(skb);
 
 	if (skb->protocol == htons(ETH_P_IP)) {
-		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
-			(data->h_dest[5] ^ data->h_source[5])) % count;
+		const struct iphdr *iph = ip_hdr(skb);
+		return ntohl(iph->saddr ^ iph->daddr) ^
+			(data->h_dest[5] ^ data->h_source[5]);
 	}
 
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
+	return bond_xmit_hash_policy_l2(skb);
 }
 
 /*
@@ -3605,36 +3615,28 @@ static int bond_xmit_hash_policy_l23(str
  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
  * altogether not IP, mimic bond_xmit_hash_policy_l2()
  */
-static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
+static u16 bond_xmit_hash_policy_l34(const struct sk_buff *skb)
 {
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
-	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
-	int layer4_xor = 0;
+	const struct ethhdr *data = eth_hdr(skb);
 
 	if (skb->protocol == htons(ETH_P_IP)) {
+		const struct iphdr *iph = ip_hdr(skb);
+		const __be16 *layer4hdr
+			= ((const void *)iph + iph->ihl);
+		u32 layer4_xor = 0;
+
 		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
 		    (iph->protocol == IPPROTO_TCP ||
 		     iph->protocol == IPPROTO_UDP)) {
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
 		}
-		return (layer4_xor ^
-			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
+		return layer4_xor ^ ntohl(iph->saddr ^ iph->daddr);
 
 	}
 
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
+	return bond_xmit_hash_policy_l2(skb);
 }
 
-/*
- * Hash for the output device based upon layer 2 data
- */
-static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
-{
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
-}
 
 /*-------------------------- Device entry points ----------------------------*/
 
@@ -4224,7 +4226,7 @@ static int bond_xmit_xor(struct sk_buff 
 	if (!BOND_IS_OK(bond))
 		goto out;
 
-	slave_no = bond->xmit_hash_policy(skb, bond->slave_cnt);
+	slave_no = bond->xmit_hash_policy(skb) %  bond->slave_cnt;
 
 	bond_for_each_slave(bond, slave, i) {
 		slave_no--;
--- a/drivers/net/bonding/bonding.h	2010-02-04 08:56:56.015821641 -0800
+++ b/drivers/net/bonding/bonding.h	2010-02-04 08:57:46.736130667 -0800
@@ -203,7 +203,7 @@ struct bonding {
 #endif /* CONFIG_PROC_FS */
 	struct   list_head bond_list;
 	struct   dev_mc_list *mc_list;
-	int      (*xmit_hash_policy)(struct sk_buff *, int);
+	u16      (*xmit_hash_policy)(const struct sk_buff *);
 	__be32   master_ip;
 	u16      flags;
 	u16      rr_tx_counter;

-- 

