From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: increment sk_drops on syn_recv state
Date: Wed, 24 Aug 2016 08:50:24 -0700
Message-ID: <1472053824.14381.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Julien Goodwin <julieng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36603 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754880AbcHXPuv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:50:51 -0400
Received: by mail-pf0-f193.google.com with SMTP id y134so1443781pfg.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 08:50:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP MD5 mismatches do increment sk_drops counter in all states but
SYN_RECV.

This is very unlikely to happen in the real world, but worth adding
to help diagnostics.

We increase the parent (listener) sk_drops.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |    1 +
 net/ipv6/tcp_ipv6.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 32b048e524d6773538918eca175b3f422f9c2aa7..436d978c6c3955dfa9a55f86b1412624ba2ed9fa 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1602,6 +1602,7 @@ process:
 
 		sk = req->rsk_listener;
 		if (unlikely(tcp_v4_inbound_md5_hash(sk, skb))) {
+			sk_drops_add(sk, skb);
 			reqsk_put(req);
 			goto discard_it;
 		}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e0f46439e391f2a8b2fac2e13b6f61a11c082715..ac0ed7bda4067a2630cc1cbb546ced3f3ded4c2c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1409,6 +1409,7 @@ process:
 		sk = req->rsk_listener;
 		tcp_v6_fill_cb(skb, hdr, th);
 		if (tcp_v6_inbound_md5_hash(sk, skb)) {
+			sk_drops_add(sk, skb);
 			reqsk_put(req);
 			goto discard_it;
 		}
