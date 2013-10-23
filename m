From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 1/2] net: make net_get_random_once irq safe
Date: Wed, 23 Oct 2013 20:05:27 +0200
Message-ID: <20131023180527.GC2403@order.stressinduktion.org>
References: <20131023111200.GB26236@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53330 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab3JWSF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 14:05:29 -0400
Content-Disposition: inline
In-Reply-To: <20131023111200.GB26236@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I initial build non irq safe version of net_get_random_once because I
would liked to have the freedom to defer even the extraction process of
get_random_bytes until the nonblocking pool is fully seeded.

I don't think this is a good idea anymore and thus this patch makes
net_get_random_once irq safe. Now someone using net_get_random_once does
not need to care from where it is called.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2: Reword the commit message only. It looked horribly.

 include/linux/net.h | 1 -
 net/core/utils.c    | 7 ++++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index aca446b..b292a04 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -250,7 +250,6 @@ bool __net_get_random_once(void *buf, int nbytes, bool *done,
 #define ___NET_RANDOM_STATIC_KEY_INIT STATIC_KEY_INIT_FALSE
 #endif /* HAVE_JUMP_LABEL */
 
-/* BE CAREFUL: this function is not interrupt safe */
 #define net_get_random_once(buf, nbytes)				\
 	({								\
 		bool ___ret = false;					\
diff --git a/net/core/utils.c b/net/core/utils.c
index bf09371..2f737bf 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -370,16 +370,17 @@ bool __net_get_random_once(void *buf, int nbytes, bool *done,
 			   struct static_key *done_key)
 {
 	static DEFINE_SPINLOCK(lock);
+	unsigned long flags;
 
-	spin_lock_bh(&lock);
+	spin_lock_irqsave(&lock, flags);
 	if (*done) {
-		spin_unlock_bh(&lock);
+		spin_unlock_irqrestore(&lock, flags);
 		return false;
 	}
 
 	get_random_bytes(buf, nbytes);
 	*done = true;
-	spin_unlock_bh(&lock);
+	spin_unlock_irqrestore(&lock, flags);
 
 	__net_random_once_disable_jump(done_key);
 
-- 
1.8.3.1
