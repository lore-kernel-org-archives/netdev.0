From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH v3 3/8] net: Only define skb_mark_napi_id in one
 spot instead of two
Date: Fri, 24 Mar 2017 10:08:06 -0700
Message-ID: <20170324170806.15226.83136.stgit@localhost.localdomain>
References: <20170324164902.15226.48358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net, linux-api@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33093 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936979AbdCXRIO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:08:14 -0400
In-Reply-To: <20170324164902.15226.48358.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Instead of defining two versions of skb_mark_napi_id I think it is more
readable to just match the format of the sk_mark_napi_id functions and just
wrap the contents of the function instead of defining two versions of the
function.  This way we can save a few lines of code since we only need 2 of
the ifdef/endif but needed 5 for the extra function declaration.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/net/busy_poll.h |   22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 3fcda9e70c3f..b82d6ba70a14 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -76,14 +76,6 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 
 bool sk_busy_loop(struct sock *sk, int nonblock);
 
-/* used in the NIC receive handler to mark the skb */
-static inline void skb_mark_napi_id(struct sk_buff *skb,
-				    struct napi_struct *napi)
-{
-	skb->napi_id = napi->napi_id;
-}
-
-
 #else /* CONFIG_NET_RX_BUSY_POLL */
 static inline unsigned long net_busy_loop_on(void)
 {
@@ -100,11 +92,6 @@ static inline bool sk_can_busy_loop(struct sock *sk)
 	return false;
 }
 
-static inline void skb_mark_napi_id(struct sk_buff *skb,
-				    struct napi_struct *napi)
-{
-}
-
 static inline bool busy_loop_timeout(unsigned long end_time)
 {
 	return true;
@@ -117,6 +104,15 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
+/* used in the NIC receive handler to mark the skb */
+static inline void skb_mark_napi_id(struct sk_buff *skb,
+				    struct napi_struct *napi)
+{
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	skb->napi_id = napi->napi_id;
+#endif
+}
+
 /* used in the protocol hanlder to propagate the napi_id to the socket */
 static inline void sk_mark_napi_id(struct sock *sk, const struct sk_buff *skb)
 {
