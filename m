From: Jiri Bohac <jbohac@suse.cz>
Subject: PATCH: fix bridged 802.3ad bonding
Date: Tue, 3 Jun 2008 15:21:06 +0200
Message-ID: <20080603132106.GA3256@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40398 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751526AbYFCOGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 10:06:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Bonding in 802.3ad mode breaks when the bond interface is added
to a bridge (which makes 802.3ad unusable in XEN, for example).

The problem is that br_pass_frame_up() will change the skb's dev
pointer to point to the bridge interface. As a result, the LACP
packets will not reach the bond_3ad_lacpdu_recv() protocol
handler registered on the bonding device. Even if they did, the
handler won't work with the changed skb->dev.

The following patch fixes the problem.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>


diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1832,6 +1832,32 @@ static inline struct net_device *skb_bond(struct sk_buff *skb)
 }
 
 
+/*
+ * If a bonding master interface in 802.3ad mode is part of a bridge,
+ * the bridging hook will mangle the skb->dev to the bridge device.
+ * The bonding 802.3ad protocol handler needs to access the original device,
+ * so fix this up for the 802.3ad packets.
+ */
+static inline void skb_fixup_bridged_bond(struct sk_buff *skb, struct net_device **orig_dev)
+{
+	if (unlikely(skb->protocol == __constant_htons(ETH_P_SLOW)) &&
+	    (skb->dev->priv_flags & IFF_EBRIDGE)) {
+		struct net_device *dev;
+
+		read_lock(&dev_base_lock);
+		dev = __dev_get_by_index(&init_net, skb->iif);
+		read_unlock(&dev_base_lock);
+
+		if (!dev)
+			return;
+
+		if (dev->master)
+			skb->dev = dev->master;
+
+		*orig_dev = dev;
+	}
+}
+
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
@@ -2080,6 +2106,8 @@ ncls:
 	if (!skb)
 		goto out;
 
+	skb_fixup_bridged_bond(skb, &orig_dev);
+
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

