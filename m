From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH v2 net 1/3] bnxt_en: Fixed incorrect implementation of ndo_set_mac_address
Date: Wed, 2 Dec 2015 01:54:06 -0500
Message-ID: <1449039248-8745-2-git-send-email-mchan@broadcom.com>
References: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jeffrey Huang <huangjw@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:29885 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbLBGyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 01:54:09 -0500
In-Reply-To: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

The existing ndo_set_mac_address only copies the new MAC addr
and didn't set the new MAC addr to the HW. The correct way is
to delete the existing default MAC filter from HW and add
the new one. Because of RFS filters are also dependent on the
default mac filter l2 context, the driver must go thru
close_nic() to delete the default MAC and RFS filters, then
open_nic() to set the default MAC address to HW.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index db15c5e..651b587 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5212,13 +5212,22 @@ init_err:
 static int bnxt_change_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
+	struct bnxt *bp = netdev_priv(dev);
+	int rc = 0;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	if (ether_addr_equal(addr->sa_data, dev->dev_addr))
+		return 0;
+
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	if (netif_running(dev)) {
+		bnxt_close_nic(bp, false, false);
+		rc = bnxt_open_nic(bp, false, false);
+	}
 
-	return 0;
+	return rc;
 }
 
 /* rtnl_lock held */
-- 
1.8.3.1
