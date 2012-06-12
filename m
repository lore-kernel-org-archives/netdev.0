From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] bonding: Fix corrupted queue_mapping
Date: Tue, 12 Jun 2012 18:03:51 +0200
Message-ID: <1339517031.22704.202.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Roland Dreier <roland@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63004 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495Ab2FLQD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 12:03:56 -0400
Received: by eeit10 with SMTP id t10so2279123eei.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 09:03:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In the transmit path of the bonding driver, skb->cb is used to
stash the skb->queue_mapping so that the bonding device can set its
own queue mapping.  This value becomes corrupted since the skb->cb is
also used in __dev_xmit_skb.

When transmitting through bonding driver, bond_select_queue is
called from dev_queue_xmit.  In bond_select_queue the original
skb->queue_mapping is copied into skb->cb (via bond_queue_mapping)
and skb->queue_mapping is overwritten with the bond driver queue.

Subsequently in dev_queue_xmit, __dev_xmit_skb is called which writes
the packet length into skb->cb, thereby overwriting the stashed
queue mappping.  In bond_dev_queue_xmit (called from hard_start_xmit),
the queue mapping for the skb is set to the stashed value which is now
the skb length and hence is an invalid queue for the slave device.

If we want to save skb->queue_mapping into skb->cb[], best place is to
add a field in struct qdisc_skb_cb, to make sure it wont conflict with
other layers (eg : Qdiscc, Infiniband...)

This patchs also makes sure (struct qdisc_skb_cb)->data is aligned on 8
bytes :

netem qdisc for example assumes it can store an u64 in it, without
misalignment penalty.

Note : we only have 20 bytes left in (struct qdisc_skb_cb)->data[].
The largest user is CHOKe and it fills it.

Based on a previous patch from Tom Herbert.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Tom Herbert <therbert@google.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Roland Dreier <roland@kernel.org>
---
 drivers/net/bonding/bond_main.c |    9 +++++----
 include/net/sch_generic.h       |    7 +++++--
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2ee8cf9..b9c2ae6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -76,6 +76,7 @@
 #include <net/route.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/pkt_sched.h>
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -381,8 +382,6 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
 	return next;
 }
 
-#define bond_queue_mapping(skb) (*(u16 *)((skb)->cb))
-
 /**
  * bond_dev_queue_xmit - Prepare skb for xmit.
  *
@@ -395,7 +394,9 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 {
 	skb->dev = slave_dev;
 
-	skb->queue_mapping = bond_queue_mapping(skb);
+	BUILD_BUG_ON(sizeof(skb->queue_mapping) !=
+		     sizeof(qdisc_skb_cb(skb)->bond_queue_mapping));
+	skb->queue_mapping = qdisc_skb_cb(skb)->bond_queue_mapping;
 
 	if (unlikely(netpoll_tx_running(slave_dev)))
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
@@ -4171,7 +4172,7 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 	/*
 	 * Save the original txq to restore before passing to the driver
 	 */
-	bond_queue_mapping(skb) = skb->queue_mapping;
+	qdisc_skb_cb(skb)->bond_queue_mapping = skb->queue_mapping;
 
 	if (unlikely(txq >= dev->real_num_tx_queues)) {
 		do {
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 55ce96b..9d7d54a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -220,13 +220,16 @@ struct tcf_proto {
 
 struct qdisc_skb_cb {
 	unsigned int		pkt_len;
-	unsigned char		data[24];
+	u16			bond_queue_mapping;
+	u16			_pad;
+	unsigned char		data[20];
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
 {
 	struct qdisc_skb_cb *qcb;
-	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(unsigned int) + sz);
+
+	BUILD_BUG_ON(sizeof(skb->cb) < offsetof(struct qdisc_skb_cb, data) + sz);
 	BUILD_BUG_ON(sizeof(qcb->data) < sz);
 }
 
