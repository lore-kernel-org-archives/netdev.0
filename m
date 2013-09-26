From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 3/7] net: introduce new macro net_get_random_once
Date: Fri, 27 Sep 2013 01:32:19 +0200
Message-ID: <1380238343-4318-4-git-send-email-hannes@stressinduktion.org>
References: <1380238343-4318-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54001 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926Ab3IZXcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 19:32:35 -0400
In-Reply-To: <1380238343-4318-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_get_random_once is a new macro which handles the initialization
of secret keys. It is possible to call it in the fast path. Only the
initialization depends on the spinlock and is rather slow. Otherwise
it should get used just before the key is used to delay the entropy
extration as late as possible to get better randomness. It returns true
if the key got initialized.

Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/net.h | 14 ++++++++++++++
 net/core/utils.c    | 21 +++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index 4f27575..d14fad5 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -243,6 +243,20 @@ do {								\
 #define net_random()		prandom_u32()
 #define net_srandom(seed)	prandom_seed((__force u32)(seed))
 
+bool __net_get_random_once(void *buf, int nbytes, bool *done);
+
+/* BE CAREFUL: this function is not interrupt safe */
+#define net_get_random_once(buf, nbytes)				\
+	({								\
+		static bool ___done = false;				\
+		bool ___ret = false;					\
+		if (unlikely(!___done))					\
+			___ret = __net_get_random_once(buf,		\
+						       nbytes,		\
+						       &___done);	\
+		___ret;							\
+	})
+
 extern int   	     kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 				    struct kvec *vec, size_t num, size_t len);
 extern int   	     kernel_recvmsg(struct socket *sock, struct msghdr *msg,
diff --git a/net/core/utils.c b/net/core/utils.c
index aa88e23..b420547 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -338,3 +338,24 @@ void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 				  csum_unfold(*sum)));
 }
 EXPORT_SYMBOL(inet_proto_csum_replace16);
+
+bool __net_get_random_once(void *buf, int nbytes, bool *done)
+{
+	static DEFINE_SPINLOCK(lock);
+
+	spin_lock_bh(&lock);
+	if (*done) {
+		spin_unlock_bh(&lock);
+		return false;
+	}
+
+	get_random_bytes(buf, nbytes);
+	/* Make sure random data is published before toggeling done.
+	 * There is no corresponding rmb.
+	 */
+	smp_wmb();
+	*done = true;
+	spin_unlock_bh(&lock);
+	return true;
+}
+EXPORT_SYMBOL(__net_get_random_once);
-- 
1.8.3.1
