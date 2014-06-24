From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 2/7] net-timestamp: MSG_TSTAMP one-shot tx timestamps
Date: Tue, 24 Jun 2014 11:43:47 -0400
Message-ID: <1403624632-17327-3-git-send-email-willemb@google.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
Cc: eric.dumazet@gmail.com, richardcochran@gmail.com,
	davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:37349 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468AbaFXPoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:44:00 -0400
Received: by mail-ob0-f201.google.com with SMTP id nu7so100640obb.2
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:44:00 -0700 (PDT)
In-Reply-To: <1403624632-17327-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel support datagram tx timestamping through socket option
SO_TIMESTAMPING. This patch add send() flag MSG_TSTAMP to allow
selectively requesting a timestamp for a single packet.

MSG_TSTAMP does not depend on SO_TIMESTAMPING. Enabling both
concurrently is redundant, but safe.

This patch adds support for IPv4 and IPv6 UDP sendmsg().

The feature maintains semantics of the socket option: with IP
fragmentation, only the first fragment is timestamped. This
should not happen, but can be forced, e.g., by disabling PMTU
on UDP.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 10 ++++++++++
 include/linux/socket.h |  1 +
 include/net/sock.h     |  5 +++--
 net/ipv4/udp.c         |  1 +
 net/ipv6/ip6_output.c  |  4 +++-
 net/socket.c           |  3 ++-
 6 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ec89301..bec3ded 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2736,6 +2736,16 @@ static inline void skb_tx_timestamp(struct sk_buff *skb)
 	sw_tx_timestamp(skb);
 }
 
+static inline u8 skbflags_tx_tstamp(int flags)
+{
+	u8 tx_flags = 0;
+
+	if (unlikely(flags & MSG_TSTAMP))
+		tx_flags |= SKBTX_SW_TSTAMP;
+
+	return tx_flags;
+}
+
 /**
  * skb_complete_wifi_ack - deliver skb with wifi status
  *
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8e98297..ce4101e 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -253,6 +253,7 @@ struct ucred {
 #define MSG_MORE	0x8000	/* Sender will send more */
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
+#define MSG_TSTAMP	0x100000
 #define MSG_EOF         MSG_FIN
 
 #define MSG_FASTOPEN	0x20000000	/* Send data in TCP SYN */
diff --git a/include/net/sock.h b/include/net/sock.h
index 07b7fcd..32cd1be 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2138,14 +2138,15 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	 * - receive time stamping in software requested (SOCK_RCVTSTAMP
 	 *   or SOCK_TIMESTAMPING_RX_SOFTWARE)
 	 * - software time stamp available and wanted
-	 *   (SOCK_TIMESTAMPING_SOFTWARE)
+	 *   (SOCK_TIMESTAMPING_SOFTWARE || SKBTX_SW_TSTAMP)
 	 * - hardware time stamps available and wanted
 	 *   (SOCK_TIMESTAMPING_SYS_HARDWARE or
 	 *   SOCK_TIMESTAMPING_RAW_HARDWARE)
 	 */
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
 	    sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE) ||
-	    (kt.tv64 && sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE)) ||
+	    (kt.tv64 && (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
+	     skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)) ||
 	    (hwtstamps->hwtstamp.tv64 &&
 	     sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE)) ||
 	    (hwtstamps->syststamp.tv64 &&
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d92f94b..9127aab 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -967,6 +967,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.oif = sk->sk_bound_dev_if;
 
 	sock_tx_timestamp(sk, &ipc.tx_flags);
+	ipc.tx_flags |= skbflags_tx_tstamp(msg->msg_flags);
 
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cb9df0e..7306c5d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1270,8 +1270,10 @@ emsgsize:
 	}
 
 	/* For UDP, check if TX timestamp is enabled */
-	if (sk->sk_type == SOCK_DGRAM)
+	if (sk->sk_type == SOCK_DGRAM) {
 		sock_tx_timestamp(sk, &tx_flags);
+		tx_flags |= skbflags_tx_tstamp(flags);
+	}
 
 	/*
 	 * Let's try using as much space as possible.
diff --git a/net/socket.c b/net/socket.c
index c001746..18ab44a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -723,7 +723,8 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	}
 
 	memset(&tss, 0, sizeof(tss));
-	if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) &&
+	if ((sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
+	     skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP) &&
 	    ktime_to_timespec_cond(skb->tstamp, &tss.ts_sw)) {
 		empty = 0;
 		tss.ts_type = SCM_TSTAMP_SND;
-- 
2.0.0.526.g5318336
