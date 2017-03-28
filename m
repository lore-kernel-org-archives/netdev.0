From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 01/15] tcp: Add clean acked data hook
Date: Tue, 28 Mar 2017 16:26:18 +0300
Message-ID: <1490707592-1430-2-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ilya Lesokhin <ilyal@mellanox.com>

Called when a TCP segment is acknowledged.
Could be used by application protocols who hold additional
metadata associated with the stream data
This is required for TLS offloads to release metadata
for acknowledged TLS records.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 include/net/inet_connection_sock.h | 2 ++
 net/ipv4/tcp_input.c               | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 146054c..0b0aceb 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -77,6 +77,7 @@ struct inet_connection_sock_af_ops {
  * @icsk_pmtu_cookie	   Last pmtu seen by socket
  * @icsk_ca_ops		   Pluggable congestion control hook
  * @icsk_af_ops		   Operations which are AF_INET{4,6} specific
+ * @icsk_clean_acked	   Clean acked data hook
  * @icsk_ca_state:	   Congestion control state
  * @icsk_retransmits:	   Number of unrecovered [RTO] timeouts
  * @icsk_pending:	   Scheduled timer event
@@ -99,6 +100,7 @@ struct inet_connection_sock {
 	__u32			  icsk_pmtu_cookie;
 	const struct tcp_congestion_ops *icsk_ca_ops;
 	const struct inet_connection_sock_af_ops *icsk_af_ops;
+	void			  (*icsk_clean_acked)(struct sock *sk);
 	unsigned int		  (*icsk_sync_mss)(struct sock *sk, u32 pmtu);
 	__u8			  icsk_ca_state:6,
 				  icsk_ca_setsockopt:1,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fe668c1..c158bec 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3667,6 +3667,9 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (!prior_packets)
 		goto no_queue;
 
+	if (icsk->icsk_clean_acked)
+		icsk->icsk_clean_acked(sk);
+
 	/* See if we can take anything off of the retransmit queue. */
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una, &acked,
 				    &sack_state, &now);
-- 
2.7.4
