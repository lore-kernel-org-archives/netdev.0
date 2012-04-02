From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 24/51] l2tp: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:14 -0400
Message-ID: <1333335521-1348-25-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab2DBC7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:45 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_netlink.c |  114 ++++++++++++++++++++++++++--------------------
 1 files changed, 64 insertions(+), 50 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 93a41a0..bc8c334 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -231,24 +231,28 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 	if (IS_ERR(hdr))
 		return PTR_ERR(hdr);
 
-	NLA_PUT_U8(skb, L2TP_ATTR_PROTO_VERSION, tunnel->version);
-	NLA_PUT_U32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id);
-	NLA_PUT_U32(skb, L2TP_ATTR_PEER_CONN_ID, tunnel->peer_tunnel_id);
-	NLA_PUT_U32(skb, L2TP_ATTR_DEBUG, tunnel->debug);
-	NLA_PUT_U16(skb, L2TP_ATTR_ENCAP_TYPE, tunnel->encap);
+	if (nla_put_u8(skb, L2TP_ATTR_PROTO_VERSION, tunnel->version) ||
+	    nla_put_u32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id) ||
+	    nla_put_u32(skb, L2TP_ATTR_PEER_CONN_ID, tunnel->peer_tunnel_id) ||
+	    nla_put_u32(skb, L2TP_ATTR_DEBUG, tunnel->debug) ||
+	    nla_put_u16(skb, L2TP_ATTR_ENCAP_TYPE, tunnel->encap))
+		goto nla_put_failure;
 
 	nest = nla_nest_start(skb, L2TP_ATTR_STATS);
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	NLA_PUT_U64(skb, L2TP_ATTR_TX_PACKETS, tunnel->stats.tx_packets);
-	NLA_PUT_U64(skb, L2TP_ATTR_TX_BYTES, tunnel->stats.tx_bytes);
-	NLA_PUT_U64(skb, L2TP_ATTR_TX_ERRORS, tunnel->stats.tx_errors);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_PACKETS, tunnel->stats.rx_packets);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_BYTES, tunnel->stats.rx_bytes);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_SEQ_DISCARDS, tunnel->stats.rx_seq_discards);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_OOS_PACKETS, tunnel->stats.rx_oos_packets);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_ERRORS, tunnel->stats.rx_errors);
+	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, tunnel->stats.tx_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, tunnel->stats.tx_bytes) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, tunnel->stats.tx_errors) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, tunnel->stats.rx_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, tunnel->stats.rx_bytes) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
+			tunnel->stats.rx_seq_discards) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
+			tunnel->stats.rx_oos_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, tunnel->stats.rx_errors))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
 	sk = tunnel->sock;
@@ -259,13 +263,16 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 
 	switch (tunnel->encap) {
 	case L2TP_ENCAPTYPE_UDP:
-		NLA_PUT_U16(skb, L2TP_ATTR_UDP_SPORT, ntohs(inet->inet_sport));
-		NLA_PUT_U16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport));
-		NLA_PUT_U8(skb, L2TP_ATTR_UDP_CSUM, (sk->sk_no_check != UDP_CSUM_NOXMIT));
+		if (nla_put_u16(skb, L2TP_ATTR_UDP_SPORT, ntohs(inet->inet_sport)) ||
+		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)) ||
+		    nla_put_u8(skb, L2TP_ATTR_UDP_CSUM,
+			       (sk->sk_no_check != UDP_CSUM_NOXMIT)))
+			goto nla_put_failure;
 		/* NOBREAK */
 	case L2TP_ENCAPTYPE_IP:
-		NLA_PUT_BE32(skb, L2TP_ATTR_IP_SADDR, inet->inet_saddr);
-		NLA_PUT_BE32(skb, L2TP_ATTR_IP_DADDR, inet->inet_daddr);
+		if (nla_put_be32(skb, L2TP_ATTR_IP_SADDR, inet->inet_saddr) ||
+		    nla_put_be32(skb, L2TP_ATTR_IP_DADDR, inet->inet_daddr))
+			goto nla_put_failure;
 		break;
 	}
 
@@ -563,43 +570,50 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags
 	if (IS_ERR(hdr))
 		return PTR_ERR(hdr);
 
-	NLA_PUT_U32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id);
-	NLA_PUT_U32(skb, L2TP_ATTR_SESSION_ID, session->session_id);
-	NLA_PUT_U32(skb, L2TP_ATTR_PEER_CONN_ID, tunnel->peer_tunnel_id);
-	NLA_PUT_U32(skb, L2TP_ATTR_PEER_SESSION_ID, session->peer_session_id);
-	NLA_PUT_U32(skb, L2TP_ATTR_DEBUG, session->debug);
-	NLA_PUT_U16(skb, L2TP_ATTR_PW_TYPE, session->pwtype);
-	NLA_PUT_U16(skb, L2TP_ATTR_MTU, session->mtu);
-	if (session->mru)
-		NLA_PUT_U16(skb, L2TP_ATTR_MRU, session->mru);
-
-	if (session->ifname && session->ifname[0])
-		NLA_PUT_STRING(skb, L2TP_ATTR_IFNAME, session->ifname);
-	if (session->cookie_len)
-		NLA_PUT(skb, L2TP_ATTR_COOKIE, session->cookie_len, &session->cookie[0]);
-	if (session->peer_cookie_len)
-		NLA_PUT(skb, L2TP_ATTR_PEER_COOKIE, session->peer_cookie_len, &session->peer_cookie[0]);
-	NLA_PUT_U8(skb, L2TP_ATTR_RECV_SEQ, session->recv_seq);
-	NLA_PUT_U8(skb, L2TP_ATTR_SEND_SEQ, session->send_seq);
-	NLA_PUT_U8(skb, L2TP_ATTR_LNS_MODE, session->lns_mode);
+	if (nla_put_u32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id) ||
+	    nla_put_u32(skb, L2TP_ATTR_SESSION_ID, session->session_id) ||
+	    nla_put_u32(skb, L2TP_ATTR_PEER_CONN_ID, tunnel->peer_tunnel_id) ||
+	    nla_put_u32(skb, L2TP_ATTR_PEER_SESSION_ID,
+			session->peer_session_id) ||
+	    nla_put_u32(skb, L2TP_ATTR_DEBUG, session->debug) ||
+	    nla_put_u16(skb, L2TP_ATTR_PW_TYPE, session->pwtype) ||
+	    nla_put_u16(skb, L2TP_ATTR_MTU, session->mtu) ||
+	    (session->mru &&
+	     nla_put_u16(skb, L2TP_ATTR_MRU, session->mru)))
+		goto nla_put_failure;
+
+	if ((session->ifname && session->ifname[0] &&
+	     nla_put_string(skb, L2TP_ATTR_IFNAME, session->ifname)) ||
+	    (session->cookie_len &&
+	     nla_put(skb, L2TP_ATTR_COOKIE, session->cookie_len,
+		     &session->cookie[0])) ||
+	    (session->peer_cookie_len &&
+	     nla_put(skb, L2TP_ATTR_PEER_COOKIE, session->peer_cookie_len,
+		     &session->peer_cookie[0])) ||
+	    nla_put_u8(skb, L2TP_ATTR_RECV_SEQ, session->recv_seq) ||
+	    nla_put_u8(skb, L2TP_ATTR_SEND_SEQ, session->send_seq) ||
+	    nla_put_u8(skb, L2TP_ATTR_LNS_MODE, session->lns_mode) ||
 #ifdef CONFIG_XFRM
-	if ((sk) && (sk->sk_policy[0] || sk->sk_policy[1]))
-		NLA_PUT_U8(skb, L2TP_ATTR_USING_IPSEC, 1);
+	    (((sk) && (sk->sk_policy[0] || sk->sk_policy[1])) &&
+	     nla_put_u8(skb, L2TP_ATTR_USING_IPSEC, 1)) ||
 #endif
-	if (session->reorder_timeout)
-		NLA_PUT_MSECS(skb, L2TP_ATTR_RECV_TIMEOUT, session->reorder_timeout);
-
+	    (session->reorder_timeout &&
+	     nla_put_msecs(skb, L2TP_ATTR_RECV_TIMEOUT, session->reorder_timeout)))
+		goto nla_put_failure;
 	nest = nla_nest_start(skb, L2TP_ATTR_STATS);
 	if (nest == NULL)
 		goto nla_put_failure;
-	NLA_PUT_U64(skb, L2TP_ATTR_TX_PACKETS, session->stats.tx_packets);
-	NLA_PUT_U64(skb, L2TP_ATTR_TX_BYTES, session->stats.tx_bytes);
-	NLA_PUT_U64(skb, L2TP_ATTR_TX_ERRORS, session->stats.tx_errors);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_PACKETS, session->stats.rx_packets);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_BYTES, session->stats.rx_bytes);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_SEQ_DISCARDS, session->stats.rx_seq_discards);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_OOS_PACKETS, session->stats.rx_oos_packets);
-	NLA_PUT_U64(skb, L2TP_ATTR_RX_ERRORS, session->stats.rx_errors);
+	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, session->stats.tx_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, session->stats.tx_bytes) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, session->stats.tx_errors) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, session->stats.rx_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, session->stats.rx_bytes) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
+			session->stats.rx_seq_discards) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
+			session->stats.rx_oos_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, session->stats.rx_errors))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
 	return genlmsg_end(skb, hdr);
-- 
1.7.7.6
