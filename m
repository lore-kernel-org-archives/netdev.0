From: fgao@ikuai8.com
Subject: [PATCH v2 net] rps: flow_dissector: Fix uninitialized flow_keys used in __skb_get_hash possibly
Date: Wed, 31 Aug 2016 14:15:05 +0800
Message-ID: <1472624105-5163-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, tom@herbertland.com, aduyck@mirantis.com,
        amir@vadai.me, edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG19.QQ.COM ([183.60.61.236]:45362 "EHLO smtpbg320.qq.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758982AbcHaGQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 02:16:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The original codes depend on that the function parameters are evaluated from
left to right. But the parameter's evaluation order is not defined in C
standard actually.

When flow_keys_have_l4(&keys) is invoked before ___skb_get_hash(skb, &keys,
hashrnd) with some compilers or environment, the keys passed to
flow_keys_have_l4 is not initialized.

Fixes: 6db61d79c1e1 ("flow_dissector: Ignore flow dissector return value from ___skb_get_hash")

Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Add fixed commit description according to Eric's advice
 v1: Inital patch

 net/core/flow_dissector.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 61ad43f..52742a0 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -680,11 +680,13 @@ EXPORT_SYMBOL_GPL(__skb_get_hash_symmetric);
 void __skb_get_hash(struct sk_buff *skb)
 {
 	struct flow_keys keys;
+	u32 hash;
 
 	__flow_hash_secret_init();
 
-	__skb_set_sw_hash(skb, ___skb_get_hash(skb, &keys, hashrnd),
-			  flow_keys_have_l4(&keys));
+	hash = ___skb_get_hash(skb, &keys, hashrnd);
+
+	__skb_set_sw_hash(skb, hash, flow_keys_have_l4(&keys));
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
-- 
1.9.1
