From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH 1/3] bonding: Incorrect TX queue offset
Date: Mon, 14 Mar 2011 09:22:04 -0700
Message-ID: <1300119726-17529-2-git-send-email-kernel@linuxace.com>
References: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net,
	Phil Oester <kernel@linuxace.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42286 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171Ab1CNQWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 12:22:45 -0400
Received: by mail-qw0-f46.google.com with SMTP id 3so1404142qwk.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 09:22:45 -0700 (PDT)
In-Reply-To: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When packets come in from a device with >= 16 receive queues
headed out a bonding interface, syslog gets filled with this:

    kernel: bond0 selects TX queue 16, but real number of TX queues is 16

because queue_mapping is offset by 1.  Adjust return value
to account for the offset.

This is a revision of my earlier patch (which did not use the
skb_rx_queue_* helpers - thanks to Ben for the suggestion).
Andy submitted a similar patch which emits a pr_warning on
invalid queue selection, but I believe the log spew is
not useful.  We can revisit that question in the future,
but in the interim I believe fixing the core problem is
worthwhile.

Signed-off-by: Phil Oester <kernel@linuxace.com>
---
 drivers/net/bonding/bond_main.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3ad4f50..a93d941 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4341,11 +4341,18 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	/*
 	 * This helper function exists to help dev_pick_tx get the correct
-	 * destination queue.  Using a helper function skips the a call to
+	 * destination queue.  Using a helper function skips a call to
 	 * skb_tx_hash and will put the skbs in the queue we expect on their
 	 * way down to the bonding driver.
 	 */
-	return skb->queue_mapping;
+	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
+
+	if (unlikely(txq >= dev->real_num_tx_queues)) {
+		do
+			txq -= dev->real_num_tx_queues;
+		while (txq >= dev->real_num_tx_queues);
+	}
+	return txq;
 }
 
 static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
1.7.4

