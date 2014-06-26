From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 1/2] rtnetlink: allow to register ops without ops->setup set
Date: Thu, 26 Jun 2014 09:58:25 +0200
Message-ID: <1403769506-9212-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pshelar@nicira.com, cwang@twopensource.com,
	nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:56733 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbaFZH6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 03:58:33 -0400
Received: by mail-wg0-f48.google.com with SMTP id n12so3121341wgh.7
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 00:58:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, it is assumed that ops->setup is filled up. But there might be
case that ops might make sense even without ->setup. In that case,
forbid to newlink and dellink.

This allows to register simple rtnl link ops containing only ->kind.
That allows consistent way of passing device kind (either device-kind or
slave-kind) to userspace.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---

v2->v3: added check into default_device_exit_batch as pointed out by Eric

v1->v2: included comments from Eric fixing default_device_exit_batch,
	not checking setup in dellink and added hopefully clearer description
	and comment.

 net/core/dev.c       |  2 +-
 net/core/rtnetlink.c | 12 ++++++++++--
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a04b12f..d8f31a2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7091,7 +7091,7 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 	rtnl_lock_unregistering(net_list);
 	list_for_each_entry(net, net_list, exit_list) {
 		for_each_netdev_reverse(net, dev) {
-			if (dev->rtnl_link_ops)
+			if (dev->rtnl_link_ops && dev->rtnl_link_ops->dellink)
 				dev->rtnl_link_ops->dellink(dev, &dev_kill_list);
 			else
 				unregister_netdevice_queue(dev, &dev_kill_list);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1063996..27acaf7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -299,7 +299,12 @@ int __rtnl_link_register(struct rtnl_link_ops *ops)
 	if (rtnl_link_ops_get(ops->kind))
 		return -EEXIST;
 
-	if (!ops->dellink)
+	/* The check for setup is here because if ops
+	 * does not have that filled up, it is not possible
+	 * to use the ops for creating device. So do not
+	 * fill up dellink as well. That disables rtnl_dellink.
+	 */
+	if (ops->setup && !ops->dellink)
 		ops->dellink = unregister_netdevice_queue;
 
 	list_add_tail(&ops->list, &link_ops);
@@ -1777,7 +1782,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -ENODEV;
 
 	ops = dev->rtnl_link_ops;
-	if (!ops)
+	if (!ops || !ops->dellink)
 		return -EOPNOTSUPP;
 
 	ops->dellink(dev, &list_kill);
@@ -2038,6 +2043,9 @@ replay:
 			return -EOPNOTSUPP;
 		}
 
+		if (!ops->setup)
+			return -EOPNOTSUPP;
+
 		if (!ifname[0])
 			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
 
-- 
1.9.0
