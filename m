From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] sock: avoid dirtying sk_stamp, if possible
Date: Thu, 30 Mar 2017 14:03:06 +0200
Message-ID: <f29d595f4a72d77730447be2a7c5f243fad47751.1490875313.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37514 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933271AbdC3MFc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 08:05:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_recv_ts_and_drops() unconditionally set sk->sk_stamp for
every packet, even if the SOCK_TIMESTAMP flag is not set in the
related socket.
If selinux is enabled, this cause a cache miss for every packet
since sk->sk_stamp and sk->sk_security share the same cacheline.
With this change sk_stamp is set only if the SOCK_TIMESTAMP
flag is set, and is cleared for the first packet, so that the user
perceived behavior is unchanged.

This gives up to 5% speed-up under udp-flood with small packets.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/sock.h | 5 ++++-
 net/core/sock.c    | 2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index cb241a0..8e53158 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2239,6 +2239,7 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 			      struct sk_buff *skb);
 
+#define SK_DEFAULT_STAMP (-1L * NSEC_PER_SEC)
 static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 					  struct sk_buff *skb)
 {
@@ -2249,8 +2250,10 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 
 	if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
 		__sock_recv_ts_and_drops(msg, sk, skb);
-	else
+	else if (unlikely(sk->sk_flags & SOCK_TIMESTAMP))
 		sk->sk_stamp = skb->tstamp;
+	else if (unlikely(sk->sk_stamp == SK_DEFAULT_STAMP))
+		sk->sk_stamp = 0;
 }
 
 void __sock_tx_timestamp(__u16 tsflags, __u8 *tx_flags);
diff --git a/net/core/sock.c b/net/core/sock.c
index 1a58a9d..392f9b6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2613,7 +2613,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_rcvtimeo		=	MAX_SCHEDULE_TIMEOUT;
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 
-	sk->sk_stamp = ktime_set(-1L, 0);
+	sk->sk_stamp = SK_DEFAULT_STAMP;
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	sk->sk_napi_id		=	0;
-- 
2.9.3
