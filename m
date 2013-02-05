From: David Miller <davem@davemloft.net>
Subject: [PATCH] l2tp: Make ipv4 protocol handler namespace aware.
Date: Tue, 05 Feb 2013 14:37:43 -0500 (EST)
Message-ID: <20130205.143743.1469716804408065331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435Ab3BEThp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:37:45 -0500
Received: from localhost (cpe-66-108-118-205.nyc.res.rr.com [66.108.118.205])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3A1F858101B
	for <netdev@vger.kernel.org>; Tue,  5 Feb 2013 11:37:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The infrastructure is already pretty much entirely there
to allow this conversion.

The tunnel and session lookups have per-namespace tables,
and the ipv4 bind lookup includes the namespace in the
lookup key.

Set netns_ok in l2tp_ip_protocol.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_ip.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 61d8b75..f7ac8f4 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -115,6 +115,7 @@ static inline struct sock *l2tp_ip_bind_lookup(struct net *net, __be32 laddr, in
  */
 static int l2tp_ip_recv(struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb->dev);
 	struct sock *sk;
 	u32 session_id;
 	u32 tunnel_id;
@@ -142,7 +143,7 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 	}
 
 	/* Ok, this is a data packet. Lookup the session. */
-	session = l2tp_session_find(&init_net, NULL, session_id);
+	session = l2tp_session_find(net, NULL, session_id);
 	if (session == NULL)
 		goto discard;
 
@@ -173,14 +174,14 @@ pass_up:
 		goto discard;
 
 	tunnel_id = ntohl(*(__be32 *) &skb->data[4]);
-	tunnel = l2tp_tunnel_find(&init_net, tunnel_id);
+	tunnel = l2tp_tunnel_find(net, tunnel_id);
 	if (tunnel != NULL)
 		sk = tunnel->sock;
 	else {
 		struct iphdr *iph = (struct iphdr *) skb_network_header(skb);
 
 		read_lock_bh(&l2tp_ip_lock);
-		sk = __l2tp_ip_bind_lookup(&init_net, iph->daddr, 0, tunnel_id);
+		sk = __l2tp_ip_bind_lookup(net, iph->daddr, 0, tunnel_id);
 		read_unlock_bh(&l2tp_ip_lock);
 	}
 
@@ -239,6 +240,7 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_l2tpip *addr = (struct sockaddr_l2tpip *) uaddr;
+	struct net *net = sock_net(sk);
 	int ret;
 	int chk_addr_ret;
 
@@ -251,7 +253,8 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	ret = -EADDRINUSE;
 	read_lock_bh(&l2tp_ip_lock);
-	if (__l2tp_ip_bind_lookup(&init_net, addr->l2tp_addr.s_addr, sk->sk_bound_dev_if, addr->l2tp_conn_id))
+	if (__l2tp_ip_bind_lookup(net, addr->l2tp_addr.s_addr,
+				  sk->sk_bound_dev_if, addr->l2tp_conn_id))
 		goto out_in_use;
 
 	read_unlock_bh(&l2tp_ip_lock);
@@ -260,7 +263,7 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_l2tpip))
 		goto out;
 
-	chk_addr_ret = inet_addr_type(&init_net, addr->l2tp_addr.s_addr);
+	chk_addr_ret = inet_addr_type(net, addr->l2tp_addr.s_addr);
 	ret = -EADDRNOTAVAIL;
 	if (addr->l2tp_addr.s_addr && chk_addr_ret != RTN_LOCAL &&
 	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
@@ -369,7 +372,7 @@ static int l2tp_ip_backlog_recv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 
 drop:
-	IP_INC_STATS(&init_net, IPSTATS_MIB_INDISCARDS);
+	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_INDISCARDS);
 	kfree_skb(skb);
 	return -1;
 }
@@ -605,6 +608,7 @@ static struct inet_protosw l2tp_ip_protosw = {
 
 static struct net_protocol l2tp_ip_protocol __read_mostly = {
 	.handler	= l2tp_ip_recv,
+	.netns_ok	= 1,
 };
 
 static int __init l2tp_ip_init(void)
-- 
1.7.11.7
