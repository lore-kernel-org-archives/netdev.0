From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH v3 -next] net/core/dev: Warn on a too-short GRO frame
Date: Sat,  2 Apr 2016 15:26:43 -0400
Message-ID: <1459625203-8637-1-git-send-email-aconole@redhat.com>
To: netdev@vger.kernel.org, Joe Perches <joe@perches.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:36403 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbcDBT0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 15:26:53 -0400
Received: by mail-qg0-f68.google.com with SMTP id n34so14230180qge.3
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 12:26:52 -0700 (PDT)
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
* Switched from WARN_ON to net_warn_ratelimited

v3:
* Amend the string to include device name as a hint

 net/core/dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index b9bcbe7..273f10d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4663,6 +4663,8 @@ static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 	if (unlikely(skb_gro_header_hard(skb, hlen))) {
 		eth = skb_gro_header_slow(skb, hlen, 0);
 		if (unlikely(!eth)) {
+			net_warn_ratelimited("%s: dropping impossible skb from %s\n",
+					     __func__, napi->dev->name);
 			napi_reuse_skb(napi, skb);
 			return NULL;
 		}
-- 
2.5.5
