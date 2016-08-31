From: fgao@ikuai8.com
Subject: [PATCH net] rps: flow_dissector: Fix uninitialized flow_keys used in __skb_get_hash possibly
Date: Wed, 31 Aug 2016 10:56:19 +0800
Message-ID: <1472612179-23601-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, fgao@ikuai8.com
To: davem@davemloft.net, philipp@redfish-solutions.com,
        tom@herbertland.com, aduyck@mirantis.com, amir@vadai.me,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG181.QQ.COM ([119.147.193.88]:48467 "EHLO smtpbg181.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755539AbcHaC5M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 22:57:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The original codes depend on that the function parameters are evaluated from
left to right. But the parameter's evaluation order is not defined in C
standard actually.

When flow_keys_have_l4(&keys) is invoked before ___skb_get_hash(skb, &keys,
hashrnd) with some compilers or environment, the keys passed to
flow_keys_have_l4 is not initialized.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
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
