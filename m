From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] net: try harder to not reuse ifindex when moving interfaces
Date: Fri, 16 Oct 2015 13:07:59 +0200
Message-ID: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
Cc: Thomas Haller <thaller@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbbJPLIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 07:08:09 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 18AEA8EA37
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 11:08:09 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When moving interfaces to a different netns, the ifindex of the interface is
kept if possible. However, this is not kept in sync with allocation of new
interfaces in the target netns. While the ifindex will be skipped when
creating a new interface in the netns, it will be reused when the old
interface disappeared since.

This causes races for GUI tools in situations like this:

1. create netns 'new_netns'
2. in root netns, move the interface with ifindex 2 to new_netns
3. in new_netns, delete the interface with ifindex 2
4. in new_netns, create an interface - it will get ifindex 2

Ensure that newly allocated interfaces in a netns get ifindex higher than
any interface that has appeared in the netns. This of course does not fix
the reuse problem for the applications; it just makes it less likely to be
hit in common usage patterns.

Reported-by: Thomas Haller <thaller@redhat.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/core/dev.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6bb6470f5b7b..e3d05c20f0ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6137,6 +6137,23 @@ static int dev_new_index(struct net *net)
 	}
 }
 
+/**
+ *	dev_update_index - update the ifindex used for allocation
+ *	@net: the applicable net namespace
+ *	@ifindex: the assigned ifindex
+ *
+ *	Updates the notion of currently allocated maximal ifindex to
+ *	decrease likelihood of ifindex reuse when the ifindex was assigned
+ *	by other means than calling dev_new_index (e.g. when moving
+ *	interface across net namespaces).  The caller must hold the rtnl
+ *	semaphore or the dev_base_lock.
+ */
+static void dev_update_index(struct net *net, int ifindex)
+{
+	if (ifindex > net->ifindex)
+		net->ifindex = ifindex;
+}
+
 /* Delayed registration/unregisteration */
 static LIST_HEAD(net_todo_list);
 DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wq);
@@ -7262,6 +7279,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	/* If there is an ifindex conflict assign a new one */
 	if (__dev_get_by_index(net, dev->ifindex))
 		dev->ifindex = dev_new_index(net);
+	else
+		dev_update_index(net, dev->ifindex);
 
 	/* Send a netdev-add uevent to the new namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
-- 
1.8.3.1
