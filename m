From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 6/7] net: add common accessor for setting dropcount on packets
Date: Thu, 26 Feb 2015 21:07:03 +0200
Message-ID: <1424977624-649-7-git-send-email-eyal.birger@gmail.com>
References: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, shmulik.ladkani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1424977624-649-1-git-send-email-eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As part of an effort to move skb->dropcount to skb->cb[], use
a common function in order to set dropcount in struct sk_buff.

Signed-off-by: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/sock.h     | 6 ++++++
 net/core/sock.c        | 2 +-
 net/packet/af_packet.c | 2 +-
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a2502d2..0996fe4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2081,6 +2081,12 @@ static inline int sock_intr_errno(long timeo)
 #define sock_skb_cb_check_size(size) \
 	BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sk_buff, cb))
 
+static inline void
+sock_skb_set_dropcount(const struct sock *sk, struct sk_buff *skb)
+{
+	skb->dropcount = atomic_read(&sk->sk_drops);
+}
+
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 			   struct sk_buff *skb);
 void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
diff --git a/net/core/sock.c b/net/core/sock.c
index 93c8b20..9c74fc8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -466,7 +466,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	skb_dst_force(skb);
 
 	spin_lock_irqsave(&list->lock, flags);
-	skb->dropcount = atomic_read(&sk->sk_drops);
+	sock_skb_set_dropcount(sk, skb);
 	__skb_queue_tail(list, skb);
 	spin_unlock_irqrestore(&list->lock, flags);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 120043f..6535a29 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1838,7 +1838,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.stats1.tp_packets++;
-	skb->dropcount = atomic_read(&sk->sk_drops);
+	sock_skb_set_dropcount(sk, skb);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	spin_unlock(&sk->sk_receive_queue.lock);
 	sk->sk_data_ready(sk);
-- 
2.1.4
