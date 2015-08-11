From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: [PATCH] bonding: Gratuitous ARP gets dropped when first slave added
Date: Tue, 11 Aug 2015 07:57:23 -0700
Message-ID: <20150811145723.GA18921@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51671 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965020AbbHKO5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 10:57:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the first slave is added (such as during bootup) the first
gratuitous ARP gets dropped. We don't see this drop during a failover.
The packet gets dropped in qdisc (noop_enqueue).

The fix is to delay the sending of gratuitous ARPs till the bond dev's
carrier is present.

It can also be worked around by setting num_grat_arp to more than 1.

Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0c627b4..2d7d72c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -786,6 +786,7 @@ static bool bond_should_notify_peers(struct bonding *bond)
 		   slave ? slave->dev->name : "NULL");
 
 	if (!slave || !bond->send_peer_notif ||
+	    !netif_carrier_ok(bond->dev) ||
 	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
 		return false;
 
-- 
1.8.2.1
