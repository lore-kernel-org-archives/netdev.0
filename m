From: Tom Herbert <therbert@google.com>
Subject: [PATCH] bonding: Fix corrupted queue_mapping
Date: Thu, 7 Jun 2012 22:05:42 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1206072201200.13686@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:45914 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758230Ab2FHFFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 01:05:45 -0400
Received: by eaao13 with SMTP id o13so81407eaa.1
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 22:05:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Fix is to set bond_queue_mapping to skb->cb +
sizeof((struct qdisc_skb_cb)

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/bonding/bond_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2ee8cf9..044c1c0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -76,6 +76,7 @@
 #include <net/route.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/sch_generic.h>
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -381,7 +382,8 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
 	return next;
 }
 
-#define bond_queue_mapping(skb) (*(u16 *)((skb)->cb))
+#define bond_queue_mapping(skb) (*(u16 *)((skb)->cb + \
+    sizeof(struct qdisc_skb_cb)))
 
 /**
  * bond_dev_queue_xmit - Prepare skb for xmit.
-- 
1.7.7.3
