From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 5/6] netlink: Create kernel netlink sockets in the proper network namespace
Date: Fri, 08 May 2015 21:11:33 -0500
Message-ID: <874mnm1ove.fsf_-_@x220.int.ebiederm.org>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:35163 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbbEICQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 22:16:07 -0400
In-Reply-To: <87383633pu.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 08 May 2015 21:05:33 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Utilize the new functionality of sk_alloc so that nothing needs to be
done to suprress the reference counting on kernel sockets.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netlink/af_netlink.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d0a82b412b24..5e3883bad65a 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2473,16 +2473,11 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 
 	if (sock_create_lite(PF_NETLINK, SOCK_DGRAM, unit, &sock))
 		return NULL;
-	/*
-	 * We have to just have a reference on the net from sk, but don't
-	 * get_net it. Besides, we cannot get and then put the net here.
-	 * So we create one inside init_net and the move it to net.
-	 */
-	if (__netlink_create(&init_net, sock, cb_mutex, unit, 0) < 0)
+
+	if (__netlink_create(net, sock, cb_mutex, unit, 1) < 0)
 		goto out_sock_release_nosk;
 
 	sk = sock->sk;
-	sk_change_net(sk, net);
 
 	if (!cfg || cfg->groups < 32)
 		groups = 32;
@@ -2538,7 +2533,10 @@ EXPORT_SYMBOL(__netlink_kernel_create);
 void
 netlink_kernel_release(struct sock *sk)
 {
-	sk_release_kernel(sk);
+	if (sk == NULL || sk->sk_socket == NULL)
+		return;
+
+	sock_release(sk->sk_socket);
 }
 EXPORT_SYMBOL(netlink_kernel_release);
 
-- 
2.2.1
