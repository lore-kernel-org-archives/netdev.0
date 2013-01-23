From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 2/2] netpoll: use the net namespace of current process instead of init_net
Date: Wed, 23 Jan 2013 17:02:11 +0800
Message-ID: <1358931731-17438-2-git-send-email-amwang@redhat.com>
References: <1358931731-17438-1-git-send-email-amwang@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972Ab3AWJCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 04:02:48 -0500
In-Reply-To: <1358931731-17438-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This will allow us to setup netconsole in a different namespace
rather than where init_net is.

Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/netpoll.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a6f39b6..c3b2589 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -1046,11 +1046,16 @@ int netpoll_setup(struct netpoll *np)
 {
 	struct net_device *ndev = NULL;
 	struct in_device *in_dev;
+	struct net *net = &init_net;
+	struct nsproxy *ns = task_nsproxy(current);
 	int err;
 
 	rtnl_lock();
-	if (np->dev_name)
-		ndev = __dev_get_by_name(&init_net, np->dev_name);
+	if (np->dev_name) {
+		if (ns != NULL)
+			net = get_net(ns->net_ns);
+		ndev = __dev_get_by_name(net, np->dev_name);
+	}
 	if (!ndev) {
 		np_err(np, "%s doesn't exist, aborting\n", np->dev_name);
 		err = -ENODEV;
@@ -1159,6 +1164,8 @@ int netpoll_setup(struct netpoll *np)
 put:
 	dev_put(ndev);
 unlock:
+	if (net != &init_net)
+		put_net(net);
 	rtnl_unlock();
 	return err;
 }
-- 
1.7.7.6
