From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 10/10] ieee802154: enable smart transmitter features of RF212
Date: Wed, 12 Feb 2014 17:37:14 +0100
Message-ID: <1392223034-19955-11-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:47104 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbaBLQm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:42:28 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s1CGgQMI000325
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 17:42:26 +0100
In-Reply-To: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does multiple things:

 * add .set_csma_params and .set_frame_retries for the RF212 radio.
   This should work fine with RF230, but since I have no RF230 radios to
   test with, RF230 does not implement these right now
 * enable TX_ARET for frame retransmission limits greater than -1

Since RF230 has no operations to change CSMA parameters or frame retry
limits, RF230 will not be able to enter TX_ARET with this patch.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c |   65 +++++++++++++++++++++++++++++++++++-
 1 file changed, 64 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 77b8111..4f87102 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -52,6 +52,7 @@ struct at86rf230_local {
 	spinlock_t lock;
 	bool irq_busy;
 	bool is_tx;
+	bool tx_aret;
 
 	int rssi_base_val;
 };
@@ -549,7 +550,10 @@ at86rf230_state(struct ieee802154_dev *dev, int state)
 	} while (val == STATE_TRANSITION_IN_PROGRESS);
 
 
-	if (val == desired_status)
+	if (val == desired_status ||
+		(desired_status == STATE_RX_ON && val == STATE_BUSY_RX) ||
+		(desired_status == STATE_RX_AACK_ON &&
+			val == STATE_BUSY_RX_AACK))
 		return 0;
 
 	pr_err("unexpected state change: %d, asked for %d\n", val, state);
@@ -570,6 +574,10 @@ at86rf230_start(struct ieee802154_dev *dev)
 	if (rc)
 		return rc;
 
+	rc = at86rf230_state(dev, STATE_FORCE_TX_ON);
+	if (rc)
+		return rc;
+
 	return at86rf230_state(dev, STATE_RX_AACK_ON);
 }
 
@@ -673,6 +681,12 @@ at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
 	if (rc)
 		goto err_rx;
 
+	if (lp->tx_aret) {
+		rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_TX_ARET_ON);
+		if (rc)
+			goto err_rx;
+	}
+
 	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_BUSY_TX);
 	if (rc)
 		goto err_rx;
@@ -827,6 +841,44 @@ at86rf212_set_cca_ed_level(struct ieee802154_dev *dev, s32 level)
 	return at86rf230_write_subreg(lp, SR_CCA_ED_THRES, desens_steps);
 }
 
+static int
+at86rf212_set_csma_params(struct ieee802154_dev *dev, u8 min_be, u8 max_be,
+			  u8 retries)
+{
+	struct at86rf230_local *lp = dev->priv;
+	int rc;
+
+	if (min_be > max_be || max_be > 8 || retries > 5)
+		return -EINVAL;
+
+	rc = at86rf230_write_subreg(lp, SR_MIN_BE, min_be);
+	if (rc)
+		return rc;
+
+	rc = at86rf230_write_subreg(lp, SR_MAX_BE, max_be);
+	if (rc)
+		return rc;
+
+	return at86rf230_write_subreg(lp, SR_MAX_CSMA_RETRIES, max_be);
+}
+
+static int
+at86rf212_set_frame_retries(struct ieee802154_dev *dev, s8 retries)
+{
+	struct at86rf230_local *lp = dev->priv;
+	int rc = 0;
+
+	if (retries < -1 || retries > 15)
+		return -EINVAL;
+
+	lp->tx_aret = retries >= 0;
+
+	if (retries >= 0)
+		rc = at86rf230_write_subreg(lp, SR_MAX_FRAME_RETRIES, retries);
+
+	return rc;
+}
+
 static struct ieee802154_ops at86rf230_ops = {
 	.owner = THIS_MODULE,
 	.xmit = at86rf230_xmit,
@@ -849,6 +901,8 @@ static struct ieee802154_ops at86rf212_ops = {
 	.set_lbt = at86rf212_set_lbt,
 	.set_cca_mode = at86rf212_set_cca_mode,
 	.set_cca_ed_level = at86rf212_set_cca_ed_level,
+	.set_csma_params = at86rf212_set_csma_params,
+	.set_frame_retries = at86rf212_set_frame_retries,
 };
 
 static void at86rf230_irqwork(struct work_struct *work)
@@ -925,6 +979,7 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	struct at86rf230_platform_data *pdata = lp->spi->dev.platform_data;
 	int rc, irq_pol;
 	u8 status;
+	u8 csma_seed[2];
 
 	rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
 	if (rc)
@@ -948,6 +1003,14 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	if (rc)
 		return rc;
 
+	get_random_bytes(csma_seed, ARRAY_SIZE(csma_seed));
+	rc = at86rf230_write_subreg(lp, SR_CSMA_SEED_0, csma_seed[0]);
+	if (rc)
+		return rc;
+	rc = at86rf230_write_subreg(lp, SR_CSMA_SEED_1, csma_seed[1]);
+	if (rc)
+		return rc;
+
 	/* CLKM changes are applied immediately */
 	rc = at86rf230_write_subreg(lp, SR_CLKM_SHA_SEL, 0x00);
 	if (rc)
-- 
1.7.9.5
