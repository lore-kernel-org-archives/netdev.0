From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net-timestamp: sock_tx_timestamp() fix
Date: Wed, 06 Aug 2014 11:49:29 +0200
Message-ID: <1407318569.11943.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
	 <1407204710-21778-6-git-send-email-willemb@google.com>
	 <1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	richardcochran@gmail.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:51788 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806AbaHFJtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 05:49:33 -0400
Received: by mail-wi0-f179.google.com with SMTP id f8so2840938wiw.6
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 02:49:32 -0700 (PDT)
In-Reply-To: <1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sock_tx_timestamp() should not ignore initial *tx_flags value, as TCP
stack can store SKBTX_SHARED_FRAG in it.

Also first argument (struct sock *) can be const.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 4ed2d765dfac ("net-timestamp: TCP timestamping")
Cc: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h |    6 ++++--
 net/socket.c       |   20 +++++++++++++-------
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 52fe0bc5598a..38805fa02e48 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2199,9 +2199,11 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 /**
  * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
  * @sk:		socket sending this packet
- * @tx_flags:	filled with instructions for time stamping
+ * @tx_flags:	completed with instructions for time stamping
+ *
+ * Note : callers should take care of initial *tx_flags value (usually 0)
  */
-void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
+void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags);
 
 /**
  * sk_eat_skb - Release a skb if it is no longer needed
diff --git a/net/socket.c b/net/socket.c
index ae89569a2db5..95ee7d8682e7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -610,20 +610,26 @@ void sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL(sock_release);
 
-void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
+void sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
 {
-	*tx_flags = 0;
+	u8 flags = *tx_flags;
+
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_HARDWARE)
-		*tx_flags |= SKBTX_HW_TSTAMP;
+		flags |= SKBTX_HW_TSTAMP;
+
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SOFTWARE)
-		*tx_flags |= SKBTX_SW_TSTAMP;
+		flags |= SKBTX_SW_TSTAMP;
+
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_SCHED)
-		*tx_flags |= SKBTX_SCHED_TSTAMP;
+		flags |= SKBTX_SCHED_TSTAMP;
+
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_TX_ACK)
-		*tx_flags |= SKBTX_ACK_TSTAMP;
+		flags |= SKBTX_ACK_TSTAMP;
 
 	if (sock_flag(sk, SOCK_WIFI_STATUS))
-		*tx_flags |= SKBTX_WIFI_STATUS;
+		flags |= SKBTX_WIFI_STATUS;
+
+	*tx_flags = flags;
 }
 EXPORT_SYMBOL(sock_tx_timestamp);
 
