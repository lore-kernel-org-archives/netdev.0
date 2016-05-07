From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next] tcp: refactor struct tcp_skb_cb
Date: Fri, 6 May 2016 20:35:35 -0700
Message-ID: <1462592135-1905403-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:15408 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752735AbcEGDfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 23:35:39 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u473WMNE006562
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 20:35:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22s81u82ak-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 06 May 2016 20:35:38 -0700
Received: from facebook.com (2401:db00:11:d037:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 c307a38c140411e6af730002c95209d8-993e9c50 for <netdev@vger.kernel.org>;	Fri,
 06 May 2016 20:35:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor tcp_skb_cb to create two overlaping areas to store
state for incoming or outgoing skbs based on comments by
Neal Cardwell to tcp_nv patch:

   AFAICT this patch would not require an increase in the size of
   sk_buff cb[] if it were to take advantage of the fact that the
   tcp_skb_cb header.h4 and header.h6 fields are only used in the packet
   reception code path, and this in_flight field is only used on the
   transmit side.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index dc588c3..c9ab561 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -765,11 +765,16 @@ struct tcp_skb_cb {
 			unused:6;
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
-		struct inet_skb_parm	h4;
+		struct {
+			/* There is space for up to 20 bytes */
+		} tx;   /* only used for outgoing skbs */
+		union {
+			struct inet_skb_parm	h4;
 #if IS_ENABLED(CONFIG_IPV6)
-		struct inet6_skb_parm	h6;
+			struct inet6_skb_parm	h6;
 #endif
-	} header;	/* For incoming frames		*/
+		} header;	/* For incoming skbs */
+	};
 };
 
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
-- 
2.8.0.rc2
