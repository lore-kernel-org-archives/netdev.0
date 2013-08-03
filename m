From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net v2 2/2] net_sched: make dev_trans_start return vlan's real dev trans_start
Date: Sat,  3 Aug 2013 22:07:47 +0200
Message-ID: <1375560467-1604-2-git-send-email-nikolay@redhat.com>
References: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, vfalico@redhat.com, fubar@us.ibm.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752925Ab3HCUL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Aug 2013 16:11:27 -0400
In-Reply-To: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>

Vlan devices are LLTX and don't update their own trans_start, so if
dev_trans_start has to be called with a vlan device then 0 or a stale
value will be returned. Currently the bonding is the only such user, and
it's needed for proper arp monitoring when the slaves are vlans.
Fix this by extracting the vlan's real device trans_start.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: drop the while, since vlan_dev_real_dev now does it for us

 net/sched/sch_generic.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4626cef..eeb8276 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -25,6 +25,7 @@
 #include <linux/rcupdate.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <linux/if_vlan.h>
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 #include <net/dst.h>
@@ -207,15 +208,19 @@ void __qdisc_run(struct Qdisc *q)
 
 unsigned long dev_trans_start(struct net_device *dev)
 {
-	unsigned long val, res = dev->trans_start;
+	unsigned long val, res;
 	unsigned int i;
 
+	if (is_vlan_dev(dev))
+		dev = vlan_dev_real_dev(dev);
+	res = dev->trans_start;
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		val = netdev_get_tx_queue(dev, i)->trans_start;
 		if (val && time_after(val, res))
 			res = val;
 	}
 	dev->trans_start = res;
+
 	return res;
 }
 EXPORT_SYMBOL(dev_trans_start);
-- 
1.8.1.4
