From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 02/11] netlink: avoid unnecessary namespace switch when create netlink kernel sockets
Date: Thu, 7 May 2015 16:52:41 +0800
Message-ID: <1430988770-28907-3-git-send-email-ying.xue@windriver.com>
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
Received: from mail1.windriver.com ([147.11.146.13]:35529 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbEGIxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:34 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As now the race between put_net() and netlink_kernel_create() is
resolved, it's unnecessary to switch namespace for a netlink kernel
socket from init_net to its desirable one, which means the kernel
socket is created and released within one namespace. But as the
kernel socket is part of a namespace, we should not hold a reference
count to the namespace, otherwise, probably modules relying on it
cannot be stopped.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/netlink/af_netlink.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbd..9aec20a 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2479,11 +2479,11 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 	 * So we create one inside init_net and the move it to net.
 	 */
 
-	if (__netlink_create(&init_net, sock, cb_mutex, unit) < 0)
+	if (__netlink_create(net, sock, cb_mutex, unit) < 0)
 		goto out_sock_release_nosk;
 
 	sk = sock->sk;
-	sk_change_net(sk, net);
+	put_net(sock_net(sk));
 
 	if (!cfg || cfg->groups < 32)
 		groups = 32;
@@ -2539,7 +2539,8 @@ EXPORT_SYMBOL(__netlink_kernel_create);
 void
 netlink_kernel_release(struct sock *sk)
 {
-	sk_release_kernel(sk);
+	get_net(sock_net(sk));
+	sock_release(sk->sk_socket);
 }
 EXPORT_SYMBOL(netlink_kernel_release);
 
-- 
1.7.9.5
