From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/15] ipv4: Use inet_csk_route_child_sock() in DCCP and
 TCP.
Date: Sun, 08 May 2011 15:37:49 -0700 (PDT)
Message-ID: <20110508.153749.246512612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755807Ab1EHWiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:21 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9041124C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Operation order is now transposed, we first create the child
socket then we try to hook up the route.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dccp/ipv4.c     |   19 ++++++++++---------
 net/ipv4/tcp_ipv4.c |   18 ++++++++++--------
 2 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 4ac1a72..46b15e9 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -396,15 +396,10 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 	if (sk_acceptq_is_full(sk))
 		goto exit_overflow;
 
-	if (dst == NULL && (dst = inet_csk_route_req(sk, req)) == NULL)
-		goto exit;
-
 	newsk = dccp_create_openreq_child(sk, req, skb);
 	if (newsk == NULL)
 		goto exit_nonewsk;
 
-	sk_setup_caps(newsk, dst);
-
 	newinet		   = inet_sk(newsk);
 	ireq		   = inet_rsk(req);
 	newinet->inet_daddr	= ireq->rmt_addr;
@@ -416,12 +411,15 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newinet->mc_ttl	   = ip_hdr(skb)->ttl;
 	newinet->inet_id   = jiffies;
 
+	if (dst == NULL && (dst = inet_csk_route_child_sock(sk, newsk, req)) == NULL)
+		goto put_and_exit;
+
+	sk_setup_caps(newsk, dst);
+
 	dccp_sync_mss(newsk, dst_mtu(dst));
 
-	if (__inet_inherit_port(sk, newsk) < 0) {
-		sock_put(newsk);
-		goto exit;
-	}
+	if (__inet_inherit_port(sk, newsk) < 0)
+		goto put_and_exit;
 	__inet_hash_nolisten(newsk, NULL);
 
 	return newsk;
@@ -433,6 +431,9 @@ exit_nonewsk:
 exit:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return NULL;
+put_and_exit:
+	sock_put(newsk);
+	goto exit;
 }
 
 EXPORT_SYMBOL_GPL(dccp_v4_request_recv_sock);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a712171..374de3c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1421,15 +1421,11 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	if (sk_acceptq_is_full(sk))
 		goto exit_overflow;
 
-	if (!dst && (dst = inet_csk_route_req(sk, req)) == NULL)
-		goto exit;
-
 	newsk = tcp_create_openreq_child(sk, req, skb);
 	if (!newsk)
 		goto exit_nonewsk;
 
 	newsk->sk_gso_type = SKB_GSO_TCPV4;
-	sk_setup_caps(newsk, dst);
 
 	newtp		      = tcp_sk(newsk);
 	newinet		      = inet_sk(newsk);
@@ -1447,6 +1443,11 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
 	newinet->inet_id = newtp->write_seq ^ jiffies;
 
+	if (!dst && (dst = inet_csk_route_child_sock(sk, newsk, req)) == NULL)
+		goto put_and_exit;
+
+	sk_setup_caps(newsk, dst);
+
 	tcp_mtup_init(newsk);
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric_advmss(dst);
@@ -1474,10 +1475,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 #endif
 
-	if (__inet_inherit_port(sk, newsk) < 0) {
-		sock_put(newsk);
-		goto exit;
-	}
+	if (__inet_inherit_port(sk, newsk) < 0)
+		goto put_and_exit;
 	__inet_hash_nolisten(newsk, NULL);
 
 	return newsk;
@@ -1489,6 +1488,9 @@ exit_nonewsk:
 exit:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return NULL;
+put_and_exit:
+	sock_put(newsk);
+	goto exit;
 }
 EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
 
-- 
1.7.5.1

