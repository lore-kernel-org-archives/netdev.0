From: Vlastimil Setka <setka@vsis.cz>
Subject: Altera TSE (altera_tse) - tx_fifo_depth init bug
Date: Tue, 27 Jan 2015 22:26:03 +0100
Message-ID: <54C8026B.9070607@vsis.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	rfi@lists.rocketboards.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.spsostrov.cz ([217.117.209.230]:36447 "EHLO
	mail.spsostrov.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759159AbbA0V0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 16:26:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have discovered a bug in Altera TSE (altera_tse) ethernet driver.

In altera_tse_main.c, function altera_tse_probe:

	if (of_property_read_u32(pdev->dev.of_node, "tx-fifo-depth",
				 &priv->rx_fifo_depth)) {

the TX related "tx-fifo-depth" is read from device tree, but by mistake 
written to RX related struct member rx_fifo_depth instead of correct 
tx_fifo_depth.

https://github.com/torvalds/linux/blob/master/drivers/net/ethernet/altera/altera_tse_main.c#L1401

I am not sure about impact of this bug, but it seems that 
priv->tx_fifo_depth is left uninitialised which is definitely not OK.

[PATCH 1/1] Altera TSE: Fix priv->tx_fifo_depth initialization

This patch fixes priv->tx_fifo_depth initialization in altera_tse_probe().
The "tx-fifo-depth" attribute was read again into rx_fifo_depth instead 
of correct tx_fifo_depth probably because of copy-and-paste typo,
and tx_fifo_depth was left uninitialised.

Signed-off-by: Vlastimil Setka <setka@vsis.cz>
---
  drivers/net/ethernet/altera/altera_tse_main.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c 
b/drivers/net/ethernet/altera/altera_tse_main.c
index 760c72c..f3d784a 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1399,7 +1399,7 @@ static int altera_tse_probe(struct platform_device 
*pdev)
         }

         if (of_property_read_u32(pdev->dev.of_node, "tx-fifo-depth",
-                                &priv->rx_fifo_depth)) {
+                                &priv->tx_fifo_depth)) {
                 dev_err(&pdev->dev, "cannot obtain tx-fifo-depth\n");
                 ret = -ENXIO;
                 goto err_free_netdev;
--
1.8.1.2


Regards,
Vlastimil Setka
