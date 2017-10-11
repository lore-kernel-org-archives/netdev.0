From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] net: dsa: tag_brcm: Indicate to master netdevice port + queue
Date: Wed, 11 Oct 2017 10:57:49 -0700
Message-ID: <20171011175752.22030-3-f.fainelli@gmail.com>
References: <20171011175752.22030-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:37340 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757631AbdJKR7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:59:36 -0400
Received: by mail-qt0-f194.google.com with SMTP id 32so671176qtp.4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:59:36 -0700 (PDT)
In-Reply-To: <20171011175752.22030-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to tell the DSA master network device doing the actual
transmission what the desired switch port and queue number is for it to
resolve that to the internal transmit queue it is mapped to.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h  | 5 +++++
 net/dsa/tag_brcm.c | 6 ++++++
 2 files changed, 11 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 40a709a0754d..ce1d622734d7 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -516,4 +516,9 @@ static inline int call_dsa_notifiers(unsigned long val, struct net_device *dev,
 }
 #endif
 
+/* Broadcom tag specific helpers to insert and extract queue/port number */
+#define BRCM_TAG_SET_PORT_QUEUE(p, q)	((p) << 8 | q)
+#define BRCM_TAG_GET_PORT(v)		((v) >> 8)
+#define BRCM_TAG_GET_QUEUE(v)		((v) & 0xff)
+
 #endif
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 8e4bdb9d9ae3..cc4f472fbd77 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -86,6 +86,12 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 		brcm_tag[2] = BRCM_IG_DSTMAP2_MASK;
 	brcm_tag[3] = (1 << p->dp->index) & BRCM_IG_DSTMAP1_MASK;
 
+	/* Now tell the master network device about the desired output queue
+	 * as well
+	 */
+	skb_set_queue_mapping(skb, BRCM_TAG_SET_PORT_QUEUE(p->dp->index,
+							   queue));
+
 	return skb;
 }
 
-- 
2.9.3
