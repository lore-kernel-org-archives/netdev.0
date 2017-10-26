From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net] net/sched: fix NULL pointer dereference in qdisc_alloc()
Date: Thu, 26 Oct 2017 20:26:48 +0200
Message-ID: <acc2f5949d2ab4562be3c28a6131fecefbaf8db1.1509040243.git.dcaratti@redhat.com>
Cc: Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47858 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932309AbdJZS1M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 14:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the following script generates a NULL pointer dereference error:

ip l a name eth0 type dummy
tc q a dev eth0 parent :1 handle 1: htb

upon creation of classful qdiscs, qdisc_alloc() dereferences dev_queue->dev
assuming it is not NULL. This is not true when eth0 has been added, but not
yet set administratively up; a bisect test proved that Linux started making
NULL exception with the above two commands after commit 59cc1f61f09c ("net:
sched:convert qdisc linked list to hashtable"). Let qdisc_alloc() return -1
(-ENOENT) when a NULL value of dev_queue->dev is seen, so that non-crashing
behaviour observable in Linux 4.8 is restored.

Fixes: 59cc1f61f09c ("net: sched:convert qdisc linked list to hashtable")
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/sched/sch_generic.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index bf8c81e07c70..5fb96f43d951 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -605,6 +605,14 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	int err = -ENOBUFS;
 	struct net_device *dev = dev_queue->dev;
 
+	/* dev_queue->dev can be NULL, if device has been registered but not
+	 * (yet) set administratively up: test it to avoid NULL dereference.
+	 */
+	if (!dev) {
+		err = -ENOENT;
+		goto errout;
+	}
+
 	p = kzalloc_node(size, GFP_KERNEL,
 			 netdev_queue_numa_node_read(dev_queue));
 
-- 
2.13.6
