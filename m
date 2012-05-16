From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/4] s390: delete any traces of token ring support
Date: Tue, 15 May 2012 20:35:41 -0400
Message-ID: <1337128544-18680-2-git-send-email-paul.gortmaker@windriver.com>
References: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux390@de.ibm.com, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44425 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967099Ab2EPAgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 20:36:25 -0400
In-Reply-To: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The token ring support is going away from the core kernel.
Divorce the S390 drivers from it in advance.

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/s390/net/Kconfig          |    5 ++---
 drivers/s390/net/lcs.c            |   21 ++-------------------
 drivers/s390/net/qeth_core.h      |    2 --
 drivers/s390/net/qeth_core_main.c |    6 +-----
 drivers/s390/net/qeth_l3_main.c   |   35 ++++++-----------------------------
 5 files changed, 11 insertions(+), 58 deletions(-)

diff --git a/drivers/s390/net/Kconfig b/drivers/s390/net/Kconfig
index 9b66d2d..dfda748 100644
--- a/drivers/s390/net/Kconfig
+++ b/drivers/s390/net/Kconfig
@@ -4,11 +4,10 @@ menu "S/390 network device drivers"
 config LCS
 	def_tristate m
 	prompt "Lan Channel Station Interface"
-	depends on CCW && NETDEVICES && (ETHERNET || TR || FDDI)
+	depends on CCW && NETDEVICES && (ETHERNET || FDDI)
 	help
 	   Select this option if you want to use LCS networking on IBM System z.
-	   This device driver supports Token Ring (IEEE 802.5),
-	   FDDI (IEEE 802.7) and Ethernet.
+	   This device driver supports FDDI (IEEE 802.7) and Ethernet.
 	   To compile as a module, choose M. The module name is lcs.
 	   If you do not know what it is, it's safe to choose Y.
 
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 687efe4..6056cf6 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -30,7 +30,6 @@
 #include <linux/if.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/trdevice.h>
 #include <linux/fddidevice.h>
 #include <linux/inetdevice.h>
 #include <linux/in.h>
@@ -50,8 +49,7 @@
 #include "lcs.h"
 
 
-#if !defined(CONFIG_ETHERNET) && \
-    !defined(CONFIG_TR) && !defined(CONFIG_FDDI)
+#if !defined(CONFIG_ETHERNET) && !defined(CONFIG_FDDI)
 #error Cannot compile lcs.c without some net devices switched on.
 #endif
 
@@ -1166,10 +1164,7 @@ static void
 lcs_get_mac_for_ipm(__be32 ipm, char *mac, struct net_device *dev)
 {
 	LCS_DBF_TEXT(4,trace, "getmac");
-	if (dev->type == ARPHRD_IEEE802_TR)
-		ip_tr_mc_map(ipm, mac);
-	else
-		ip_eth_mc_map(ipm, mac);
+	ip_eth_mc_map(ipm, mac);
 }
 
 /**
@@ -1641,12 +1636,6 @@ lcs_startlan_auto(struct lcs_card *card)
 		return 0;
 
 #endif
-#ifdef CONFIG_TR
-	card->lan_type = LCS_FRAME_TYPE_TR;
-	rc = lcs_send_startlan(card, LCS_INITIATOR_TCPIP);
-	if (rc == 0)
-		return 0;
-#endif
 #ifdef CONFIG_FDDI
 	card->lan_type = LCS_FRAME_TYPE_FDDI;
 	rc = lcs_send_startlan(card, LCS_INITIATOR_TCPIP);
@@ -2172,12 +2161,6 @@ lcs_new_device(struct ccwgroup_device *ccwgdev)
 		dev = alloc_etherdev(0);
 		break;
 #endif
-#ifdef CONFIG_TR
-	case LCS_FRAME_TYPE_TR:
-		card->lan_type_trans = tr_type_trans;
-		dev = alloc_trdev(0);
-		break;
-#endif
 #ifdef CONFIG_FDDI
 	case LCS_FRAME_TYPE_FDDI:
 		card->lan_type_trans = fddi_type_trans;
diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index ec7921b..bb7190f 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -13,8 +13,6 @@
 
 #include <linux/if.h>
 #include <linux/if_arp.h>
-#include <linux/if_tr.h>
-#include <linux/trdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
 #include <linux/ctype.h>
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 8334dad..83b0d2f 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4911,11 +4911,7 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 		break;
 	case QETH_HEADER_TYPE_LAYER3:
 		skb_len = (*hdr)->hdr.l3.length;
-		if ((card->info.link_type == QETH_LINK_TYPE_LANE_TR) ||
-		    (card->info.link_type == QETH_LINK_TYPE_HSTR))
-			headroom = TR_HLEN;
-		else
-			headroom = ETH_HLEN;
+		headroom = ETH_HLEN;
 		break;
 	case QETH_HEADER_TYPE_OSN:
 		skb_len = (*hdr)->hdr.osn.pdu_length;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index f859216..74ebeaf 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1671,10 +1671,7 @@ qeth_diags_trace(struct qeth_card *card, enum qeth_diags_trace_cmds diags_cmd)
 static void qeth_l3_get_mac_for_ipm(__u32 ipm, char *mac,
 				struct net_device *dev)
 {
-	if (dev->type == ARPHRD_IEEE802_TR)
-		ip_tr_mc_map(ipm, mac);
-	else
-		ip_eth_mc_map(ipm, mac);
+	ip_eth_mc_map(ipm, mac);
 }
 
 static void qeth_l3_add_mc(struct qeth_card *card, struct in_device *in4_dev)
@@ -1922,8 +1919,6 @@ static inline int qeth_l3_rebuild_skb(struct qeth_card *card,
 #endif
 			case __constant_htons(ETH_P_IP):
 				ip_hdr = (struct iphdr *)skb->data;
-				(card->dev->type == ARPHRD_IEEE802_TR) ?
-				ip_tr_mc_map(ip_hdr->daddr, tg_addr):
 				ip_eth_mc_map(ip_hdr->daddr, tg_addr);
 				break;
 			default:
@@ -1959,12 +1954,7 @@ static inline int qeth_l3_rebuild_skb(struct qeth_card *card,
 				tg_addr, "FAKELL", card->dev->addr_len);
 	}
 
-#ifdef CONFIG_TR
-	if (card->dev->type == ARPHRD_IEEE802_TR)
-		skb->protocol = tr_type_trans(skb, card->dev);
-	else
-#endif
-		skb->protocol = eth_type_trans(skb, card->dev);
+	skb->protocol = eth_type_trans(skb, card->dev);
 
 	if (hdr->hdr.l3.ext_flags &
 	    (QETH_HDR_EXT_VLAN_FRAME | QETH_HDR_EXT_INCLUDE_VLAN_TAG)) {
@@ -2883,13 +2873,7 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 			hdr->hdr.l3.flags &= ~QETH_HDR_PASSTHRU;
 		memcpy(hdr->hdr.l3.dest_addr, pkey, 16);
 	} else {
-		/* passthrough */
-		if ((skb->dev->type == ARPHRD_IEEE802_TR) &&
-			!memcmp(skb->data + sizeof(struct qeth_hdr) +
-			sizeof(__u16), skb->dev->broadcast, 6)) {
-			hdr->hdr.l3.flags = QETH_CAST_BROADCAST |
-						QETH_HDR_PASSTHRU;
-		} else if (!memcmp(skb->data + sizeof(struct qeth_hdr),
+		if (!memcmp(skb->data + sizeof(struct qeth_hdr),
 			    skb->dev->broadcast, 6)) {
 			/* broadcast? */
 			hdr->hdr.l3.flags = QETH_CAST_BROADCAST |
@@ -3031,10 +3015,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_pull(new_skb, ETH_HLEN);
 	} else {
 		if (ipv == 4) {
-			if (card->dev->type == ARPHRD_IEEE802_TR)
-				skb_pull(new_skb, TR_HLEN);
-			else
-				skb_pull(new_skb, ETH_HLEN);
+			skb_pull(new_skb, ETH_HLEN);
 		}
 
 		if (ipv != 4 && vlan_tx_tag_present(new_skb)) {
@@ -3318,12 +3299,8 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 	    card->info.type == QETH_CARD_TYPE_OSX) {
 		if ((card->info.link_type == QETH_LINK_TYPE_LANE_TR) ||
 		    (card->info.link_type == QETH_LINK_TYPE_HSTR)) {
-#ifdef CONFIG_TR
-			card->dev = alloc_trdev(0);
-#endif
-			if (!card->dev)
-				return -ENODEV;
-			card->dev->netdev_ops = &qeth_l3_netdev_ops;
+			pr_info("qeth_l3: ignoring TR device\n");
+			return -ENODEV;
 		} else {
 			card->dev = alloc_etherdev(0);
 			if (!card->dev)
-- 
1.7.9.1
