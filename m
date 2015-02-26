From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v2 5/7] net: use common macro for assering skb->cb[] available size in protocol families
Date: Thu, 26 Feb 2015 21:07:02 +0200
Message-ID: <1424977624-649-6-git-send-email-eyal.birger@gmail.com>
References: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:39412 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523AbbBZTHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 14:07:37 -0500
In-Reply-To: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of an effort to move skb->dropcount to skb->cb[] use a common
macro in protocol families using skb->cb[] for ancillary data to
validate available room in skb->cb[].

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 include/net/sock.h           | 3 +++
 net/bluetooth/af_bluetooth.c | 3 +--
 net/can/bcm.c                | 2 +-
 net/can/raw.c                | 6 +++---
 net/ipv4/af_inet.c           | 2 +-
 net/ipv4/tcp.c               | 3 +--
 net/ipv6/af_inet6.c          | 2 +-
 net/packet/af_packet.c       | 3 +--
 net/sctp/protocol.c          | 3 +--
 9 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ab186b1..a2502d2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2078,6 +2078,9 @@ static inline int sock_intr_errno(long timeo)
 	return timeo == MAX_SCHEDULE_TIMEOUT ? -ERESTARTSYS : -EINTR;
 }
 
+#define sock_skb_cb_check_size(size) \
+	BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sk_buff, cb))
+
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 			   struct sk_buff *skb);
 void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index ce22e0c..4b904c9 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -711,10 +711,9 @@ EXPORT_SYMBOL_GPL(bt_debugfs);
 
 static int __init bt_init(void)
 {
-	struct sk_buff *skb;
 	int err;
 
-	BUILD_BUG_ON(sizeof(struct bt_skb_cb) > sizeof(skb->cb));
+	sock_skb_cb_check_size(sizeof(struct bt_skb_cb));
 
 	BT_INFO("Core ver %s", VERSION);
 
diff --git a/net/can/bcm.c b/net/can/bcm.c
index ee9ffd9..d559f92 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -328,7 +328,7 @@ static void bcm_send_to_user(struct bcm_op *op, struct bcm_msg_head *head,
 	 *  containing the interface index.
 	 */
 
-	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct sockaddr_can));
+	sock_skb_cb_check_size(sizeof(struct sockaddr_can));
 	addr = (struct sockaddr_can *)skb->cb;
 	memset(addr, 0, sizeof(*addr));
 	addr->can_family  = AF_CAN;
diff --git a/net/can/raw.c b/net/can/raw.c
index 00c13ef..94601b7 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -95,8 +95,8 @@ struct raw_sock {
  */
 static inline unsigned int *raw_flags(struct sk_buff *skb)
 {
-	BUILD_BUG_ON(sizeof(skb->cb) <= (sizeof(struct sockaddr_can) +
-					 sizeof(unsigned int)));
+	sock_skb_cb_check_size(sizeof(struct sockaddr_can) +
+			       sizeof(unsigned int));
 
 	/* return pointer after struct sockaddr_can */
 	return (unsigned int *)(&((struct sockaddr_can *)skb->cb)[1]);
@@ -135,7 +135,7 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 	 *  containing the interface index.
 	 */
 
-	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct sockaddr_can));
+	sock_skb_cb_check_size(sizeof(struct sockaddr_can));
 	addr = (struct sockaddr_can *)skb->cb;
 	memset(addr, 0, sizeof(*addr));
 	addr->can_family  = AF_CAN;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d2e49ba..4ce954c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1675,7 +1675,7 @@ static int __init inet_init(void)
 	struct list_head *r;
 	int rc = -EINVAL;
 
-	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > FIELD_SIZEOF(struct sk_buff, cb));
+	sock_skb_cb_check_size(sizeof(struct inet_skb_parm));
 
 	rc = proto_register(&tcp_prot, 1);
 	if (rc)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9d72a0f..4b57ea8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3005,12 +3005,11 @@ static void __init tcp_init_mem(void)
 
 void __init tcp_init(void)
 {
-	struct sk_buff *skb = NULL;
 	unsigned long limit;
 	int max_rshare, max_wshare, cnt;
 	unsigned int i;
 
-	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
+	sock_skb_cb_check_size(sizeof(struct tcp_skb_cb));
 
 	percpu_counter_init(&tcp_sockets_allocated, 0, GFP_KERNEL);
 	percpu_counter_init(&tcp_orphan_count, 0, GFP_KERNEL);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e8c4400..6bafcc2 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -824,7 +824,7 @@ static int __init inet6_init(void)
 	struct list_head *r;
 	int err = 0;
 
-	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > FIELD_SIZEOF(struct sk_buff, cb));
+	sock_skb_cb_check_size(sizeof(struct inet6_skb_parm));
 
 	/* Register the socket-side information for inet6_create.  */
 	for (r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9d571bc..120043f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1810,8 +1810,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 		skb = nskb;
 	}
 
-	BUILD_BUG_ON(sizeof(*PACKET_SKB_CB(skb)) + MAX_ADDR_LEN - 8 >
-		     sizeof(skb->cb));
+	sock_skb_cb_check_size(sizeof(*PACKET_SKB_CB(skb)) + MAX_ADDR_LEN - 8);
 
 	sll = &PACKET_SKB_CB(skb)->sa.ll;
 	sll->sll_family = AF_PACKET;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 8f34b27..53b7acd 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1322,8 +1322,7 @@ static __init int sctp_init(void)
 	int max_share;
 	int order;
 
-	BUILD_BUG_ON(sizeof(struct sctp_ulpevent) >
-		     sizeof(((struct sk_buff *) 0)->cb));
+	sock_skb_cb_check_size(sizeof(struct sctp_ulpevent));
 
 	/* Allocate bind_bucket and chunk caches. */
 	status = -ENOBUFS;
-- 
2.1.4
