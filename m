From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_is_gso_v6() requires skb_is_gso()
Date: Sun, 29 Sep 2013 01:21:32 -0700
Message-ID: <1380442892.3596.22.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:62636 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910Ab3I2IVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 04:21:33 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so4573912pad.9
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 01:21:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

bnx2x makes a dangerous use of skb_is_gso_v6().

It should first make sure skb is a gso packet

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   18 +++++++-------
 include/linux/skbuff.h                          |    1 
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 61726af..0c7fb1e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3256,14 +3256,16 @@ static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 	if (prot == IPPROTO_TCP)
 		rc |= XMIT_CSUM_TCP;
 
-	if (skb_is_gso_v6(skb)) {
-		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP);
-		if (rc & XMIT_CSUM_ENC)
-			rc |= XMIT_GSO_ENC_V6;
-	} else if (skb_is_gso(skb)) {
-		rc |= (XMIT_GSO_V4 | XMIT_CSUM_TCP);
-		if (rc & XMIT_CSUM_ENC)
-			rc |= XMIT_GSO_ENC_V4;
+	if (skb_is_gso(skb)) {
+		if (skb_is_gso_v6(skb)) {
+			rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP);
+			if (rc & XMIT_CSUM_ENC)
+				rc |= XMIT_GSO_ENC_V6;
+		} else {
+			rc |= (XMIT_GSO_V4 | XMIT_CSUM_TCP);
+			if (rc & XMIT_CSUM_ENC)
+				rc |= XMIT_GSO_ENC_V4;
+		}
 	}
 
 	return rc;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d..d48fde30 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2783,6 +2783,7 @@ static inline bool skb_is_gso(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_size;
 }
 
+/* Note: Should be called only if skb_is_gso(skb) is true */
 static inline bool skb_is_gso_v6(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
