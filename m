From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 2/3] [LLC]: bogus llc packet length
Date: Fri, 28 Mar 2008 16:59:35 +0900
Message-ID: <1206691175-10905-1-git-send-email-joonwpark81@gmail.com>
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.237]:17195 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbYC1H7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 03:59:42 -0400
Received: by qb-out-0506.google.com with SMTP id e11so5538806qbe.15
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 00:59:41 -0700 (PDT)
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

discard llc packet which has bogus packet length.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/llc/llc_input.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index c40c9b2..bfd2567 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -117,8 +117,12 @@ static inline int llc_fixup_skb(struct sk_buff *skb)
 	skb_pull(skb, llc_len);
 	if (skb->protocol == htons(ETH_P_802_2)) {
 		__be16 pdulen = eth_hdr(skb)->h_proto;
-		u16 data_size = ntohs(pdulen) - llc_len;
+		s32 data_size = ntohs(pdulen) - llc_len;
 
+		if (data_size < 0 ||
+		    ((skb_tail_pointer(skb) -
+		      (u8 *)pdu) - llc_len) < data_size)
+			return 0;
 		if (unlikely(pskb_trim_rcsum(skb, data_size)))
 			return 0;
 	}
-- 
1.5.4.3

