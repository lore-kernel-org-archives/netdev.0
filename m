From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vlan: fix a race in egress prio management
Date: Thu, 18 Jul 2013 09:35:10 -0700
Message-ID: <1374165310.6097.39.camel@edumazet-glaptop>
References: <1374157166.6097.28.camel@edumazet-glaptop>
	 <1374162570.6097.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:42007 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932427Ab3GRQfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 12:35:15 -0400
Received: by mail-ob0-f173.google.com with SMTP id wc20so3966147obb.32
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 09:35:14 -0700 (PDT)
In-Reply-To: <1374162570.6097.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

egress_priority_map[] hash table updates are protected by rtnl,
and we never remove elements until device is dismantled.

We have to make sure that before inserting an new element in hash table,
all its fields are committed to memory or else another cpu could
find corrupt values and crash.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/8021q/vlan_dev.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 3a8c8fd..1cd3d2a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -73,6 +73,8 @@ vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vlan_priority_tci_mapping *mp;
 
+	smp_rmb(); /* coupled with smp_wmb() in vlan_dev_set_egress_priority() */
+
 	mp = vlan_dev_priv(dev)->egress_priority_map[(skb->priority & 0xF)];
 	while (mp) {
 		if (mp->priority == skb->priority) {
@@ -249,6 +251,11 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 	np->next = mp;
 	np->priority = skb_prio;
 	np->vlan_qos = vlan_qos;
+	/* Before inserting this element in hash table, make sure all its fields
+	 * are committed to memory.
+	 * coupled with smp_rmb() in vlan_dev_get_egress_qos_mask()
+	 */
+	smp_wmb();
 	vlan->egress_priority_map[skb_prio & 0xF] = np;
 	if (vlan_qos)
 		vlan->nr_egress_mappings++;
