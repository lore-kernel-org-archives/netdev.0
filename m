From: cooldavid@cooldavid.org
Subject: [PATCH net-2.6 2/3] jme: Adding lock to protect vlgrp structure.
Date: Mon, 15 Mar 2010 13:15:07 +0800
Message-ID: <1268630108-10374-2-git-send-email-cooldavid@cooldavid.org>
References: <1268630108-10374-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:53308 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932496Ab0COFVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Mar 2010 01:21:10 -0400
In-Reply-To: <1268630108-10374-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Adding a lock to prevent modifying the vlgrp structure while receiving
VLAN packet.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |    6 ++++++
 drivers/net/jme.h |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index cfc7b98..9096bbd 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -942,11 +942,14 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, int idx)
 			skb->ip_summed = CHECKSUM_NONE;
 
 		if (rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_TAGON)) {
+			spin_lock(&jme->vlgrp_lock);
 			if (jme->vlgrp) {
 				jme->jme_vlan_rx(skb, jme->vlgrp,
 					le16_to_cpu(rxdesc->descwb.vlan));
+				spin_unlock(&jme->vlgrp_lock);
 				NET_STAT(jme).rx_bytes += 4;
 			} else {
+				spin_unlock(&jme->vlgrp_lock);
 				dev_kfree_skb(skb);
 			}
 		} else {
@@ -2088,7 +2091,9 @@ jme_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
 
+	spin_lock_bh(&jme->vlgrp_lock);
 	jme->vlgrp = grp;
+	spin_unlock_bh(&jme->vlgrp_lock);
 }
 
 static void
@@ -2755,6 +2760,7 @@ jme_init_one(struct pci_dev *pdev,
 	spin_lock_init(&jme->phy_lock);
 	spin_lock_init(&jme->macaddr_lock);
 	spin_lock_init(&jme->rxmcs_lock);
+	spin_lock_init(&jme->vlgrp_lock);
 
 	atomic_set(&jme->link_changing, 1);
 	atomic_set(&jme->rx_cleaning, 1);
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index c19db91..0ed4924 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -393,6 +393,7 @@ struct jme_adapter {
 	spinlock_t		phy_lock;
 	spinlock_t		macaddr_lock;
 	spinlock_t		rxmcs_lock;
+	spinlock_t		vlgrp_lock;
 	struct tasklet_struct	rxempty_task;
 	struct tasklet_struct	rxclean_task;
 	struct tasklet_struct	txclean_task;
-- 
1.6.4.4

