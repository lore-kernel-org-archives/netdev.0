From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net] enic: free all rq buffs when allocation fails
Date: Fri,  2 Jan 2015 20:53:27 +0530
Message-ID: <1420212207-30219-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:65521 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbbABPYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2015 10:24:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocation of all RQs fail, we do not free previously allocated buffers,
before returning error. This causes memory leak.

This patch fixes this by calling vnic_rq_clean(), which frees all the rq
buffers.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 705f334..b29e027 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1616,7 +1616,7 @@ static int enic_open(struct net_device *netdev)
 		if (vnic_rq_desc_used(&enic->rq[i]) == 0) {
 			netdev_err(netdev, "Unable to alloc receive buffers\n");
 			err = -ENOMEM;
-			goto err_out_notify_unset;
+			goto err_out_free_rq;
 		}
 	}
 
@@ -1649,7 +1649,9 @@ static int enic_open(struct net_device *netdev)
 
 	return 0;
 
-err_out_notify_unset:
+err_out_free_rq:
+	for (i = 0; i < enic->rq_count; i++)
+		vnic_rq_clean(&enic->rq[i], enic_free_rq_buf);
 	enic_dev_notify_unset(enic);
 err_out_free_intr:
 	enic_free_intr(enic);
-- 
2.2.1
