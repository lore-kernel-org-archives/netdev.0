From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] sock: fix possible NULL sk dereference in __skb_tstamp_tx
Date: Wed, 11 Mar 2015 15:43:55 -0400
Message-ID: <1426103035-24748-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, gnomes@lxorguk.ukuu.org.uk,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:40067 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbbCKTn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 15:43:59 -0400
Received: by ykq142 with SMTP id 142so5091236ykq.7
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 12:43:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Test that sk != NULL before reading sk->sk_tsflags.

Fixes: 49ca0d8bfaf3 ("net-timestamp: no-payload option")

Reported-by: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 47c3241..5bffca7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3689,9 +3689,13 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 		     struct sock *sk, int tstype)
 {
 	struct sk_buff *skb;
-	bool tsonly = sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY;
+	bool tsonly;
 
-	if (!sk || !skb_may_tx_timestamp(sk, tsonly))
+	if (!sk)
+		return;
+
+	tsonly = sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TSONLY;
+	if (!skb_may_tx_timestamp(sk, tsonly))
 		return;
 
 	if (tsonly)
-- 
2.2.0.rc0.207.ga3a616c
