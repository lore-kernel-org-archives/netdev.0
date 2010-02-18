From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] smsc911x: convert to use netdev_for_each_mc_addr
Date: Thu, 18 Feb 2010 10:22:38 +0100
Message-ID: <20100218092238.GD2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, steve.glendinning@smsc.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752406Ab0BRJWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 04:22:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

also removed unnecessary checks

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/smsc911x.c |   27 +++++++++------------------
 1 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 13c0b76..4fd1d8b 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1383,29 +1383,20 @@ static void smsc911x_set_multicast_list(struct net_device *dev)
 		/* Enabling specific multicast addresses */
 		unsigned int hash_high = 0;
 		unsigned int hash_low = 0;
-		unsigned int count = 0;
-		struct dev_mc_list *mc_list = dev->mc_list;
+		struct dev_mc_list *mc_list;
 
 		pdata->set_bits_mask = MAC_CR_HPFILT_;
 		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_MCPAS_);
 
-		while (mc_list) {
-			count++;
-			if ((mc_list->dmi_addrlen) == ETH_ALEN) {
-				unsigned int bitnum =
-				    smsc911x_hash(mc_list->dmi_addr);
-				unsigned int mask = 0x01 << (bitnum & 0x1F);
-				if (bitnum & 0x20)
-					hash_high |= mask;
-				else
-					hash_low |= mask;
-			} else {
-				SMSC_WARNING(DRV, "dmi_addrlen != 6");
-			}
-			mc_list = mc_list->next;
+		netdev_for_each_mc_addr(mc_list, dev) {
+			unsigned int bitnum = smsc911x_hash(mc_list->dmi_addr);
+			unsigned int mask = 0x01 << (bitnum & 0x1F);
+
+			if (bitnum & 0x20)
+				hash_high |= mask;
+			else
+				hash_low |= mask;
 		}
-		if (count != (unsigned int)netdev_mc_count(dev))
-			SMSC_WARNING(DRV, "mc_count != dev->mc_count");
 
 		pdata->hashhi = hash_high;
 		pdata->hashlo = hash_low;
-- 
1.6.6

