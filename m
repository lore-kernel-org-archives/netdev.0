From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH v5 net-next 2/4] tcp:  refactor struct tcp_skb_cb
Date: Tue, 4 Aug 2015 18:39:06 -0700
Message-ID: <1438738748-1756255-3-git-send-email-brakmo@fb.com>
References: <1438738748-1756255-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:11373 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751856AbbHEBjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 21:39:16 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t751c621016300
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2015 18:39:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1w38mc03cb-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 18:39:15 -0700
Received: from facebook.com (2401:db00:20:a00f:face:0:16:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 c5a3d9603b1211e581c924be05956610-1ba006b0 for <netdev@vger.kernel.org>;	Tue,
 04 Aug 2015 18:39:11 -0700
In-Reply-To: <1438738748-1756255-1-git-send-email-brakmo@fb.com>
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
---
 include/net/tcp.h | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0121529..a086a98 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -755,11 +755,16 @@ struct tcp_skb_cb {
 	/* 1 byte hole */
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
1.8.5.6
