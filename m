From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 02/13] stmmac: convert unicast addr list to list_head
Date: Thu,  7 Jan 2010 10:07:12 +0100
Message-ID: <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:49486 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756292Ab0AGJH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:29 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D584916B
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:23 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9E579BE8
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:23 +0000 (GMT)
In-Reply-To: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts unicast address list to standard list_head using
previously introduced struct netdev_hw_addr.

Note: this patch also removes a debug printk used for displaying the
mac addresses. Indeed, it's is possible to dump the registers with
ethtool.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/gmac.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/stmmac/gmac.c b/drivers/net/stmmac/gmac.c
index 52586ee..9828756 100644
--- a/drivers/net/stmmac/gmac.c
+++ b/drivers/net/stmmac/gmac.c
@@ -435,7 +435,7 @@ static void gmac_set_filter(struct net_device *dev)
 	unsigned int value = 0;
 
 	DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
-	    __func__, dev->mc_count, dev->uc_count);
+	    __func__, dev->mc_count, dev->uc.count);
 
 	if (dev->flags & IFF_PROMISC)
 		value = GMAC_FRAME_FILTER_PR;
@@ -469,25 +469,17 @@ static void gmac_set_filter(struct net_device *dev)
 	}
 
 	/* Handle multiple unicast addresses (perfect filtering)*/
-	if (dev->uc_count > GMAC_MAX_UNICAST_ADDRESSES)
+	if (dev->uc.count > GMAC_MAX_UNICAST_ADDRESSES)
 		/* Switch to promiscuous mode is more than 16 addrs
 		   are required */
 		value |= GMAC_FRAME_FILTER_PR;
 	else {
-		int i;
-		struct dev_addr_list *uc_ptr = dev->uc_list;
-
-			for (i = 0; i < dev->uc_count; i++) {
-				gmac_set_umac_addr(ioaddr, uc_ptr->da_addr,
-						i + 1);
-
-				DBG(KERN_INFO "\t%d "
-				"- Unicast addr %02x:%02x:%02x:%02x:%02x:"
-				"%02x\n", i + 1,
-				uc_ptr->da_addr[0], uc_ptr->da_addr[1],
-				uc_ptr->da_addr[2], uc_ptr->da_addr[3],
-				uc_ptr->da_addr[4], uc_ptr->da_addr[5]);
-				uc_ptr = uc_ptr->next;
+		int reg = 1;
+		struct netdev_hw_addr *ha;
+
+		list_for_each_entry(ha, &dev->uc.list, list) {
+			gmac_set_umac_addr(ioaddr, ha->addr, reg);
+			reg++;
 		}
 	}
 
-- 
1.6.0.4

