From: roy.qing.li@gmail.com
Subject: [RFC PATCH] xfrm: avoid to send/receive the exceeding hard lifetime data
Date: Thu, 13 Dec 2012 16:25:52 +0800
Message-ID: <1355387152-9963-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:56390 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab2LMI0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 03:26:00 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so1367671pad.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 00:26:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

If setkey sets both bh and bs as 1024, and the total send and receive package
size is 1024, then if next package size is too large, this package should be
discard.

Example, first package size is 1000, send success, then the second package
is 500, 1000+500 is larger than 1024, so the second package should be discard.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com> 
---
 net/xfrm/xfrm_input.c  |    6 +++---
 net/xfrm/xfrm_output.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ab2bb42..d0de8f3 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -178,6 +178,9 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop_unlock;
 		}
 
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
+
 		if (xfrm_state_check_expire(x)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEEXPIRED);
 			goto drop_unlock;
@@ -219,9 +222,6 @@ resume:
 
 		x->repl->advance(x, seq);
 
-		x->curlft.bytes += skb->len;
-		x->curlft.packets++;
-
 		spin_unlock(&x->lock);
 
 		XFRM_MODE_SKB_CB(skb)->protocol = nexthdr;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 95a338c..0f38cb2 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -61,6 +61,9 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		}
 
 		spin_lock_bh(&x->lock);
+
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
 		err = xfrm_state_check_expire(x);
 		if (err) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEEXPIRED);
@@ -73,9 +76,6 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 			goto error;
 		}
 
-		x->curlft.bytes += skb->len;
-		x->curlft.packets++;
-
 		spin_unlock_bh(&x->lock);
 
 		skb_dst_force(skb);
-- 
1.7.5.4
