From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 2/2] cxgb4: Fix for write-combining stats configuration
Date: Tue,  8 Sep 2015 16:25:40 +0530
Message-ID: <1441709740-7533-3-git-send-email-hariprasad@chelsio.com>
References: <1441709740-7533-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10078 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754346AbbIHKzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 06:55:45 -0400
In-Reply-To: <1441709740-7533-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The write-combining configuration register SGE_STAT_CFG_A needs to
be configured after FW initializes the adapter, else FW will reset
the configuration

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 592a4d6..f5dcde2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4719,8 +4719,6 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			err = -ENOMEM;
 			goto out_free_adapter;
 		}
-		t4_write_reg(adapter, SGE_STAT_CFG_A,
-			     STATSOURCE_T5_V(7) | STATMODE_V(0));
 	}
 
 	setup_memwin(adapter);
@@ -4732,6 +4730,11 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto out_unmap_bar;
 
+	/* configure SGE_STAT_CFG_A to read WC stats */
+	if (!is_t4(adapter->params.chip))
+		t4_write_reg(adapter, SGE_STAT_CFG_A,
+			     STATSOURCE_T5_V(7) | STATMODE_V(0));
+
 	for_each_port(adapter, i) {
 		struct net_device *netdev;
 
-- 
2.3.4
