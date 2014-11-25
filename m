From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH rfc 1/4] net-timestamp: pull headers for SOCK_STREAM
Date: Tue, 25 Nov 2014 12:58:03 -0500
Message-ID: <1416938286-14147-2-git-send-email-willemb@google.com>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, luto@amacapital.net, richardcochran@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:63938 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaKYR6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:58:11 -0500
Received: by mail-yh0-f50.google.com with SMTP id 29so570926yhl.9
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:58:11 -0800 (PST)
In-Reply-To: <1416938286-14147-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When returning timestamped packets on the error queue, only return
the data that the application initially sent: not the protocol
headers.

This changes the ABI. The TCP interface is new enough that it should
be safe to do so. The UDP interface could be changed analogously with

+  else if (sk->sk_protocol == IPPROTO_UDP)
+    skb_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr));

Tested with Documentation/networking/timestamping/txtimestamp -l 60 -x

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 92116df..70a8596 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3580,6 +3580,7 @@ static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 					int tstype)
 {
 	struct sock_exterr_skb *serr;
+	bool is_tcp = sk->sk_protocol == IPPROTO_TCP;
 	int err;
 
 	serr = SKB_EXT_ERR(skb);
@@ -3589,10 +3590,13 @@ static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 	serr->ee.ee_info = tstype;
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID) {
 		serr->ee.ee_data = skb_shinfo(skb)->tskey;
-		if (sk->sk_protocol == IPPROTO_TCP)
+		if (is_tcp)
 			serr->ee.ee_data -= sk->sk_tskey;
 	}
 
+	if (is_tcp)
+		skb_pull(skb, skb_transport_offset(skb) + tcp_hdrlen(skb));
+
 	err = sock_queue_err_skb(sk, skb);
 
 	if (err)
-- 
2.1.0.rc2.206.gedb03e5
