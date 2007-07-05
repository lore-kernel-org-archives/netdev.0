From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] tg3: Fix VLAN tag corruption
Date: Thu, 05 Jul 2007 14:54:33 -0700
Message-ID: <1183672474.24582.9.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Robert Olsson" <Robert.Olsson@data.slu.se>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Gagan Arneja" <gaagaan@gmail.com>, netdev@vger.kernel.org,
	"Rick Jones" <rick.jones2@hp.com>,
	"Sridhar Samudrala" <sri@us.ibm.com>,
	"David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "jamal" <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2959 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757992AbXGEVyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 17:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a VLAN tag corruption bug introduced in the tx batching
modifications.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index be03cbd..cef9cbe 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3896,8 +3896,15 @@ struct tg3_tx_cbdata {
 static int tg3_prep_bug_frame(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
+	struct tg3 *tp = netdev_priv(dev);
+	u32 vlantag = 0;
+
+#if TG3_VLAN_TAG_USED
+	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
+		vlantag = (TXD_FLAG_VLAN | (vlan_tx_tag_get(skb) << 16));
+#endif
 
-	cb->base_flags = 0;
+	cb->base_flags = vlantag;
 	cb->mss = skb_shinfo(skb)->gso_size;
 	if (cb->mss != 0) {
 		if (skb_header_cloned(skb) &&
@@ -3919,8 +3926,15 @@ static int tg3_prep_bug_frame(struct sk_buff *skb, struct net_device *dev)
 static int tg3_prep_frame(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
+	struct tg3 *tp = netdev_priv(dev);
+	u32 vlantag = 0;
+
+#if TG3_VLAN_TAG_USED
+	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
+		vlantag = (TXD_FLAG_VLAN | (vlan_tx_tag_get(skb) << 16));
+#endif
 
-	cb->base_flags = 0;
+	cb->base_flags = vlantag;
 	cb->mss = skb_shinfo(skb)->gso_size;
 	if (cb->mss != 0) {
 		int tcp_opt_len, ip_tcp_len;
@@ -3985,13 +3999,6 @@ static int tg3_enqueue(struct sk_buff *skb, struct net_device *dev)
 	u32 len, entry;
 	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
 
-
-#if TG3_VLAN_TAG_USED
-	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
-		cb->base_flags |= (TXD_FLAG_VLAN |
-			       (vlan_tx_tag_get(skb) << 16));
-#endif
-
 	entry = tp->tx_prod;
 	len = skb_headlen(skb);
 	/* Queue skb data, a.k.a. the main skb fragment. */
@@ -4187,11 +4194,6 @@ static int tg3_enqueue_buggy(struct sk_buff *skb, struct net_device *dev)
 			}
 		}
 	}
-#if TG3_VLAN_TAG_USED
-	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
-		cb->base_flags |= (TXD_FLAG_VLAN |
-			       (vlan_tx_tag_get(skb) << 16));
-#endif
 	len = skb_headlen(skb);
 	entry = tp->tx_prod;
 


