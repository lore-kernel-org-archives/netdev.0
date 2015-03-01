From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v3 7/7] net: move skb->dropcount to skb->cb[]
Date: Sun,  1 Mar 2015 14:58:31 +0200
Message-ID: <1425214711-9562-8-git-send-email-eyal.birger@gmail.com>
References: <1425214711-9562-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, shmulik.ladkani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425214711-9562-1-git-send-email-eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 977750076d98 ("af_packet: add interframe drop cmsg (v6)")
unionized skb->mark and skb->dropcount in order to allow recording
of the socket drop count while maintaining struct sk_buff size.

skb->dropcount was introduced since there was no available room
in skb->cb[] in packet sockets. However, its introduction led to
the inability to export skb->mark, or any other aliased field to
userspace if so desired.

Moving the dropcount metric to skb->cb[] eliminates this problem
at the expense of 4 bytes less in skb->cb[] for protocol families
using it.

Signed-off-by: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/skbuff.h |  2 --
 include/net/sock.h     | 18 ++++++++++++++++--
 net/socket.c           |  4 ++--
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d898b32..bba1330 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -492,7 +492,6 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
   *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
  *	@mark: Generic packet mark
- *	@dropcount: total number of sk_receive_queue overflows
  *	@vlan_proto: vlan encapsulation protocol
  *	@vlan_tci: vlan tag control information
  *	@inner_protocol: Protocol (encapsulation)
@@ -641,7 +640,6 @@ struct sk_buff {
 #endif
 	union {
 		__u32		mark;
-		__u32		dropcount;
 		__u32		reserved_tailroom;
 	};
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 0996fe4..38369d3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2078,13 +2078,27 @@ static inline int sock_intr_errno(long timeo)
 	return timeo == MAX_SCHEDULE_TIMEOUT ? -ERESTARTSYS : -EINTR;
 }
 
+struct sock_skb_cb {
+	u32 dropcount;
+};
+
+/* Store sock_skb_cb at the end of skb->cb[] so protocol families
+ * using skb->cb[] would keep using it directly and utilize its
+ * alignement guarantee.
+ */
+#define SOCK_SKB_CB_OFFSET ((FIELD_SIZEOF(struct sk_buff, cb) - \
+			    sizeof(struct sock_skb_cb)))
+
+#define SOCK_SKB_CB(__skb) ((struct sock_skb_cb *)((__skb)->cb + \
+			    SOCK_SKB_CB_OFFSET))
+
 #define sock_skb_cb_check_size(size) \
-	BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sk_buff, cb))
+	BUILD_BUG_ON((size) > SOCK_SKB_CB_OFFSET)
 
 static inline void
 sock_skb_set_dropcount(const struct sock *sk, struct sk_buff *skb)
 {
-	skb->dropcount = atomic_read(&sk->sk_drops);
+	SOCK_SKB_CB(skb)->dropcount = atomic_read(&sk->sk_drops);
 }
 
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
diff --git a/net/socket.c b/net/socket.c
index bbedbfc..b78cf60 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -731,9 +731,9 @@ EXPORT_SYMBOL_GPL(__sock_recv_wifi_status);
 static inline void sock_recv_drops(struct msghdr *msg, struct sock *sk,
 				   struct sk_buff *skb)
 {
-	if (sock_flag(sk, SOCK_RXQ_OVFL) && skb && skb->dropcount)
+	if (sock_flag(sk, SOCK_RXQ_OVFL) && skb && SOCK_SKB_CB(skb)->dropcount)
 		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL,
-			sizeof(__u32), &skb->dropcount);
+			sizeof(__u32), &SOCK_SKB_CB(skb)->dropcount);
 }
 
 void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
-- 
2.1.4
