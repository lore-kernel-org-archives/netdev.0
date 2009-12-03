From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 3/7] net: Allow xfrm_user_net_exit to batch efficiently.
Date: Thu,  3 Dec 2009 04:29:05 -0800
Message-ID: <1259843349-3810-3-git-send-email-ebiederm@xmission.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56945 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbZLCM30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:29:26 -0500
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

xfrm.nlsk is provided by the xfrm_user module and is access via rcu from
other parts of the xfrm code.  Add xfrm.nlsk_stash a copy of xfrm.nlsk that
will never be set to NULL.  This allows the synchronize_net and
netlink_kernel_release to be deferred until a whole batch of xfrm.nlsk sockets
have been set to NULL.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_user.c     |   18 ++++++++++--------
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 1ba9127..56f8e55 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -43,6 +43,7 @@ struct netns_xfrm {
 	struct work_struct	policy_hash_work;
 
 	struct sock		*nlsk;
+	struct sock		*nlsk_stash;
 
 	u32			sysctl_aevent_etime;
 	u32			sysctl_aevent_rseqth;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index fb42d77..1ada618 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2721,22 +2721,24 @@ static int __net_init xfrm_user_net_init(struct net *net)
 				     xfrm_netlink_rcv, NULL, THIS_MODULE);
 	if (nlsk == NULL)
 		return -ENOMEM;
+	net->xfrm.nlsk_stash = nlsk; /* Don't set to NULL */
 	rcu_assign_pointer(net->xfrm.nlsk, nlsk);
 	return 0;
 }
 
-static void __net_exit xfrm_user_net_exit(struct net *net)
+static void __net_exit xfrm_user_net_exit(struct list_head *net_exit_list)
 {
-	struct sock *nlsk = net->xfrm.nlsk;
-
-	rcu_assign_pointer(net->xfrm.nlsk, NULL);
-	synchronize_rcu();
-	netlink_kernel_release(nlsk);
+	struct net *net;
+	list_for_each_entry(net, net_exit_list, exit_list)
+		rcu_assign_pointer(net->xfrm.nlsk, NULL);
+	synchronize_net();
+	list_for_each_entry(net, net_exit_list, exit_list)
+		netlink_kernel_release(net->xfrm.nlsk_stash);
 }
 
 static struct pernet_operations xfrm_user_net_ops = {
-	.init = xfrm_user_net_init,
-	.exit = xfrm_user_net_exit,
+	.init	    = xfrm_user_net_init,
+	.exit_batch = xfrm_user_net_exit,
 };
 
 static int __init xfrm_user_init(void)
-- 
1.6.5.2.143.g8cc62

