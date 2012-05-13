From: David Miller <davem@davemloft.net>
Subject: bonding: Fix LACPDU rx_dropped commit.
Date: Sun, 13 May 2012 15:49:23 -0400 (EDT)
Message-ID: <20120513.154923.2118195000949421378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab2EMTvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2012 15:51:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I applied the wrong version of Jiri's bonding fix in commit
13a8e0c8cdb43982372bd6c65fb26839c8fd8ce9 ("bonding: don't increase
rx_dropped after processing LACPDUs")

I applied v3, which introduces warnings I asked him to fix,
instead of v4 which properly takes care of those issues.

This inter-diffs such that the warnings are now gone.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I'm still trying to figure out how I mistakenly put v3 into my tree
instead of v4, must be some kind of sorcery or curse that I'm not
familiar with.

 drivers/net/bonding/bond_alb.c |   12 +++++++-----
 drivers/net/bonding/bonding.h  |    2 +-
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9abfde4..2e1f806 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -342,26 +342,26 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 	_unlock_rx_hashtbl_bh(bond);
 }
 
-static void rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
+static int rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave)
 {
 	struct arp_pkt *arp;
 
 	if (skb->protocol != cpu_to_be16(ETH_P_ARP))
-		return;
+		goto out;
 
 	arp = (struct arp_pkt *) skb->data;
 	if (!arp) {
 		pr_debug("Packet has no ARP data\n");
-		return;
+		goto out;
 	}
 
 	if (!pskb_may_pull(skb, arp_hdr_len(bond->dev)))
-		return;
+		goto out;
 
 	if (skb->len < sizeof(struct arp_pkt)) {
 		pr_debug("Packet is too small to be an ARP\n");
-		return;
+		goto out;
 	}
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
@@ -369,6 +369,8 @@ static void rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
 		rlb_update_entry_from_arp(bond, arp);
 		pr_debug("Server received an ARP Reply from client\n");
 	}
+out:
+	return RX_HANDLER_ANOTHER;
 }
 
 /* Caller must hold bond lock for read */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 9f2bae66..4581aa5 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -218,7 +218,7 @@ struct bonding {
 	struct   slave *primary_slave;
 	bool     force_primary;
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
-	void     (*recv_probe)(struct sk_buff *, struct bonding *,
+	int     (*recv_probe)(struct sk_buff *, struct bonding *,
 			       struct slave *);
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
-- 
1.7.10.1
