From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] memory leak in netlink user->kernel processing
Date: Mon, 1 Oct 2007 18:29:07 +0400
Message-ID: <20071001142907.GA10022@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:65122 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754606AbXJAO1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 10:27:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netlink_kernel_create can be called with NULL as an input callback in several
places, f.e. in kobject_uevent_init. This means that if one sends packet from
user to kernel for such a socket, the packet will be leaked in the socket
queue forever.

This patch adds a simple generic cleanup callback for these sockets.

Signed-off-by: Denis V. Lunev <den@openvz.org>

--- ./net/netlink/af_netlink.c.nlk4	2007-08-26 19:30:38.000000000 +0400
+++ ./net/netlink/af_netlink.c	2007-10-01 18:00:58.000000000 +0400
@@ -1301,6 +1301,13 @@ out:
 	return err ? : copied;
 }
 
+static void netlink_rcv_drop(struct sock *sk, int len)
+{
+	struct sk_buff *skb;
+	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL)
+		kfree_skb(skb);
+}
+
 static void netlink_data_ready(struct sock *sk, int len)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -1346,8 +1353,7 @@ netlink_kernel_create(struct net *net, i
 
 	sk = sock->sk;
 	sk->sk_data_ready = netlink_data_ready;
-	if (input)
-		nlk_sk(sk)->data_ready = input;
+	nlk_sk(sk)->data_ready = input != NULL ? input : netlink_rcv_drop;
 
 	if (netlink_insert(sk, net, 0))
 		goto out_sock_release;
