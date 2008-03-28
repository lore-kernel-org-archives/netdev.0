From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 11/11 net-2.6.26] [NETNS]: Use TCP control socket from a correct namespace.
Date: Fri, 28 Mar 2008 12:08:58 +0300
Message-ID: <1206695338-5947-11-git-send-email-den@openvz.org>
References: <1206695071.3271.8.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45867 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753776AbYC1JIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:08:31 -0400
In-Reply-To: <1206695071.3271.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V.Lunev <den@openvz.org>
---
 net/ipv4/tcp_ipv4.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 14944af..34f9174 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -88,9 +88,6 @@ int sysctl_tcp_low_latency __read_mostly;
 /* Check TCP sequence numbers in ICMP packets. */
 #define ICMP_MIN_LENGTH 8
 
-/* Socket used for sending RSTs */
-static struct sock *tcp_sock __read_mostly;
-
 void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -598,7 +595,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 
-	ip_send_reply(tcp_sock, skb, &arg, arg.iov[0].iov_len);
+	ip_send_reply(dev_net(skb->dst->dev)->ipv4.tcp_sock, skb,
+		      &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 	TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
@@ -693,7 +691,8 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 	if (twsk)
 		arg.bound_dev_if = twsk->tw_sk.tw_bound_dev_if;
 
-	ip_send_reply(tcp_sock, skb, &arg, arg.iov[0].iov_len);
+	ip_send_reply(dev_net(skb->dev)->ipv4.tcp_sock, skb,
+		      &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 }
@@ -2517,7 +2516,6 @@ void __init tcp_v4_init(void)
 {
 	if (register_pernet_device(&tcp_sk_ops))
 		panic("Failed to create the TCP control socket.\n");
-	tcp_sock = init_net.ipv4.tcp_sock;
 }
 
 EXPORT_SYMBOL(ipv4_specific);
-- 
1.5.3.rc5

