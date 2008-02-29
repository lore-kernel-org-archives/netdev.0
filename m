From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 7/12 net-2.6.26] No need for a separate __netlink_release call.
Date: Fri, 29 Feb 2008 16:40:53 +0300
Message-ID: <1204292458-11636-7-git-send-email-den@openvz.org>
References: <1204292360.10368.11.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53788 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759674AbYB2Nkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 08:40:42 -0500
In-Reply-To: <1204292360.10368.11.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merge it to netlink_kernel_release.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/netlink/af_netlink.c |   30 ++++++++++++------------------
 1 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1ab0da2..e6b636d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1344,22 +1344,6 @@ static void netlink_data_ready(struct sock *sk, int len)
  *	queueing.
  */
 
-static void __netlink_release(struct sock *sk)
-{
-	/*
-	 * Last sock_put should drop referrence to sk->sk_net. It has already
-	 * been dropped in netlink_kernel_create. Taking referrence to stopping
-	 * namespace is not an option.
-	 * Take referrence to a socket to remove it from netlink lookup table
-	 * _alive_ and after that destroy it in the context of init_net.
-	 */
-
-	sock_hold(sk);
-	sock_release(sk->sk_socket);
-	sk->sk_net = get_net(&init_net);
-	sock_put(sk);
-}
-
 struct sock *
 netlink_kernel_create(struct net *net, int unit, unsigned int groups,
 		      void (*input)(struct sk_buff *skb),
@@ -1424,7 +1408,7 @@ netlink_kernel_create(struct net *net, int unit, unsigned int groups,
 
 out_sock_release:
 	kfree(listeners);
-	__netlink_release(sk);
+	netlink_kernel_release(sk);
 	return NULL;
 
 out_sock_release_nosk:
@@ -1437,10 +1421,20 @@ EXPORT_SYMBOL(netlink_kernel_create);
 void
 netlink_kernel_release(struct sock *sk)
 {
+	/*
+	 * Last sock_put should drop referrence to sk->sk_net. It has already
+	 * been dropped in netlink_kernel_create. Taking referrence to stopping
+	 * namespace is not an option.
+	 * Take referrence to a socket to remove it from netlink lookup table
+	 * _alive_ and after that destroy it in the context of init_net.
+	 */
 	if (sk == NULL || sk->sk_socket == NULL)
 		return;
 
-	__netlink_release(sk);
+	sock_hold(sk);
+	sock_release(sk->sk_socket);
+	sk->sk_net = get_net(&init_net);
+	sock_put(sk);
 }
 EXPORT_SYMBOL(netlink_kernel_release);
 
-- 
1.5.3.rc5

