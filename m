From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 4/6][NETNS][IPV6] tcp6 - make socket control per namespace
Date: Fri, 07 Mar 2008 16:26:42 +0100
Message-ID: <20080307152941.384598567@mai.toulouse-stg.fr.ibm.com>
References: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:3781 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764110AbYCGPaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:30:13 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m27FUB9G323038
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:11 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27FUBq81540294
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:11 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27FUBdf018817
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:11 +0100
Content-Disposition: inline; filename=make-tcp6-socket-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having a tcp6_socket global to all the namespace, there is tcp6 socket
control per namespace. That is consistent with which namespace sent a RST
and allows to pass the socket to the underlying function to retrieve the network
namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv6.h |    1 +
 net/ipv6/tcp_ipv6.c      |   43 +++++++++++++++++++++++++++++++++----------
 2 files changed, 34 insertions(+), 10 deletions(-)

Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -52,5 +52,6 @@ struct netns_ipv6 {
 #endif
 	struct sock		**icmp_sk;
 	struct sock             *ndisc_sk;
+	struct sock             *tcp_sk;
 };
 #endif
Index: net-2.6.26/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6.26/net/ipv6/tcp_ipv6.c
@@ -69,9 +69,6 @@
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
 
-/* Socket used for sending RSTs and ACKs */
-static struct socket *tcp6_socket;
-
 static void	tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb);
 static void	tcp_v6_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req);
 static void	tcp_v6_send_check(struct sock *sk, int len,
@@ -1075,10 +1072,11 @@ static void tcp_v6_send_reset(struct soc
 	 * Underlying function will use this to retrieve the network
 	 * namespace
 	 */
-	if (!ip6_dst_lookup(tcp6_socket->sk, &buff->dst, &fl)) {
+	if (!ip6_dst_lookup(init_net.ipv6.tcp_sk, &buff->dst, &fl)) {
 
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
-			ip6_xmit(tcp6_socket->sk, buff, &fl, NULL, 0);
+			ip6_xmit(init_net.ipv6.tcp_sk,
+				 buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 			TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
 			return;
@@ -1175,9 +1173,10 @@ static void tcp_v6_send_ack(struct tcp_t
 	fl.fl_ip_sport = t1->source;
 	security_skb_classify_flow(skb, &fl);
 
-	if (!ip6_dst_lookup(tcp6_socket->sk, &buff->dst, &fl)) {
+	if (!ip6_dst_lookup(init_net.ipv6.tcp_sk, &buff->dst, &fl)) {
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
-			ip6_xmit(tcp6_socket->sk, buff, &fl, NULL, 0);
+			ip6_xmit(init_net.ipv6.tcp_sk,
+				 buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 			return;
 		}
@@ -2198,6 +2197,31 @@ static struct inet_protosw tcpv6_protosw
 				INET_PROTOSW_ICSK,
 };
 
+static int tcpv6_net_init(struct net *net)
+{
+	int err;
+	struct socket *sock;
+	struct sock *sk;
+
+	err = inet_csk_ctl_sock_create(&sock, PF_INET6, SOCK_RAW, IPPROTO_TCP);
+	if (err)
+		return err;
+
+	net->ipv6.tcp_sk = sk = sock->sk;
+	sk_change_net(sk, net);
+	return err;
+}
+
+static void tcpv6_net_exit(struct net *net)
+{
+	sk_release_kernel(net->ipv6.tcp_sk);
+}
+
+static struct pernet_operations tcpv6_net_ops = {
+	.init = tcpv6_net_init,
+	.exit = tcpv6_net_exit,
+};
+
 int __init tcpv6_init(void)
 {
 	int ret;
@@ -2211,8 +2235,7 @@ int __init tcpv6_init(void)
 	if (ret)
 		goto out_tcpv6_protocol;
 
-	ret = inet_csk_ctl_sock_create(&tcp6_socket, PF_INET6,
-				       SOCK_RAW, IPPROTO_TCP);
+	ret = register_pernet_subsys(&tcpv6_net_ops);
 	if (ret)
 		goto out_tcpv6_protosw;
 out:
@@ -2227,7 +2250,7 @@ out_tcpv6_protosw:
 
 void tcpv6_exit(void)
 {
-	sock_release(tcp6_socket);
+	unregister_pernet_subsys(&tcpv6_net_ops);
 	inet6_unregister_protosw(&tcpv6_protosw);
 	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
 }

-- 
