From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 01/11] netns: Fix race between put_net() and netlink_kernel_create()
Date: Thu, 7 May 2015 16:52:40 +0800
Message-ID: <1430988770-28907-2-git-send-email-ying.xue@windriver.com>
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
Received: from mail.windriver.com ([147.11.1.11]:40516 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbbEGIxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:33 -0400
In-Reply-To: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
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
double release: if we find there is still pending a cleanup work
in __put_net(), we don't queue a new cleanup work again. The solution
is not only simple and easily understandable, but also it can help us
to avoid unnecessary namespace change for kernel sockets which will
be made in the future commits.

Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/net_namespace.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 78fc04a..058508f 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -242,6 +242,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	net->dev_base_seq = 1;
 	net->user_ns = user_ns;
 	idr_init(&net->netns_ids);
+	INIT_LIST_HEAD(&net->cleanup_list);
 
 	list_for_each_entry(ops, &pernet_list, list) {
 		error = ops_init(ops, net);
@@ -409,12 +410,17 @@ void __put_net(struct net *net)
 {
 	/* Cleanup the network namespace in process context */
 	unsigned long flags;
+	bool added = false;
 
 	spin_lock_irqsave(&cleanup_list_lock, flags);
-	list_add(&net->cleanup_list, &cleanup_list);
+	if (list_empty(&net->cleanup_list)) {
+		list_add(&net->cleanup_list, &cleanup_list);
+		added = true;
+	}
 	spin_unlock_irqrestore(&cleanup_list_lock, flags);
 
-	queue_work(netns_wq, &net_cleanup_work);
+	if (added)
+		queue_work(netns_wq, &net_cleanup_work);
 }
 EXPORT_SYMBOL_GPL(__put_net);
 
-- 
1.7.9.5
