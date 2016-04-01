From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v2 -next] net/core/dev: Warn on a too-short GRO frame
Date: Fri,  1 Apr 2016 15:58:15 -0400
Message-ID: <1459540695-24404-1-git-send-email-aconole@redhat.com>
To: netdev@vger.kernel.org, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33167 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbcDAT6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 15:58:38 -0400
Received: by mail-qk0-f195.google.com with SMTP id q184so5045552qkb.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 12:58:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

When signaling that a GRO frame is ready to be processed, the network stack
correctly checks length and aborts processing when a frame is less than 14
bytes. However, such a condition is really indicative of a broken driver,
and should be loudly signaled, rather than silently dropped as the case is
today.

Convert the condition to use net_warn_ratelimited() to ensure the stack
loudly complains about such broken drivers.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
v2:
* Convert from WARN_ON to net_warn_ratelimited

 net/core/dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index b9bcbe7..1be269e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4663,6 +4663,8 @@ static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 	if (unlikely(skb_gro_header_hard(skb, hlen))) {
 		eth = skb_gro_header_slow(skb, hlen, 0);
 		if (unlikely(!eth)) {
+			net_warn_ratelimited("%s: dropping impossible skb\n",
+					     __func__);
 			napi_reuse_skb(napi, skb);
 			return NULL;
 		}
-- 
2.5.5
