From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net 2/2] tcp: mark skbs with SCM_TIMESTAMPING_OPT_STATS
Date: Sat, 18 Mar 2017 17:03:00 -0400
Message-ID: <20170318210300.163288-2-soheil.kdev@gmail.com>
References: <20170318210300.163288-1-soheil.kdev@gmail.com>
Cc: zzoru007@gmail.com, Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35504 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751181AbdCRXAA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 19:00:00 -0400
Received: by mail-qk0-f195.google.com with SMTP id o135so13980833qke.2
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 15:59:59 -0700 (PDT)
In-Reply-To: <20170318210300.163288-1-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

SOF_TIMESTAMPING_OPT_STATS can be enabled and disabled
while packets are collected on the error queue.
So, checking SOF_TIMESTAMPING_OPT_STATS in sk->sk_tsflags
is not enough to safely assume that the skb contains
OPT_STATS data.

Add a bit in sock_exterr_skb to indicate whether the
skb contains opt_stats data.

Fixes: 1c885808e456 ("tcp: SOF_TIMESTAMPING_OPT_STATS option for SO_TIMESTAMPING")
Reported-by: JongHwan Kim <zzoru007@gmail.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/errqueue.h |  2 ++
 net/core/skbuff.c        | 17 +++++++++++------
 net/socket.c             |  2 +-
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/linux/errqueue.h b/include/linux/errqueue.h
index 9ca23fcfb5d7..6fdfc884fdeb 100644
--- a/include/linux/errqueue.h
+++ b/include/linux/errqueue.h
@@ -20,6 +20,8 @@ struct sock_exterr_skb {
 	struct sock_extended_err	ee;
 	u16				addr_offset;
 	__be16				port;
+	u8				opt_stats:1,
+					unused:7;
 };
 
 #endif
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b1fbd1958eb6..9f781092fda9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3793,16 +3793,20 @@ EXPORT_SYMBOL(skb_clone_sk);
 
 static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 					struct sock *sk,
-					int tstype)
+					int tstype,
+					bool opt_stats)
 {
 	struct sock_exterr_skb *serr;
 	int err;
 
+	BUILD_BUG_ON(sizeof(struct sock_exterr_skb) > sizeof(skb->cb));
+
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
 	serr->ee.ee_info = tstype;
+	serr->opt_stats = opt_stats;
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID) {
 		serr->ee.ee_data = skb_shinfo(skb)->tskey;
 		if (sk->sk_protocol == IPPROTO_TCP &&
@@ -3843,7 +3847,7 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	 */
 	if (likely(atomic_inc_not_zero(&sk->sk_refcnt))) {
 		*skb_hwtstamps(skb) = *hwtstamps;
-		__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
+		__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND, false);
 		sock_put(sk);
 	}
 }
@@ -3854,7 +3858,7 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 		     struct sock *sk, int tstype)
 {
 	struct sk_buff *skb;
-	bool tsonly;
+	bool tsonly, opt_stats = false;
 
 	if (!sk)
 		return;
@@ -3867,9 +3871,10 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 #ifdef CONFIG_INET
 		if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS) &&
 		    sk->sk_protocol == IPPROTO_TCP &&
-		    sk->sk_type == SOCK_STREAM)
+		    sk->sk_type == SOCK_STREAM) {
 			skb = tcp_get_timestamping_opt_stats(sk);
-		else
+			opt_stats = true;
+		} else
 #endif
 			skb = alloc_skb(0, GFP_ATOMIC);
 	} else {
@@ -3888,7 +3893,7 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	else
 		skb->tstamp = ktime_get_real();
 
-	__skb_complete_tx_timestamp(skb, sk, tstype);
+	__skb_complete_tx_timestamp(skb, sk, tstype, opt_stats);
 }
 EXPORT_SYMBOL_GPL(__skb_tstamp_tx);
 
diff --git a/net/socket.c b/net/socket.c
index 692d6989d2c2..985ef06792d6 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -706,7 +706,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 			 SCM_TIMESTAMPING, sizeof(tss), &tss);
 
 		if (skb_is_err_queue(skb) && skb->len &&
-		    (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS))
+		    SKB_EXT_ERR(skb)->opt_stats)
 			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_OPT_STATS,
 				 skb->len, skb->data);
 	}
-- 
2.12.0.367.g23dc2f6d3c-goog
