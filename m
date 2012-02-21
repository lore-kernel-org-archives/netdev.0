From: Alexandru Juncu <ajuncu@ixiacom.com>
Subject: [PATCH] llc: fix skb_over_panic due to bogus RX packet
Date: Tue, 21 Feb 2012 12:13:16 +0200
Message-ID: <1329819196-25176-1-git-send-email-ajuncu@ixiacom.com>
Cc: dbaluta@ixiacom.com, alexj@rosedu.org,
	Alexandru Juncu <ajuncu@ixiacom.com>
To: acme@ghostprotocols.net, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63566 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253Ab2BUKNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 05:13:22 -0500
Received: by eekc14 with SMTP id c14so2604350eek.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 02:13:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Verify size of received packet so that no illegal access is made.

Signed-off-by: Alexandru Juncu <ajuncu@ixiacom.com>
---
 include/net/llc_pdu.h |   10 ++++++++--
 net/llc/llc_s_ac.c    |   12 +++++++++---
 net/llc/llc_station.c |    4 +++-
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/net/llc_pdu.h b/include/net/llc_pdu.h
index f57e7d4..9c3ed6c 100644
--- a/include/net/llc_pdu.h
+++ b/include/net/llc_pdu.h
@@ -14,6 +14,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/if_tr.h>
+#include <net/sock.h>
 
 /* Lengths of frame formats */
 #define LLC_PDU_LEN_I	4       /* header and 2 control bytes */
@@ -336,7 +337,7 @@ static inline void llc_pdu_init_as_test_cmd(struct sk_buff *skb)
  *
  *	Builds a pdu frame as a TEST response.
  */
-static inline void llc_pdu_init_as_test_rsp(struct sk_buff *skb,
+static inline int llc_pdu_init_as_test_rsp(struct sk_buff *skb,
 					    struct sk_buff *ev_skb)
 {
 	struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
@@ -348,10 +349,15 @@ static inline void llc_pdu_init_as_test_rsp(struct sk_buff *skb,
 		struct llc_pdu_un *ev_pdu = llc_pdu_un_hdr(ev_skb);
 		int dsize;
 
-		dsize = ntohs(eth_hdr(ev_skb)->h_proto) - 3;
+		dsize = ntohs(eth_hdr(ev_skb)->h_proto);
+		if((dsize < 3) || (dsize > skb_tailroom(skb))) {
+			return -EINVAL;
+		}
+		dsize -= 3;
 		memcpy(((u8 *)pdu) + 3, ((u8 *)ev_pdu) + 3, dsize);
 		skb_put(skb, dsize);
 	}
+	return 0;
 }
 
 /* LLC Type 1 XID command/response information fields format */
diff --git a/net/llc/llc_s_ac.c b/net/llc/llc_s_ac.c
index a94bd56..0972590 100644
--- a/net/llc/llc_s_ac.c
+++ b/net/llc/llc_s_ac.c
@@ -158,12 +158,18 @@ int llc_sap_action_send_test_r(struct llc_sap *sap, struct sk_buff *skb)
 		goto out;
 	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, sap->laddr.lsap, dsap,
 			    LLC_PDU_RSP);
-	llc_pdu_init_as_test_rsp(nskb, skb);
+	rc = llc_pdu_init_as_test_rsp(nskb, skb);
+	if (unlikely(rc))
+		goto free;
 	rc = llc_mac_hdr_init(nskb, mac_sa, mac_da);
-	if (likely(!rc))
-		rc = dev_queue_xmit(nskb);
+	if (unlikely(rc))
+		goto free;
+	rc = dev_queue_xmit(nskb);
 out:
 	return rc;
+free:
+	kfree_skb(nskb);
+	goto out;
 }
 
 /**
diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index cf4aea3..f3a92d1 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -314,7 +314,9 @@ static int llc_station_ac_send_test_r(struct sk_buff *skb)
 	llc_pdu_decode_sa(skb, mac_da);
 	llc_pdu_decode_ssap(skb, &dsap);
 	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, 0, dsap, LLC_PDU_RSP);
-	llc_pdu_init_as_test_rsp(nskb, skb);
+	rc = llc_pdu_init_as_test_rsp(nskb, skb);
+	if (unlikely(rc))
+		goto free;
 	rc = llc_mac_hdr_init(nskb, skb->dev->dev_addr, mac_da);
 	if (unlikely(rc))
 		goto free;
-- 
1.7.5.4
