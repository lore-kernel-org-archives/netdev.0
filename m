From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 2.6.36 stable] vlan: Avoid hwaccel vlan packets when vid not used.
Date: Mon,  8 Nov 2010 13:23:01 -0800
Message-ID: <1289251381-6671-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56067 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232Ab0KHVXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:23:09 -0500
Received: by fxm16 with SMTP id 16so4424607fxm.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 13:23:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Normally hardware accelerated vlan packets are quickly dropped if
there is no corresponding vlan device configured.  The one exception
is promiscuous mode, where we allow all of these packets through so
they can be picked up by tcpdump.  However, this behavior causes a
crash if we actually try to receive these packets.  This fixes that
crash by ignoring packets with vids not corresponding to a configured
device in the vlan hwaccel routines and then dropping them before they
get to consumers in the network stack.

This patch applies only to 2.6.36 stable.  The problem was introduced
in that release and is already fixed by larger changes to the vlan
code in 2.6.37.

Reported-by: Ben Greear <greearb@candelatech.com>
Tested-by: Nikola Ciprich <extmaillist@linuxbox.cz>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/8021q/vlan_core.c |    3 +++
 net/core/dev.c        |   13 +++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 0eb96f7..2dcff0b 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -43,6 +43,9 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct vlan_rx_stats     *rx_stats;
 
+	if (unlikely(!is_vlan_dev(dev)))
+		return 0;
+
 	skb->dev = vlan_dev_info(dev)->real_dev;
 	netif_nit_deliver(skb);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 660dd41..dd72996 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2891,6 +2891,19 @@ static int __netif_receive_skb(struct sk_buff *skb)
 ncls:
 #endif
 
+	/* If we got this far with a hardware accelerated VLAN tag, it means
+	 * that we were put in promiscuous mode but nobody is interested in
+	 * this vid.  Drop the packet now to prevent it from getting propagated
+	 * to other parts of the stack that won't know how to deal with packets
+	 * tagged in this manner.
+	 */
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		if (pt_prev)
+			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+		kfree_skb(skb);
+		goto out;
+	}
+
 	/* Handle special case of bridge or macvlan */
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
-- 
1.7.1

