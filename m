From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next 5/8] net/wan/fsl_ucc_hdlc: call qe_setbrg only for loopback mode
Date: Wed, 17 May 2017 17:24:36 +0200
Message-ID: <20170517152439.8817-5-holger.brunck@keymile.com>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:47389 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753426AbdEQPbl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:31:41 -0400
In-Reply-To: <20170517152439.8817-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't assume that we are always in loopback mode if rx and tx clock
have the same clock source. If we want to use HDLC busmode we also have
the same clock source but we are not in loopback mode. So move the
setting of the baudrate generator after the check for property for the
loopback mode.

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Cc: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 49b91b2c113c..4c93d561b18a 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -113,6 +113,9 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	/* Loopback mode */
 	if (priv->loopback) {
 		dev_info(priv->dev, "Loopback Mode\n");
+		/* use the same clock when work in loopback */
+		qe_setbrg(ut_info->uf_info.rx_clock, 20000000, 1);
+
 		gumr = ioread32be(&priv->uf_regs->gumr);
 		gumr |= (UCC_FAST_GUMR_LOOPBACK | UCC_FAST_GUMR_CDS |
 			 UCC_FAST_GUMR_TCI);
@@ -1021,10 +1024,6 @@ static int ucc_hdlc_probe(struct platform_device *pdev)
 		return -EINVAL;
 	}
 
-	/* use the same clock when work in loopback */
-	if (ut_info->uf_info.rx_clock == ut_info->uf_info.tx_clock)
-		qe_setbrg(ut_info->uf_info.rx_clock, 20000000, 1);
-
 	ret = of_address_to_resource(np, 0, &res);
 	if (ret)
 		return -EINVAL;
-- 
2.12.0.rc1
