From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] atm: remove an unnecessary loop
Date: Wed, 11 Jan 2017 21:02:01 -0800
Message-ID: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: mhocko@kernel.org, romieu@fr.zoreil.com, 3chas3@gmail.com,
        andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33237 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750700AbdALFC1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 00:02:27 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so1593681pfg.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 21:02:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_tx() is already inside a wait loop for a successful skb
allocation, this loop inside alloc_tx() is quite unnecessary
and actually problematic.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/atm/common.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/atm/common.c b/net/atm/common.c
index a3ca922..7ec3bbc 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -72,10 +72,11 @@ static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
 			 sk_wmem_alloc_get(sk), size, sk->sk_sndbuf);
 		return NULL;
 	}
-	while (!(skb = alloc_skb(size, GFP_KERNEL)))
-		schedule();
-	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
-	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+	skb = alloc_skb(size, GFP_KERNEL);
+	if (skb) {
+		pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
+		atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+	}
 	return skb;
 }
 
-- 
2.5.5
