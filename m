From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net] bonding:update rlb entry for arp request
Date: Wed, 29 Feb 2012 21:55:36 +0800
Message-ID: <69d333c976553016d3dea2a4eab1c6d652366b27.1330523517.git.panweiping3@gmail.com>
References: <20120227173400.GB816@midget.suse.cz>
Cc: jbohac@suse.cz, fubar@us.ibm.com, andy@greyhouse.net,
	Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62064 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757996Ab2B2NvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 08:51:20 -0500
Received: by dajr28 with SMTP id r28so357220daj.19
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 05:51:20 -0800 (PST)
In-Reply-To: <20120227173400.GB816@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rlb_arp_recv() only handles arp reply packets,
but I think arp request packets contain the latest information about
clients(ip and mac), so we should update rlb entry for arp request.

This patch can resolve a problem that if an IP address is migrated to a
different host in the network, the corresponding rlb entry still contains the
old mac address for this IP, and bonding will send out invalid ARP packets
that will poison other systems' ARP caches.

Jiri Bohac <jbohac@suse.cz> found this problem and posted a patch,
but I don't know whether this patch can fix his problem.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_alb.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index f820b26..fe881a9 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -332,7 +332,6 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 	if ((client_info->assigned) &&
-	    (client_info->ip_src == arp->ip_dst) &&
 	    (client_info->ip_dst == arp->ip_src) &&
 	    (compare_ether_addr_64bits(client_info->mac_dst, arp->mac_src))) {
 		/* update the clients MAC address */
@@ -366,11 +365,9 @@ static void rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
 		return;
 	}
 
-	if (arp->op_code == htons(ARPOP_REPLY)) {
-		/* update rx hash table for this ARP */
-		rlb_update_entry_from_arp(bond, arp);
-		pr_debug("Server received an ARP Reply from client\n");
-	}
+	/* update rx hash table for this ARP */
+	rlb_update_entry_from_arp(bond, arp);
+	pr_debug("Server received an ARP Request/Reply from client\n");
 }
 
 /* Caller must hold bond lock for read */
-- 
1.7.4.4
