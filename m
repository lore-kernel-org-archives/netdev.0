From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 03/11] tun: avoid unnecessary namespace switch during kernel socket creation
Date: Thu, 7 May 2015 16:52:42 +0800
Message-ID: <1430988770-28907-4-git-send-email-ying.xue@windriver.com>
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
Received: from mail1.windriver.com ([147.11.146.13]:35533 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbEGIxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:35 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the race between put_net() and kernel socket's creation is
solved, it's unnecessary to switch namespace for a kernel socket
from init_net to its desirable one. But as the kernel socket is
released when namespace is shutdown, the namespace is never released
if the kernel socket holds a reference count to the namespace. So we
have to put its namespace's reference counter after the kernel socket
is created with sk_alloc(), and get it again before it's released.

Cc: Maxim Krasnyansky <maxk@qti.qualcomm.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 drivers/net/tun.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e470ae5..abf7bae 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -456,6 +456,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 {
 	struct tun_file *ntfile;
 	struct tun_struct *tun;
+	struct sock *sk = &tfile->sk;
 
 	tun = rtnl_dereference(tfile->tun);
 
@@ -482,7 +483,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 		tun_set_real_num_queues(tun);
 	} else if (tfile->detached && clean) {
 		tun = tun_enable_queue(tfile);
-		sock_put(&tfile->sk);
+		sock_put(sk);
 	}
 
 	if (clean) {
@@ -496,7 +497,8 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 
 		BUG_ON(!test_bit(SOCK_EXTERNALLY_ALLOCATED,
 				 &tfile->socket.flags));
-		sk_release_kernel(&tfile->sk);
+		get_net(sock_net(sk));
+		sock_release(sk->sk_socket);
 	}
 }
 
@@ -2155,15 +2157,17 @@ out:
 static int tun_chr_open(struct inode *inode, struct file * file)
 {
 	struct tun_file *tfile;
+	struct net *net;
 
 	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
 
-	tfile = (struct tun_file *)sk_alloc(&init_net, AF_UNSPEC, GFP_KERNEL,
+	net = get_net(current->nsproxy->net_ns);
+	tfile = (struct tun_file *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
 					    &tun_proto);
 	if (!tfile)
 		return -ENOMEM;
 	RCU_INIT_POINTER(tfile->tun, NULL);
-	tfile->net = get_net(current->nsproxy->net_ns);
+	tfile->net = net;
 	tfile->flags = 0;
 	tfile->ifindex = 0;
 
@@ -2174,7 +2178,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	tfile->socket.ops = &tun_socket_ops;
 
 	sock_init_data(&tfile->socket, &tfile->sk);
-	sk_change_net(&tfile->sk, tfile->net);
+	put_net(sock_net(&tfile->sk));
 
 	tfile->sk.sk_write_space = tun_sock_write_space;
 	tfile->sk.sk_sndbuf = INT_MAX;
-- 
1.7.9.5
