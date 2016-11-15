From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 9/9] alx: enable multiple tx queues
Date: Tue, 15 Nov 2016 12:43:16 +0100
Message-ID: <25fa5d0b1d851bc05009e037e103b11075311e48.1479208630.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36494 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753090AbcKOLnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:42 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so24866503wma.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:42 -0800 (PST)
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable multiple tx queues by default based on the number of online cpus. The
hardware supports up to four tx queues.

Based on the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 91c9149ab3f2..c8f525574d68 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -834,7 +834,7 @@ static bool alx_enable_msix(struct alx_priv *alx)
 {
 	int i, err, num_vec, num_txq, num_rxq;
 
-	num_txq = 1;
+	num_txq = min_t(int, num_online_cpus(), ALX_MAX_TX_QUEUES);
 	num_rxq = 1;
 	num_vec = max_t(int, num_txq, num_rxq) + 1;
 
@@ -1241,6 +1241,9 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 	if (err)
 		goto out_free_rings;
 
+	netif_set_real_num_tx_queues(alx->dev, alx->num_txq);
+	netif_set_real_num_rx_queues(alx->dev, alx->num_rxq);
+
 	/* clear old interrupts */
 	alx_write_mem32(&alx->hw, ALX_ISR, ~(u32)ALX_ISR_DIS);
 
@@ -1749,7 +1752,8 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_pci_release;
 	}
 
-	netdev = alloc_etherdev(sizeof(*alx));
+	netdev = alloc_etherdev_mqs(sizeof(*alx),
+				    ALX_MAX_TX_QUEUES, 1);
 	if (!netdev) {
 		err = -ENOMEM;
 		goto out_pci_release;
-- 
2.7.4
