From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 08/11] ipvs: avoid to switch namespace for ipvs kernel socket
Date: Thu, 7 May 2015 16:52:47 +0800
Message-ID: <1430988770-28907-9-git-send-email-ying.xue@windriver.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <herbert@gondor.apana.org.au>,
	<xemul@openvz.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <ebiederm@xmission.com>,
	<maxk@qti.qualcomm.com>, <stephen@networkplumber.org>,
	<tgraf@suug.ch>, <nicolas.dichtel@6wind.com>,
	<tom@herbertland.com>, <jchapman@katalix.com>,
	<erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<horms@verge.net.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40665 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbbEGIx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:59 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The race between put_net() and kernel socket creation is gone, so
it's unnecessary to change namespace from init_net to a desirable
one.

Cc: Simon Horman <horms@verge.net.au>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |   32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 19b9cce..4472fa0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1458,7 +1458,7 @@ static struct socket *make_send_sock(struct net *net, int id)
 	int result;
 
 	/* First create a socket move it to right name space later */
-	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = __sock_create(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
@@ -1466,9 +1466,10 @@ static struct socket *make_send_sock(struct net *net, int id)
 	/*
 	 * Kernel sockets that are a part of a namespace, should not
 	 * hold a reference to a namespace in order to allow to stop it.
-	 * After sk_change_net should be released using sk_release_kernel.
+	 * After the reference is decreased here with put_net(), it should
+	 * be increased again using get_net() before the socket is released.
 	 */
-	sk_change_net(sock->sk, net);
+	put_net(sock_net(sock->sk));
 	result = set_mcast_if(sock->sk, ipvs->master_mcast_ifn);
 	if (result < 0) {
 		pr_err("Error setting outbound mcast interface\n");
@@ -1497,7 +1498,8 @@ static struct socket *make_send_sock(struct net *net, int id)
 	return sock;
 
 error:
-	sk_release_kernel(sock->sk);
+	get_net(sock_net(sock->sk));
+	sock_release(sock);
 	return ERR_PTR(result);
 }
 
@@ -1518,7 +1520,7 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	int result;
 
 	/* First create a socket */
-	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
+	result = __sock_create(net, PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock, 1);
 	if (result < 0) {
 		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
@@ -1526,9 +1528,10 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	/*
 	 * Kernel sockets that are a part of a namespace, should not
 	 * hold a reference to a namespace in order to allow to stop it.
-	 * After sk_change_net should be released using sk_release_kernel.
+	 * After the reference is decreased here with put_net(), it should
+	 * be increased again using get_net() before the socket is released.
 	 */
-	sk_change_net(sock->sk, net);
+	put_net(sock_net(sock->sk));
 	/* it is equivalent to the REUSEADDR option in user-space */
 	sock->sk->sk_reuse = SK_CAN_REUSE;
 	result = sysctl_sync_sock_size(ipvs);
@@ -1554,7 +1557,8 @@ static struct socket *make_receive_sock(struct net *net, int id)
 	return sock;
 
 error:
-	sk_release_kernel(sock->sk);
+	get_net(sock_net(sock->sk));
+	sock_release(sock);
 	return ERR_PTR(result);
 }
 
@@ -1692,7 +1696,8 @@ done:
 		ip_vs_sync_buff_release(sb);
 
 	/* release the sending multicast socket */
-	sk_release_kernel(tinfo->sock->sk);
+	get_net(sock_net(tinfo->sock->sk));
+	sock_release(tinfo->sock);
 	kfree(tinfo);
 
 	return 0;
@@ -1729,7 +1734,8 @@ static int sync_thread_backup(void *data)
 	}
 
 	/* release the sending multicast socket */
-	sk_release_kernel(tinfo->sock->sk);
+	get_net(sock_net(tinfo->sock->sk));
+	sock_release(tinfo->sock);
 	kfree(tinfo->buf);
 	kfree(tinfo);
 
@@ -1854,11 +1860,13 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 	return 0;
 
 outsocket:
-	sk_release_kernel(sock->sk);
+	get_net(sock_net(sock->sk));
+	sock_release(sock);
 
 outtinfo:
 	if (tinfo) {
-		sk_release_kernel(tinfo->sock->sk);
+		get_net(sock_net(tinfo->sock->sk));
+		sock_release(tinfo->sock);
 		kfree(tinfo->buf);
 		kfree(tinfo);
 	}
-- 
1.7.9.5
