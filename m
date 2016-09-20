From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v4 net-next 05/16] tcp: switch back to proper tcp_skb_cb size check in tcp_init()
Date: Mon, 19 Sep 2016 23:39:12 -0400
Message-ID: <1474342763-16715-6-git-send-email-ncardwell@google.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36103 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753200AbcITDjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 23:39:36 -0400
Received: by mail-qk0-f175.google.com with SMTP id z190so4286568qkc.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 20:39:35 -0700 (PDT)
In-Reply-To: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Revert to the tcp_skb_cb size check that tcp_init() had before commit
b4772ef879a8 ("net: use common macro for assering skb->cb[] available
size in protocol families"). As related commit 744d5a3e9fe2 ("net:
move skb->dropcount to skb->cb[]") explains, the
sock_skb_cb_check_size() mechanism was added to ensure that there is
space for dropcount, "for protocol families using it". But TCP is not
a protocol using dropcount, so tcp_init() doesn't need to provision
space for dropcount in the skb->cb[], and thus we can revert to the
older form of the tcp_skb_cb size check. Doing so allows TCP to use 4
more bytes of the skb->cb[] space.

Fixes: b4772ef879a8 ("net: use common macro for assering skb->cb[] available size in protocol families")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5b0b49c..9d1ae18 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3244,11 +3244,12 @@ static void __init tcp_init_mem(void)
 
 void __init tcp_init(void)
 {
-	unsigned long limit;
 	int max_rshare, max_wshare, cnt;
+	unsigned long limit;
 	unsigned int i;
 
-	sock_skb_cb_check_size(sizeof(struct tcp_skb_cb));
+	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) >
+		     FIELD_SIZEOF(struct sk_buff, cb));
 
 	percpu_counter_init(&tcp_sockets_allocated, 0, GFP_KERNEL);
 	percpu_counter_init(&tcp_orphan_count, 0, GFP_KERNEL);
-- 
2.8.0.rc3.226.g39d4020
