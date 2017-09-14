From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH net-next 2/5] tcp: Add clean acked data hook
Date: Thu, 14 Sep 2017 13:46:25 +0300
Message-ID: <1505385988-94522-3-git-send-email-ilyal@mellanox.com>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, tom@herbertland.com,
        hannes@stressinduktion.org, borisp@mellanox.com,
        ilyal@mellanox.com, aviadye@mellanox.com, liranl@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37184 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751845AbdINKqi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 06:46:38 -0400
In-Reply-To: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Called when a TCP segment is acknowledged.
Could be used by application protocols who hold additional
metadata associated with the stream data
This is required by TLS device offload to release
metadata associated with acknowledged TLS records.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 include/net/inet_connection_sock.h | 2 ++
 net/ipv4/tcp_input.c               | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 13e4c89..2ea1026 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -77,6 +77,7 @@ struct inet_connection_sock_af_ops {
  * @icsk_af_ops		   Operations which are AF_INET{4,6} specific
  * @icsk_ulp_ops	   Pluggable ULP control hook
  * @icsk_ulp_data	   ULP private data
+ * @icsk_clean_acked	   Clean acked data hook
  * @icsk_ca_state:	   Congestion control state
  * @icsk_retransmits:	   Number of unrecovered [RTO] timeouts
  * @icsk_pending:	   Scheduled timer event
@@ -101,6 +102,7 @@ struct inet_connection_sock {
 	const struct inet_connection_sock_af_ops *icsk_af_ops;
 	const struct tcp_ulp_ops  *icsk_ulp_ops;
 	void			  *icsk_ulp_data;
+	void			  (*icsk_clean_acked)(struct sock *sk);
 	unsigned int		  (*icsk_sync_mss)(struct sock *sk, u32 pmtu);
 	__u8			  icsk_ca_state:6,
 				  icsk_ca_setsockopt:1,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c5d7656..37ebdbb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3645,6 +3645,9 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (!prior_packets)
 		goto no_queue;
 
+	if (icsk->icsk_clean_acked)
+		icsk->icsk_clean_acked(sk);
+
 	/* See if we can take anything off of the retransmit queue. */
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una, &acked,
 				    &sack_state);
-- 
1.8.3.1
