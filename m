From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next] netlink: avoid namespace change while creating socket
Date: Mon, 4 May 2015 17:22:19 +0800
Message-ID: <1430731339-22292-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <den@openvz.org>, <davem@davemloft.net>, <avagin@gmail.com>,
	<netdev@vger.kernel.org>
To: <herbert@gondor.apana.org.au>, <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45987 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbbEDJWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 05:22:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 23fe18669e7f ("[NETNS]: Fix race between put_net() and
netlink_kernel_create().") attempts to fix the following race
scenario:

put_net()
  if (atomic_dec_and_test(&net->refcnt))
    /* true */
      __put_net(net);
        queue_work(...);

/*
 * note: the net now has refcnt 0, but still in
 * the global list of net namespaces
 */

== re-schedule ==

register_pernet_subsys(&some_ops);
  register_pernet_operations(&some_ops);
    (*some_ops)->init(net);
      /*
       * we call netlink_kernel_create() here
       * in some places
       */
      netlink_kernel_create();
         sk_alloc();
            get_net(net); /* refcnt = 1 */
         /*
          * now we drop the net refcount not to
          * block the net namespace exit in the
          * future (or this can be done on the
          * error path)
          */
         put_net(sk->sk_net);
             if (atomic_dec_and_test(&...))
                   /*
                    * true. BOOOM! The net is
                    * scheduled for release twice
                    */

In order to prevent the race from happening, the commit adopted the
following solution: create netlink socket inside init_net namespace
and then re-attach it to the desired one right the socket is created;
similarly, when closing the socket, first move its namespace to
init_net so that the socket can be destroyed in the same context of
the socket creation.

Actually the proposal artificially makes the whole thing complex.
Instead there exists a simpler solution to avoid the risk of net
double release: if we find that the net reference counter reaches
zero before the reference counter is increased in sk_alloc(), we
can identify that the process of the net namespace exit happening
in workqueue is not finished yet. At the moment, we should immediately
exit from sk_alloc() to avoid the risk. The method is not only simple
and easily understandable, but also it can help to avoid the redundant
namespace change. After this, both creation and deletion of netlink
socket happen in its desired namespace all the time.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/sock.c          |    7 ++++++-
 net/netlink/af_netlink.c |   14 ++------------
 2 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index e891bcf..88fdf2c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1411,7 +1411,12 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		 */
 		sk->sk_prot = sk->sk_prot_creator = prot;
 		sock_lock_init(sk);
-		sock_net_set(sk, get_net(net));
+		net = maybe_get_net(net);
+		if (!net) {
+			sk_prot_free(prot, sk);
+			return NULL;
+		}
+		sock_net_set(sk, net);
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbd..3914662 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2473,17 +2473,10 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 	if (sock_create_lite(PF_NETLINK, SOCK_DGRAM, unit, &sock))
 		return NULL;
 
-	/*
-	 * We have to just have a reference on the net from sk, but don't
-	 * get_net it. Besides, we cannot get and then put the net here.
-	 * So we create one inside init_net and the move it to net.
-	 */
-
-	if (__netlink_create(&init_net, sock, cb_mutex, unit) < 0)
+	if (__netlink_create(net, sock, cb_mutex, unit) < 0)
 		goto out_sock_release_nosk;
 
 	sk = sock->sk;
-	sk_change_net(sk, net);
 
 	if (!cfg || cfg->groups < 32)
 		groups = 32;
@@ -2527,9 +2520,6 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 
 out_sock_release:
 	kfree(listeners);
-	netlink_kernel_release(sk);
-	return NULL;
-
 out_sock_release_nosk:
 	sock_release(sock);
 	return NULL;
@@ -2539,7 +2529,7 @@ EXPORT_SYMBOL(__netlink_kernel_create);
 void
 netlink_kernel_release(struct sock *sk)
 {
-	sk_release_kernel(sk);
+	sock_release(sk->sk_socket);
 }
 EXPORT_SYMBOL(netlink_kernel_release);
 
-- 
1.7.9.5
