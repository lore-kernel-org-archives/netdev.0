From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] tun: do not block BH again in tun_flow_cleanup()
Date: Fri, 20 Oct 2017 11:29:55 -0700
Message-ID: <20171020182957.32729-2-edumazet@google.com>
References: <20171020182957.32729-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jason Wang <jasowang@redhat.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:56509 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752369AbdJTSaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:30:03 -0400
Received: by mail-pf0-f193.google.com with SMTP id b85so12183655pfj.13
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:30:03 -0700 (PDT)
In-Reply-To: <20171020182957.32729-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun_flow_cleanup() being a timer callback, it is already
running in BH context.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3b41c36eae904fec5d11f51ed9fde0e060bba27e..f9541f7f9fb7592b50ac818702006f4f1042b448 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -454,7 +454,7 @@ static void tun_flow_cleanup(unsigned long data)
 
 	tun_debug(KERN_INFO, tun, "tun_flow_cleanup\n");
 
-	spin_lock_bh(&tun->lock);
+	spin_lock(&tun->lock);
 	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++) {
 		struct tun_flow_entry *e;
 		struct hlist_node *n;
@@ -472,7 +472,7 @@ static void tun_flow_cleanup(unsigned long data)
 
 	if (count)
 		mod_timer(&tun->flow_gc_timer, round_jiffies_up(next_timer));
-	spin_unlock_bh(&tun->lock);
+	spin_unlock(&tun->lock);
 }
 
 static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
-- 
2.15.0.rc0.271.g36b669edcc-goog
