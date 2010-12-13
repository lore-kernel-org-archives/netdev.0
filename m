From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 1/3] bonding/vlan: Remove redundant VLAN tag
 insertion logic
Date: Mon, 13 Dec 2010 18:19:28 +0000
Message-ID: <1292264368.9860.13.camel@bwh-desktop>
References: <1292264216.9860.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:35320 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145Ab0LMSTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 13:19:31 -0500
In-Reply-To: <1292264216.9860.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bond may have a mixture of slave devices with and without hardware
VLAN tag insertion capability.  Therefore it always claims this
capability and performs software VLAN tag insertion if the slave does
not.

Since commit 7b9c60903714bf0a19d746b228864bad3497284e, this has
also been done by dev_hard_start_xmit().  The result is that VLAN-
tagged skbs are now double-tagged when transmitted through slave
devices without hardware VLAN tag insertion!

Remove the now-redundant logic from bond_dev_queue_xmit().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/bonding/bond_main.c |   27 +--------------------------
 1 files changed, 1 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d0ea760..ef370c9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -418,36 +418,11 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
  * @bond: bond device that got this skb for tx.
  * @skb: hw accel VLAN tagged skb to transmit
  * @slave_dev: slave that is supposed to xmit this skbuff
- *
- * When the bond gets an skb to transmit that is
- * already hardware accelerated VLAN tagged, and it
- * needs to relay this skb to a slave that is not
- * hw accel capable, the skb needs to be "unaccelerated",
- * i.e. strip the hwaccel tag and re-insert it as part
- * of the payload.
  */
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 			struct net_device *slave_dev)
 {
-	unsigned short uninitialized_var(vlan_id);
-
-	/* Test vlan_list not vlgrp to catch and handle 802.1p tags */
-	if (!list_empty(&bond->vlan_list) &&
-	    !(slave_dev->features & NETIF_F_HW_VLAN_TX) &&
-	    vlan_get_tag(skb, &vlan_id) == 0) {
-		skb->dev = slave_dev;
-		skb = vlan_put_tag(skb, vlan_id);
-		if (!skb) {
-			/* vlan_put_tag() frees the skb in case of error,
-			 * so return success here so the calling functions
-			 * won't attempt to free is again.
-			 */
-			return 0;
-		}
-	} else {
-		skb->dev = slave_dev;
-	}
-
+	skb->dev = slave_dev;
 	skb->priority = 1;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	if (unlikely(bond->dev->priv_flags & IFF_IN_NETPOLL)) {
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

