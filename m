From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH v2] mt7601u: check memory allocation failure
Date: Tue, 22 Aug 2017 00:06:17 +0200
Message-ID: <20170821220617.21513-1-christophe.jaillet@wanadoo.fr>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: kubakici@wp.pl, kvalo@codeaurora.org, matthias.bgg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check memory allocation failure and return -ENOMEM in such a case, as
already done a few lines below.

As 'dev->tx_q' can be NULL, we also need to check for that in
'mt7601u_free_tx()', and return early.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
v2: avoid another NULL pointer dereference in 'mt7601u_free_tx()' if the
allocation had failed.
---
 drivers/net/wireless/mediatek/mt7601u/dma.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/wireless/mediatek/mt7601u/dma.c b/drivers/net/wireless/mediatek/mt7601u/dma.c
index 660267b359e4..7f3e3983b781 100644
--- a/drivers/net/wireless/mediatek/mt7601u/dma.c
+++ b/drivers/net/wireless/mediatek/mt7601u/dma.c
@@ -457,6 +457,9 @@ static void mt7601u_free_tx(struct mt7601u_dev *dev)
 {
 	int i;
 
+	if (!dev->tx_q)
+		return;
+
 	for (i = 0; i < __MT_EP_OUT_MAX; i++)
 		mt7601u_free_tx_queue(&dev->tx_q[i]);
 }
@@ -484,6 +487,8 @@ static int mt7601u_alloc_tx(struct mt7601u_dev *dev)
 
 	dev->tx_q = devm_kcalloc(dev->dev, __MT_EP_OUT_MAX,
 				 sizeof(*dev->tx_q), GFP_KERNEL);
+	if (!dev->tx_q)
+		return -ENOMEM;
 
 	for (i = 0; i < __MT_EP_OUT_MAX; i++)
 		if (mt7601u_alloc_tx_queue(dev, &dev->tx_q[i]))
-- 
2.11.0
