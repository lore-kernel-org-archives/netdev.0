From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: check sk sk_type and protocol early in ip_mroute_set/getsockopt
Date: Fri, 24 Feb 2017 16:29:06 +0800
Message-ID: <3d5396c3b5950c5a7476cf8a69198f916b4f01a4.1487924946.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33001 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdBXI3Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 03:29:25 -0500
Received: by mail-pf0-f193.google.com with SMTP id p185so751371pfb.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 00:29:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5e1859fbcc3c ("ipv4: ipmr: various fixes and cleanups") fixed
the issue for ipv4 ipmr:

  ip_mroute_setsockopt() & ip_mroute_getsockopt() should not
  access/set raw_sk(sk)->ipmr_table before making sure the socket
  is a raw socket, and protocol is IGMP

The same fix should be done for ipv6 ipmr as well.

This patch can fix the panic caused by overwriting the same offset
as ipmr_table as in raw_sk(sk) when accessing other type's socket
by ip_mroute_setsockopt().

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/ip6mr.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index babaf3e..6ba6c90 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1666,6 +1666,10 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	struct net *net = sock_net(sk);
 	struct mr6_table *mrt;
 
+	if (sk->sk_type != SOCK_RAW ||
+	    inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
+		return -EOPNOTSUPP;
+
 	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
 	if (!mrt)
 		return -ENOENT;
@@ -1677,9 +1681,6 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 
 	switch (optname) {
 	case MRT6_INIT:
-		if (sk->sk_type != SOCK_RAW ||
-		    inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
-			return -EOPNOTSUPP;
 		if (optlen < sizeof(int))
 			return -EINVAL;
 
@@ -1815,6 +1816,10 @@ int ip6_mroute_getsockopt(struct sock *sk, int optname, char __user *optval,
 	struct net *net = sock_net(sk);
 	struct mr6_table *mrt;
 
+	if (sk->sk_type != SOCK_RAW ||
+	    inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
+		return -EOPNOTSUPP;
+
 	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
 	if (!mrt)
 		return -ENOENT;
-- 
2.1.0
