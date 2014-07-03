From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 8/8] net-timestamp: SOCK_RAW and PING timestamping
Date: Thu,  3 Jul 2014 15:39:40 -0400
Message-ID: <1404416380-3545-9-git-send-email-willemb@google.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gomail.com, stephen@networkplumber.org,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:41650 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbaGCTju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 15:39:50 -0400
Received: by mail-qa0-f73.google.com with SMTP id m5so87880qaj.0
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 12:39:50 -0700 (PDT)
In-Reply-To: <1404416380-3545-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SO_TIMESTAMPING to sockets of type PF_INET[6]/SOCK_RAW.
Add MSG_TSTAMP support to these sockets and ping sockets.
Ping sockets already supported SO_TIMESTAMPING, though the
feature was broken.

SOCK_RAW support was tested:
- socket option and flag
- with and without IP_HDRINCL

This fixes http://bugzilla.kernel.org/show_bug.cgi?id=77221

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/ip_output.c | 7 +++----
 net/ipv4/ping.c      | 1 +
 net/ipv4/raw.c       | 6 ++++++
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8d3b6b0..234a7ea 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -962,10 +962,6 @@ alloc_new_skb:
 							   sk->sk_allocation);
 				if (unlikely(skb == NULL))
 					err = -ENOBUFS;
-				else
-					/* only the initial fragment is
-					   time stamped */
-					cork->tx_flags = 0;
 			}
 			if (skb == NULL)
 				goto error;
@@ -1010,6 +1006,9 @@ alloc_new_skb:
 			exthdrlen = 0;
 			csummode = CHECKSUM_NONE;
 
+			/* only the initial fragment is time stamped */
+			cork->tx_flags = 0;
+
 			/*
 			 * Put the packet on the pending queue.
 			 */
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 044a0dd..1926fb7 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -732,6 +732,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	ipc.tos = -1;
 
 	sock_tx_timestamp(sk, &ipc.tx_flags);
+	ipc.tx_flags |= skbflags_tx_tstamp(msg->msg_flags);
 
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc, false);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2c65160..ade2c8c 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -365,6 +365,9 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb->ip_summed = CHECKSUM_NONE;
 
+	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
+	skb_shinfo(skb)->tx_flags |= skbflags_tx_tstamp(flags);
+
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
 	if (memcpy_fromiovecend((void *)iph, from, 0, length))
@@ -606,6 +609,9 @@ back_from_confirm:
 				      &rt, msg->msg_flags);
 
 	 else {
+		sock_tx_timestamp(sk, &ipc.tx_flags);
+		ipc.tx_flags |= skbflags_tx_tstamp(msg->msg_flags);
+
 		if (!ipc.addr)
 			ipc.addr = fl4.daddr;
 		lock_sock(sk);
-- 
2.0.0.526.g5318336
