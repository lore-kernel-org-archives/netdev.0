From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/11 net-2.6.26] [TCP]: Replace socket with sock for reset sending.
Date: Fri, 28 Mar 2008 12:08:48 +0300
Message-ID: <1206695338-5947-1-git-send-email-den@openvz.org>
References: <1206695071.3271.8.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46957 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753733AbYC1JIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:08:31 -0400
In-Reply-To: <1206695071.3271.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is more effective (less derefferences on fast paths). Additionally,
the approach is unified to one used in ICMP.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/tcp_ipv4.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2a5881c..9d47870 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -89,7 +89,7 @@ int sysctl_tcp_low_latency __read_mostly;
 #define ICMP_MIN_LENGTH 8
 
 /* Socket used for sending RSTs */
-static struct socket *tcp_socket __read_mostly;
+static struct sock *tcp_sock __read_mostly;
 
 void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
 
@@ -598,7 +598,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 
-	ip_send_reply(tcp_socket->sk, skb, &arg, arg.iov[0].iov_len);
+	ip_send_reply(tcp_sock, skb, &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 	TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
@@ -693,7 +693,7 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 	if (twsk)
 		arg.bound_dev_if = twsk->tw_sk.tw_bound_dev_if;
 
-	ip_send_reply(tcp_socket->sk, skb, &arg, arg.iov[0].iov_len);
+	ip_send_reply(tcp_sock, skb, &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 }
@@ -2493,9 +2493,11 @@ struct proto tcp_prot = {
 
 void __init tcp_v4_init(void)
 {
-	if (inet_csk_ctl_sock_create(&tcp_socket, PF_INET, SOCK_RAW,
+	struct socket *__tcp_socket;
+	if (inet_csk_ctl_sock_create(&__tcp_socket, PF_INET, SOCK_RAW,
 				     IPPROTO_TCP) < 0)
 		panic("Failed to create the TCP control socket.\n");
+	tcp_sock = __tcp_socket->sk;
 }
 
 EXPORT_SYMBOL(ipv4_specific);
-- 
1.5.3.rc5

