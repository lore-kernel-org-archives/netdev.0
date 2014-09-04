From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next v4 3/3] net: merge cases where sock_efree and
 sock_edemux are the same function
Date: Thu, 04 Sep 2014 13:32:11 -0400
Message-ID: <20140904173141.7702.95608.stgit@ahduyck-bv4.jf.intel.com>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34048 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbaIDRks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 13:40:48 -0400
In-Reply-To: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since sock_efree and sock_demux are essentially the same code for non-TCP
sockets and the case where CONFIG_INET is not defined we can combine the
code or replace the call to sock_edemux in several spots.  As a result we
can avoid a bit of unnecessary code or code duplication.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

---

v4: Added this change as a separate patch.

 include/net/sock.h |    4 ++++
 net/core/sock.c    |    4 ++--
 net/ipv4/udp.c     |    2 +-
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e02be37..ad23e80 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1575,7 +1575,11 @@ void sock_wfree(struct sk_buff *skb);
 void skb_orphan_partial(struct sk_buff *skb);
 void sock_rfree(struct sk_buff *skb);
 void sock_efree(struct sk_buff *skb);
+#ifdef CONFIG_INET
 void sock_edemux(struct sk_buff *skb);
+#else
+#define sock_edemux(skb) sock_efree(skb)
+#endif
 
 int sock_setsockopt(struct socket *sock, int level, int op,
 		    char __user *optval, unsigned int optlen);
diff --git a/net/core/sock.c b/net/core/sock.c
index d04005c..69592cb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1643,18 +1643,18 @@ void sock_efree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_efree);
 
+#ifdef CONFIG_INET
 void sock_edemux(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 
-#ifdef CONFIG_INET
 	if (sk->sk_state == TCP_TIME_WAIT)
 		inet_twsk_put(inet_twsk(sk));
 	else
-#endif
 		sock_put(sk);
 }
 EXPORT_SYMBOL(sock_edemux);
+#endif
 
 kuid_t sock_i_uid(struct sock *sk)
 {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0da3849..cd0db54 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1972,7 +1972,7 @@ void udp_v4_early_demux(struct sk_buff *skb)
 		return;
 
 	skb->sk = sk;
-	skb->destructor = sock_edemux;
+	skb->destructor = sock_efree;
 	dst = sk->sk_rx_dst;
 
 	if (dst)
