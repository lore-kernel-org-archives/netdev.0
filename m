From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 9/13 net-2.6.26] [ICMP]: Simplify ICMP control socket creation.
Date: Mon, 31 Mar 2008 17:16:49 +0400
Message-ID: <1206969413-12096-9-git-send-email-den@openvz.org>
References: <1206969367.10660.16.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36557 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755347AbYCaNRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:17:05 -0400
In-Reply-To: <1206969367.10660.16.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace sock_create_kern with inet_ctl_sock_create.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/icmp.c |   25 +++++++------------------
 1 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 803bc9f..efc7cbe 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -93,6 +93,7 @@
 #include <asm/uaccess.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <net/inet_common.h>
 
 /*
  *	Build xmit assembly blocks
@@ -1136,7 +1137,7 @@ static void __net_exit icmp_sk_exit(struct net *net)
 	int i;
 
 	for_each_possible_cpu(i)
-		sk_release_kernel(net->ipv4.icmp_sk[i]);
+		inet_ctl_sock_destroy(net->ipv4.icmp_sk[i]);
 	kfree(net->ipv4.icmp_sk);
 	net->ipv4.icmp_sk = NULL;
 }
@@ -1152,17 +1153,13 @@ int __net_init icmp_sk_init(struct net *net)
 
 	for_each_possible_cpu(i) {
 		struct sock *sk;
-		struct socket *sock;
-		struct inet_sock *inet;
 
-		err = sock_create_kern(PF_INET, SOCK_RAW, IPPROTO_ICMP, &sock);
+		err = inet_ctl_sock_create(&sk, PF_INET,
+					   SOCK_RAW, IPPROTO_ICMP, net);
 		if (err < 0)
 			goto fail;
 
-		net->ipv4.icmp_sk[i] = sk = sock->sk;
-		sk_change_net(sk, net);
-
-		sk->sk_allocation = GFP_ATOMIC;
+		net->ipv4.icmp_sk[i] = sk;
 
 		/* Enough space for 2 64K ICMP packets, including
 		 * sk_buff struct overhead.
@@ -1170,15 +1167,7 @@ int __net_init icmp_sk_init(struct net *net)
 		sk->sk_sndbuf =
 			(2 * ((64 * 1024) + sizeof(struct sk_buff)));
 
-		inet = inet_sk(sk);
-		inet->uc_ttl = -1;
-		inet->pmtudisc = IP_PMTUDISC_DONT;
-
-		/* Unhash it so that IP input processing does not even
-		 * see it, we do not wish this socket to see incoming
-		 * packets.
-		 */
-		sk->sk_prot->unhash(sk);
+		inet_sk(sk)->pmtudisc = IP_PMTUDISC_DONT;
 	}
 
 	/* Control parameters for ECHO replies. */
@@ -1208,7 +1197,7 @@ int __net_init icmp_sk_init(struct net *net)
 
 fail:
 	for_each_possible_cpu(i)
-		sk_release_kernel(net->ipv4.icmp_sk[i]);
+		inet_ctl_sock_destroy(net->ipv4.icmp_sk[i]);
 	kfree(net->ipv4.icmp_sk);
 	return err;
 }
-- 
1.5.3.rc5

