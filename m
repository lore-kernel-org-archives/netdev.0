From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH v2 net-next] netlink: avoid namespace change while creating socket
Date: Wed, 6 May 2015 14:08:46 +0800
Message-ID: <1430892526-2446-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <herbert@gondor.apana.org.au>, <xemul@openvz.org>,
	<davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:34789 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbbEFGJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 02:09:07 -0400
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
and then re-attach it to the desired one right after the socket is
created; similarly, when close the socket, move back its namespace
to init_net so that the socket can be destroyed in the context which
is same as the socket creation.

Actually the proposal artificially makes the whole thing complex.
Instead there exists a simpler solution to avoid the risk of net
double release: if we find that the net reference counter reaches
zero before the reference counter will be increased in sk_alloc(),
we can identify that the process of the net namespace exit happening
in workqueue is not finished yet. At the moment, we should immediately
exit from sk_alloc() to avoid the risk. This is because once refcount
reaches zero, the net will be definetely destroyed later in workqueue
whatever we take its refcount or not. This solution is not only simple
and easily understandable, but also it can help to avoid the redundant
namespace change.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
v2 Changes:
  Kernel sockets should not hold a reference count to a namespace,
  otherwise, probably modules relying on them cannot be stopped. But
  we hold a reference on the net from sk allocated in sk_alloc() in
  previous version. In this version, we correct the wrong behaviour
  by putting the net reference count once sk is created successfully.

 net/core/sock.c          |    7 ++++++-
 net/netlink/af_netlink.c |   11 ++++++-----
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index e891bcf..9442387 100644
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
index ec4adbd..ca3f63a 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2475,15 +2475,15 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 
 	/*
 	 * We have to just have a reference on the net from sk, but don't
-	 * get_net it. Besides, we cannot get and then put the net here.
-	 * So we create one inside init_net and the move it to net.
+	 * get_net it as netlink kernel sockets are a part of the net. So
+	 * we put the net here and get it before release the socket.
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
