From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/11 net-2.6.26] [DCCP]: Replace socket with sock for reset sending.
Date: Fri, 28 Mar 2008 12:08:49 +0300
Message-ID: <1206695338-5947-2-git-send-email-den@openvz.org>
References: <1206695071.3271.8.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29442 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754305AbYC1JIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:08:32 -0400
In-Reply-To: <1206695071.3271.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace dccp_v(4|6)_ctl_socket with sock to unify a code with TCP/ICMP.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/dccp/ipv4.c |   16 +++++++++-------
 net/dccp/ipv6.c |   10 ++++++----
 2 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 4ca8b0c..79a9a4a 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -36,7 +36,7 @@
  * the Out-of-the-blue (OOTB) packets. A control sock will be created
  * for this socket at the initialization time.
  */
-static struct socket *dccp_v4_ctl_socket;
+static struct sock *dccp_v4_ctl_sk;
 
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
@@ -514,11 +514,11 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (rxskb->rtable->rt_type != RTN_LOCAL)
 		return;
 
-	dst = dccp_v4_route_skb(dccp_v4_ctl_socket->sk, rxskb);
+	dst = dccp_v4_route_skb(dccp_v4_ctl_sk, rxskb);
 	if (dst == NULL)
 		return;
 
-	skb = dccp_ctl_make_reset(dccp_v4_ctl_socket, rxskb);
+	skb = dccp_ctl_make_reset(dccp_v4_ctl_sk->sk_socket, rxskb);
 	if (skb == NULL)
 		goto out;
 
@@ -527,10 +527,10 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 								 rxiph->daddr);
 	skb->dst = dst_clone(dst);
 
-	bh_lock_sock(dccp_v4_ctl_socket->sk);
-	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
+	bh_lock_sock(dccp_v4_ctl_sk);
+	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_sk,
 				    rxiph->daddr, rxiph->saddr, NULL);
-	bh_unlock_sock(dccp_v4_ctl_socket->sk);
+	bh_unlock_sock(dccp_v4_ctl_sk);
 
 	if (net_xmit_eval(err) == 0) {
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
@@ -994,6 +994,7 @@ static struct inet_protosw dccp_v4_protosw = {
 
 static int __init dccp_v4_init(void)
 {
+	struct socket *socket;
 	int err = proto_register(&dccp_v4_prot, 1);
 
 	if (err != 0)
@@ -1005,10 +1006,11 @@ static int __init dccp_v4_init(void)
 
 	inet_register_protosw(&dccp_v4_protosw);
 
-	err = inet_csk_ctl_sock_create(&dccp_v4_ctl_socket, PF_INET,
+	err = inet_csk_ctl_sock_create(&socket, PF_INET,
 				       SOCK_DCCP, IPPROTO_DCCP);
 	if (err)
 		goto out_unregister_protosw;
+	dccp_v4_ctl_sk = socket->sk;
 out:
 	return err;
 out_unregister_protosw:
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 2fec1af..249640d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -34,7 +34,7 @@
 #include "feat.h"
 
 /* Socket used for sending RSTs and ACKs */
-static struct socket *dccp_v6_ctl_socket;
+static struct sock *dccp_v6_ctl_sk;
 
 static struct inet_connection_sock_af_ops dccp_ipv6_mapped;
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops;
@@ -303,7 +303,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (!ipv6_unicast_destination(rxskb))
 		return;
 
-	skb = dccp_ctl_make_reset(dccp_v6_ctl_socket, rxskb);
+	skb = dccp_ctl_make_reset(dccp_v6_ctl_sk->sk_socket, rxskb);
 	if (skb == NULL)
 		return;
 
@@ -324,7 +324,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
 		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >= 0) {
-			ip6_xmit(dccp_v6_ctl_socket->sk, skb, &fl, NULL, 0);
+			ip6_xmit(dccp_v6_ctl_sk, skb, &fl, NULL, 0);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
 			return;
@@ -1176,6 +1176,7 @@ static struct inet_protosw dccp_v6_protosw = {
 
 static int __init dccp_v6_init(void)
 {
+	struct socket *socket;
 	int err = proto_register(&dccp_v6_prot, 1);
 
 	if (err != 0)
@@ -1187,10 +1188,11 @@ static int __init dccp_v6_init(void)
 
 	inet6_register_protosw(&dccp_v6_protosw);
 
-	err = inet_csk_ctl_sock_create(&dccp_v6_ctl_socket, PF_INET6,
+	err = inet_csk_ctl_sock_create(&socket, PF_INET6,
 				       SOCK_DCCP, IPPROTO_DCCP);
 	if (err != 0)
 		goto out_unregister_protosw;
+	dccp_v6_ctl_sk = socket->sk;
 out:
 	return err;
 out_unregister_protosw:
-- 
1.5.3.rc5

