From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 2/5] s390: qeth driver fixes
Date: Mon, 8 Jan 2007 17:29:58 +0100
Message-ID: <20070108162958.GB21639@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:52146 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161351AbXAHQbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 11:31:25 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l08GVNrU011959
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 11:31:23 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l08GVNQv532338
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:31:23 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l08GVMAb010891
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:31:22 -0700
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 2/5] s390: qeth driver fixes

From: Frank Blaschka <Frank.Blaschka@de.ibm.com>
    - packet socket support is not complete.
      Recvfrom a packet socket does not fill the sockaddr_ll structure.
      device function hard_header_parse is not implemented.
      For layer 2 mode and layer 3 mode with fake_ll turned on, we have
      the information to fill sockaddr_ll.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/qeth_main.c |   58 ++++++++++++++++++++++++++++++++++++++----
 1 files changed, 53 insertions(+), 5 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 67062d5..337304d 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -3953,13 +3953,22 @@ static inline struct sk_buff *
 qeth_prepare_skb(struct qeth_card *card, struct sk_buff *skb,
 		 struct qeth_hdr **hdr, int ipv)
 {
-	struct sk_buff *new_skb;
+	struct sk_buff *new_skb, *new_skb2;
 	
 	QETH_DBF_TEXT(trace, 6, "prepskb");
-
-        new_skb = qeth_realloc_headroom(card, skb, sizeof(struct qeth_hdr));
-       	if (new_skb == NULL)
+	new_skb = skb;
+	new_skb = qeth_pskb_unshare(skb, GFP_ATOMIC);
+	if (!new_skb)
 		return NULL;
+	new_skb2 = qeth_realloc_headroom(card, new_skb,
+					 sizeof(struct qeth_hdr));
+	if (!new_skb2) {
+		__qeth_free_new_skb(skb, new_skb);
+		return NULL;
+	}
+	if (new_skb != skb)
+		__qeth_free_new_skb(new_skb2, new_skb);
+	new_skb = new_skb2;
 	*hdr = __qeth_prepare_skb(card, new_skb, ipv);
 	if (*hdr == NULL) {
 		__qeth_free_new_skb(skb, new_skb);
@@ -6336,6 +6345,42 @@ static struct ethtool_ops qeth_ethtool_o
 };
 
 static int
+qeth_hard_header_parse(struct sk_buff *skb, unsigned char *haddr)
+{
+	struct qeth_card *card;
+	struct ethhdr *eth;
+
+	card = qeth_get_card_from_dev(skb->dev);
+	if (card->options.layer2)
+		goto haveheader;
+#ifdef CONFIG_QETH_IPV6
+	/* cause of the manipulated arp constructor and the ARP
+	   flag for OSAE devices we have some nasty exceptions */
+	if (card->info.type == QETH_CARD_TYPE_OSAE) {
+		if (!card->options.fake_ll) {
+			if ((skb->pkt_type==PACKET_OUTGOING) &&
+			    (skb->protocol==ETH_P_IPV6))
+				goto haveheader;
+			else
+				return 0;
+		} else {
+			if ((skb->pkt_type==PACKET_OUTGOING) &&
+			    (skb->protocol==ETH_P_IP))
+				return 0;
+			else
+				goto haveheader;
+		}
+	}
+#endif
+	if (!card->options.fake_ll)
+		return 0;
+haveheader:
+	eth = eth_hdr(skb);
+	memcpy(haddr, eth->h_source, ETH_ALEN);
+	return ETH_ALEN;
+}
+
+static int
 qeth_netdev_init(struct net_device *dev)
 {
 	struct qeth_card *card;
@@ -6373,7 +6418,10 @@ #endif
 	if (card->options.fake_ll &&
 		(qeth_get_netdev_flags(card) & IFF_NOARP))
 			dev->hard_header = qeth_fake_header;
-	dev->hard_header_parse = NULL;
+	if (dev->type == ARPHRD_IEEE802_TR)
+		dev->hard_header_parse = NULL;
+	else
+		dev->hard_header_parse = qeth_hard_header_parse;
 	dev->set_mac_address = qeth_layer2_set_mac_address;
 	dev->flags |= qeth_get_netdev_flags(card);
 	if ((card->options.fake_broadcast) ||
-- 
1.4.2.3

