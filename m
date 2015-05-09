From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/6] tun: Utilize the normal socket network namespace refcounting.
Date: Fri, 08 May 2015 21:07:08 -0500
Message-ID: <87vbg21p2r.fsf_-_@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
	<20150509011339.GA19116@gondor.apana.org.au>
	<87383633pu.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ying Xue <ying.xue@windriver.com>, netdev@vger.kernel.org,
	cwang@twopensource.com, xemul@openvz.org, eric.dumazet@gmail.com,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37601 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbbEICLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 22:11:42 -0400
In-Reply-To: <87383633pu.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 08 May 2015 21:05:33 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is no need for tun to do the weird network namespace refcounting.
The existing network namespace refcounting in tfile has almost exactly
the same lifetime.  So rewrite the code to use the struct sock network
namespace refcounting and remove the unnecessary hand rolled network
namespace refcounting and the unncesary tfile->net.

This change allows the tun code to directly call sock_put bypassing
sock_release and making SOCK_EXTERNALLY_ALLOCATED unnecessary.

Remove the now unncessary tun_release so that if anything tries to use
the sock_release code path the kernel will oops, and let us know about
the bug.

The macvtap code already uses it's internal socket this way.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/tun.c   | 24 ++++--------------------
 include/linux/net.h |  1 -
 net/socket.c        |  3 ---
 3 files changed, 4 insertions(+), 24 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e470ae59d405..3262f3e2b8b2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -146,7 +146,6 @@ struct tun_file {
 	struct socket socket;
 	struct socket_wq wq;
 	struct tun_struct __rcu *tun;
-	struct net *net;
 	struct fasync_struct *fasync;
 	/* only used for fasnyc */
 	unsigned int flags;
@@ -493,10 +492,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 			    tun->dev->reg_state == NETREG_REGISTERED)
 				unregister_netdevice(tun->dev);
 		}
-
-		BUG_ON(!test_bit(SOCK_EXTERNALLY_ALLOCATED,
-				 &tfile->socket.flags));
-		sk_release_kernel(&tfile->sk);
+		sock_put(&tfile->sk);
 	}
 }
 
@@ -1492,18 +1488,10 @@ out:
 	return ret;
 }
 
-static int tun_release(struct socket *sock)
-{
-	if (sock->sk)
-		sock_put(sock->sk);
-	return 0;
-}
-
 /* Ops structure to mimic raw sockets with tun */
 static const struct proto_ops tun_socket_ops = {
 	.sendmsg = tun_sendmsg,
 	.recvmsg = tun_recvmsg,
-	.release = tun_release,
 };
 
 static struct proto tun_proto = {
@@ -1865,7 +1853,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	if (cmd == TUNSETIFF && !tun) {
 		ifr.ifr_name[IFNAMSIZ-1] = '\0';
 
-		ret = tun_set_iff(tfile->net, file, &ifr);
+		ret = tun_set_iff(sock_net(&tfile->sk), file, &ifr);
 
 		if (ret)
 			goto unlock;
@@ -2154,16 +2142,16 @@ out:
 
 static int tun_chr_open(struct inode *inode, struct file * file)
 {
+	struct net *net = current->nsproxy->net_ns;
 	struct tun_file *tfile;
 
 	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
 
-	tfile = (struct tun_file *)sk_alloc(&init_net, AF_UNSPEC, GFP_KERNEL,
+	tfile = (struct tun_file *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
 					    &tun_proto);
 	if (!tfile)
 		return -ENOMEM;
 	RCU_INIT_POINTER(tfile->tun, NULL);
-	tfile->net = get_net(current->nsproxy->net_ns);
 	tfile->flags = 0;
 	tfile->ifindex = 0;
 
@@ -2174,13 +2162,11 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	tfile->socket.ops = &tun_socket_ops;
 
 	sock_init_data(&tfile->socket, &tfile->sk);
-	sk_change_net(&tfile->sk, tfile->net);
 
 	tfile->sk.sk_write_space = tun_sock_write_space;
 	tfile->sk.sk_sndbuf = INT_MAX;
 
 	file->private_data = tfile;
-	set_bit(SOCK_EXTERNALLY_ALLOCATED, &tfile->socket.flags);
 	INIT_LIST_HEAD(&tfile->next);
 
 	sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
@@ -2191,10 +2177,8 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 static int tun_chr_close(struct inode *inode, struct file *file)
 {
 	struct tun_file *tfile = file->private_data;
-	struct net *net = tfile->net;
 
 	tun_detach(tfile, true);
-	put_net(net);
 
 	return 0;
 }
diff --git a/include/linux/net.h b/include/linux/net.h
index 738ea48be889..8a5e81d2bdf7 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -38,7 +38,6 @@ struct net;
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
-#define SOCK_EXTERNALLY_ALLOCATED 5
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff --git a/net/socket.c b/net/socket.c
index 884e32997698..b5f1f43ed8f4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -576,9 +576,6 @@ void sock_release(struct socket *sock)
 	if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
 		pr_err("%s: fasync list not empty!\n", __func__);
 
-	if (test_bit(SOCK_EXTERNALLY_ALLOCATED, &sock->flags))
-		return;
-
 	this_cpu_sub(sockets_in_use, 1);
 	if (!sock->file) {
 		iput(SOCK_INODE(sock));
-- 
2.2.1
