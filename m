From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] strip: neighbour table refcount leak
Date: Tue, 29 Aug 2006 14:59:36 -0700
Message-ID: <20060829145936.64db642c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stuart Cheshire <cheshire@cs.stanford.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31723 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965438AbWH2WAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 18:00:47 -0400
To: Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Found by inspection. The STRIP driver does neigh_lookup() but never releases.
This driver shouldn't being doing gratuitous arp anyway.
Untested, obviously, because of lack of hardware.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/drivers/net/wireless/strip.c
+++ linux-2.6/drivers/net/wireless/strip.c
@@ -467,6 +467,7 @@ static int arp_query(unsigned char *hadd
 		     struct net_device *dev)
 {
 	struct neighbour *neighbor_entry;
+	int ret = 0;
 
 	neighbor_entry = neigh_lookup(&arp_tbl, &paddr, dev);
 
@@ -474,10 +475,11 @@ static int arp_query(unsigned char *hadd
 		neighbor_entry->used = jiffies;
 		if (neighbor_entry->nud_state & NUD_VALID) {
 			memcpy(haddr, neighbor_entry->ha, dev->addr_len);
-			return 1;
+			ret = 1;
 		}
+		neigh_release(neighbor_entry);
 	}
-	return 0;
+	return ret;
 }
 
 static void DumpData(char *msg, struct strip *strip_info, __u8 * ptr,
