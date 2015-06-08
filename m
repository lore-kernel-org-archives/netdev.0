From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net: replace last open coded skb_orphan_frags with function call
Date: Mon,  8 Jun 2015 11:53:08 -0400
Message-ID: <1433778788-16971-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, mst@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:36115 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747AbbFHPxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 11:53:16 -0400
Received: by yked142 with SMTP id d142so53952819yke.3
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 08:53:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Commit 70008aa50e92 ("skbuff: convert to skb_orphan_frags") replaced
open coded tests of SKBTX_DEV_ZEROCOPY and skb_copy_ubufs with calls
to helper function skb_orphan_frags. Apply that to the last remaining
open coded site.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/dev.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0602e91..6778a99 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1723,15 +1723,8 @@ EXPORT_SYMBOL_GPL(is_skb_forwardable);
 
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 {
-	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
-		if (skb_copy_ubufs(skb, GFP_ATOMIC)) {
-			atomic_long_inc(&dev->rx_dropped);
-			kfree_skb(skb);
-			return NET_RX_DROP;
-		}
-	}
-
-	if (unlikely(!is_skb_forwardable(dev, skb))) {
+	if (skb_orphan_frags(skb, GFP_ATOMIC) ||
+	    unlikely(!is_skb_forwardable(dev, skb))) {
 		atomic_long_inc(&dev->rx_dropped);
 		kfree_skb(skb);
 		return NET_RX_DROP;
-- 
2.2.0.rc0.207.ga3a616c
