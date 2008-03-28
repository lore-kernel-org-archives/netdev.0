From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 7/11 net-2.6.26] [ICMP]: Simplify ICMP control socket creation.
Date: Fri, 28 Mar 2008 12:08:54 +0300
Message-ID: <1206695338-5947-7-git-send-email-den@openvz.org>
References: <1206695071.3271.8.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11101 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753797AbYC1JIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:08:32 -0400
In-Reply-To: <1206695071.3271.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace sock_create_kern with inet_csk_ctl_sock_create.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/icmp.c |   23 +++++------------------
 1 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 803bc9f..b00bc20 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1152,33 +1152,20 @@ int __net_init icmp_sk_init(struct net *net)
 
 	for_each_possible_cpu(i) {
 		struct sock *sk;
-		struct socket *sock;
-		struct inet_sock *inet;
 
-		err = sock_create_kern(PF_INET, SOCK_RAW, IPPROTO_ICMP, &sock);
+		err = inet_csk_ctl_sock_create(&sk,
+					       PF_INET, SOCK_RAW, IPPROTO_ICMP);
 		if (err < 0)
 			goto fail;
 
-		net->ipv4.icmp_sk[i] = sk = sock->sk;
+		net->ipv4.icmp_sk[i] = sk;
 		sk_change_net(sk, net);
 
-		sk->sk_allocation = GFP_ATOMIC;
-
 		/* Enough space for 2 64K ICMP packets, including
 		 * sk_buff struct overhead.
 		 */
-		sk->sk_sndbuf =
-			(2 * ((64 * 1024) + sizeof(struct sk_buff)));
-
-		inet = inet_sk(sk);
-		inet->uc_ttl = -1;
-		inet->pmtudisc = IP_PMTUDISC_DONT;
-
-		/* Unhash it so that IP input processing does not even
-		 * see it, we do not wish this socket to see incoming
-		 * packets.
-		 */
-		sk->sk_prot->unhash(sk);
+		sk->sk_sndbuf = (2 * ((64 * 1024) + sizeof(struct sk_buff)));
+		inet_sk(sk)->pmtudisc = IP_PMTUDISC_DONT;
 	}
 
 	/* Control parameters for ECHO replies. */
-- 
1.5.3.rc5

