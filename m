From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: ipmr: various fixes and cleanups
Date: Sun, 25 Nov 2012 08:41:45 -0800
Message-ID: <1353861705.30446.675.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:38257 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187Ab2KYQly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 11:41:54 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so5232542iea.19
        for <netdev@vger.kernel.org>; Sun, 25 Nov 2012 08:41:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

1) ip_mroute_setsockopt() & ip_mroute_getsockopt() should not
   access/set raw_sk(sk)->ipmr_table before making sure the socket
   is a raw socket, and protocol is IGMP

2) MRT_INIT should return -EINVAL if optlen != sizeof(int), not
   -ENOPROTOOPT

3) MRT_ASSERT & MRT_PIM should validate optlen

4) " (v) ? 1 : 0 " can be written as " !!v "

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ipmr.c |   24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 6168c4d..af4ef54 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1207,6 +1207,10 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	struct net *net = sock_net(sk);
 	struct mr_table *mrt;
 
+	if (sk->sk_type != SOCK_RAW ||
+	    inet_sk(sk)->inet_num != IPPROTO_IGMP)
+		return -EOPNOTSUPP;
+
 	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
 	if (mrt == NULL)
 		return -ENOENT;
@@ -1219,11 +1223,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 
 	switch (optname) {
 	case MRT_INIT:
-		if (sk->sk_type != SOCK_RAW ||
-		    inet_sk(sk)->inet_num != IPPROTO_IGMP)
-			return -EOPNOTSUPP;
 		if (optlen != sizeof(int))
-			return -ENOPROTOOPT;
+			return -EINVAL;
 
 		rtnl_lock();
 		if (rtnl_dereference(mrt->mroute_sk)) {
@@ -1284,9 +1285,11 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	case MRT_ASSERT:
 	{
 		int v;
+		if (optlen != sizeof(v))
+			return -EINVAL;
 		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
-		mrt->mroute_do_assert = (v) ? 1 : 0;
+		mrt->mroute_do_assert = !!v;
 		return 0;
 	}
 #ifdef CONFIG_IP_PIMSM
@@ -1294,9 +1297,11 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	{
 		int v;
 
+		if (optlen != sizeof(v))
+			return -EINVAL;
 		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
-		v = (v) ? 1 : 0;
+		v = !!v;
 
 		rtnl_lock();
 		ret = 0;
@@ -1325,7 +1330,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		} else {
 			if (!ipmr_new_table(net, v))
 				ret = -ENOMEM;
-			raw_sk(sk)->ipmr_table = v;
+			else
+				raw_sk(sk)->ipmr_table = v;
 		}
 		rtnl_unlock();
 		return ret;
@@ -1351,6 +1357,10 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 	struct net *net = sock_net(sk);
 	struct mr_table *mrt;
 
+	if (sk->sk_type != SOCK_RAW ||
+	    inet_sk(sk)->inet_num != IPPROTO_IGMP)
+		return -EOPNOTSUPP;
+
 	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
 	if (mrt == NULL)
 		return -ENOENT;
