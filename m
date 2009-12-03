From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH 1/4] llc: use dev_hard_header
Date: Fri,  4 Dec 2009 00:31:35 +0200
Message-ID: <1259879498-27860-2-git-send-email-opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: opurdila@ixiacom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:20102 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751954AbZLCWer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:34:47 -0500
In-Reply-To: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using dev_hard_header allows us to use LLC with VLANs and potentially
other Ethernet/TokernRing specific encapsulations. It also removes code
duplication between LLC and Ethernet/TokenRing core code.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 drivers/net/myri_sbus.c |    6 +++---
 net/8021q/vlan_dev.c    |    7 +++----
 net/ethernet/eth.c      |    7 ++++---
 net/llc/llc_output.c    |   45 ++++++++-------------------------------------
 4 files changed, 18 insertions(+), 47 deletions(-)

diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index b3513ad..8b43130 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -716,10 +716,10 @@ static int myri_header(struct sk_buff *skb, struct net_device *dev,
 	pad[0] = MYRI_PAD_LEN;
 	pad[1] = 0xab;
 
-	/* Set the protocol type. For a packet of type ETH_P_802_3 we put the length
-	 * in here instead. It is up to the 802.2 layer to carry protocol information.
+	/* Set the protocol type. For a packet of type ETH_P_802_3/2 we put the
+	 * length in here instead.
 	 */
-	if (type != ETH_P_802_3)
+	if (type != ETH_P_802_3 && type != ETH_P_802_2)
 		eth->h_proto = htons(type);
 	else
 		eth->h_proto = htons(len);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index de0dc6b..1bc9be5 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -263,11 +263,10 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		vhdr->h_vlan_TCI = htons(vlan_tci);
 
 		/*
-		 *  Set the protocol type. For a packet of type ETH_P_802_3 we
-		 *  put the length in here instead. It is up to the 802.2
-		 *  layer to carry protocol information.
+		 *  Set the protocol type. For a packet of type ETH_P_802_3/2 we
+		 *  put the length in here instead.
 		 */
-		if (type != ETH_P_802_3)
+		if (type != ETH_P_802_3 && type != ETH_P_802_2)
 			vhdr->h_vlan_encapsulated_proto = htons(type);
 		else
 			vhdr->h_vlan_encapsulated_proto = htons(len);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index dd3db88..c380da6 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -1,3 +1,4 @@
+]
 /*
  * INET		An implementation of the TCP/IP protocol suite for the LINUX
  *		operating system.  INET is implemented using the  BSD Socket
@@ -73,8 +74,8 @@ __setup("ether=", netdev_boot_setup);
  * @len:   packet length (<= skb->len)
  *
  *
- * Set the protocol type. For a packet of type ETH_P_802_3 we put the length
- * in here instead. It is up to the 802.2 layer to carry protocol information.
+ * Set the protocol type. For a packet of type ETH_P_802_3/2 we put the length
+ * in here instead.
  */
 int eth_header(struct sk_buff *skb, struct net_device *dev,
 	       unsigned short type,
@@ -82,7 +83,7 @@ int eth_header(struct sk_buff *skb, struct net_device *dev,
 {
 	struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
 
-	if (type != ETH_P_802_3)
+	if (type != ETH_P_802_3 && type != ETH_P_802_2)
 		eth->h_proto = htons(type);
 	else
 		eth->h_proto = htons(len);
diff --git a/net/llc/llc_output.c b/net/llc/llc_output.c
index 754f4fe..b38a107 100644
--- a/net/llc/llc_output.c
+++ b/net/llc/llc_output.c
@@ -33,48 +33,19 @@
 int llc_mac_hdr_init(struct sk_buff *skb,
 		     const unsigned char *sa, const unsigned char *da)
 {
-	int rc = 0;
+	int rc = -EINVAL;
 
 	switch (skb->dev->type) {
-#ifdef CONFIG_TR
-	case ARPHRD_IEEE802_TR: {
-		struct net_device *dev = skb->dev;
-		struct trh_hdr *trh;
-
-		skb_push(skb, sizeof(*trh));
-		skb_reset_mac_header(skb);
-		trh = tr_hdr(skb);
-		trh->ac = AC;
-		trh->fc = LLC_FRAME;
-		if (sa)
-			memcpy(trh->saddr, sa, dev->addr_len);
-		else
-			memset(trh->saddr, 0, dev->addr_len);
-		if (da) {
-			memcpy(trh->daddr, da, dev->addr_len);
-			tr_source_route(skb, trh, dev);
-			skb_reset_mac_header(skb);
-		}
-		break;
-	}
-#endif
+	case ARPHRD_IEEE802_TR:
 	case ARPHRD_ETHER:
-	case ARPHRD_LOOPBACK: {
-		unsigned short len = skb->len;
-		struct ethhdr *eth;
-
-		skb_push(skb, sizeof(*eth));
-		skb_reset_mac_header(skb);
-		eth = eth_hdr(skb);
-		eth->h_proto = htons(len);
-		memcpy(eth->h_dest, da, ETH_ALEN);
-		memcpy(eth->h_source, sa, ETH_ALEN);
+	case ARPHRD_LOOPBACK:
+		rc = dev_hard_header(skb, skb->dev, ETH_P_802_2, da, sa,
+				     skb->len);
+		if (rc > 0)
+			rc = 0;
 		break;
-	}
 	default:
-		printk(KERN_WARNING "device type not supported: %d\n",
-		       skb->dev->type);
-		rc = -EINVAL;
+		WARN(1, "device type not supported: %d\n", skb->dev->type);
 	}
 	return rc;
 }
-- 
1.5.6.5

