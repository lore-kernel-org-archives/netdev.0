From: sjur.brandeland@stericsson.com
Subject: [PATCH net-2.6 3/6] caif: Bugfix - handle mem-allocation failures
Date: Fri, 21 May 2010 14:16:09 +0200
Message-ID: <1274444172-31969-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: sjurbr@gmail.com, linus.walleij@stericsson.com,
	marcel@holtmann.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:44152 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801Ab0EUMQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 08:16:46 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R003T3RFAK140@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:22 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R006WURF8S590@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:22 +0200 (CEST)
In-reply-to: <1274444172-31969-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Discovered bugs when injecting slab allocation failures.
Add checks on all memory allocation.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfpkt_skbuff.c |   25 +++++++++++++++++--------
 net/caif/cfserl.c       |    3 ++-
 net/caif/cfsrvl.c       |    6 ++++++
 3 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 83fff2f..a6fdf89 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -238,6 +238,7 @@ int cfpkt_add_head(struct cfpkt *pkt, const void *data2, u16 len)
 	struct sk_buff *lastskb;
 	u8 *to;
 	const u8 *data = data2;
+	int ret;
 	if (unlikely(is_erronous(pkt)))
 		return -EPROTO;
 	if (unlikely(skb_headroom(skb) < len)) {
@@ -246,9 +247,10 @@ int cfpkt_add_head(struct cfpkt *pkt, const void *data2, u16 len)
 	}
 
 	/* Make sure data is writable */
-	if (unlikely(skb_cow_data(skb, 0, &lastskb) < 0)) {
+	ret = skb_cow_data(skb, 0, &lastskb);
+	if (unlikely(ret < 0)) {
 		PKT_ERROR(pkt, "cfpkt_add_head: cow failed\n");
-		return -EPROTO;
+		return ret;
 	}
 
 	to = skb_push(skb, len);
@@ -316,6 +318,8 @@ EXPORT_SYMBOL(cfpkt_setlen);
 struct cfpkt *cfpkt_create_uplink(const unsigned char *data, unsigned int len)
 {
 	struct cfpkt *pkt = cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
+	if (!pkt)
+		return NULL;
 	if (unlikely(data != NULL))
 		cfpkt_add_body(pkt, data, len);
 	return pkt;
@@ -344,12 +348,13 @@ struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
 
 	if (dst->tail + neededtailspace > dst->end) {
 		/* Create a dumplicate of 'dst' with more tail space */
+		struct cfpkt *tmppkt;
 		dstlen = skb_headlen(dst);
 		createlen = dstlen + neededtailspace;
-		tmp = pkt_to_skb(
-			cfpkt_create(createlen + PKT_PREFIX + PKT_POSTFIX));
-		if (!tmp)
+		tmppkt = cfpkt_create(createlen + PKT_PREFIX + PKT_POSTFIX);
+		if (tmppkt == NULL)
 			return NULL;
+		tmp = pkt_to_skb(tmppkt);
 		skb_set_tail_pointer(tmp, dstlen);
 		tmp->len = dstlen;
 		memcpy(tmp->data, dst->data, dstlen);
@@ -368,6 +373,7 @@ struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 pos)
 {
 	struct sk_buff *skb2;
 	struct sk_buff *skb = pkt_to_skb(pkt);
+	struct cfpkt *tmppkt;
 	u8 *split = skb->data + pos;
 	u16 len2nd = skb_tail_pointer(skb) - split;
 
@@ -381,9 +387,12 @@ struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 pos)
 	}
 
 	/* Create a new packet for the second part of the data */
-	skb2 = pkt_to_skb(
-		cfpkt_create_pfx(len2nd + PKT_PREFIX + PKT_POSTFIX,
-				 PKT_PREFIX));
+	tmppkt = cfpkt_create_pfx(len2nd + PKT_PREFIX + PKT_POSTFIX,
+				  PKT_PREFIX);
+	if (tmppkt == NULL)
+		return NULL;
+	skb2 = pkt_to_skb(tmppkt);
+
 
 	if (skb2 == NULL)
 		return NULL;
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index 06029ea..cb4325a 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -67,6 +67,8 @@ static int cfserl_receive(struct cflayer *l, struct cfpkt *newpkt)
 		layr->incomplete_frm =
 		    cfpkt_append(layr->incomplete_frm, newpkt, expectlen);
 		pkt = layr->incomplete_frm;
+		if (pkt == NULL)
+			return -ENOMEM;
 	} else {
 		pkt = newpkt;
 	}
@@ -154,7 +156,6 @@ static int cfserl_receive(struct cflayer *l, struct cfpkt *newpkt)
 			if (layr->usestx) {
 				if (tail_pkt != NULL)
 					pkt = cfpkt_append(pkt, tail_pkt, 0);
-
 				/* Start search for next STX if frame failed */
 				continue;
 			} else {
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index aff31f3..6e5b707 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -123,6 +123,12 @@ static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 			struct caif_payload_info *info;
 			u8 flow_off = SRVL_FLOW_OFF;
 			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
+			if (!pkt) {
+				pr_warning("CAIF: %s(): Out of memory\n",
+					__func__);
+				return -ENOMEM;
+			}
+
 			if (cfpkt_add_head(pkt, &flow_off, 1) < 0) {
 				pr_err("CAIF: %s(): Packet is erroneous!\n",
 					__func__);
-- 
1.6.3.3

