From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 2/2] Phonet: do not reply to indication reset packets
Date: Fri, 24 Oct 2008 17:55:39 +0300
Message-ID: <1224860139-23097-2-git-send-email-remi.denis-courmont@nokia.com>
Cc: Remi Denis-Courmont <redenisc@esdhcp041185.research.nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:65399 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777AbYJXPGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 11:06:00 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m9OF5dwc011105
	for <netdev@vger.kernel.org>; Fri, 24 Oct 2008 18:05:57 +0300
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Remi Denis-Courmont <redenisc@esdhcp041185.research.nokia.com>

This fixes a potential error packet loop.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/phonet.h |    1 +
 net/phonet/af_phonet.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index c9609f9..4157faa 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -72,6 +72,7 @@ struct phonetmsg {
 	} pn_msg_u;
 };
 #define PN_COMMON_MESSAGE	0xF0
+#define PN_COMMGR		0x10
 #define PN_PREFIX		0xE0 /* resource for extended messages */
 #define pn_submsg_id		pn_msg_u.base.pn_submsg_id
 #define pn_e_submsg_id		pn_msg_u.ext.pn_e_submsg_id
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index b9d97ef..defeb7a 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -261,6 +261,8 @@ static inline int can_respond(struct sk_buff *skb)
 		return 0; /* we are not the destination */
 	if (ph->pn_res == PN_PREFIX && !pskb_may_pull(skb, 5))
 		return 0;
+	if (ph->pn_res == PN_COMMGR) /* indications */
+		return 0;
 
 	ph = pn_hdr(skb); /* re-acquires the pointer */
 	pm = pn_msg(skb);
@@ -309,7 +311,8 @@ static int send_reset_indications(struct sk_buff *rskb)
 
 	return pn_raw_send(data, sizeof(data), rskb->dev,
 				pn_object(oph->pn_sdev, 0x00),
-				pn_object(oph->pn_rdev, oph->pn_robj), 0x10);
+				pn_object(oph->pn_rdev, oph->pn_robj),
+				PN_COMMGR);
 }
 
 
-- 
1.5.4.3

