From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH 1/3] ipv6: Prevent unexpected sk->sk_prot changes
Date: Thu, 10 Aug 2017 13:33:14 +0300
Message-ID: <1502361196-127278-2-git-send-email-ilyal@mellanox.com>
References: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, aviadye@mellanox.com,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33012 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752460AbdHJKd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 06:33:26 -0400
In-Reply-To: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch IPV6 code ensure that only sockets with the
expected sk->sk_prot are converted to IPV4.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
---
 net/ipv6/ipv6_sockglue.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 02d795f..318cd344 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -174,6 +174,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		if (val == PF_INET) {
 			struct ipv6_txoptions *opt;
 			struct sk_buff *pktopt;
+			struct proto *expected_prot;
 
 			if (sk->sk_type == SOCK_RAW)
 				break;
@@ -199,6 +200,17 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 				break;
 			}
 
+			if (sk->sk_protocol == IPPROTO_TCP &&
+			    sk->sk_prot != &tcpv6_prot)
+				break;
+
+			expected_prot = &udpv6_prot;
+			if (sk->sk_protocol == IPPROTO_UDPLITE)
+				expected_prot = &udplitev6_prot;
+
+			if (sk->sk_prot != expected_prot)
+				break;
+
 			fl6_free_socklist(sk);
 			__ipv6_sock_mc_close(sk);
 
-- 
1.8.3.1
